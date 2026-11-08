import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/extractor/models/media_track.dart';

class LocalStorageService {
  static const String _favoritesKey = 'hook_favorites_tracks';
  static const String _historyKey = 'hook_history_tracks';
  static const String _playlistsKey = 'hook_user_playlists';
  static const String _activeThemeKey = 'hook_active_theme_id';
  static const String _customThemeJsonKey = 'hook_custom_theme_json';
  static const int _maxHistoryCount = 100;

  final SharedPreferences _prefs;
  final StreamController<void> _favoritesController =
      StreamController<void>.broadcast();

  Stream<void> get favoritesChanges => _favoritesController.stream;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // --- THEME PERSISTENCE ---
  static const String _oledDefaultAppliedKey = 'hook_oled_default_applied';

  /// Whether the switch to OLED Monolith as the default theme already ran.
  bool get oledDefaultApplied =>
      _prefs.getBool(_oledDefaultAppliedKey) ?? false;
  Future<void> markOledDefaultApplied() =>
      _prefs.setBool(_oledDefaultAppliedKey, true);

  String? getSavedThemeId() => _prefs.getString(_activeThemeKey);
  Future<void> saveThemeId(String id) => _prefs.setString(_activeThemeKey, id);

  String? getSavedCustomThemeJson() => _prefs.getString(_customThemeJsonKey);
  Future<void> saveCustomThemeJson(String json) =>
      _prefs.setString(_customThemeJsonKey, json);

  // --- LOCALE ---
  String? getLocaleCode() => _prefs.getString('hook_locale_code');
  Future<void> saveLocaleCode(String code) =>
      _prefs.setString('hook_locale_code', code);

  // --- REMOTE RESOLVER ---
  String? getRemoteResolverUrl() =>
      _prefs.getString('hook_remote_resolver_url');
  Future<void> saveRemoteResolverUrl(String? url) =>
      url == null || url.trim().isEmpty
      ? _prefs.remove('hook_remote_resolver_url')
      : _prefs.setString('hook_remote_resolver_url', url.trim());

  // --- ONBOARDING ---
  bool getOnboardingDone() => _prefs.getBool('hook_onboarding_done') ?? false;
  Future<void> saveOnboardingDone() =>
      _prefs.setBool('hook_onboarding_done', true);

  // --- LYRICS PRESENTATION ---
  bool getLyricsAutoHide() => _prefs.getBool('hook_lyrics_auto_hide') ?? true;
  Future<void> saveLyricsAutoHide(bool enabled) =>
      _prefs.setBool('hook_lyrics_auto_hide', enabled);

  String? getLyricsDisplayMode() =>
      _prefs.getString('hook_lyrics_display_mode');
  Future<void> saveLyricsDisplayMode(String mode) =>
      _prefs.setString('hook_lyrics_display_mode', mode);

