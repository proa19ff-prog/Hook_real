package com.hook.music

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.provider.OpenableColumns
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors

class MainActivity : AudioServiceActivity() {
    private var importChannel: MethodChannel? = null
    private var pendingImport: MethodChannel.Result? = null
    private val importExecutor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        importChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "hook/import_file")
        importChannel?.setMethodCallHandler { call, result ->
            if (call.method != "pickTextFile") {
                result.notImplemented()
            } else if (pendingImport != null) {
                result.error("busy", "A file selection is already open.", null)
            } else {
                pendingImport = result
                val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "*/*"
                    putExtra(Intent.EXTRA_MIME_TYPES, arrayOf(
                        "text/csv", "text/comma-separated-values", "application/csv",
                        "text/plain", "application/vnd.ms-excel", "application/octet-stream"
                    ))
                }
                try {
                    startActivityForResult(intent, IMPORT_REQUEST)
                } catch (_: ActivityNotFoundException) {
                    pendingImport = null
                    result.error("unavailable", "No document picker is available.", null)
                } catch (_: SecurityException) {
                    pendingImport = null
                    result.error("readFailed", "Unable to open the document picker.", null)
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != IMPORT_REQUEST) return
        val result = pendingImport ?: return
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            pendingImport = null
            result.success(null)
            return
        }
        importExecutor.execute {
            try {
                val name = contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME),
                    null, null, null)?.use { cursor ->
                    if (cursor.moveToFirst()) cursor.getString(0) else null
                } ?: "import"
                if (!name.endsWith(".csv", true) && !name.endsWith(".txt", true)) {
                    runOnUiThread {
                        if (pendingImport === result) {
                            pendingImport = null
                            result.error("unsupported", "Choose a CSV or TXT file.", null)
                        }
                    }
                    return@execute
                }
                val bytes = contentResolver.openInputStream(uri)?.use { stream ->
                    val output = ByteArrayOutputStream()
                    val buffer = ByteArray(8192)
                    var total = 0
                    while (!Thread.currentThread().isInterrupted) {
                        val count = stream.read(buffer)
                        if (count < 0) break
                        total += count
                        if (total > MAX_IMPORT_BYTES) throw FileTooLargeException()
                        output.write(buffer, 0, count)
                    }
                    output.toByteArray()
                } ?: throw IllegalStateException("The document has no readable stream.")
                runOnUiThread {
                    if (pendingImport === result) {
                        pendingImport = null
                        result.success(mapOf("name" to name, "bytes" to bytes))
                    }
                }
            } catch (error: Exception) {
                runOnUiThread {
                    if (pendingImport === result) {
                        pendingImport = null
                        result.error(if (error is FileTooLargeException) "tooLarge" else "readFailed",
                            "Unable to read the selected file.", null)
                    }
                }
            }
        }
    }

    override fun onDestroy() {
        importChannel?.setMethodCallHandler(null)
        pendingImport?.error("cancelled", "The activity was closed.", null)
        pendingImport = null
        importExecutor.shutdownNow()
        super.onDestroy()
    }

    private class FileTooLargeException : Exception()

    companion object {
        private const val IMPORT_REQUEST = 7318
        private const val MAX_IMPORT_BYTES = 10 * 1024 * 1024
    }
}
