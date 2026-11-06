import '../../features/extractor/models/media_track.dart';
import '../../features/lyrics/domain/lyrics_display_mode.dart';
import '../../l10n/generated/app_localizations.dart';

extension LocalizedTrackSource on TrackSource {
  String labelFor(AppLocalizations strings) => switch (this) {
    TrackSource.soundcloud => strings.sourceSoundCloud,
    TrackSource.local => strings.sourceDevice,
    TrackSource.spotify => strings.sourceCatalog,
    TrackSource.youtubeMusic => strings.sourceYouTube,
    TrackSource.audius => strings.sourceAudius,
    TrackSource.remote => strings.sourceServer,
  };
}

extension LocalizedLyricsDisplayMode on LyricsDisplayMode {
  String labelFor(AppLocalizations strings) => switch (this) {
    LyricsDisplayMode.lines => strings.lyricsModeLines,
    LyricsDisplayMode.karaoke => strings.lyricsModeKaraoke,
    LyricsDisplayMode.focus => strings.lyricsModeFocus,
  };

  String descriptionFor(AppLocalizations strings) => switch (this) {
    LyricsDisplayMode.lines => strings.lyricsModeLinesDescription,
    LyricsDisplayMode.karaoke => strings.lyricsModeKaraokeDescription,
    LyricsDisplayMode.focus => strings.lyricsModeFocusDescription,
  };
}
