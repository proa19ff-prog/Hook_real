// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'Settings';

  @override
  String get settingsCaption => 'Changes are saved on this device.';

  @override
  String get playerSettings => 'Player';

  @override
  String get lyricsAutoHide => 'Hide controls while reading lyrics';

  @override
  String get lyricsAutoHideDescription =>
      'After 10 seconds without interaction, the player panels slide away. Use the restore button to bring them back.';

  @override
  String get showPlayerControls => 'Show player controls';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get equalizerEnabled => 'Sound processing';

  @override
  String get equalizerPresets => 'Sound profile';

  @override
  String get equalizerFlat => 'Original';

  @override
  String get equalizerBass => 'Deep bass';

  @override
  String get equalizerVocal => 'Vocals';

  @override
  String get equalizerRock => 'Rock';

  @override
  String get equalizerElectronic => 'Electronic';

  @override
  String get equalizerSoft => 'Soft';

  @override
  String get equalizerCustom => 'Custom';

  @override
  String get equalizerBands => 'Frequency bands';

  @override
  String get equalizerBassBoost => 'Bass boost';

  @override
  String get equalizerBassUnsupported =>
      'Additional bass boost is not supported. Use the low-frequency bands.';

  @override
  String get equalizerPreamp => 'Preamp';

  @override
  String get equalizerHeadroom => 'Automatic headroom';

  @override
  String get equalizerHeadroomDescription =>
      'Reduces output level when boosting frequencies to leave room for peaks. It is not a limiter.';

  @override
  String get equalizerWaiting =>
      'Start a track to connect the equalizer to its audio session.';

  @override
  String get equalizerUnsupported =>
      'Sound processing is currently available on Android only.';

  @override
  String get equalizerFailed =>
      'This device could not enable audio effects. Music can still play without them.';

  @override
  String get equalizerRetry => 'Reconnect effects';

  @override
  String get equalizerLive =>
      'Changes apply immediately and are saved on this device.';

  @override
  String get youtubeAccount => 'YouTube & MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'Read-only playlist access. Signing in does not guarantee audio availability.';

  @override
  String get youtubeAccountCompatibility => 'Compatibility and privacy';

  @override
  String get youtubeAccountSubtitle => 'Account connection and playlist import';

  @override
  String get youtubeAccountPrivacy =>
      'Hook requests read-only YouTube access. Enter your password only in Google\'s system dialog, never in Hook. The token is not sent to a Hook server and is kept only in memory. Reconnect after restarting the app.';

  @override
  String get youtubeAccountPlaybackNotice =>
      'Signing in grants access to account data, not audio streams. It does not guarantee a fix for HTTP 403. Imports preserve YouTube recordings without substituting another source.';

  @override
  String get youtubeAccountConnect => 'Connect account';

  @override
  String get youtubeAccountDisconnect => 'Disconnect in Hook';

  @override
  String get youtubeAccountDisconnected => 'No account connected';

  @override
  String get youtubeAccountDisconnectNotice =>
      'Disconnect this account in Hook only? Saved playlists will remain. Google and MicroG accounts on the phone will not be signed out.';

  @override
  String get youtubeAccountSystem => 'System Google APIs';

  @override
  String get youtubeAccountServicesMissing =>
      'Compatible system Google APIs are unavailable. A separate ReVanced GmsCore installation does not replace them for Hook sign-in.';

  @override
  String get youtubeAccountMicrogNotice =>
      'A separate ReVanced GmsCore installation was detected. Hook does not use ReVanced accounts or tokens. System MicroG may provide compatible Google APIs, but compatibility with this sign-in method is not guaranteed.';

  @override
  String get youtubeAccountRevancedFound =>
      'YouTube Music ReVanced is installed';

  @override
  String get youtubeAccountPlaylists => 'Account playlists';

  @override
  String get youtubeAccountNoPlaylists =>
      'No accessible playlists. Some automatic YouTube Music collections are not available through the YouTube Data API.';

  @override
  String get youtubeAccountMore => 'Load more';

  @override
  String get youtubeAccountPreview => 'Prepare import';

  @override
  String youtubeAccountProgress(int count) {
    return 'Tracks retrieved: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'Unavailable entries skipped: $count. They are not replaced with other tracks.';
  }

  @override
  String get youtubeAccountSetup => 'Sign-in setup';

  @override
  String get youtubeAccountSetupBody =>
      'The developer must enable YouTube Data API v3 in Google Cloud, register an Android OAuth client for com.hook.music and the installed build\'s signing SHA-1, and configure the consent screen. Add permitted users in testing mode. See docs/YOUTUBE_ACCOUNT_SETUP.md. Never add passwords, client secrets, or tokens from other apps.';

  @override
  String get youtubeAccountConfigError =>
      'Sign-in is not configured for this build. Check the Android OAuth client, package name, SHA-1 and permitted test users in Google Cloud.';

  @override
  String get youtubeAccountPermissionError =>
      'Read access to YouTube data was not granted.';

  @override
  String get youtubeAccountExpired =>
      'Your session has expired. Reconnect the account.';

  @override
  String get youtubeAccountNoChannel =>
      'The selected account has no accessible YouTube channel.';

  @override
  String get youtubeAccountQuota =>
      'YouTube API quota exceeded. Try again later.';

  @override
  String get youtubeAccountFailed =>
      'Could not retrieve YouTube data. Check your connection and try again.';

  @override
  String get youtubeAccountUnsupported =>
      'Account connection requires Android with compatible system Google APIs.';

  @override
  String get importedFromYouTube => 'Imported from YouTube account';

  @override
  String get translateLyrics => 'Translate lyrics';

  @override
  String get hideTranslation => 'Hide translation';

  @override
  String get cancelTranslation => 'Cancel translation';

  @override
  String get translationLoading => 'Preparing translation…';

  @override
  String get translationAttribution =>
      'Automatically translated by Google Translate';

  @override
  String get translationNotice =>
      'Translation may not capture the song\'s meaning accurately. Word highlighting applies only to the original.';

  @override
  String get translationModelTitle => 'Download language models?';

  @override
  String get translationModelBody =>
      'Translation runs on your phone: lyrics are not sent to a server. The first translation needs Google ML Kit models, taking tens of megabytes. The download uses your current connection, including mobile data. Cancelling hides the result, but a model download already started may finish in the background.';

  @override
  String get translationDownload => 'Download and translate';

  @override
  String get translationUnavailable =>
      'Translation failed. Check access to model downloads and try again.';

  @override
  String get translationUnsupported =>
      'On-device translation is currently available on Android only.';

  @override
  String get translationUnknownLanguage =>
      'Could not identify a supported language for this song.';

  @override
  String get translationSameLanguage =>
      'The lyrics are already in the selected language.';

  @override
  String get translationTooLarge =>
      'These lyrics are too long for on-device translation.';

  @override
  String get translationRussian => 'To Russian';

  @override
  String get translationEnglish => 'To English';

  @override
  String get translationTarget => 'Translation language';

  @override
  String get retry => 'Retry';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get library => 'Library';

  @override
  String get youtubeUnavailableTitle => 'YouTube is currently unavailable';

  @override
  String get youtubeUnavailableBody =>
      'Couldn\'t obtain an audio stream. Check your network and VPN route: YouTube may reject requests even with a VPN.';

  @override
  String get checkAgain => 'Check again';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get goodNight => 'Good night';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get themeSettings => 'Appearance settings';

  @override
  String get onYourAir => 'On your air';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recent signals',
      one: '1 recent signal',
      zero: 'No recent signals',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'Your collection is waiting';

  @override
  String get saved => 'Saved';

  @override
  String get collectionEmptyDetail =>
      'Music you want to return to will stay here';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks',
      one: '1 track',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'Track, artist, or lyrics';

  @override
  String get searchUpper => 'SEARCH';

  @override
  String get findFirstTrack => 'Find your first track';

  @override
  String continuationAfter(String artist) {
    return 'More music after $artist';
  }

  @override
  String get chooseTrackWaveDetail =>
      'Choose a track and we\'ll build a wave around its mood.';

  @override
  String get continueWaveLabel => 'CONTINUE / 01';

  @override
  String get yourWaveLabel => 'YOUR WAVE / 01';

  @override
  String get continueWave => 'Continue wave';

  @override
  String get chooseTrack => 'Choose a track';

  @override
  String get firstTrace => 'Leave your first trace here';

  @override
  String get favoriteWaveHint =>
      'Save favorites and your wave will become more accurate.';

  @override
  String get openSearch => 'Open search';

  @override
  String get findYourMusic => 'Find your sound.';

  @override
  String get importMusic => 'Import music';

  @override
  String get rememberedLyricsHint => 'The words you remember…';

  @override
  String get trackArtistHint => 'Track or artist — any language';

  @override
  String get clear => 'Clear';

  @override
  String get music => 'Music';

  @override
  String get byLyrics => 'By lyrics';

  @override
  String get allSources => 'All sources';

  @override
  String get lyricsSearchCaption =>
      'Search for a phrase in a song, not just its title.';

  @override
  String get searchingLyrics => 'Looking for familiar lines…';

  @override
  String get searchingSources => 'Searching music sources…';

  @override
  String get connectionFailed => 'Couldn\'t connect';

  @override
  String get noMatches => 'No matches yet';

  @override
  String get lyricsUnavailable =>
      'Lyrics search is unavailable right now. Try later or search by title.';

  @override
  String get searchUnavailable =>
      'Search failed. Check your connection and try again.';

  @override
  String get lyricsNoMatches => 'Try another line. Not every lyric is indexed.';

  @override
  String get trackNoMatches =>
      'Add the artist or choose another source. Some services may be unavailable on your network.';

  @override
  String get repeatSearch => 'Search again';

  @override
  String get lyricMatchesUpper => 'LYRIC MATCHES';

  @override
  String get tracksUpper => 'TRACKS';

  @override
  String playTrack(String title, String artist) {
    return 'Play $title, $artist';
  }

  @override
  String get familiarLinesUpper => 'FAMILIAR LINES';

  @override
  String get bestMatchUpper => 'BEST MATCH';

  @override
  String get fullVersionOnPlayback =>
      'We\'ll find the full version when playback starts.';

  @override
  String get forgotTitle => 'Forgot the title.\nNot the music.';

  @override
  String get startAsYouRemember =>
      'A name, title, or line from a song.\nStart with whatever you remember.';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => 'Search names the way they sound';

  @override
  String get rememberOnlyLine => 'I only remember a line';

  @override
  String get findSongByWords => 'Find a song by its words';

  @override
  String get yourArtistsUpper => 'YOUR ARTISTS';

  @override
  String get language => 'Language';

  @override
  String get languageCaption => 'The interface follows your choice immediately';

  @override
  String get systemLanguage => 'System';

  @override
  String get russian => 'Russian';

  @override
  String get english => 'English';

  @override
  String get themesAndShaders => 'Themes and effects';

  @override
  String get themesSubtitle => 'Appearance, language and background motion';

  @override
  String get invalidThemeJson =>
      'Could not read the theme. Check the JSON format and field values.';

  @override
  String get exportJson => 'Export JSON';

  @override
  String get importJson => 'Import JSON';

  @override
  String get readyThemes => 'Theme presets';

  @override
  String get gpuShaders => 'Background effects';

  @override
  String get meshGradient => 'Smooth GPU gradient based on track colors';

  @override
  String get vinylNoise => 'Analog vinyl grain (Noise)';

  @override
  String get glassBlur => 'Glass blur (Backdrop Blur)';

  @override
  String get cornerRadius => 'Interface corner radius';

  @override
  String get importThemeTitle => 'Import theme from JSON';

  @override
  String get pasteThemeJson => 'Paste the theme JSON configuration:';

  @override
  String get cancel => 'Cancel';

  @override
  String get apply => 'Apply';

  @override
  String get themeApplied => 'Theme applied successfully!';

  @override
  String get exportThemeTitle => 'Export theme (JSON)';

  @override
  String get close => 'Close';

  @override
  String get copyJson => 'Copy JSON';

  @override
  String get jsonCopied => 'Theme JSON copied to clipboard!';

  @override
  String get libraryUpper => 'LIBRARY';

  @override
  String get localCollection => 'Local collection and playlists';

  @override
  String get importShort => 'Import';

  @override
  String get favorites => 'Favorites';

  @override
  String get playlists => 'Playlists';

  @override
  String get history => 'History';

  @override
  String get offline => 'Offline';

  @override
  String get favoritesEmpty =>
      'Your favorites are empty.\nTap the heart on a track to add it here.';

  @override
  String get historyEmpty =>
      'Your listening history is empty.\nPlay music from search and it will appear here.';

  @override
  String get noPlaylists => 'You don\'t have any playlists yet';

  @override
  String get importPlaylistHint =>
      'Import a Spotify playlist or paste a track list.';

  @override
  String get importMusicAction => 'Import music';

  @override
  String get playPlaylist => 'Play playlist';

  @override
  String playlistStarted(String name, int count) {
    return 'Playing “$name” ($count tracks)';
  }

  @override
  String get deletePlaylist => 'Delete playlist';

  @override
  String get playAll => 'Play all';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get localAudioCache => 'Local audio cache';

  @override
  String get cacheDescription =>
      'Played tracks are stored locally for instant replay without an internet connection.';

  @override
  String deviceUsage(String size) {
    return 'On this device: $size';
  }

  @override
  String get clearCache => 'Clear all cache';

  @override
  String savedTracksUpper(int count) {
    return 'SAVED TRACKS ($count):';
  }

  @override
  String get cacheFeaturesUpper => 'CACHE FEATURES:';

  @override
  String get offlineFirst => 'Fully offline-first';

  @override
  String get offlineFirstDescription =>
      'On replay, audio loads directly from the device file system.';

  @override
  String get maximumBitrate => 'Maximum bitrate';

  @override
  String get maximumBitrateDescription =>
      'Clean Opus/M4A streams at 160–256 kbps are cached without transcoding.';

  @override
  String get trafficAndBattery => 'Save data and battery';

  @override
  String get trafficAndBatteryDescription =>
      'Avoiding repeated network requests helps your phone last longer.';

  @override
  String get cacheEmpty => 'Cache is empty';

  @override
  String get cachedTracksAppear =>
      'Downloaded tracks will appear here automatically';

  @override
  String get removeFromCache => 'Remove from cache';

  @override
  String get removeCachedTrackTitle => 'Remove track from cache?';

  @override
  String removeCachedTrackBody(String title) {
    return '“$title” will be removed from this device.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get trackRemovedFromCache => 'Track removed from cache';

  @override
  String get clearCacheTitle => 'Clear cache?';

  @override
  String get clearCacheBody =>
      'All saved audio files will be removed from this device. Favorites and history won\'t change.';

  @override
  String get cacheCleared => 'Local cache cleared';

  @override
  String get back => 'Back';

  @override
  String get playlistActions => 'Playlist actions';

  @override
  String get playlistUpper => 'PLAYLIST';

  @override
  String get playlistEmpty => 'There are no tracks in this playlist yet';

  @override
  String get pasteTrackList => 'Paste a track list';

  @override
  String get pasteImportLink => 'Paste a link to import';

  @override
  String get tracksNotFound => 'No tracks were found at that link.';

  @override
  String get importError =>
      'Import failed. Check the link and your internet connection.';

  @override
  String importedPlaylistStarted(int count) {
    return 'Playing imported playlist ($count tracks)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'Import ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return 'Playlist “$name” saved to your library!';
  }

  @override
  String get spotifyImportSubtitle => 'Spotify • Playlists, albums, and tracks';

  @override
  String get artistTrackOrCsv => 'Artist — Track, or an Exportify CSV';

  @override
  String get pastePlaylistOrTrackLink => 'Paste a playlist or track link';

  @override
  String get pasteFromClipboard => 'Paste from clipboard';

  @override
  String get link => 'Link';

  @override
  String get trackList => 'Track list';

  @override
  String get playlistName => 'Playlist name';

  @override
  String get startImport => 'Start import';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count tracks';
  }

  @override
  String get importedFromSpotify => 'Imported from Spotify';

  @override
  String get importedFromDeezer => 'Imported from Deezer';

  @override
  String get importIntro =>
      'Bring your playlists with you. Use a Spotify link, a track list, or an Exportify file.';

  @override
  String get importTextTab => 'Text';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'Choose a file';

  @override
  String get importFileHint =>
      'Choose the CSV exported by Exportify, or a TXT track list. UTF-8, up to 10 MB and 10,000 tracks.';

  @override
  String get importFileAndroidOnly =>
      'File selection is available on Android. Here you can paste the contents of a CSV or track list.';

  @override
  String get importTextHint =>
      'One Artist — Track per line. You can also paste the full CSV, including its header.';

  @override
  String get importPreview => 'Preview tracks';

  @override
  String get importedFromCsv => 'Imported from CSV';

  @override
  String get importedFromText => 'Imported from a track list';

  @override
  String importMoreTracks(int count) {
    return 'And $count more';
  }

  @override
  String get importMetadataHint =>
      'The playlist is saved on this device. Audio is found when you play a track; importing does not download songs.';

  @override
  String get importAnother => 'Import something else';

  @override
  String get importReading => 'Reading your playlist…';

  @override
  String get importSaving => 'Saving to your library…';

  @override
  String get importNameRequired => 'Enter a playlist name.';

  @override
  String get importNameExists =>
      'A playlist with this name already exists. Choose another name to keep both.';

  @override
  String get importSaveFailed =>
      'Couldn\'t save the playlist. Your preview is still here — try again.';

  @override
  String get importFileTooLarge =>
      'This file is larger than 10 MB. Split the playlist into smaller exports.';

  @override
  String get importFileUnsupported => 'Choose a .csv or .txt file.';

  @override
  String get importFileEncoding =>
      'Couldn\'t read the text encoding. Save the file as UTF-8 and try again.';

  @override
  String get importCsvInvalid =>
      'The CSV is incomplete or malformed. Export it again without editing its columns or quotation marks.';

  @override
  String get importCsvMissingColumns =>
      'The CSV needs Track Name and Artist Name(s) columns, or Title and Artist. Choose the original Exportify export.';

  @override
  String get importFileEmpty =>
      'No tracks were found. Choose a populated export or paste an Artist — Track list.';

  @override
  String get importTooManyTracks =>
      'A single import can contain up to 10,000 tracks. Split this playlist; nothing has been saved yet.';

  @override
  String get importFileReadFailed =>
      'Couldn\'t open this file. Check that it is available on your device and choose it again.';

  @override
  String get importSpotifyBlocked =>
      'Spotify didn\'t share this playlist in your region. Export it with Exportify and choose the CSV file instead.';

  @override
  String get listen => 'Play';

  @override
  String get addToPlaylists => 'Add to playlists';

  @override
  String trackSemantics(String title, String artist) {
    return 'Track $title, $artist';
  }

  @override
  String get trackActions => 'Track actions';

  @override
  String get updatesTitle => 'Updates';

  @override
  String currentVersion(String version) {
    return 'Version $version';
  }

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get checkingForUpdates => 'Checking…';

  @override
  String get upToDate => 'You\'re on the latest version';

  @override
  String updateAvailable(String version) {
    return 'Version $version is available';
  }

  @override
  String get downloadingUpdate => 'Downloading update…';

  @override
  String get installUpdate => 'Install';

  @override
  String get updateCheckFailed =>
      'Couldn\'t check for updates. Check your internet.';

  @override
  String get installPermissionNeeded =>
      'Allow Hook to install unknown apps, then tap Install again.';

  @override
  String updateSize(String size) {
    return '$size MB';
  }

  @override
  String get download => 'Download';

  @override
  String get downloading => 'Downloading…';

  @override
  String get downloaded => 'Downloaded';

  @override
  String get downloadFailed => 'Couldn\'t download';

  @override
  String get removeDownload => 'Remove download';

  @override
  String get downloadSavedOffline => 'Saved offline';

  @override
  String get startWaveFromTrack => 'Start a wave from this track';

  @override
  String get addToQueue => 'Add to queue';

  @override
  String addedToQueue(String title) {
    return 'Added to queue: $title';
  }

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get addToPlaylist => 'Add to playlist';

  @override
  String get goToArtist => 'Go to artist';

  @override
  String get myPlaylist => 'My playlist';

  @override
  String get newPlaylist => 'New playlist';

  @override
  String get name => 'Name';

  @override
  String get create => 'Create';

  @override
  String get loading => 'Loading…';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Play';

  @override
  String get next => 'Next';

  @override
  String get speedAndPitch => 'Speed and pitch';

  @override
  String speedValue(String value) {
    return 'Speed: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'Pitch: ${value}x';
  }

  @override
  String get reset => 'Reset';

  @override
  String get moreActions => 'More actions';

  @override
  String get playbackQueue => 'Playback queue';

  @override
  String get queueEmpty => 'Queue is empty';

  @override
  String get selectingSource => 'Selecting source';

  @override
  String get collapsePlayer => 'Collapse player';

  @override
  String get nowPlayingUpper => 'NOW PLAYING';

  @override
  String get queue => 'Queue';

  @override
  String get startWave => 'Start wave';

  @override
  String get cover => 'Artwork';

  @override
  String get karaokeLyrics => 'Karaoke lyrics';

  @override
  String get findMusicStart => 'Find music and start playback';

  @override
  String get playbackNotStarted => 'Playback hasn\'t started yet';

  @override
  String get openSearchFirstTrack => 'Open search to find your first track';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => 'On device';

  @override
  String get sourceCatalog => 'Catalog';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'Server';

  @override
  String get serverResolver => 'Resolver server';

  @override
  String get serverResolverCaption =>
      'Optional self-hosted server that resolves full audio streams. The app sends a search query or track ID; the server returns a playback URL. The contract and a reference implementation live in docs/REMOTE_RESOLVER.md.';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'Not configured';

  @override
  String get serverSave => 'Save';

  @override
  String get serverDisable => 'Disable';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Hook';

  @override
  String get onboardingWelcomeCaption =>
      'Music, lyrics and your own visual style. Pick a language to begin — you can change it later in settings.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Continue';

  @override
  String get onboardingStart => 'Start listening';

  @override
  String get onboardingMicrogTitle => 'MicroG and the Google account';

  @override
  String get onboardingMicrogBody =>
      'MicroG re-creates Google services on custom Android ROMs that ship without them. Hook uses those services only for one optional feature: connecting a YouTube account to import your playlists. Music playback never requires MicroG or any Google service.';

  @override
  String get onboardingMicrogNote =>
      'Playback does not depend on MicroG. Connecting an account is optional.';

  @override
  String get onboardingMicrogDownload => 'Download MicroG';

  @override
  String get onboardingMicrogStatusChecking => 'Checking Google services…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'Google services are present on this device ($version). Account import will work out of the box.';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'ReVanced GmsCore detected ($version). The official Google sign-in SDK is not compatible with it, so account connection may not work. Playback is unaffected.';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'Google services were not found. To import playlists from a YouTube account, install MicroG first — or skip this and use Hook without an account.';

  @override
  String lyricsView(String mode) {
    return 'Lyrics view · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'Your reading rhythm';

  @override
  String get lyricsModeSubtitle => 'Three ways to get closer to the song.';

  @override
  String get lyricsModeLines => 'Lines';

  @override
  String get lyricsModeKaraoke => 'Karaoke';

  @override
  String get lyricsModeFocus => 'Focus';

  @override
  String get lyricsModeLinesDescription =>
      'Calm lyrics with the current line highlighted';

  @override
  String get lyricsModeKaraokeDescription =>
      'Words light up smoothly with the vocals';

  @override
  String get lyricsModeFocusDescription => 'One large line. Nothing else';

  @override
  String get lyricsModeSaveFailed => 'Couldn\'t save the lyrics view.';

  @override
  String get lyricsModeFootnote =>
      'Your choice is saved for future songs. Karaoke accuracy depends on the source data: word highlighting is approximate without word-level timing, and lyrics stay still without timestamps.';

  @override
  String get lyricsNotFound => 'Lyrics not found';

  @override
  String get karaokeUnavailable =>
      'Karaoke lyrics aren\'t available for this track';

  @override
  String get unsyncedLyrics => 'Unsynced lyrics';

  @override
  String get wordSyncUpper => 'WORD-BY-WORD SYNC';

  @override
  String get lineSyncUpper => 'LINE-BY-LINE SYNC';

  @override
  String get adjustLyricsSync => 'Adjust lyrics synchronization';

  @override
  String get startsSoon => 'Starting soon';

  @override
  String get musicContinues => 'Music continues';

  @override
  String get decreaseLyricsOffset => 'Decrease offset by 0.1 s';

  @override
  String lyricsOffset(String value) {
    return 'Offset: $value s';
  }

  @override
  String get increaseLyricsOffset => 'Increase offset by 0.1 s';

  @override
  String get hideSetting => 'Hide setting';

  @override
  String get lyricsOffsetSaveFailed => 'Couldn\'t save the lyrics offset.';

  @override
  String get audioForbidden =>
      'The audio server denied access (HTTP 403). The track was found, but its stream is unavailable. A VPN doesn\'t guarantee audio access.';

  @override
  String get fullVersionUnavailable =>
      'No full version was found in the available sources. Check your connection or try again later.';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source couldn\'t play this track. Check your connection or try again later.';
  }

  @override
  String get recentQueriesUpper => 'RECENT QUERIES';

  @override
  String get clearHistory => 'Clear';

  @override
  String get waveFromArtist => 'Artist wave';

  @override
  String get popularTracksUpper => 'POPULAR TRACKS';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks',
      one: '1 track',
      zero: 'no tracks yet',
    );
    return '$_temp0';
  }
}
