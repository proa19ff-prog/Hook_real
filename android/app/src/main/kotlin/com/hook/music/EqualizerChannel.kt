package com.hook.music

import android.media.audiofx.BassBoost
import android.media.audiofx.Equalizer
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import kotlin.math.roundToInt

/** Effects belong to Hook's player session, never the global output session. */
class EqualizerChannel(messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, "hook/equalizer")
    private var equalizer: Equalizer? = null
    private var bassBoost: BassBoost? = null
    private var sessionId: Int? = null

    init {
        channel.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "attach" -> {
                        val id = call.argument<Number>("sessionId")?.toInt()
                        require(id != null && id > 0) { "A player audio session is required." }
                        if (id != sessionId || equalizer == null) {
                            release()
                            equalizer = Equalizer(0, id)
                            sessionId = id
                            // Some devices implement EQ but not BassBoost. Keep EQ usable.
                            bassBoost = try { BassBoost(0, id) } catch (_: RuntimeException) { null }
                        }
                        val eq = equalizer!!
                        val range = eq.bandLevelRange
                        result.success(mapOf(
                            "frequencies" to (0 until eq.numberOfBands.toInt()).map {
                                eq.getCenterFreq(it.toShort()).toDouble() / 1000.0
                            },
                            "minDb" to range[0].toDouble() / 100.0,
                            "maxDb" to range[1].toDouble() / 100.0,
                            "bassSupported" to (bassBoost?.strengthSupported == true)
                        ))
                    }
                    "apply" -> {
                        val eq = equalizer ?: throw IllegalStateException("No player session.")
                        val enabled = call.argument<Boolean>("enabled") == true
                        val gains = call.argument<List<Number>>("gains")
                        require(gains != null && gains.size == eq.numberOfBands.toInt())
                        val bass = call.argument<Number>("bass")?.toDouble() ?: 0.0
                        require(bass.isFinite() && gains.all { it.toDouble().isFinite() })
                        check(eq.hasControl()) { "Audio effect control unavailable." }
                        val range = eq.bandLevelRange
                        // Android Equalizer uses millibels: 100 mB = 1 dB.
                        gains.forEachIndexed { index, gain ->
                            val millibels = (gain.toDouble() * 100.0).roundToInt()
                                .coerceIn(range[0].toInt(), range[1].toInt()).toShort()
                            eq.setBandLevel(index.toShort(), millibels)
                        }
                        check(eq.setEnabled(enabled) == 0) { "Unable to enable equalizer." }
                        bassBoost?.let { boost ->
                            if (boost.strengthSupported) {
                                boost.setStrength((bass.coerceIn(0.0, 1.0) * 1000.0).roundToInt().toShort())
                                check(boost.setEnabled(enabled && bass > 0) == 0)
                            }
                        }
                        result.success(null)
                    }
                    "release" -> {
                        release()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (_: Exception) {
                release()
                // Device support failures must never bring down audio playback.
                result.error("effectsUnavailable", "Audio effects are unavailable for this session.", null)
            }
        }
    }

    private fun release() {
        try { equalizer?.release() } catch (_: RuntimeException) { }
        try { bassBoost?.release() } catch (_: RuntimeException) { }
        equalizer = null
        bassBoost = null
        sessionId = null
    }

    fun close() {
        channel.setMethodCallHandler(null)
        release()
    }
}

/** Keep effects alive with the audio engine while the Activity is backgrounded. */
class EqualizerPlugin : FlutterPlugin {
    private var effects: EqualizerChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        effects = EqualizerChannel(binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        effects?.close()
        effects = null
    }
}
