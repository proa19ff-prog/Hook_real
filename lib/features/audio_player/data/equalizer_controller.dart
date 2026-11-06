import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum EqualizerStatus { waiting, ready, unsupported, failed }

enum EqualizerPreset { flat, bass, vocal, rock, electronic, soft, custom }

class EqualizerBand {
  final double frequency;
  const EqualizerBand(this.frequency);
}

class EqualizerHardware {
  final List<EqualizerBand> bands;
  final double minDb;
  final double maxDb;
  final bool bassSupported;

  const EqualizerHardware({
    required this.bands,
    required this.minDb,
    required this.maxDb,
    required this.bassSupported,
  });
}

/// Gains are stored by frequency, not Android band index. This also lets a
/// saved curve adapt to a different number of bands on another output/device.
class EqualizerSettings {
  static const anchors = [60.0, 230.0, 910.0, 3600.0, 14000.0];
  final bool enabled;
  final EqualizerPreset preset;
  final Map<double, double> gains;
  final double bass;
  final double preampDb;
  final bool autoHeadroom;

  const EqualizerSettings({
    this.enabled = false,
    this.preset = EqualizerPreset.flat,
    this.gains = const {},
    this.bass = 0,
    this.preampDb = 0,
    this.autoHeadroom = true,
  });

  EqualizerSettings copyWith({
    bool? enabled,
    EqualizerPreset? preset,
    Map<double, double>? gains,
    double? bass,
    double? preampDb,
    bool? autoHeadroom,
  }) => EqualizerSettings(
    enabled: enabled ?? this.enabled,
    preset: preset ?? this.preset,
    gains: Map.unmodifiable(gains ?? this.gains),
    bass: bass ?? this.bass,
    preampDb: preampDb ?? this.preampDb,
    autoHeadroom: autoHeadroom ?? this.autoHeadroom,
  );

  EqualizerSettings withPreset(EqualizerPreset value) {
    if (value == EqualizerPreset.custom) return copyWith(preset: value);
    final curve = switch (value) {
      EqualizerPreset.bass => [6.0, 3.0, 0.0, -1.0, 0.0],
      EqualizerPreset.vocal => [-2.0, -1.0, 3.0, 2.0, 0.0],
      EqualizerPreset.rock => [4.0, 2.0, -1.0, 2.0, 4.0],
      EqualizerPreset.electronic => [5.0, 2.0, -2.0, 2.0, 4.0],
      EqualizerPreset.soft => [2.0, 1.0, 0.0, -2.0, -3.0],
      _ => [0.0, 0.0, 0.0, 0.0, 0.0],
    };
    return copyWith(
      preset: value,
      gains: Map.fromIterables(anchors, curve),
      bass: 0,
    );
  }

  double gainAt(double frequency) {
    if (gains.isEmpty) return 0;
    final frequencies = gains.keys.toList()..sort();
    if (frequency <= frequencies.first) return gains[frequencies.first]!;
    if (frequency >= frequencies.last) return gains[frequencies.last]!;
    for (var i = 1; i < frequencies.length; i++) {
      if (frequency <= frequencies[i]) {
        final low = frequencies[i - 1];
        final high = frequencies[i];
        final mix = math.log(frequency / low) / math.log(high / low);
        return gains[low]! + (gains[high]! - gains[low]!) * mix;
      }
    }
    return 0;
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'preset': preset.name,
    'gains': gains.map((key, value) => MapEntry(key.toString(), value)),
    'bass': bass,
    'preampDb': preampDb,
    'autoHeadroom': autoHeadroom,
  };

  factory EqualizerSettings.fromJson(Map<String, dynamic> json) {
    double bounded(Object? value, double min, double max, double fallback) =>
        value is num && value.isFinite
        ? value.toDouble().clamp(min, max)
        : fallback;
    final gains = <double, double>{};
    final raw = json['gains'];
    if (raw is Map) {
      for (final entry in raw.entries.take(32)) {
        final frequency = double.tryParse(entry.key.toString());
        if (frequency != null &&
            frequency.isFinite &&
            frequency > 0 &&
            frequency <= 24000) {
          gains[frequency] = bounded(entry.value, -15, 15, 0);
        }
      }
    }
    return EqualizerSettings(
      enabled: json['enabled'] == true,
      preset: EqualizerPreset.values.firstWhere(
        (value) => value.name == json['preset'],
        orElse: () => EqualizerPreset.custom,
      ),
      gains: Map.unmodifiable(gains),
      bass: bounded(json['bass'], 0, 1, 0),
      preampDb: bounded(json['preampDb'], -12, 0, 0),
      autoHeadroom: json['autoHeadroom'] != false,
    );
  }
}

