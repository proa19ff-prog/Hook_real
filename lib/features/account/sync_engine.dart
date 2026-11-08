import 'dart:async';

import '../../core/diagnostics/playback_diagnostics.dart';
import '../../core/storage/local_storage_service.dart';
import '../extractor/models/media_track.dart';

/// Syncable content keys and their tombstone companions.
///
/// Every key lives in the snapshot as an envelope `{'t': epochMs, 'v': …}`.
/// Removals need tombstones because the merge is union-based: without them a
/// deleted favorite or playlist would return on the next pull. Tombstones are
/// regular envelopes too (`…_del`), so they ride the same LWW-per-entry rule.
abstract final class SyncKeys {
  static const favorites = 'favorites';
  static const favoritesDel = 'favorites_del';
  static const history = 'history';
  static const playlists = 'playlists';
  static const playlistsDel = 'playlists_del';
  static const playCounts = 'play_counts';
  static const playTimestamps = 'play_timestamps';
  static const searchHistory = 'search_history';
  static const searchHistoryDel = 'search_history_del';
  static const lyricsOffsets = 'lyrics_offsets';
  static const lyricsOffsetsDel = 'lyrics_offsets_del';
  static const lyricsDisplayMode = 'lyrics_display_mode';
  static const lyricsAutoHide = 'lyrics_auto_hide';
  static const themeId = 'theme_id';
  static const customThemeJson = 'custom_theme_json';

  static const all = <String>[
    favorites,
    favoritesDel,
    history,
    playlists,
    playlistsDel,
    playCounts,
    playTimestamps,
    searchHistory,
    searchHistoryDel,
    lyricsOffsets,
    lyricsOffsetsDel,
    lyricsDisplayMode,
    lyricsAutoHide,
    themeId,
    customThemeJson,
  ];

  static const delKeys = <String>[
    favoritesDel,
    playlistsDel,
    searchHistoryDel,
    lyricsOffsetsDel,
  ];
}

/// Server side of the sync: one JSON snapshot per user.
abstract class SyncTransport {
  /// The stored snapshot, or null when the user has never synced.
  Future<Map<String, Object?>?> fetchSnapshot();

  Future<void> saveSnapshot(Map<String, Object?> data);
}

/// Pure snapshot merge. Takes two envelope maps and returns the merged one;
/// the caller applies the result to storage. Rules per key family:
///
/// - track lists (favorites, history): union by (source, id), the fresher
///   side provides the order, extras from the other side are appended.
/// - playlists: union of names; a name on both sides merges its tracks like
///   a track list; names in either tombstone map are dropped.
/// - play counts / timestamps: max per `artist|title` entry.
/// - search history: union of strings (case-insensitive), tombstoned
///   entries dropped.
/// - lyrics offsets: per `source:id`; disagreements resolve to the fresher
///   side; tombstoned entries dropped.
/// - scalars (display mode, auto-hide, themes): whole-value LWW, ties go to
///   the local side.
abstract final class SyncMerger {
  static Map<String, Object?> merge({
    required Map<String, Object?> local,
    required Map<String, Object?>? remote,
  }) {
    if (remote == null || remote.isEmpty) return Map.of(local);
    final result = <String, Object?>{};
    for (final key in SyncKeys.all) {
      final merged = _mergeEnvelope(
        key,
        local[key] as Map<String, Object?>?,
        remote[key] as Map<String, Object?>?,
      );
      if (merged == null) continue;
      // Removals always win over union members, regardless of which side
      // provided the item. Needs the whole snapshots, not just envelopes.
      final tombstones = _tombstonesFor(key, local, remote);
      if (tombstones != null) {
        merged['v'] = _dropTombstoned(key, merged['v'], tombstones);
      }
      result[key] = merged;
    }
    return result;
  }

