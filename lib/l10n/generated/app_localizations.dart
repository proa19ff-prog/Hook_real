import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Hook'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsCaption.
  ///
  /// In en, this message translates to:
  /// **'Changes are saved on this device.'**
  String get settingsCaption;

  /// No description provided for @playerSettings.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get playerSettings;

  /// No description provided for @lyricsAutoHide.
  ///
  /// In en, this message translates to:
  /// **'Hide controls while reading lyrics'**
  String get lyricsAutoHide;

  /// No description provided for @lyricsAutoHideDescription.
  ///
  /// In en, this message translates to:
  /// **'After 10 seconds without interaction, the player panels slide away. Use the restore button to bring them back.'**
  String get lyricsAutoHideDescription;

  /// No description provided for @showPlayerControls.
  ///
  /// In en, this message translates to:
  /// **'Show player controls'**
  String get showPlayerControls;

  /// No description provided for @equalizer.
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get equalizer;

  /// No description provided for @equalizerEnabled.
  ///
  /// In en, this message translates to:
  /// **'Sound processing'**
  String get equalizerEnabled;

  /// No description provided for @equalizerPresets.
  ///
  /// In en, this message translates to:
  /// **'Sound profile'**
  String get equalizerPresets;

  /// No description provided for @equalizerFlat.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get equalizerFlat;

  /// No description provided for @equalizerBass.
  ///
  /// In en, this message translates to:
  /// **'Deep bass'**
  String get equalizerBass;

  /// No description provided for @equalizerVocal.
  ///
  /// In en, this message translates to:
  /// **'Vocals'**
  String get equalizerVocal;

  /// No description provided for @equalizerRock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get equalizerRock;

  /// No description provided for @equalizerElectronic.
  ///
  /// In en, this message translates to:
  /// **'Electronic'**
  String get equalizerElectronic;

  /// No description provided for @equalizerSoft.
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get equalizerSoft;

  /// No description provided for @equalizerCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get equalizerCustom;

  /// No description provided for @equalizerBands.
  ///
  /// In en, this message translates to:
  /// **'Frequency bands'**
  String get equalizerBands;

  /// No description provided for @equalizerBassBoost.
  ///
  /// In en, this message translates to:
  /// **'Bass boost'**
  String get equalizerBassBoost;

  /// No description provided for @equalizerBassUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Additional bass boost is not supported. Use the low-frequency bands.'**
  String get equalizerBassUnsupported;

  /// No description provided for @equalizerPreamp.
  ///
  /// In en, this message translates to:
  /// **'Preamp'**
  String get equalizerPreamp;

  /// No description provided for @equalizerHeadroom.
  ///
  /// In en, this message translates to:
  /// **'Automatic headroom'**
  String get equalizerHeadroom;

  /// No description provided for @equalizerHeadroomDescription.
  ///
  /// In en, this message translates to:
  /// **'Reduces output level when boosting frequencies to leave room for peaks. It is not a limiter.'**
  String get equalizerHeadroomDescription;

  /// No description provided for @equalizerWaiting.
  ///
  /// In en, this message translates to:
  /// **'Start a track to connect the equalizer to its audio session.'**
  String get equalizerWaiting;

  /// No description provided for @equalizerUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Sound processing is currently available on Android only.'**
  String get equalizerUnsupported;

  /// No description provided for @equalizerFailed.
  ///
  /// In en, this message translates to:
  /// **'This device could not enable audio effects. Music can still play without them.'**
  String get equalizerFailed;

  /// No description provided for @equalizerRetry.
  ///
  /// In en, this message translates to:
  /// **'Reconnect effects'**
  String get equalizerRetry;

  /// No description provided for @equalizerLive.
  ///
  /// In en, this message translates to:
  /// **'Changes apply immediately and are saved on this device.'**
  String get equalizerLive;

  /// No description provided for @youtubeAccount.
  ///
  /// In en, this message translates to:
  /// **'YouTube & MicroG'**
  String get youtubeAccount;

  /// No description provided for @youtubeAccountReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read-only playlist access. Signing in does not guarantee audio availability.'**
  String get youtubeAccountReadOnly;

  /// No description provided for @youtubeAccountCompatibility.
  ///
  /// In en, this message translates to:
  /// **'Compatibility and privacy'**
  String get youtubeAccountCompatibility;

  /// No description provided for @youtubeAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account connection and playlist import'**
  String get youtubeAccountSubtitle;

  /// No description provided for @youtubeAccountPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Hook requests read-only YouTube access. Enter your password only in Google\'s system dialog, never in Hook. The token is not sent to a Hook server and is kept only in memory. Reconnect after restarting the app.'**
  String get youtubeAccountPrivacy;

  /// No description provided for @youtubeAccountPlaybackNotice.
  ///
  /// In en, this message translates to:
  /// **'Signing in grants access to account data, not audio streams. It does not guarantee a fix for HTTP 403. Imports preserve YouTube recordings without substituting another source.'**
  String get youtubeAccountPlaybackNotice;

  /// No description provided for @youtubeAccountConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect account'**
  String get youtubeAccountConnect;

  /// No description provided for @youtubeAccountDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect in Hook'**
  String get youtubeAccountDisconnect;

  /// No description provided for @youtubeAccountDisconnected.
  ///
  /// In en, this message translates to:
  /// **'No account connected'**
  String get youtubeAccountDisconnected;

  /// No description provided for @youtubeAccountDisconnectNotice.
  ///
  /// In en, this message translates to:
  /// **'Disconnect this account in Hook only? Saved playlists will remain. Google and MicroG accounts on the phone will not be signed out.'**
  String get youtubeAccountDisconnectNotice;

  /// No description provided for @youtubeAccountSystem.
  ///
  /// In en, this message translates to:
  /// **'System Google APIs'**
  String get youtubeAccountSystem;

  /// No description provided for @youtubeAccountServicesMissing.
  ///
  /// In en, this message translates to:
  /// **'Compatible system Google APIs are unavailable. A separate ReVanced GmsCore installation does not replace them for Hook sign-in.'**
  String get youtubeAccountServicesMissing;

  /// No description provided for @youtubeAccountMicrogNotice.
  ///
  /// In en, this message translates to:
  /// **'A separate ReVanced GmsCore installation was detected. Hook does not use ReVanced accounts or tokens. System MicroG may provide compatible Google APIs, but compatibility with this sign-in method is not guaranteed.'**
  String get youtubeAccountMicrogNotice;

  /// No description provided for @youtubeAccountRevancedFound.
  ///
  /// In en, this message translates to:
  /// **'YouTube Music ReVanced is installed'**
  String get youtubeAccountRevancedFound;

  /// No description provided for @youtubeAccountPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Account playlists'**
  String get youtubeAccountPlaylists;

  /// No description provided for @youtubeAccountNoPlaylists.
  ///
  /// In en, this message translates to:
  /// **'No accessible playlists. Some automatic YouTube Music collections are not available through the YouTube Data API.'**
  String get youtubeAccountNoPlaylists;

  /// No description provided for @youtubeAccountMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get youtubeAccountMore;

  /// No description provided for @youtubeAccountPreview.
  ///
  /// In en, this message translates to:
  /// **'Prepare import'**
  String get youtubeAccountPreview;

  /// No description provided for @youtubeAccountProgress.
  ///
  /// In en, this message translates to:
  /// **'Tracks retrieved: {count}'**
  String youtubeAccountProgress(int count);

  /// No description provided for @youtubeAccountUnavailableTracks.
  ///
  /// In en, this message translates to:
  /// **'Unavailable entries skipped: {count}. They are not replaced with other tracks.'**
  String youtubeAccountUnavailableTracks(int count);

  /// No description provided for @youtubeAccountSetup.
  ///
  /// In en, this message translates to:
  /// **'Sign-in setup'**
  String get youtubeAccountSetup;

  /// No description provided for @youtubeAccountSetupBody.
  ///
  /// In en, this message translates to:
  /// **'The developer must enable YouTube Data API v3 in Google Cloud, register an Android OAuth client for com.hook.music and the installed build\'s signing SHA-1, and configure the consent screen. Add permitted users in testing mode. See docs/YOUTUBE_ACCOUNT_SETUP.md. Never add passwords, client secrets, or tokens from other apps.'**
  String get youtubeAccountSetupBody;

  /// No description provided for @youtubeAccountConfigError.
  ///
  /// In en, this message translates to:
  /// **'Sign-in is not configured for this build. Check the Android OAuth client, package name, SHA-1 and permitted test users in Google Cloud.'**
  String get youtubeAccountConfigError;

  /// No description provided for @youtubeAccountPermissionError.
  ///
  /// In en, this message translates to:
  /// **'Read access to YouTube data was not granted.'**
  String get youtubeAccountPermissionError;

  /// No description provided for @youtubeAccountExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Reconnect the account.'**
  String get youtubeAccountExpired;

  /// No description provided for @youtubeAccountNoChannel.
  ///
  /// In en, this message translates to:
  /// **'The selected account has no accessible YouTube channel.'**
  String get youtubeAccountNoChannel;

  /// No description provided for @youtubeAccountQuota.
  ///
  /// In en, this message translates to:
  /// **'YouTube API quota exceeded. Try again later.'**
  String get youtubeAccountQuota;

  /// No description provided for @youtubeAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve YouTube data. Check your connection and try again.'**
  String get youtubeAccountFailed;

  /// No description provided for @youtubeAccountUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Account connection requires Android with compatible system Google APIs.'**
  String get youtubeAccountUnsupported;

  /// No description provided for @importedFromYouTube.
  ///
  /// In en, this message translates to:
  /// **'Imported from YouTube account'**
  String get importedFromYouTube;

  /// No description provided for @translateLyrics.
  ///
  /// In en, this message translates to:
  /// **'Translate lyrics'**
  String get translateLyrics;

  /// No description provided for @hideTranslation.
  ///
  /// In en, this message translates to:
  /// **'Hide translation'**
  String get hideTranslation;

  /// No description provided for @cancelTranslation.
  ///
  /// In en, this message translates to:
  /// **'Cancel translation'**
  String get cancelTranslation;

  /// No description provided for @translationLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing translation…'**
  String get translationLoading;

  /// No description provided for @translationAttribution.
  ///
  /// In en, this message translates to:
  /// **'Automatically translated by Google Translate'**
  String get translationAttribution;

  /// No description provided for @translationNotice.
  ///
  /// In en, this message translates to:
  /// **'Translation may not capture the song\'s meaning accurately. Word highlighting applies only to the original.'**
  String get translationNotice;

  /// No description provided for @translationModelTitle.
  ///
  /// In en, this message translates to:
  /// **'Download language models?'**
  String get translationModelTitle;

  /// No description provided for @translationModelBody.
  ///
  /// In en, this message translates to:
  /// **'Translation runs on your phone: lyrics are not sent to a server. The first translation needs Google ML Kit models, taking tens of megabytes. The download uses your current connection, including mobile data. Cancelling hides the result, but a model download already started may finish in the background.'**
  String get translationModelBody;

  /// No description provided for @translationDownload.
  ///
  /// In en, this message translates to:
  /// **'Download and translate'**
  String get translationDownload;

  /// No description provided for @translationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Translation failed. Check access to model downloads and try again.'**
  String get translationUnavailable;

  /// No description provided for @translationUnsupported.
  ///
  /// In en, this message translates to:
  /// **'On-device translation is currently available on Android only.'**
  String get translationUnsupported;

  /// No description provided for @translationUnknownLanguage.
  ///
  /// In en, this message translates to:
  /// **'Could not identify a supported language for this song.'**
  String get translationUnknownLanguage;

  /// No description provided for @translationSameLanguage.
  ///
  /// In en, this message translates to:
  /// **'The lyrics are already in the selected language.'**
  String get translationSameLanguage;

  /// No description provided for @translationTooLarge.
  ///
  /// In en, this message translates to:
  /// **'These lyrics are too long for on-device translation.'**
  String get translationTooLarge;

  /// No description provided for @translationRussian.
  ///
  /// In en, this message translates to:
  /// **'To Russian'**
  String get translationRussian;

  /// No description provided for @translationEnglish.
  ///
  /// In en, this message translates to:
  /// **'To English'**
  String get translationEnglish;

  /// No description provided for @translationTarget.
  ///
  /// In en, this message translates to:
  /// **'Translation language'**
  String get translationTarget;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @youtubeUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'YouTube is currently unavailable'**
  String get youtubeUnavailableTitle;

  /// No description provided for @youtubeUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t obtain an audio stream. Check your network and VPN route: YouTube may reject requests even with a VPN.'**
  String get youtubeUnavailableBody;

  /// No description provided for @checkAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get checkAgain;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get goodNight;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @themeSettings.
  ///
  /// In en, this message translates to:
  /// **'Appearance settings'**
  String get themeSettings;

  /// No description provided for @onYourAir.
  ///
  /// In en, this message translates to:
  /// **'On your air'**
  String get onYourAir;

  /// No description provided for @recentSignals.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No recent signals} =1{1 recent signal} other{{count} recent signals}}'**
  String recentSignals(int count);

  /// No description provided for @collectionWaiting.
  ///
  /// In en, this message translates to:
  /// **'Your collection is waiting'**
  String get collectionWaiting;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @collectionEmptyDetail.
  ///
  /// In en, this message translates to:
  /// **'Music you want to return to will stay here'**
  String get collectionEmptyDetail;

  /// No description provided for @tracksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 track} other{{count} tracks}}'**
  String tracksCount(int count);

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Track, artist, or lyrics'**
  String get homeSearchHint;

  /// No description provided for @searchUpper.
  ///
  /// In en, this message translates to:
  /// **'SEARCH'**
  String get searchUpper;

  /// No description provided for @findFirstTrack.
  ///
  /// In en, this message translates to:
  /// **'Find your first track'**
  String get findFirstTrack;

  /// No description provided for @continuationAfter.
  ///
  /// In en, this message translates to:
  /// **'More music after {artist}'**
  String continuationAfter(String artist);

  /// No description provided for @chooseTrackWaveDetail.
  ///
  /// In en, this message translates to:
  /// **'Choose a track and we\'ll build a wave around its mood.'**
  String get chooseTrackWaveDetail;

  /// No description provided for @continueWaveLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE / 01'**
  String get continueWaveLabel;

  /// No description provided for @yourWaveLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR WAVE / 01'**
  String get yourWaveLabel;

  /// No description provided for @continueWave.
  ///
  /// In en, this message translates to:
  /// **'Continue wave'**
  String get continueWave;

  /// No description provided for @chooseTrack.
  ///
  /// In en, this message translates to:
  /// **'Choose a track'**
  String get chooseTrack;

  /// No description provided for @firstTrace.
  ///
  /// In en, this message translates to:
  /// **'Leave your first trace here'**
  String get firstTrace;

  /// No description provided for @favoriteWaveHint.
  ///
  /// In en, this message translates to:
  /// **'Save favorites and your wave will become more accurate.'**
  String get favoriteWaveHint;

  /// No description provided for @openSearch.
  ///
  /// In en, this message translates to:
  /// **'Open search'**
  String get openSearch;

  /// No description provided for @findYourMusic.
  ///
  /// In en, this message translates to:
  /// **'Find your sound.'**
  String get findYourMusic;

  /// No description provided for @importMusic.
  ///
  /// In en, this message translates to:
  /// **'Import music'**
  String get importMusic;

  /// No description provided for @rememberedLyricsHint.
  ///
  /// In en, this message translates to:
  /// **'The words you remember…'**
  String get rememberedLyricsHint;

  /// No description provided for @trackArtistHint.
  ///
  /// In en, this message translates to:
  /// **'Track or artist — any language'**
  String get trackArtistHint;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @byLyrics.
  ///
  /// In en, this message translates to:
  /// **'By lyrics'**
  String get byLyrics;

  /// No description provided for @allSources.
  ///
  /// In en, this message translates to:
  /// **'All sources'**
  String get allSources;

  /// No description provided for @lyricsSearchCaption.
  ///
  /// In en, this message translates to:
  /// **'Search for a phrase in a song, not just its title.'**
  String get lyricsSearchCaption;

  /// No description provided for @searchingLyrics.
  ///
  /// In en, this message translates to:
  /// **'Looking for familiar lines…'**
  String get searchingLyrics;

  /// No description provided for @searchingSources.
  ///
  /// In en, this message translates to:
  /// **'Searching music sources…'**
  String get searchingSources;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect'**
  String get connectionFailed;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches yet'**
  String get noMatches;

  /// No description provided for @lyricsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Lyrics search is unavailable right now. Try later or search by title.'**
  String get lyricsUnavailable;

  /// No description provided for @searchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Search failed. Check your connection and try again.'**
  String get searchUnavailable;

  /// No description provided for @lyricsNoMatches.
  ///
  /// In en, this message translates to:
  /// **'Try another line. Not every lyric is indexed.'**
  String get lyricsNoMatches;

  /// No description provided for @trackNoMatches.
  ///
  /// In en, this message translates to:
  /// **'Add the artist or choose another source. Some services may be unavailable on your network.'**
  String get trackNoMatches;

  /// No description provided for @repeatSearch.
  ///
  /// In en, this message translates to:
  /// **'Search again'**
  String get repeatSearch;

  /// No description provided for @lyricMatchesUpper.
  ///
  /// In en, this message translates to:
  /// **'LYRIC MATCHES'**
  String get lyricMatchesUpper;

  /// No description provided for @tracksUpper.
  ///
  /// In en, this message translates to:
  /// **'TRACKS'**
  String get tracksUpper;

  /// No description provided for @playTrack.
  ///
  /// In en, this message translates to:
  /// **'Play {title}, {artist}'**
  String playTrack(String title, String artist);

  /// No description provided for @familiarLinesUpper.
  ///
  /// In en, this message translates to:
  /// **'FAMILIAR LINES'**
  String get familiarLinesUpper;

  /// No description provided for @bestMatchUpper.
  ///
  /// In en, this message translates to:
  /// **'BEST MATCH'**
  String get bestMatchUpper;

  /// No description provided for @fullVersionOnPlayback.
  ///
  /// In en, this message translates to:
  /// **'We\'ll find the full version when playback starts.'**
  String get fullVersionOnPlayback;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot the title.\nNot the music.'**
  String get forgotTitle;

  /// No description provided for @startAsYouRemember.
  ///
  /// In en, this message translates to:
  /// **'A name, title, or line from a song.\nStart with whatever you remember.'**
  String get startAsYouRemember;

  /// No description provided for @foreignNameExample.
  ///
  /// In en, this message translates to:
  /// **'Martin Rose'**
  String get foreignNameExample;

  /// No description provided for @foreignNamesCaption.
  ///
  /// In en, this message translates to:
  /// **'Search names the way they sound'**
  String get foreignNamesCaption;

  /// No description provided for @rememberOnlyLine.
  ///
  /// In en, this message translates to:
  /// **'I only remember a line'**
  String get rememberOnlyLine;

  /// No description provided for @findSongByWords.
  ///
  /// In en, this message translates to:
  /// **'Find a song by its words'**
  String get findSongByWords;

  /// No description provided for @yourArtistsUpper.
  ///
  /// In en, this message translates to:
  /// **'YOUR ARTISTS'**
  String get yourArtistsUpper;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageCaption.
  ///
  /// In en, this message translates to:
  /// **'The interface follows your choice immediately'**
  String get languageCaption;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemLanguage;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @themesAndShaders.
  ///
  /// In en, this message translates to:
  /// **'Themes and effects'**
  String get themesAndShaders;

  /// No description provided for @themesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance, language and background motion'**
  String get themesSubtitle;

  /// No description provided for @invalidThemeJson.
  ///
  /// In en, this message translates to:
  /// **'Could not read the theme. Check the JSON format and field values.'**
  String get invalidThemeJson;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJson;

  /// No description provided for @importJson.
  ///
  /// In en, this message translates to:
  /// **'Import JSON'**
  String get importJson;

  /// No description provided for @readyThemes.
  ///
  /// In en, this message translates to:
  /// **'Theme presets'**
  String get readyThemes;

  /// No description provided for @gpuShaders.
  ///
  /// In en, this message translates to:
  /// **'Background effects'**
  String get gpuShaders;

  /// No description provided for @meshGradient.
  ///
  /// In en, this message translates to:
  /// **'Smooth GPU gradient based on track colors'**
  String get meshGradient;

  /// No description provided for @vinylNoise.
  ///
  /// In en, this message translates to:
  /// **'Analog vinyl grain (Noise)'**
  String get vinylNoise;

  /// No description provided for @glassBlur.
  ///
  /// In en, this message translates to:
  /// **'Glass blur (Backdrop Blur)'**
  String get glassBlur;

  /// No description provided for @cornerRadius.
  ///
  /// In en, this message translates to:
  /// **'Interface corner radius'**
  String get cornerRadius;

  /// No description provided for @importThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Import theme from JSON'**
  String get importThemeTitle;

  /// No description provided for @pasteThemeJson.
  ///
  /// In en, this message translates to:
  /// **'Paste the theme JSON configuration:'**
  String get pasteThemeJson;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @themeApplied.
  ///
  /// In en, this message translates to:
  /// **'Theme applied successfully!'**
  String get themeApplied;

  /// No description provided for @exportThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Export theme (JSON)'**
  String get exportThemeTitle;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @copyJson.
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get copyJson;

  /// No description provided for @jsonCopied.
  ///
  /// In en, this message translates to:
  /// **'Theme JSON copied to clipboard!'**
  String get jsonCopied;

  /// No description provided for @libraryUpper.
  ///
  /// In en, this message translates to:
  /// **'LIBRARY'**
  String get libraryUpper;

  /// No description provided for @localCollection.
  ///
  /// In en, this message translates to:
  /// **'Local collection and playlists'**
  String get localCollection;

  /// No description provided for @importShort.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importShort;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your favorites are empty.\nTap the heart on a track to add it here.'**
  String get favoritesEmpty;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your listening history is empty.\nPlay music from search and it will appear here.'**
  String get historyEmpty;

  /// No description provided for @noPlaylists.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any playlists yet'**
  String get noPlaylists;

  /// No description provided for @importPlaylistHint.
  ///
  /// In en, this message translates to:
  /// **'Import a Spotify playlist or paste a track list.'**
  String get importPlaylistHint;

  /// No description provided for @importMusicAction.
  ///
  /// In en, this message translates to:
  /// **'Import music'**
  String get importMusicAction;

  /// No description provided for @playPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Play playlist'**
  String get playPlaylist;

  /// No description provided for @playlistStarted.
  ///
  /// In en, this message translates to:
  /// **'Playing “{name}” ({count} tracks)'**
  String playlistStarted(String name, int count);

  /// No description provided for @deletePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist'**
  String get deletePlaylist;

  /// No description provided for @playAll.
  ///
  /// In en, this message translates to:
  /// **'Play all'**
  String get playAll;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @localAudioCache.
  ///
  /// In en, this message translates to:
  /// **'Local audio cache'**
  String get localAudioCache;

  /// No description provided for @cacheDescription.
  ///
  /// In en, this message translates to:
  /// **'Played tracks are stored locally for instant replay without an internet connection.'**
  String get cacheDescription;

  /// No description provided for @deviceUsage.
  ///
  /// In en, this message translates to:
  /// **'On this device: {size}'**
  String deviceUsage(String size);

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear all cache'**
  String get clearCache;

  /// No description provided for @savedTracksUpper.
  ///
  /// In en, this message translates to:
  /// **'SAVED TRACKS ({count}):'**
  String savedTracksUpper(int count);

  /// No description provided for @cacheFeaturesUpper.
  ///
  /// In en, this message translates to:
  /// **'CACHE FEATURES:'**
  String get cacheFeaturesUpper;

  /// No description provided for @offlineFirst.
  ///
  /// In en, this message translates to:
  /// **'Fully offline-first'**
  String get offlineFirst;

  /// No description provided for @offlineFirstDescription.
  ///
  /// In en, this message translates to:
  /// **'On replay, audio loads directly from the device file system.'**
  String get offlineFirstDescription;

  /// No description provided for @maximumBitrate.
  ///
  /// In en, this message translates to:
  /// **'Maximum bitrate'**
  String get maximumBitrate;

  /// No description provided for @maximumBitrateDescription.
  ///
  /// In en, this message translates to:
  /// **'Clean Opus/M4A streams at 160–256 kbps are cached without transcoding.'**
  String get maximumBitrateDescription;

  /// No description provided for @trafficAndBattery.
  ///
  /// In en, this message translates to:
  /// **'Save data and battery'**
  String get trafficAndBattery;

  /// No description provided for @trafficAndBatteryDescription.
  ///
  /// In en, this message translates to:
  /// **'Avoiding repeated network requests helps your phone last longer.'**
  String get trafficAndBatteryDescription;

  /// No description provided for @cacheEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cache is empty'**
  String get cacheEmpty;

  /// No description provided for @cachedTracksAppear.
  ///
  /// In en, this message translates to:
  /// **'Downloaded tracks will appear here automatically'**
  String get cachedTracksAppear;

  /// No description provided for @removeFromCache.
  ///
  /// In en, this message translates to:
  /// **'Remove from cache'**
  String get removeFromCache;

  /// No description provided for @removeCachedTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove track from cache?'**
  String get removeCachedTrackTitle;

  /// No description provided for @removeCachedTrackBody.
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be removed from this device.'**
  String removeCachedTrackBody(String title);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @trackRemovedFromCache.
  ///
  /// In en, this message translates to:
  /// **'Track removed from cache'**
  String get trackRemovedFromCache;

  /// No description provided for @clearCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear cache?'**
  String get clearCacheTitle;

  /// No description provided for @clearCacheBody.
  ///
  /// In en, this message translates to:
  /// **'All saved audio files will be removed from this device. Favorites and history won\'t change.'**
  String get clearCacheBody;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Local cache cleared'**
  String get cacheCleared;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @playlistActions.
  ///
  /// In en, this message translates to:
  /// **'Playlist actions'**
  String get playlistActions;

  /// No description provided for @playlistUpper.
  ///
  /// In en, this message translates to:
  /// **'PLAYLIST'**
  String get playlistUpper;

  /// No description provided for @playlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no tracks in this playlist yet'**
  String get playlistEmpty;

  /// No description provided for @pasteTrackList.
  ///
  /// In en, this message translates to:
  /// **'Paste a track list'**
  String get pasteTrackList;

  /// No description provided for @pasteImportLink.
  ///
  /// In en, this message translates to:
  /// **'Paste a link to import'**
  String get pasteImportLink;

  /// No description provided for @tracksNotFound.
  ///
  /// In en, this message translates to:
  /// **'No tracks were found at that link.'**
  String get tracksNotFound;

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Check the link and your internet connection.'**
  String get importError;

  /// No description provided for @importedPlaylistStarted.
  ///
  /// In en, this message translates to:
  /// **'Playing imported playlist ({count} tracks)'**
  String importedPlaylistStarted(int count);

  /// No description provided for @importedPlaylistName.
  ///
  /// In en, this message translates to:
  /// **'Import ({platform})'**
  String importedPlaylistName(String platform);

  /// No description provided for @playlistSaved.
  ///
  /// In en, this message translates to:
  /// **'Playlist “{name}” saved to your library!'**
  String playlistSaved(String name);

  /// No description provided for @spotifyImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Spotify • Playlists, albums, and tracks'**
  String get spotifyImportSubtitle;

  /// No description provided for @artistTrackOrCsv.
  ///
  /// In en, this message translates to:
  /// **'Artist — Track, or an Exportify CSV'**
  String get artistTrackOrCsv;

  /// No description provided for @pastePlaylistOrTrackLink.
  ///
  /// In en, this message translates to:
  /// **'Paste a playlist or track link'**
  String get pastePlaylistOrTrackLink;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get pasteFromClipboard;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @trackList.
  ///
  /// In en, this message translates to:
  /// **'Track list'**
  String get trackList;

  /// No description provided for @playlistName.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistName;

  /// No description provided for @startImport.
  ///
  /// In en, this message translates to:
  /// **'Start import'**
  String get startImport;

  /// No description provided for @importedCollectionMeta.
  ///
  /// In en, this message translates to:
  /// **'{author} • {count} tracks'**
  String importedCollectionMeta(String author, int count);

  /// No description provided for @importedFromSpotify.
  ///
  /// In en, this message translates to:
  /// **'Imported from Spotify'**
  String get importedFromSpotify;

  /// No description provided for @importIntro.
  ///
  /// In en, this message translates to:
  /// **'Bring your playlists with you. Use a Spotify link, a track list, or an Exportify file.'**
  String get importIntro;

  /// No description provided for @importTextTab.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get importTextTab;

  /// No description provided for @importFileTab.
  ///
  /// In en, this message translates to:
  /// **'CSV / TXT'**
  String get importFileTab;

  /// No description provided for @importChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get importChooseFile;

  /// No description provided for @importFileHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the CSV exported by Exportify, or a TXT track list. UTF-8, up to 10 MB and 10,000 tracks.'**
  String get importFileHint;

  /// No description provided for @importFileAndroidOnly.
  ///
  /// In en, this message translates to:
  /// **'File selection is available on Android. Here you can paste the contents of a CSV or track list.'**
  String get importFileAndroidOnly;

  /// No description provided for @importTextHint.
  ///
  /// In en, this message translates to:
  /// **'One Artist — Track per line. You can also paste the full CSV, including its header.'**
  String get importTextHint;

  /// No description provided for @importPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview tracks'**
  String get importPreview;

  /// No description provided for @importedFromCsv.
  ///
  /// In en, this message translates to:
  /// **'Imported from CSV'**
  String get importedFromCsv;

  /// No description provided for @importedFromText.
  ///
  /// In en, this message translates to:
  /// **'Imported from a track list'**
  String get importedFromText;

  /// No description provided for @importMoreTracks.
  ///
  /// In en, this message translates to:
  /// **'And {count} more'**
  String importMoreTracks(int count);

  /// No description provided for @importMetadataHint.
  ///
  /// In en, this message translates to:
  /// **'The playlist is saved on this device. Audio is found when you play a track; importing does not download songs.'**
  String get importMetadataHint;

  /// No description provided for @importAnother.
  ///
  /// In en, this message translates to:
  /// **'Import something else'**
  String get importAnother;

  /// No description provided for @importReading.
  ///
  /// In en, this message translates to:
  /// **'Reading your playlist…'**
  String get importReading;

  /// No description provided for @importSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving to your library…'**
  String get importSaving;

  /// No description provided for @importNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a playlist name.'**
  String get importNameRequired;

  /// No description provided for @importNameExists.
  ///
  /// In en, this message translates to:
  /// **'A playlist with this name already exists. Choose another name to keep both.'**
  String get importNameExists;

  /// No description provided for @importSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the playlist. Your preview is still here — try again.'**
  String get importSaveFailed;

  /// No description provided for @importFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This file is larger than 10 MB. Split the playlist into smaller exports.'**
  String get importFileTooLarge;

  /// No description provided for @importFileUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Choose a .csv or .txt file.'**
  String get importFileUnsupported;

  /// No description provided for @importFileEncoding.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the text encoding. Save the file as UTF-8 and try again.'**
  String get importFileEncoding;

  /// No description provided for @importCsvInvalid.
  ///
  /// In en, this message translates to:
  /// **'The CSV is incomplete or malformed. Export it again without editing its columns or quotation marks.'**
  String get importCsvInvalid;

  /// No description provided for @importCsvMissingColumns.
  ///
  /// In en, this message translates to:
  /// **'The CSV needs Track Name and Artist Name(s) columns, or Title and Artist. Choose the original Exportify export.'**
  String get importCsvMissingColumns;

  /// No description provided for @importFileEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tracks were found. Choose a populated export or paste an Artist — Track list.'**
  String get importFileEmpty;

  /// No description provided for @importTooManyTracks.
  ///
  /// In en, this message translates to:
  /// **'A single import can contain up to 10,000 tracks. Split this playlist; nothing has been saved yet.'**
  String get importTooManyTracks;

  /// No description provided for @importFileReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open this file. Check that it is available on your device and choose it again.'**
  String get importFileReadFailed;

  /// No description provided for @importSpotifyBlocked.
  ///
  /// In en, this message translates to:
  /// **'Spotify didn\'t share this playlist in your region. Export it with Exportify and choose the CSV file instead.'**
  String get importSpotifyBlocked;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get listen;

  /// No description provided for @addToPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Add to playlists'**
  String get addToPlaylists;

  /// No description provided for @trackSemantics.
  ///
  /// In en, this message translates to:
  /// **'Track {title}, {artist}'**
  String trackSemantics(String title, String artist);

  /// No description provided for @trackActions.
  ///
  /// In en, this message translates to:
  /// **'Track actions'**
  String get trackActions;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get downloading;

  /// No description provided for @downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaded;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t download'**
  String get downloadFailed;

  /// No description provided for @removeDownload.
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get removeDownload;

  /// No description provided for @downloadSavedOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved offline'**
  String get downloadSavedOffline;

  /// No description provided for @startWaveFromTrack.
  ///
  /// In en, this message translates to:
  /// **'Start a wave from this track'**
  String get startWaveFromTrack;

  /// No description provided for @addToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get addToQueue;

  /// No description provided for @addedToQueue.
  ///
  /// In en, this message translates to:
  /// **'Added to queue: {title}'**
  String addedToQueue(String title);

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFavorite;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addFavorite;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get addToPlaylist;

  /// No description provided for @goToArtist.
  ///
  /// In en, this message translates to:
  /// **'Go to artist'**
  String get goToArtist;

  /// No description provided for @myPlaylist.
  ///
  /// In en, this message translates to:
  /// **'My playlist'**
  String get myPlaylist;

  /// No description provided for @newPlaylist.
  ///
  /// In en, this message translates to:
  /// **'New playlist'**
  String get newPlaylist;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @speedAndPitch.
  ///
  /// In en, this message translates to:
  /// **'Speed and pitch'**
  String get speedAndPitch;

  /// No description provided for @speedValue.
  ///
  /// In en, this message translates to:
  /// **'Speed: {value}x'**
  String speedValue(String value);

  /// No description provided for @pitchValue.
  ///
  /// In en, this message translates to:
  /// **'Pitch: {value}x'**
  String pitchValue(String value);

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @playbackQueue.
  ///
  /// In en, this message translates to:
  /// **'Playback queue'**
  String get playbackQueue;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Queue is empty'**
  String get queueEmpty;

  /// No description provided for @selectingSource.
  ///
  /// In en, this message translates to:
  /// **'Selecting source'**
  String get selectingSource;

  /// No description provided for @collapsePlayer.
  ///
  /// In en, this message translates to:
  /// **'Collapse player'**
  String get collapsePlayer;

  /// No description provided for @nowPlayingUpper.
  ///
  /// In en, this message translates to:
  /// **'NOW PLAYING'**
  String get nowPlayingUpper;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @startWave.
  ///
  /// In en, this message translates to:
  /// **'Start wave'**
  String get startWave;

  /// No description provided for @cover.
  ///
  /// In en, this message translates to:
  /// **'Artwork'**
  String get cover;

  /// No description provided for @karaokeLyrics.
  ///
  /// In en, this message translates to:
  /// **'Karaoke lyrics'**
  String get karaokeLyrics;

  /// No description provided for @findMusicStart.
  ///
  /// In en, this message translates to:
  /// **'Find music and start playback'**
  String get findMusicStart;

  /// No description provided for @playbackNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Playback hasn\'t started yet'**
  String get playbackNotStarted;

  /// No description provided for @openSearchFirstTrack.
  ///
  /// In en, this message translates to:
  /// **'Open search to find your first track'**
  String get openSearchFirstTrack;

  /// No description provided for @sourceSoundCloud.
  ///
  /// In en, this message translates to:
  /// **'SoundCloud'**
  String get sourceSoundCloud;

  /// No description provided for @sourceDevice.
  ///
  /// In en, this message translates to:
  /// **'On device'**
  String get sourceDevice;

  /// No description provided for @sourceCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get sourceCatalog;

  /// No description provided for @sourceYouTube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get sourceYouTube;

  /// No description provided for @sourceAudius.
  ///
  /// In en, this message translates to:
  /// **'Audius'**
  String get sourceAudius;

  /// No description provided for @sourceServer.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get sourceServer;

  /// No description provided for @serverResolver.
  ///
  /// In en, this message translates to:
  /// **'Resolver server'**
  String get serverResolver;

  /// No description provided for @serverResolverCaption.
  ///
  /// In en, this message translates to:
  /// **'Optional self-hosted server that resolves full audio streams. The app sends a search query or track ID; the server returns a playback URL. The contract and a reference implementation live in docs/REMOTE_RESOLVER.md.'**
  String get serverResolverCaption;

  /// No description provided for @serverResolverHint.
  ///
  /// In en, this message translates to:
  /// **'https://hook-resolver.example.com'**
  String get serverResolverHint;

  /// No description provided for @serverResolverDisabled.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get serverResolverDisabled;

  /// No description provided for @serverSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get serverSave;

  /// No description provided for @serverDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get serverDisable;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Hook'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeCaption.
  ///
  /// In en, this message translates to:
  /// **'Music, lyrics and your own visual style. Pick a language to begin — you can change it later in settings.'**
  String get onboardingWelcomeCaption;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start listening'**
  String get onboardingStart;

  /// No description provided for @onboardingMicrogTitle.
  ///
  /// In en, this message translates to:
  /// **'MicroG and the Google account'**
  String get onboardingMicrogTitle;

  /// No description provided for @onboardingMicrogBody.
  ///
  /// In en, this message translates to:
  /// **'MicroG re-creates Google services on custom Android ROMs that ship without them. Hook uses those services only for one optional feature: connecting a YouTube account to import your playlists. Music playback never requires MicroG or any Google service.'**
  String get onboardingMicrogBody;

  /// No description provided for @onboardingMicrogNote.
  ///
  /// In en, this message translates to:
  /// **'Playback does not depend on MicroG. Connecting an account is optional.'**
  String get onboardingMicrogNote;

  /// No description provided for @onboardingMicrogDownload.
  ///
  /// In en, this message translates to:
  /// **'Download MicroG'**
  String get onboardingMicrogDownload;

  /// No description provided for @onboardingMicrogStatusChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking Google services…'**
  String get onboardingMicrogStatusChecking;

  /// No description provided for @onboardingMicrogStatusOk.
  ///
  /// In en, this message translates to:
  /// **'Google services are present on this device ({version}). Account import will work out of the box.'**
  String onboardingMicrogStatusOk(String version);

  /// No description provided for @onboardingMicrogStatusReVanced.
  ///
  /// In en, this message translates to:
  /// **'ReVanced GmsCore detected ({version}). The official Google sign-in SDK is not compatible with it, so account connection may not work. Playback is unaffected.'**
  String onboardingMicrogStatusReVanced(String version);

  /// No description provided for @onboardingMicrogStatusMissing.
  ///
  /// In en, this message translates to:
  /// **'Google services were not found. To import playlists from a YouTube account, install MicroG first — or skip this and use Hook without an account.'**
  String get onboardingMicrogStatusMissing;

  /// No description provided for @lyricsView.
  ///
  /// In en, this message translates to:
  /// **'Lyrics view · {mode}'**
  String lyricsView(String mode);

  /// No description provided for @lyricsReadingRhythm.
  ///
  /// In en, this message translates to:
  /// **'Your reading rhythm'**
  String get lyricsReadingRhythm;

  /// No description provided for @lyricsModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Three ways to get closer to the song.'**
  String get lyricsModeSubtitle;

  /// No description provided for @lyricsModeLines.
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get lyricsModeLines;

  /// No description provided for @lyricsModeKaraoke.
  ///
  /// In en, this message translates to:
  /// **'Karaoke'**
  String get lyricsModeKaraoke;

  /// No description provided for @lyricsModeFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get lyricsModeFocus;

  /// No description provided for @lyricsModeLinesDescription.
  ///
  /// In en, this message translates to:
  /// **'Calm lyrics with the current line highlighted'**
  String get lyricsModeLinesDescription;

  /// No description provided for @lyricsModeKaraokeDescription.
  ///
  /// In en, this message translates to:
  /// **'Words light up smoothly with the vocals'**
  String get lyricsModeKaraokeDescription;

  /// No description provided for @lyricsModeFocusDescription.
  ///
  /// In en, this message translates to:
  /// **'One large line. Nothing else'**
  String get lyricsModeFocusDescription;

  /// No description provided for @lyricsModeSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the lyrics view.'**
  String get lyricsModeSaveFailed;

  /// No description provided for @lyricsModeFootnote.
  ///
  /// In en, this message translates to:
  /// **'Your choice is saved for future songs. Karaoke accuracy depends on the source data: word highlighting is approximate without word-level timing, and lyrics stay still without timestamps.'**
  String get lyricsModeFootnote;

  /// No description provided for @lyricsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Lyrics not found'**
  String get lyricsNotFound;

  /// No description provided for @karaokeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Karaoke lyrics aren\'t available for this track'**
  String get karaokeUnavailable;

  /// No description provided for @unsyncedLyrics.
  ///
  /// In en, this message translates to:
  /// **'Unsynced lyrics'**
  String get unsyncedLyrics;

  /// No description provided for @wordSyncUpper.
  ///
  /// In en, this message translates to:
  /// **'WORD-BY-WORD SYNC'**
  String get wordSyncUpper;

  /// No description provided for @lineSyncUpper.
  ///
  /// In en, this message translates to:
  /// **'LINE-BY-LINE SYNC'**
  String get lineSyncUpper;

  /// No description provided for @adjustLyricsSync.
  ///
  /// In en, this message translates to:
  /// **'Adjust lyrics synchronization'**
  String get adjustLyricsSync;

  /// No description provided for @startsSoon.
  ///
  /// In en, this message translates to:
  /// **'Starting soon'**
  String get startsSoon;

  /// No description provided for @musicContinues.
  ///
  /// In en, this message translates to:
  /// **'Music continues'**
  String get musicContinues;

  /// No description provided for @decreaseLyricsOffset.
  ///
  /// In en, this message translates to:
  /// **'Decrease offset by 0.1 s'**
  String get decreaseLyricsOffset;

  /// No description provided for @lyricsOffset.
  ///
  /// In en, this message translates to:
  /// **'Offset: {value} s'**
  String lyricsOffset(String value);

  /// No description provided for @increaseLyricsOffset.
  ///
  /// In en, this message translates to:
  /// **'Increase offset by 0.1 s'**
  String get increaseLyricsOffset;

  /// No description provided for @hideSetting.
  ///
  /// In en, this message translates to:
  /// **'Hide setting'**
  String get hideSetting;

  /// No description provided for @lyricsOffsetSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the lyrics offset.'**
  String get lyricsOffsetSaveFailed;

  /// No description provided for @audioForbidden.
  ///
  /// In en, this message translates to:
  /// **'The audio server denied access (HTTP 403). The track was found, but its stream is unavailable. A VPN doesn\'t guarantee audio access.'**
  String get audioForbidden;

  /// No description provided for @fullVersionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No full version was found in the available sources. Check your connection or try again later.'**
  String get fullVersionUnavailable;

  /// No description provided for @sourcePlaybackFailed.
  ///
  /// In en, this message translates to:
  /// **'{source} couldn\'t play this track. Check your connection or try again later.'**
  String sourcePlaybackFailed(String source);

  /// No description provided for @recentQueriesUpper.
  ///
  /// In en, this message translates to:
  /// **'RECENT QUERIES'**
  String get recentQueriesUpper;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearHistory;

  /// No description provided for @waveFromArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist wave'**
  String get waveFromArtist;

  /// No description provided for @popularTracksUpper.
  ///
  /// In en, this message translates to:
  /// **'POPULAR TRACKS'**
  String get popularTracksUpper;

  /// No description provided for @artistTracksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no tracks yet} =1{1 track} other{{count} tracks}}'**
  String artistTracksCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'it',
    'ja',
    'ko',
    'nl',
    'pl',
    'pt',
    'ru',
    'th',
    'tr',
    'uk',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