abstract class EqualizerBackend {
  bool get supported;
  Future<EqualizerHardware> attach(int sessionId);
  Future<void> apply({
    required bool enabled,
    required List<double> gains,
    required double bass,
  });
  Future<void> release();
}

/// Native Android uses millibels (100 per dB), with the real hardware limits.
/// A separate channel avoids just_audio 0.9's EQ millibel scaling mismatch.
class AndroidEqualizerBackend implements EqualizerBackend {
  static const _channel = MethodChannel('hook/equalizer');
  @override
  bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<EqualizerHardware> attach(int sessionId) async {
    final data = await _channel.invokeMapMethod<String, dynamic>('attach', {
      'sessionId': sessionId,
    });
    if (data == null) throw StateError('Missing equalizer parameters');
    final frequencies = (data['frequencies'] as List).cast<num>();
    final min = (data['minDb'] as num).toDouble();
    final max = (data['maxDb'] as num).toDouble();
    if (frequencies.isEmpty ||
        !min.isFinite ||
        !max.isFinite ||
        min >= max ||
        frequencies.any((f) => !f.isFinite || f <= 0)) {
      throw StateError('Invalid equalizer parameters');
    }
    return EqualizerHardware(
      bands: frequencies
          .map((f) => EqualizerBand(f.toDouble()))
          .toList(growable: false),
      minDb: min,
      maxDb: max,
      bassSupported: data['bassSupported'] == true,
    );
  }

  @override
  Future<void> apply({
    required bool enabled,
    required List<double> gains,
    required double bass,
  }) => _channel.invokeMethod<void>('apply', {
    'enabled': enabled,
    'gains': gains,
    'bass': bass,
  });

  @override
  Future<void> release() => _channel.invokeMethod<void>('release');
}

class EqualizerController extends ChangeNotifier {
  static const _key = 'hook_equalizer_v1';
  final EqualizerBackend _backend;
  EqualizerController({EqualizerBackend? backend})
    : _backend = backend ?? AndroidEqualizerBackend();

  EqualizerSettings _settings = const EqualizerSettings();
  EqualizerSettings get settings => _settings;
  EqualizerHardware? _hardware;
  EqualizerHardware? get hardware => _hardware;
  EqualizerStatus _status = EqualizerStatus.waiting;
  EqualizerStatus get status => _status;
  bool _disposed = false;
  bool _loaded = false;
  int? _sessionId;
  int _sessionVersion = 0;
  double _volume = 1;
  Future<void> Function(double)? _writeVolume;
  StreamSubscription<int?>? _sessionSubscription;
  SharedPreferences? _prefs;
  Future<void> _operations = Future.value();
  Future<void> _writes = Future.value();
  Timer? _saveTimer;

  List<double> get bandGains =>
      _hardware?.bands
          .map(
            (band) => _settings
                .gainAt(band.frequency)
                .clamp(_hardware!.minDb, _hardware!.maxDb),
          )
          .toList() ??
      const [];

  /// A conservative output reduction, not a hard limiter or a loudness boost.
  double get attenuationDb {
    if (!_settings.enabled || _status != EqualizerStatus.ready) return 0;
    final peak = bandGains.fold<double>(0, math.max);
    final bassAllowance = _hardware?.bassSupported == true
        ? _settings.bass * 6
        : 0.0;
    return _settings.preampDb -
        (_settings.autoHeadroom ? peak + bassAllowance : 0);
  }

  Future<void> attachPlayer(AudioPlayer player) => bind(
    sessionIds: player.androidAudioSessionIdStream,
    initialSessionId: player.androidAudioSessionId,
    initialVolume: player.volume,
    writeVolume: player.setVolume,
  );

  /// Injectable binding also allows tests without an Android audio session.
  Future<void> bind({
    required Stream<int?> sessionIds,
    int? initialSessionId,
    double initialVolume = 1,
    required Future<void> Function(double) writeVolume,
  }) async {
    _writeVolume = writeVolume;
    _volume = initialVolume;
    try {
      _prefs = await SharedPreferences.getInstance();
      final saved = _prefs!.getString(_key);
      if (saved != null) {
        _settings = EqualizerSettings.fromJson(
          jsonDecode(saved) as Map<String, dynamic>,
        );
      }
    } catch (_) {
      // Corrupt or unavailable preferences must not break audio playback.
    }
    if (_disposed) return;
    _loaded = true;
    if (!_backend.supported) {
      _status = EqualizerStatus.unsupported;
      notifyListeners();
      return;
    }
    _sessionSubscription = sessionIds.distinct().listen((id) {
      if (id != _sessionId) unawaited(connect(id));
    });
    if (initialSessionId != null) await connect(initialSessionId);
    if (!_disposed) notifyListeners();
  }