  static Map<String, Object?>? _mergeEnvelope(
    String key,
    Map<String, Object?>? local,
    Map<String, Object?>? remote,
  ) {
    if (local == null) return remote == null ? null : Map.of(remote);
    if (remote == null) return Map.of(local);
    final localT = (local['t'] as num?)?.toInt() ?? 0;
    final remoteT = (remote['t'] as num?)?.toInt() ?? 0;
    final localFirst = localT >= remoteT;
    final localValue = local['v'];
    final remoteValue = remote['v'];

    Object? merged;
    switch (key) {
      case SyncKeys.favorites || SyncKeys.history:
        merged = _unionTrackJson(
          localFirst ? localValue : remoteValue,
          localFirst ? remoteValue : localValue,
        );
      case SyncKeys.playlists:
        merged = _unionPlaylists(
          localFirst ? localValue : remoteValue,
          localFirst ? remoteValue : localValue,
        );
      case SyncKeys.playCounts || SyncKeys.playTimestamps:
        merged = _maxPerEntry(localValue, remoteValue);
      case SyncKeys.searchHistory:
        merged = _unionStrings(
          localFirst ? localValue : remoteValue,
          localFirst ? remoteValue : localValue,
        );
      case SyncKeys.lyricsOffsets:
        merged = _offsetsPerEntry(
          localFirst ? localValue : remoteValue,
          localFirst ? remoteValue : localValue,
        );
      case SyncKeys.favoritesDel ||
          SyncKeys.playlistsDel ||
          SyncKeys.searchHistoryDel ||
          SyncKeys.lyricsOffsetsDel:
        merged = _maxPerEntry(localValue, remoteValue);
      case SyncKeys.lyricsDisplayMode ||
          SyncKeys.lyricsAutoHide ||
          SyncKeys.themeId ||
          SyncKeys.customThemeJson:
        merged = localFirst
            ? (localValue ?? remoteValue)
            : (remoteValue ?? localValue);
      default:
        merged = localValue;
    }

    return {
      't': localT > remoteT ? localT : remoteT,
      if (merged != null) 'v': merged,
    };
  }

  static Map<String, Object?>? _tombstonesFor(
    String key,
    Map<String, Object?> local,
    Map<String, Object?> remote,
  ) {
    final String? delKey;
    switch (key) {
      case SyncKeys.favorites:
        delKey = SyncKeys.favoritesDel;
      case SyncKeys.playlists:
        delKey = SyncKeys.playlistsDel;
      case SyncKeys.searchHistory:
        delKey = SyncKeys.searchHistoryDel;
      case SyncKeys.lyricsOffsets:
        delKey = SyncKeys.lyricsOffsetsDel;
      default:
        delKey = null;
    }
    if (delKey == null) return null;
    final localDel = local[delKey];
    final remoteDel = remote[delKey];
    if (localDel == null && remoteDel == null) return null;
    return _maxPerEntry(
      localDel is Map ? localDel['v'] : null,
      remoteDel is Map ? remoteDel['v'] : null,
    );
  }

  static Object? _dropTombstoned(
    String key,
    Object? payload,
    Object? tombstones,
  ) {
    final deleted = <String>{
      if (tombstones is Map) for (final k in tombstones.keys) '$k',
    };
    if (deleted.isEmpty) return payload;
    switch (key) {
      case SyncKeys.favorites || SyncKeys.history:
        if (payload is! List) return payload;
        return payload
            .where((item) =>
                item is Map && !deleted.contains(trackKeyJsonOf(item)))
            .toList();
      case SyncKeys.playlists:
        if (payload is! Map) return payload;
        return {
          for (final entry in payload.entries)
            if (!deleted.contains('${entry.key}')) entry.key: entry.value,
        };
      case SyncKeys.searchHistory:
        if (payload is! List) return payload;
        return payload
            .where((q) => !deleted.contains('$q'.toLowerCase()))
            .toList();
      case SyncKeys.lyricsOffsets:
        if (payload is! Map) return payload;
        return {
          for (final entry in payload.entries)
            if (!deleted.contains('${entry.key}')) entry.key: entry.value,
        };
      default:
        return payload;
    }
  }

  /// Stable identity of a track inside a sync payload: `source:id`.
  static String trackKeyJsonOf(Object? item) {
    if (item is! Map) return '';
    final source = '${item['source'] ?? 'spotify'}';
    return '$source:${item['id'] ?? ''}';
  }

  static List<Object?>? _unionTrackJson(Object? base, Object? extra) {
    if (base is! List && extra is! List) return null;
    final ordered = <Object?>[
      if (base is List) ...base,
    ];
    final seen = <String>{
      for (final item in ordered) trackKeyJsonOf(item),
    };
    if (extra is List) {
      for (final item in extra) {
        if (seen.add(trackKeyJsonOf(item))) ordered.add(item);
      }
    }
    return ordered;
  }

