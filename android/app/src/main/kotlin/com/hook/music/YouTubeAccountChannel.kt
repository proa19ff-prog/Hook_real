package com.hook.music

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import com.google.android.gms.auth.api.identity.AuthorizationClient
import com.google.android.gms.auth.api.identity.AuthorizationRequest
import com.google.android.gms.auth.api.identity.AuthorizationResult
import com.google.android.gms.auth.api.identity.Identity
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.CommonStatusCodes
import com.google.android.gms.common.api.Scope
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.lang.ref.WeakReference
import java.math.BigDecimal
import java.math.RoundingMode
import java.net.URL
import java.util.concurrent.CancellationException
import java.util.concurrent.Executors
import java.util.concurrent.Future
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicReference
import javax.net.ssl.HttpsURLConnection

/** Official, read-only YouTube authorization. Tokens never leave native process memory. */
class YouTubeAccountChannel(
    private val activity: Activity,
    messenger: BinaryMessenger,
) {
    private val channel = MethodChannel(messenger, "hook/youtube_account")
    private val handler = Handler(Looper.getMainLooper())
    private val ioExecutor = Executors.newSingleThreadExecutor()
    private val cleanupExecutor = Executors.newSingleThreadExecutor()
    private var active: Operation? = null
    private var session: Session? = null
    private var generation = 0L
    private var closed = false
    private var sdkUnsupported = false

    // This is intentionally not a data class: its generated toString must not expose a token.
    private class Session(
        val token: String,
        val profile: Map<String, Any?>,
        val expiresAt: Long,
    )

    private class Operation(val generation: Long, var result: MethodChannel.Result?) {
        val cancelled = AtomicBoolean(false)
        val connection = AtomicReference<HttpsURLConnection?>(null)
        var client: AuthorizationClient? = null
        var consentRequest: Int? = null
        var future: Future<*>? = null
        var timeout: Runnable? = null
    }

    private class AccountFailure(val code: String) : Exception()

    private enum class Endpoint(val path: String) {
        CHANNELS("channels"), PLAYLISTS("playlists"), PLAYLIST_ITEMS("playlistItems"), VIDEOS("videos")
    }

    init {
        channel.setMethodCallHandler { call, result ->
            if (closed) {
                error(result, "cancelled")
            } else {
                when (call.method) {
                    "status" -> result.success(status())
                    "profile" -> result.success(currentSession()?.profile)
                    "connect" -> connect(result)
                    "playlists" -> fetchPlaylists(call, result)
                    "playlistTracks" -> fetchPlaylistTracks(call, result)
                    "cancel" -> {
                        cancelActive()
                        result.success(null)
                    }
                    "disconnect" -> {
                        session = null
                        cancelActive()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun status(): Map<String, Any?> {
        // Package/SDK availability checks only: never authorize or issue HTTP at startup.
        val servicesAvailable = servicesAvailable()
        return mapOf(
            "supported" to (servicesAvailable && !sdkUnsupported),
            "systemServicesAvailable" to servicesAvailable,
            "systemServicesVersion" to packageVersion("com.google.android.gms"),
            "revancedGmsCoreVersion" to packageVersion("app.revanced.android.gms"),
            "revancedMusicInstalled" to (packageVersion("app.revanced.android.apps.youtube.music") != null),
            "connected" to (currentSession() != null),
        )
    }

    @Suppress("DEPRECATION")
    private fun packageVersion(name: String): String? = try {
        activity.packageManager.getPackageInfo(name, 0).versionName ?: "unknown"
    } catch (_: PackageManager.NameNotFoundException) {
        null
    } catch (_: SecurityException) {
        null
    }

    private fun servicesAvailable(): Boolean = try {
        GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(activity) == ConnectionResult.SUCCESS
    } catch (_: Exception) {
        false
    }

    private fun currentSession(): Session? {
        if (session?.let { SystemClock.elapsedRealtime() >= it.expiresAt } == true) session = null
        return session
    }

    private fun begin(result: MethodChannel.Result, timeoutMs: Long): Operation? {
        if (active != null) {
            error(result, "busy")
            return null
        }
        return Operation(++generation, result).also {
            active = it
            setTimeout(it, timeoutMs)
        }
    }

    private fun setTimeout(op: Operation, timeoutMs: Long) {
        op.timeout?.let { handler.removeCallbacks(it) }
        op.timeout = Runnable {
            fail(op, if (op.consentRequest != null) "cancelled" else "network")
        }.also { handler.postDelayed(it, timeoutMs) }
    }

    private fun isActive(op: Operation): Boolean =
        !closed && !op.cancelled.get() && active === op && generation == op.generation

    private fun connect(result: MethodChannel.Result) {
        if (active != null) {
            error(result, "busy")
            return
        }
        if (!servicesAvailable() || sdkUnsupported) {
            error(result, "servicesUnavailable")
            return
        }
        val op = begin(result, CONSENT_TIMEOUT_MS) ?: return
        // An explicit reconnect must not accidentally retain the previous account.
        session = null
        try {
            val client = Identity.getAuthorizationClient(activity)
            op.client = client
            val request = AuthorizationRequest.builder()
                .setRequestedScopes(listOf(Scope(YOUTUBE_READONLY)))
                .setPrompt(AuthorizationRequest.Prompt.SELECT_ACCOUNT)
                .build()
            // authorize() has no cancellation API. Weak listeners must not retain a closed
            // activity; a released operation has no result/client and cannot commit a session.
            val owner = WeakReference(this)
            client.authorize(request)
                .addOnSuccessListener { authorization ->
                    owner.get()?.let { channel ->
                        if (channel.isActive(op)) channel.handleAuthorization(op, authorization, allowResolution = true)
                    }
                }
                .addOnFailureListener { exception -> owner.get()?.authorizationFailed(op, exception) }
                .addOnCanceledListener { owner.get()?.fail(op, "cancelled") }
        } catch (exception: Exception) {
            authorizationFailed(op, exception)
        }
    }

    private fun handleAuthorization(op: Operation, authorization: AuthorizationResult, allowResolution: Boolean) {
        if (!isActive(op)) return
        if (authorization.hasResolution()) {
            if (!allowResolution) {
                fail(op, "permissionDenied")
                return
            }
            val pendingIntent = authorization.pendingIntent
            val requestCode = nextConsentRequest.getAndIncrement()
            if (pendingIntent == null || requestCode > LAST_CONSENT_REQUEST) {
                fail(op, "unavailable")
                return
            }
            op.consentRequest = requestCode
            try {
                activity.startIntentSenderForResult(pendingIntent.intentSender, requestCode, null, 0, 0, 0)
            } catch (_: Exception) {
                sdkUnsupported = true
                fail(op, "servicesUnavailable")
            }
            return
        }
        if (YOUTUBE_READONLY !in authorization.grantedScopes) {
            fail(op, "permissionDenied")
            return
        }
        val token = authorization.accessToken
        if (token.isNullOrBlank()) {
            fail(op, "expired")
            return
        }
        op.client = null
        val expiresAt = SystemClock.elapsedRealtime() + SESSION_LIFETIME_MS
        setTimeout(op, API_TIMEOUT_MS)
        runNetwork(op, {
            val response = get(op, token, Endpoint.CHANNELS, mapOf(
                "part" to "snippet", "mine" to "true", "maxResults" to "1",
                "fields" to "items(id,snippet(title,thumbnails))",
            ))
            val item = response.optJSONArray("items")?.optJSONObject(0) ?: throw AccountFailure("noChannel")
            val snippet = item.optJSONObject("snippet") ?: throw AccountFailure("unavailable")
            val channelId = text(item, "id") ?: throw AccountFailure("unavailable")
            val name = text(snippet, "title") ?: throw AccountFailure("unavailable")
            mapOf<String, Any?>("channelId" to channelId, "name" to name, "artworkUrl" to artwork(snippet))
        }) { profile ->
            session = Session(token, profile, expiresAt)
            succeed(op, profile)
        }
    }

    /** Called by MainActivity; request codes never collide with the import picker (7318). */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode !in FIRST_CONSENT_REQUEST..LAST_CONSENT_REQUEST) return false
        val op = active ?: return true
        if (!isActive(op) || op.consentRequest != requestCode) return true
        op.consentRequest = null
        if (data == null) {
            fail(op, if (resultCode == Activity.RESULT_OK) "unavailable" else "cancelled")
            return true
        }
        try {
            val client = op.client ?: throw AccountFailure("unavailable")
            // Even RESULT_CANCELED can carry an SDK error (notably configuration error 10).
            val authorization = client.getAuthorizationResultFromIntent(data)
            if (resultCode == Activity.RESULT_OK) {
                handleAuthorization(op, authorization, allowResolution = false)
            } else {
                fail(op, "cancelled")
            }
        } catch (exception: Exception) {
            authorizationFailed(op, exception)
        }
        return true
    }

    private fun authorizationFailed(op: Operation, exception: Exception) {
        if (!isActive(op)) return
        val code = when (exception) {
            is AccountFailure -> exception.code
            is CancellationException -> "cancelled"
            is ApiException -> when (exception.statusCode) {
                CommonStatusCodes.DEVELOPER_ERROR -> "configurationRequired"
                CommonStatusCodes.CANCELED, CommonStatusCodes.INTERRUPTED, 12501 -> "cancelled"
                CommonStatusCodes.NETWORK_ERROR, CommonStatusCodes.TIMEOUT -> "network"
                CommonStatusCodes.SIGN_IN_REQUIRED -> "expired"
                CommonStatusCodes.INVALID_ACCOUNT -> "permissionDenied"
                // Service missing/outdated/disabled/invalid, API unavailable, or API update required.
                1, 2, 3, 9, 17, 21 -> "servicesUnavailable"
                else -> "unavailable"
            }
            is UnsupportedOperationException, is SecurityException -> "servicesUnavailable"
            else -> "unavailable"
        }
        if (code == "servicesUnavailable") sdkUnsupported = true
        fail(op, code)
    }

    private fun fetchPlaylists(call: MethodCall, result: MethodChannel.Result) {
        val pageToken: String?
        try {
            pageToken = pageToken(call)
        } catch (_: AccountFailure) {
            error(result, "unavailable")
            return
        }
        withSession(result) { op, token ->
            val params = mutableMapOf(
                "part" to "snippet,contentDetails", "mine" to "true", "maxResults" to "50",
                "fields" to "items(id,snippet(title,thumbnails),contentDetails(itemCount)),nextPageToken",
            )
            pageToken?.let { params["pageToken"] = it }
            val response = get(op, token, Endpoint.PLAYLISTS, params)
            val entries = response.optJSONArray("items") ?: JSONArray()
            val items = (0 until minOf(entries.length(), 50)).mapNotNull { index ->
                val item = entries.optJSONObject(index) ?: return@mapNotNull null
                val snippet = item.optJSONObject("snippet") ?: return@mapNotNull null
                val id = text(item, "id") ?: return@mapNotNull null
                val title = text(snippet, "title") ?: return@mapNotNull null
                mapOf<String, Any?>(
                    "id" to id, "title" to title, "artworkUrl" to artwork(snippet),
                    "itemCount" to (item.optJSONObject("contentDetails")?.optInt("itemCount", 0) ?: 0).coerceAtLeast(0),
                )
            }
            page(items, response)
        }
    }

    private fun fetchPlaylistTracks(call: MethodCall, result: MethodChannel.Result) {
        val playlistId: String
        val pageToken: String?
        try {
            playlistId = (call.arguments as? Map<*, *>)?.get("playlistId") as? String
                ?: throw AccountFailure("unavailable")
            if (!PLAYLIST_ID.matches(playlistId)) throw AccountFailure("unavailable")
            pageToken = pageToken(call)
        } catch (_: AccountFailure) {
            error(result, "unavailable")
            return
        }
        withSession(result) { op, token ->
            val params = mutableMapOf(
                "part" to "contentDetails", "playlistId" to playlistId, "maxResults" to "50",
                "fields" to "items(contentDetails(videoId)),nextPageToken",
            )
            pageToken?.let { params["pageToken"] = it }
            val response = get(op, token, Endpoint.PLAYLIST_ITEMS, params)
            val entries = response.optJSONArray("items") ?: JSONArray()
            // Keep playlist ordering and repeated videos; do not replace IDs with search results.
            val ids = (0 until minOf(entries.length(), 50)).map { index ->
                entries.optJSONObject(index)?.optJSONObject("contentDetails")?.let { text(it, "videoId") }
                    ?.takeIf { VIDEO_ID.matches(it) }
            }
            val uniqueIds = ids.filterNotNull().distinct()
            val videos = if (uniqueIds.isEmpty()) JSONArray() else get(op, token, Endpoint.VIDEOS, mapOf(
                // With the id filter, videos.list limits by IDs (maxResults is not supported).
                "part" to "snippet,contentDetails,status", "id" to uniqueIds.joinToString(","),
                "fields" to "items(id,snippet(title,channelTitle,thumbnails),contentDetails(duration),status(uploadStatus))",
            )).optJSONArray("items") ?: JSONArray()
            val byId = mutableMapOf<String, Map<String, Any?>>()
            for (index in 0 until minOf(videos.length(), 50)) {
                val video = videos.optJSONObject(index) ?: continue
                val id = text(video, "id")?.takeIf { it in uniqueIds } ?: continue
                val uploadStatus = video.optJSONObject("status")?.let { text(it, "uploadStatus") }
                if (uploadStatus in listOf("deleted", "failed", "rejected")) continue
                val snippet = video.optJSONObject("snippet") ?: continue
                val title = text(snippet, "title") ?: continue
                val artist = text(snippet, "channelTitle") ?: continue
                val duration = video.optJSONObject("contentDetails")?.let { text(it, "duration") }
                    ?.let { durationMs(it) } ?: continue
                byId[id] = mapOf(
                    "id" to id, "title" to title, "artist" to artist,
                    "artworkUrl" to artwork(snippet), "durationMs" to duration,
                )
            }
            val items = ids.mapNotNull { id -> id?.let { byId[it] } }
            page(items, response).apply { put("unavailableCount", ids.size - items.size) }
        }
    }

    private fun pageToken(call: MethodCall): String? {
        if (call.arguments != null && call.arguments !is Map<*, *>) throw AccountFailure("unavailable")
        val value = (call.arguments as? Map<*, *>)?.get("pageToken") ?: return null
        if (value !is String || value.length > 2048 || value.any { it.isISOControl() }) {
            throw AccountFailure("unavailable")
        }
        return value.takeIf { it.isNotBlank() }
    }

    private fun page(items: List<Map<String, Any?>>, response: JSONObject): MutableMap<String, Any?> =
        mutableMapOf<String, Any?>("items" to items).apply {
            text(response, "nextPageToken")?.let { put("nextPageToken", it) }
        }

    private fun withSession(result: MethodChannel.Result, work: (Operation, String) -> Map<String, Any?>) {
        if (active != null) {
            error(result, "busy")
            return
        }
        val connected = currentSession()
        if (connected == null) {
            error(result, "expired")
            return
        }
        val op = begin(result, API_TIMEOUT_MS) ?: return
        runNetwork(op, { work(op, connected.token) }) { succeed(op, it) }
    }

    private fun <T> runNetwork(op: Operation, work: () -> T, complete: (T) -> Unit) {
        op.future = ioExecutor.submit {
            try {
                checkCancelled(op)
                val value = work()
                if (!op.cancelled.get()) handler.post { if (isActive(op)) complete(value) }
            } catch (exception: Exception) {
                val code = when (exception) {
                    is AccountFailure -> exception.code
                    is CancellationException, is InterruptedException -> "cancelled"
                    is IOException -> "network"
                    else -> "unavailable"
                }
                if (!op.cancelled.get()) handler.post { fail(op, code) }
            }
        }
    }

    private fun checkCancelled(op: Operation) {
        if (op.cancelled.get() || Thread.currentThread().isInterrupted) throw CancellationException()
    }

    private fun get(op: Operation, token: String, endpoint: Endpoint, params: Map<String, String>): JSONObject {
        checkCancelled(op)
        val builder = Uri.Builder().scheme("https").authority("www.googleapis.com")
            .appendPath("youtube").appendPath("v3").appendPath(endpoint.path)
        params.forEach { (key, value) -> builder.appendQueryParameter(key, value) }
        val connection = URL(builder.build().toString()).openConnection() as HttpsURLConnection
        op.connection.set(connection)
        try {
            checkCancelled(op)
            connection.requestMethod = "GET"
            connection.connectTimeout = 10000
            connection.readTimeout = 15000
            connection.instanceFollowRedirects = false
            connection.useCaches = false
            connection.setRequestProperty("Accept", "application/json")
            connection.setRequestProperty("Authorization", "Bearer $token")
            val statusCode = connection.responseCode
            val stream = if (statusCode in 200..299) connection.inputStream else connection.errorStream
            val body = stream?.use { input ->
                val output = ByteArrayOutputStream()
                val buffer = ByteArray(8192)
                while (true) {
                    checkCancelled(op)
                    val count = input.read(buffer)
                    if (count < 0) break
                    if (output.size() + count > MAX_BODY_BYTES) throw AccountFailure("unavailable")
                    output.write(buffer, 0, count)
                }
                output.toString("UTF-8")
            }.orEmpty()
            checkCancelled(op)
            val json = try { JSONObject(body) } catch (_: Exception) { null }
            if (statusCode !in 200..299) throw AccountFailure(apiError(statusCode, json))
            return json ?: throw AccountFailure("unavailable")
        } finally {
            op.connection.compareAndSet(connection, null)
            connection.disconnect()
        }
    }

    private fun apiError(status: Int, body: JSONObject?): String {
        val error = body?.optJSONObject("error")
        val errors = error?.optJSONArray("errors") ?: JSONArray()
        val details = error?.optJSONArray("details") ?: JSONArray()
        val reasons = listOf(errors, details).flatMap { entries ->
            (0 until entries.length()).mapNotNull { entries.optJSONObject(it)?.let { e -> text(e, "reason") } }
        }
        return when {
            status == 401 -> "expired"
            status == 429 || reasons.any { it in QUOTA_REASONS } -> "quotaExceeded"
            reasons.any { it in CONFIGURATION_REASONS } -> "configurationRequired"
            "youtubeSignupRequired" in reasons -> "noChannel"
            status == 403 -> "permissionDenied"
            status == 408 || status in 500..599 -> "network"
            else -> "unavailable"
        }
    }

    private fun text(json: JSONObject, key: String): String? =
        (json.opt(key) as? String)?.takeIf { it.isNotBlank() }

    private fun artwork(snippet: JSONObject): String? {
        val thumbnails = snippet.optJSONObject("thumbnails") ?: return null
        for (size in listOf("maxres", "standard", "high", "medium", "default")) {
            val url = thumbnails.optJSONObject(size)?.let { text(it, "url") } ?: continue
            // Artwork is metadata only, never fetched with the native bearer token.
            val uri = Uri.parse(url)
            if (uri.scheme == "https" && !uri.host.isNullOrBlank() && uri.userInfo == null) return url
        }
        return null
    }

    private fun durationMs(value: String): Long? {
        if (value.length > 64 || value.endsWith("T")) return null
        val match = ISO_DURATION.matchEntire(value) ?: return null
        if (match.groupValues.drop(1).all { it.isEmpty() }) return null
        return try {
            val factors = listOf(86400000L, 3600000L, 60000L, 1000L)
            match.groupValues.drop(1).mapIndexed { index, part ->
                if (part.isEmpty()) BigDecimal.ZERO else part.toBigDecimal().multiply(BigDecimal.valueOf(factors[index]))
            }.fold(BigDecimal.ZERO, BigDecimal::add).setScale(0, RoundingMode.DOWN).longValueExact()
        } catch (_: ArithmeticException) {
            null
        } catch (_: NumberFormatException) {
            null
        }
    }

    private fun succeed(op: Operation, value: Any?) {
        if (!isActive(op)) return
        val result = release(op)
        result?.success(value)
    }

    private fun fail(op: Operation, code: String) {
        if (!isActive(op)) return
        if (code == "expired" || code == "permissionDenied" || code == "noChannel") session = null
        val result = release(op)
        result?.let { error(it, code) }
    }

    private fun release(op: Operation): MethodChannel.Result? {
        op.cancelled.set(true)
        if (active === op) active = null
        val result = op.result
        op.result = null
        op.timeout?.let { handler.removeCallbacks(it) }
        op.timeout = null
        op.client = null
        op.future?.cancel(true)
        op.future = null
        op.connection.getAndSet(null)?.let { connection ->
            // Socket cleanup must not block the main thread or delay a channel result.
            cleanupExecutor.execute { try { connection.disconnect() } catch (_: Exception) { } }
        }
        op.consentRequest?.let { requestCode ->
            try { activity.finishActivity(requestCode) } catch (_: Exception) { }
        }
        op.consentRequest = null
        return result
    }

    private fun cancelActive() {
        active?.let { fail(it, "cancelled") }
        generation++
    }

    private fun error(result: MethodChannel.Result, code: String) {
        // Never send an SDK exception, API response, account identifier, or token to Dart/logs.
        val message = when (code) {
            "cancelled" -> "YouTube account operation cancelled."
            "busy" -> "Another YouTube account operation is in progress."
            "servicesUnavailable" -> "Compatible system Google services are unavailable. Separate ReVanced GmsCore is not an OAuth provider for Hook."
            "configurationRequired" -> "Configure the YouTube Data API and Android OAuth client for this app's package and signing certificate."
            "permissionDenied" -> "Read-only YouTube permission was not granted or this resource is not accessible."
            "expired" -> "Connect your YouTube account again."
            "noChannel" -> "This Google account does not have an accessible YouTube channel."
            "quotaExceeded" -> "The YouTube Data API quota or rate limit was reached."
            "network" -> "The YouTube account request could not complete over the network."
            else -> "The YouTube account operation is unavailable."
        }
        result.error(code, message, null)
    }

    fun close() {
        if (closed) return
        session = null
        cancelActive()
        closed = true
        channel.setMethodCallHandler(null)
        handler.removeCallbacksAndMessages(null)
        ioExecutor.shutdownNow()
        cleanupExecutor.shutdown()
    }

    companion object {
        private const val YOUTUBE_READONLY = "https://www.googleapis.com/auth/youtube.readonly"
        private const val CONSENT_TIMEOUT_MS = 180000L
        private const val API_TIMEOUT_MS = 45000L
        // The SDK result has no typed expiry property. Never silently refresh; a 401 also clears it.
        private const val SESSION_LIFETIME_MS = 50 * 60 * 1000L
        private const val MAX_BODY_BYTES = 2 * 1024 * 1024
        private const val FIRST_CONSENT_REQUEST = 7320
        private const val LAST_CONSENT_REQUEST = 16383
        // Process-wide monotonic codes prevent a cancelled consent result matching a newer one,
        // including after Flutter engine reconfiguration. Exhaustion fails closed, never wraps.
        private val nextConsentRequest = AtomicInteger(FIRST_CONSENT_REQUEST)
        private val VIDEO_ID = Regex("[A-Za-z0-9_-]{11}")
        private val PLAYLIST_ID = Regex("[A-Za-z0-9_-]{1,256}")
        private val ISO_DURATION = Regex("P(?:(\\d+)D)?(?:T(?:(\\d+)H)?(?:(\\d+)M)?(?:(\\d+(?:\\.\\d+)?)S)?)?")
        private val QUOTA_REASONS = setOf("quotaExceeded", "dailyLimitExceeded", "rateLimitExceeded", "userRateLimitExceeded")
        private val CONFIGURATION_REASONS = setOf(
            "accessNotConfigured", "serviceDisabled", "keyInvalid", "ipRefererBlocked", "forbiddenProject",
            "SERVICE_DISABLED", "API_KEY_INVALID", "CONSUMER_INVALID", "PROJECT_DELETED",
        )
    }
}
