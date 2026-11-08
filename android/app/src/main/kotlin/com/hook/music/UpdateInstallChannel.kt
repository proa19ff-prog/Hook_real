package com.hook.music

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/// Opens the system package installer for a downloaded Hook APK. Silent
/// installs are impossible for a non-system app: Android always shows its
/// own confirmation, and on 8+ the user has to allow "install unknown apps"
/// for Hook once — we detect that and open the exact settings screen.
object UpdateInstallChannel {
    private var channel: MethodChannel? = null

    fun register(engine: FlutterEngine, activity: Context) {
        channel?.setMethodCallHandler(null)
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, "hook/updater").apply {
            setMethodCallHandler { call, result ->
                if (call.method != "installApk") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val path = call.argument<String>("path")
                if (path.isNullOrEmpty() || !File(path).exists()) {
                    result.error("noFile", "The update APK is not on disk.", null)
                    return@setMethodCallHandler
                }
                result.success(installApk(activity, File(path)))
            }
        }
    }

    fun close() {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    private fun installApk(context: Context, file: File): String {
        val uri: Uri = FileProvider.getUriForFile(
            context, "${context.packageName}.files", file)

        // 26+: unknown-app installs are granted per app; 24/25 still rely on
        // the legacy global "unknown sources" switch handled by the installer.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            !context.packageManager.canRequestPackageInstalls()) {
            val settings = Intent(
                Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                Uri.parse("package:${context.packageName}"))
            context.startActivity(settings.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            return "permission_needed"
        }

        val installer = Intent(Intent.ACTION_VIEW)
            .setDataAndType(uri, "application/vnd.android.package-archive")
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            context.startActivity(installer)
            return "started"
        } catch (_: ActivityNotFoundException) {
            return "no_installer"
        }
    }
}