  static Map<String, Object?>? _unionPlaylists(Object? base, Object? extra) {
    if (base is! Map && extra is! Map) return null;
    final merged = <String, Object?>{};
    final order = <String>[];
    void absorb(Map source) {
      source.forEach((name, tracks) {
        final key = '$name';
        if (!merged.containsKey(key)) {
          order.add(key);
          merged[key] = tracks;
        } else {
          merged[key] = _unionTrackJson(merged[key], tracks);
        }
      });
    }

    if (base is Map) absorb(base);
    if (extra is Map) absorb(extra);
    return {for (final name in order) name: merged[name]!};
  }

  static Map<String, Object?>? _maxPerEntry(Object? a, Object? b) {
    if (a is! Map && b is! Map) return null;
    final result = <String, Object?>{};
    if (a is Map) {
      a.forEach((k, v) {
        if (v is num) result['$k'] = v;
      });
    }
    if (b is Map) {
      b.forEach((k, v) {
        if (v is num) {
          final key = '$k';
          final current = result[key];
          if (current is! num || v > current) result[key] = v;
        }
      });
    }
    return result;
  }

  static List<Object?>? _unionStrings(Object? base, Object? extra) {
    if (base is! List && extra is! List) return null;
    final ordered = <Object?>[if (base is List) ...base];
    final seen = <String>{
      for (final q in ordered) '$q'.toLowerCase(),
    };
    if (extra is List) {
      for (final q in extra) {
        if (seen.add('$q'.toLowerCase())) ordered.add(q);
      }
    }
    return ordered;
  }

  static Map<String, Object?>? _offsetsPerEntry(Object? base, Object? extra) {
    if (base is! Map && extra is! Map) return null;
    final result = <String, Object?>{};
    if (base is Map) {
      base.forEach((k, v) {
        if (v is num) result['$k'] = v;
      });
    }
    if (extra is Map) {
      extra.forEach((k, v) {
        if (v is num) result.putIfAbsent('$k', () => v);
      });
    }
    return result;
  }
}