  Map<String, dynamic> _lyricsOffsets() {
    try {
      final decoded = jsonDecode(
        _prefs.getString('hook_lyrics_offsets') ?? '{}',
      );
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  double getLyricsOffset(String trackKey) {
    final value = _lyricsOffsets()[trackKey];
    return value is num && value.isFinite
        ? value.toDouble().clamp(-45.0, 45.0)
        : 0.0;
  }

  /// Whether the listener has tuned this track by hand. An absent entry
  /// means the auto intro compensation may take over.
  bool hasLyricsOffset(String trackKey) =>
      _lyricsOffsets().containsKey(trackKey);

  // --- Update checks -------------------------------------------------------

  static const _updateLastCheckKey = 'hook_update_last_check';

  DateTime? get lastUpdateCheck {
    final ms = _prefs.getInt(_updateLastCheckKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> markUpdateChecked() => _prefs.setInt(
        _updateLastCheckKey,
        DateTime.now().millisecondsSinceEpoch,
      );

  Future<void> saveLyricsOffset(String trackKey, double seconds) async {
    if (!seconds.isFinite) return;
    final offsets = _lyricsOffsets()..remove(trackKey);
    if (seconds != 0) offsets[trackKey] = seconds.clamp(-45.0, 45.0);
    while (offsets.length > 200) {
      offsets.remove(offsets.keys.first);
    }
    await _prefs.setString('hook_lyrics_offsets', jsonEncode(offsets));
  }

  // --- FAVORITES ---
  List<MediaTrack> getFavorites() {
    final raw = _prefs.getStringList(_favoritesKey) ?? [];
    return raw
        .map((str) {
          try {
            return MediaTrack.fromJson(jsonDecode(str) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<MediaTrack>()
        .toList();
  }

  Future<bool> isFavorite(String trackId, {TrackSource? source}) async {
    final favorites = getFavorites();
    return favorites.any(
      (t) => t.id == trackId && (source == null || t.source == source),
    );
  }

  Future<void> toggleFavorite(MediaTrack track) async {
    final favorites = getFavorites();
    final index = favorites.indexWhere(
      (t) => t.id == track.id && t.source == track.source,
    );
    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      favorites.insert(0, track);
    }
    await _saveFavorites(favorites);
    if (!_favoritesController.isClosed) _favoritesController.add(null);
  }

  Future<void> _saveFavorites(List<MediaTrack> tracks) async {
    final serialized = tracks.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList(_favoritesKey, serialized);
  }

  // --- PLAYBACK HISTORY ---
  List<MediaTrack> getHistory() {
    final raw = _prefs.getStringList(_historyKey) ?? [];
    return raw
        .map((str) {
          try {
            return MediaTrack.fromJson(jsonDecode(str) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<MediaTrack>()
        .toList();
  }

  Future<void> addToHistory(MediaTrack track) async {
    final history = getHistory();
    history.removeWhere((t) => t.id == track.id && t.source == track.source);
    history.insert(0, track);
    if (history.length > _maxHistoryCount) {
      history.removeLast();
    }
    final serialized = history.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList(_historyKey, serialized);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }

  // --- SEARCH HISTORY ---
  static const String _searchHistoryKey = 'hook_search_history';
  static const int _maxSearchHistoryCount = 15;

  List<String> getSearchHistory() =>
      _prefs.getStringList(_searchHistoryKey) ?? [];

  Future<void> addSearchQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || trimmed.length < 2) return;
    final history = getSearchHistory()
      ..removeWhere((q) => q.toLowerCase() == trimmed.toLowerCase());
    history.insert(0, trimmed);
    if (history.length > _maxSearchHistoryCount) history.removeLast();
    await _prefs.setStringList(_searchHistoryKey, history);
  }

  Future<void> removeSearchQuery(String query) async {
    final history = getSearchHistory()
      ..removeWhere((q) => q.toLowerCase() == query.trim().toLowerCase());
    await _prefs.setStringList(_searchHistoryKey, history);
  }

  Future<void> clearSearchHistory() async {
    await _prefs.remove(_searchHistoryKey);
  }

  // --- PLAY SIGNALS (personal recommendations) ---
  static const String _playCountsKey = 'hook_play_counts';
  static const String _playTimestampsKey = 'hook_play_timestamps';
  static const int _maxPlaySignalEntries = 500;

  Map<String, int> _intMap(String key) {
    try {
      final decoded = jsonDecode(_prefs.getString(key) ?? '{}');
      if (decoded is! Map) return {};
      return {
        for (final entry in decoded.entries)
          if (entry.value is num) entry.key as String: (entry.value as num).toInt(),
      };
    } catch (_) {
      return {};
    }
  }

  /// How many times a track (by artist|title key) was actually played.
  Map<String, int> getPlayCounts() => _intMap(_playCountsKey);

  /// Epoch milliseconds of the last play, for recency decay.
  Map<String, int> getPlayTimestamps() => _intMap(_playTimestampsKey);

  Future<void> registerPlay(String trackKey) async {
    final counts = getPlayCounts();
    counts[trackKey] = (counts[trackKey] ?? 0) + 1;
    while (counts.length > _maxPlaySignalEntries) {
      counts.remove(counts.keys.first);
    }
    final stamps = getPlayTimestamps()
      ..[trackKey] = DateTime.now().millisecondsSinceEpoch;
    while (stamps.length > _maxPlaySignalEntries) {
      stamps.remove(stamps.keys.first);
    }
    await _prefs.setString(_playCountsKey, jsonEncode(counts));
    await _prefs.setString(_playTimestampsKey, jsonEncode(stamps));
  }

  // --- PLAYLISTS ---
  Map<String, List<MediaTrack>> getPlaylists() {
    final raw = _prefs.getString(_playlistsKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final result = <String, List<MediaTrack>>{};
      decoded.forEach((key, value) {
        if (value is List) {
          result[key] = value
              .map((item) {
                try {
                  return MediaTrack.fromJson(item as Map<String, dynamic>);
                } catch (_) {
                  return null;
                }
              })
              .whereType<MediaTrack>()
              .toList();
        }
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  Future<void> savePlaylist(String name, List<MediaTrack> tracks) async {
    final playlists = getPlaylists();
    playlists[name] = tracks;
    final serialized = playlists.map(
      (key, list) => MapEntry(key, list.map((t) => t.toJson()).toList()),
    );
    await _prefs.setString(_playlistsKey, jsonEncode(serialized));
  }

  Future<void> deletePlaylist(String name) async {
    final playlists = getPlaylists();
    playlists.remove(name);
    final serialized = playlists.map(
      (key, list) => MapEntry(key, list.map((t) => t.toJson()).toList()),
    );
    await _prefs.setString(_playlistsKey, jsonEncode(serialized));
  }
}
