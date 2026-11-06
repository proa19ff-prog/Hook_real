package com.hook.music

import android.os.Handler
import android.os.Looper
import com.google.mlkit.common.model.DownloadConditions
import com.google.mlkit.common.model.RemoteModelManager
import com.google.mlkit.nl.languageid.LanguageIdentification
import com.google.mlkit.nl.languageid.LanguageIdentifier
import com.google.mlkit.nl.translate.TranslateLanguage
import com.google.mlkit.nl.translate.TranslateRemoteModel
import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.Translator
import com.google.mlkit.nl.translate.TranslatorOptions
import com.google.android.gms.tasks.Tasks
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/** On-device only. No lyrics, raw exceptions, or translated text are logged. */
class LyricsTranslationChannel(messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, "hook/lyrics_translation")
    private val handler = Handler(Looper.getMainLooper())
    private var active: Job? = null
    private var closed = false

    private class Job(val id: String, val result: MethodChannel.Result) {
        var identifier: LanguageIdentifier? = null
        var translator: Translator? = null
        var timeout: Runnable? = null
    }

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "cancel" -> {
                    if (active?.id == call.argument<String>("id")) {
                        active?.let { fail(it, "cancelled") }
                    }
                    result.success(null)
                }
                "translate" -> {
                    val id = call.argument<String>("id")
                    val target = call.argument<String>("target")
                    val lines = call.argument<List<String>>("lines")
                    if (closed || id == null || target !in listOf("ru", "en") ||
                        lines == null || lines.isEmpty() || lines.size > 500 ||
                        lines.sumOf { it.length } > 50000 || lines.any { it.length > 5000 }) {
                        result.error("invalidInput", "Unsupported translation input.", null)
                    } else if (active != null) {
                        result.error("busy", "A translation is already running.", null)
                    } else {
                        val job = Job(id, result)
                        active = job
                        job.timeout = Runnable { fail(job, "timeout") }.also {
                            handler.postDelayed(it, 150000)
                        }
                        identify(job, lines, target!!,
                            call.argument<Boolean>("allowDownload") == true)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isActive(job: Job) = !closed && active === job

    private fun identify(job: Job, lines: List<String>, target: String, allowDownload: Boolean) {
        val identifier = LanguageIdentification.getClient()
        job.identifier = identifier
        identifier.identifyLanguage(lines.joinToString("\n").take(8000))
            .addOnSuccessListener { tag ->
                if (!isActive(job)) return@addOnSuccessListener
                identifier.close()
                job.identifier = null
                val source = TranslateLanguage.fromLanguageTag(tag)
                when {
                    source == null || tag == "und" -> fail(job, "unsupportedLanguage")
                    source == target -> fail(job, "sameLanguage")
                    else -> prepare(job, lines, source, target, allowDownload)
                }
            }
            .addOnFailureListener { fail(job, "unavailable") }
    }

    private fun prepare(job: Job, lines: List<String>, source: String, target: String, allowDownload: Boolean) {
        val translator = Translation.getClient(TranslatorOptions.Builder()
            .setSourceLanguage(source).setTargetLanguage(target).build())
        job.translator = translator
        val manager = RemoteModelManager.getInstance()
        // English is the pivot and has no standalone translation model.
        val languages = setOf(source, target) - TranslateLanguage.ENGLISH
        val checks = languages.map { language ->
            manager.isModelDownloaded(TranslateRemoteModel.Builder(language).build())
        }
        Tasks.whenAllSuccess<Boolean>(checks).addOnSuccessListener { downloaded ->
            if (!isActive(job)) return@addOnSuccessListener
            if (downloaded.all { it }) {
                translateNext(job, lines, mutableListOf(), 0)
            } else if (!allowDownload) {
                fail(job, "modelRequired")
            } else {
                translator.downloadModelIfNeeded(DownloadConditions.Builder().build())
                    .addOnSuccessListener {
                        if (isActive(job)) translateNext(job, lines, mutableListOf(), 0)
                    }
                    .addOnFailureListener { fail(job, "downloadFailed") }
            }
        }.addOnFailureListener { fail(job, "unavailable") }
    }

    private fun translateNext(job: Job, lines: List<String>, output: MutableList<String>, index: Int) {
        if (!isActive(job)) return
        if (index >= lines.size) {
            release(job)
            job.result.success(output)
            return
        }
        job.translator!!.translate(lines[index]).addOnSuccessListener { translated ->
            if (isActive(job)) {
                output.add(translated)
                // Yield between lines; keep playback and UI responsive.
                handler.post { translateNext(job, lines, output, index + 1) }
            }
        }.addOnFailureListener { fail(job, "translationFailed") }
    }

    private fun release(job: Job) {
        if (active === job) active = null
        job.timeout?.let { handler.removeCallbacks(it) }
        job.identifier?.close()
        job.translator?.close()
        job.identifier = null
        job.translator = null
    }

    private fun fail(job: Job, code: String) {
        if (!isActive(job)) return
        release(job)
        job.result.error(code, "On-device translation did not complete.", null)
    }

    fun close() {
        active?.let { fail(it, "cancelled") }
        closed = true
        channel.setMethodCallHandler(null)
        handler.removeCallbacksAndMessages(null)
    }
}