/// Keeps local timestamps and tombstones in sync with what was last pushed,
/// reads/writes storage, and moves snapshots through a [SyncTransport].
class SyncEngine {
  SyncEngine({
    required this.storage,
    required this.transport,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now {
    final meta = storage.getSyncMeta();
    final times = meta['times'];
    if (times is Map) {
      times.forEach((k, v) {
        if (v is num) _times['$k'] = v.toInt();
      });
    }
    final del = meta['del'];
    if (del is Map) {
      del.forEach((key, entries) {
        if (entries is Map) {
          _tombstones['$key'] = {
            for (final entry in entries.entries)
              if (entry.value is num)
                '${entry.key}': (entry.value as num).toInt(),
          };
        }
      });
    }
  }

  static const Set<String> _tombstoneTargets = {
    SyncKeys.favorites,
    SyncKeys.playlists,
    SyncKeys.searchHistory,
    SyncKeys.lyricsOffsets,
  };

  final LocalStorageService storage;
  final SyncTransport transport;
  final DateTime Function() _now;

  final Map<String, int> _times = {};
  final Map<String, Map<String, int>> _tombstones = {};
  Map<String, Object?>? _lastLocal;
  bool _applying = false;

  /// Whether the current change event was caused by the engine itself.
  bool get applyingRemote => _applying;

  // --- READ / APPLY --------------------------------------------------------

  Object? _readPayload(String key) {
    switch (key) {
      case SyncKeys.favorites:
        return _forSyncTracks(storage.getFavorites());
      case SyncKeys.history:
        return _forSyncTracks(storage.getHistory());
      case SyncKeys.playlists:
        return {
          for (final entry in storage.getPlaylists().entries)
            entry.key: _forSyncTracks(entry.value),
        };
      case SyncKeys.playCounts:
        return storage.getPlayCounts();
      case SyncKeys.playTimestamps:
        return storage.getPlayTimestamps();
      case SyncKeys.searchHistory:
        return storage.getSearchHistory();
      case SyncKeys.lyricsOffsets:
        return storage.getLyricsOffsets();
      case SyncKeys.lyricsDisplayMode:
        return storage.getLyricsDisplayMode();
      case SyncKeys.lyricsAutoHide:
        return storage.getLyricsAutoHide();
      case SyncKeys.themeId:
        return storage.getSavedThemeId();
      case SyncKeys.customThemeJson:
        return storage.getSavedCustomThemeJson();
      case SyncKeys.favoritesDel ||
          SyncKeys.playlistsDel ||
          SyncKeys.searchHistoryDel ||
          SyncKeys.lyricsOffsetsDel:
        return _tombstones[key];
      default:
        return null;
    }
  }

  /// The sync payload for a track: everything durable, nothing ephemeral
  /// (signed stream URLs, the local cached flag).
  static List<Map<String, Object?>> _forSyncTracks(List<MediaTrack> tracks) => [
        for (final track in tracks)
          {
            'id': track.id,
            'title': track.title,
            'artist': track.artist,
            if (track.album != null) 'album': track.album,
            'durationMs': track.duration.inMilliseconds,
            'artworkUrl': track.artworkUrl,
            'source': track.source.name,
            'isCached': false,
            if (track.playbackCount > 0) 'playbackCount': track.playbackCount,
          },
      ];

  Map<String, Object?> _localEnvelopes() {
    final envelopes = <String, Object?>{};
    for (final key in SyncKeys.all) {
      final payload = _readPayload(key);
      if (payload == null) continue;
      if (key.endsWith('_del')) {
        final empty = payload is List ? payload.isEmpty : payload is Map && payload.isEmpty;
        if (empty) continue;
      }
      envelopes[key] = {'t': _times[key] ?? 0, 'v': payload};
    }
    return envelopes;
  }

  Future<void> _apply(Map<String, Object?> snapshot) async {
    _applying = true;
    try {
      Map<String, Object?>? envelope(String key) =>
          snapshot[key] as Map<String, Object?>?;

      final favorites = envelope(SyncKeys.favorites)?['v'];
      if (favorites is List) {
        await storage.setFavorites(_tracksFrom(favorites));
      }
      final history = envelope(SyncKeys.history)?['v'];
      if (history is List) {
        await storage.setHistory(_tracksFrom(history));
      }
      final playlists = envelope(SyncKeys.playlists)?['v'];
      if (playlists is Map) {
        await storage.setPlaylists({
          for (final entry in playlists.entries)
            if (entry.value is List)
              entry.key: _tracksFrom(entry.value as List),
        });
      }
      final counts = envelope(SyncKeys.playCounts)?['v'];
      if (counts is Map) {
        await storage.setPlayCounts({
          for (final entry in counts.entries)
            if (entry.value is num) entry.key: (entry.value as num).toInt(),
        });
      }
      final stamps = envelope(SyncKeys.playTimestamps)?['v'];
      if (stamps is Map) {
        await storage.setPlayTimestamps({
          for (final entry in stamps.entries)
            if (entry.value is num) entry.key: (entry.value as num).toInt(),
        });
      }
      final searches = envelope(SyncKeys.searchHistory)?['v'];
      if (searches is List) {
        await storage.setSearchHistory([
          for (final q in searches) '$q',
        ]);
      }
      final offsets = envelope(SyncKeys.lyricsOffsets)?['v'];
      if (offsets is Map) {
        await storage.setLyricsOffsets({
          for (final entry in offsets.entries)
            if (entry.value is num) entry.key: (entry.value as num).toDouble(),
        });
      }
      final displayMode = envelope(SyncKeys.lyricsDisplayMode)?['v'];
      if (displayMode is String) {
        await storage.saveLyricsDisplayMode(displayMode);
      }
      final autoHide = envelope(SyncKeys.lyricsAutoHide)?['v'];
      if (autoHide is bool) {
        await storage.saveLyricsAutoHide(autoHide);
      }
      final themeId = envelope(SyncKeys.themeId)?['v'];
      if (themeId is String) {
        await storage.saveThemeId(themeId);
      }
      final customTheme = envelope(SyncKeys.customThemeJson)?['v'];
      if (customTheme is String) {
        await storage.saveCustomThemeJson(customTheme);
      }
    } finally {
      _applying = false;
    }
  }

  static List<MediaTrack> _tracksFrom(List<Object?> raw) => [
        for (final item in raw)
          if (_trackFrom(item) case final track?) track,
      ];

  static MediaTrack? _trackFrom(Object? item) {
    final Map<String, dynamic> json;
    if (item is Map<String, dynamic>) {
      json = item;
    } else if (item is Map) {
      json = Map<String, dynamic>.from(item);
    } else {
      return null;
    }
    try {
      return MediaTrack.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  // --- OPERATIONS ----------------------------------------------------------

  /// A local mutation happened. Records timestamps and any removals the
  /// engine can see by diffing against the last known local snapshot.
  void onChanged(String key) {
    if (_applying) return;
    final t = _now().millisecondsSinceEpoch;
    _times[key] = t;
    if (_tombstoneTargets.contains(key)) {
      _recordTombstones(key, t);
    }
    _persistMeta();
  }

  void _recordTombstones(String key, int t) {
    final before = _lastLocal?[key];
    final beforeEntries = before is Map ? before['v'] : null;
    final after = _readPayload(key);
    String Function(Object) entryKeyOf;
    switch (key) {
      case SyncKeys.favorites:
        entryKeyOf = (raw) => raw is Map ? SyncMerger.trackKeyJsonOf(raw) : '';
      case SyncKeys.searchHistory:
        entryKeyOf = (raw) => '$raw'.toLowerCase();
      default:
        entryKeyOf = (raw) => '$raw';
    }
    Set<String> keysOf(Object? payload) {
      if (payload is List) {
        return {for (final item in payload) entryKeyOf(item)};
      }
      if (payload is Map) {
        return {for (final name in payload.keys) '$name'};
      }
      return {};
    }

    final afterKeys = keysOf(after);
    final removed = keysOf(beforeEntries)..removeWhere((entry) {
      return entry.isEmpty || afterKeys.contains(entry);
    });
    if (removed.isEmpty) return;
    final tombstoneKey = _tombstoneKeyFor(key);
    final store = _tombstones.putIfAbsent(tombstoneKey, () => {});
    for (final entry in removed) {
      store[entry] = t;
    }
    _times[tombstoneKey] = t;
  }

  static String _tombstoneKeyFor(String key) {
    switch (key) {
      case SyncKeys.favorites:
        return SyncKeys.favoritesDel;
      case SyncKeys.playlists:
        return SyncKeys.playlistsDel;
      case SyncKeys.searchHistory:
        return SyncKeys.searchHistoryDel;
      case SyncKeys.lyricsOffsets:
        return SyncKeys.lyricsOffsetsDel;
      default:
        return key;
    }
  }

  void _persistMeta() {
    unawaited(storage.setSyncMeta({
      'times': _times,
      'del': _tombstones,
    }));
  }

  /// Push the current local snapshot. Returns the pushed envelope map.
  Future<Map<String, Object?>> push() async {
    final envelopes = _localEnvelopes();
    await transport.saveSnapshot(envelopes);
    _lastLocal = envelopes;
    return envelopes;
  }

  /// Pull the server snapshot, merge, apply locally and — when the merge
  /// produced something the server has not seen — push it back.
  Future<void> pull() async {
    final remote = await transport.fetchSnapshot();
    final local = _localEnvelopes();
    final merged = SyncMerger.merge(local: local, remote: remote);
    await _apply(merged);
    for (final entry in merged.entries) {
      final t = (entry.value as Map?)?['t'];
      if (t is num) _times[entry.key] = t.toInt();
    }
    for (final delKey in SyncKeys.delKeys) {
      final envelope = merged[delKey];
      final value = envelope is Map ? envelope['v'] : null;
      if (value is Map) {
        _tombstones[delKey] = {
          for (final entry in value.entries)
            if (entry.value is num) '${entry.key}': (entry.value as num).toInt(),
        };
      }
    }
    _persistMeta();
    _lastLocal = merged;
    if (remote == null || !_deepEquals(remote, merged)) {
      try {
        await transport.saveSnapshot(merged);
      } catch (error) {
        // The merged state is already local; the next push retries.
        PlaybackDiagnostics.record(
          'sync.push',
          source: 'sync',
          error: error.toString(),
        );
      }
    }
  }
}

/// Order-insensitive comparison of two JSON-like trees (maps compare by
/// key sets, lists by position).
bool _deepEquals(Object? a, Object? b) {
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey('${entry.key}')) return false;
      if (!_deepEquals(entry.value, b[entry.key])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_deepEquals(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}