  Future<void> connect(int? sessionId) {
    _sessionId = sessionId;
    final version = ++_sessionVersion;
    return _enqueue(() async {
      if (version != _sessionVersion) return;
      if (sessionId == null || sessionId <= 0) {
        await _backend.release();
        _hardware = null;
        _status = EqualizerStatus.waiting;
        await _updateVolume();
      } else {
        _hardware = await _backend.attach(sessionId);
        if (_disposed || version != _sessionVersion) return;
        _status = EqualizerStatus.ready;
        await _apply();
      }
      if (!_disposed) notifyListeners();
    });
  }

  Future<void> retry() => connect(_sessionId);

  Future<void> _enqueue(Future<void> Function() action) {
    _operations = _operations.then((_) async {
      if (_disposed) return;
      try {
        await action();
      } catch (_) {
        if (_disposed) return;
        _status = EqualizerStatus.failed;
        try {
          await _backend.release();
        } catch (_) {}
        try {
          await _updateVolume();
        } catch (_) {}
        if (!_disposed) notifyListeners();
      }
    });
    return _operations;
  }

  Future<void> _updateVolume() async {
    final gain = math.pow(10, attenuationDb / 20).toDouble();
    await _writeVolume?.call((_volume * gain).clamp(0.0, 1.0));
  }

  Future<void> _apply() async {
    if (_status != EqualizerStatus.ready) return;
    if (_settings.enabled) await _updateVolume();
    await _backend.apply(
      enabled: _settings.enabled,
      gains: bandGains,
      bass: _hardware!.bassSupported ? _settings.bass : 0,
    );
    if (!_settings.enabled) await _updateVolume();
  }

  void _change(EqualizerSettings value) {
    if (_disposed || !_loaded) return;
    _settings = value;
    notifyListeners();
    unawaited(_enqueue(_apply));
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 250), _save);
  }

  void setEnabled(bool value) => _change(_settings.copyWith(enabled: value));
  void setPreset(EqualizerPreset value) => _change(_settings.withPreset(value));
  void setBass(double value) {
    if (value.isFinite) {
      _change(
        _settings.copyWith(
          bass: value.clamp(0, 1),
          preset: EqualizerPreset.custom,
        ),
      );
    }
  }

  void setPreamp(double value) {
    if (value.isFinite) {
      _change(_settings.copyWith(preampDb: value.clamp(-12, 0)));
    }
  }

  void setAutoHeadroom(bool value) =>
      _change(_settings.copyWith(autoHeadroom: value));
  void setBand(int index, double value) {
    final hardware = _hardware;
    if (hardware == null ||
        index < 0 ||
        index >= hardware.bands.length ||
        !value.isFinite) {
      return;
    }
    // Materialize the interpolated curve on this device before one-band edits.
    final gains = <double, double>{
      for (final band in hardware.bands)
        band.frequency: _settings
            .gainAt(band.frequency)
            .clamp(hardware.minDb, hardware.maxDb),
    };
    gains[hardware.bands[index].frequency] = value.clamp(
      hardware.minDb,
      hardware.maxDb,
    );
    _change(_settings.copyWith(gains: gains, preset: EqualizerPreset.custom));
  }

  void reset() => _change(EqualizerSettings(enabled: _settings.enabled));

  Future<void> setVolume(double value) {
    if (!value.isFinite) return Future.value();
    _volume = value.clamp(0, 1);
    return _enqueue(_updateVolume);
  }

  void _save() {
    final prefs = _prefs;
    if (prefs == null) return;
    final json = jsonEncode(_settings.toJson());
    _writes = _writes.then((_) async {
      try {
        await prefs.setString(_key, json);
      } catch (_) {}
    });
  }

  Future<void> flush() async {
    _saveTimer?.cancel();
    _save();
    await _writes;
    await _operations;
  }

  @override
  void dispose() {
    if (_disposed) return;
    _saveTimer?.cancel();
    _save();
    _disposed = true;
    unawaited(_sessionSubscription?.cancel());
    // Drain an in-flight native call before releasing its effects.
    unawaited(
      _operations.then((_) async {
        try {
          await _backend.release();
        } catch (_) {}
      }),
    );
    super.dispose();
  }
}
