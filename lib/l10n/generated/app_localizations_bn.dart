// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'সেটিংস';

  @override
  String get settingsCaption => 'পরিবর্তনগুলি এই ডিভাইসে সংরক্ষিত হয়।';

  @override
  String get playerSettings => 'প্লেয়ার';

  @override
  String get lyricsAutoHide => 'গান পড়ার সময় নিয়ন্ত্রণ লুকান';

  @override
  String get lyricsAutoHideDescription =>
      '১০ সেকেন্ড কোনো ইন্টারঅ্যাকশন না থাকলে প্লেয়ারের প্যানেলগুলি সরে যায়। ফিরিয়ে আনতে রিস্টোর বোতাম ব্যবহার করুন।';

  @override
  String get showPlayerControls => 'প্লেয়ার নিয়ন্ত্রণ দেখান';

  @override
  String get equalizer => 'ইকুয়ালাইজার';

  @override
  String get equalizerEnabled => 'শব্দ প্রসেসিং';

  @override
  String get equalizerPresets => 'শব্দ প্রোফাইল';

  @override
  String get equalizerFlat => 'মূল';

  @override
  String get equalizerBass => 'গভীর বেস';

  @override
  String get equalizerVocal => 'ভোকাল';

  @override
  String get equalizerRock => 'রক';

  @override
  String get equalizerElectronic => 'ইলেকট্রনিক';

  @override
  String get equalizerSoft => 'মৃদু';

  @override
  String get equalizerCustom => 'কাস্টম';

  @override
  String get equalizerBands => 'ফ্রিকোয়েন্সি ব্যান্ড';

  @override
  String get equalizerBassBoost => 'বেস বুস্ট';

  @override
  String get equalizerBassUnsupported =>
      'অতিরিক্ত বেস বুস্ট সমর্থিত নয়। নিম্ন-ফ্রিকোয়েন্সি ব্যান্ড ব্যবহার করুন।';

  @override
  String get equalizerPreamp => 'প্রি-অ্যাম্প';

  @override
  String get equalizerHeadroom => 'স্বয়ংক্রিয় হেডরুম';

  @override
  String get equalizerHeadroomDescription =>
      'শিখরগুলির জন্য জায়গা রাখতে ফ্রিকোয়েন্সি বাড়ানোর সময় আউটপুট স্তর কমায়। এটি লিমিটার নয়।';

  @override
  String get equalizerWaiting =>
      'ইকুয়ালাইজারকে তার অডিও সেশনের সঙ্গে যুক্ত করতে একটি ট্র্যাক চালান।';

  @override
  String get equalizerUnsupported =>
      'শব্দ প্রসেসিং এখন শুধু অ্যান্ড্রয়েডে উপলব্ধ।';

  @override
  String get equalizerFailed =>
      'এই ডিভাইস অডিও ইফেক্ট চালু করতে পারেনি। এগুলি ছাড়াও সংগীত বাজতে পারে।';

  @override
  String get equalizerRetry => 'ইফেক্ট আবার সংযোগ করুন';

  @override
  String get equalizerLive =>
      'পরিবর্তন সঙ্গে সঙ্গে প্রয়োগ হয় এবং এই ডিভাইসে সংরক্ষিত হয়।';

  @override
  String get youtubeAccount => 'YouTube ও MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'প্লেলিস্টে শুধুমাত্র-পাঠের অ্যাক্সেস। সাইন ইন করলেই অডিওর প্রাপ্যতা নিশ্চিত হয় না।';

  @override
  String get youtubeAccountCompatibility => 'সামঞ্জস্য ও গোপনীয়তা';

  @override
  String get youtubeAccountSubtitle => 'অ্যাকাউন্ট সংযোগ ও প্লেলিস্ট আমদানি';

  @override
  String get youtubeAccountPrivacy =>
      'Hook YouTube-এ শুধুমাত্র-পাঠের অ্যাক্সেস চায়। পাসওয়ার্ড কেবল Google-এর সিস্টেম ডায়ালগে দিন, কখনও Hook-এ নয়। টোকেন কোনো Hook সার্ভারে পাঠানো হয় না এবং শুধু মেমোরিতে থাকে। অ্যাপ আবার চালু করার পর পুনরায় সংযোগ করুন।';

  @override
  String get youtubeAccountPlaybackNotice =>
      'সাইন ইন করলে অ্যাকাউন্টের ডেটায় অ্যাক্সেস মেলে, অডিও স্ট্রিমে নয়। এটি HTTP 403 সমাধানের গ্যারান্টি দেয় না। আমদানি YouTube রেকর্ডিং অক্ষুণ্ণ রাখে, অন্য উৎসে বদলায় না।';

  @override
  String get youtubeAccountConnect => 'অ্যাকাউন্ট সংযোগ করুন';

  @override
  String get youtubeAccountDisconnect => 'Hook-এ সংযোগ বিচ্ছিন্ন করুন';

  @override
  String get youtubeAccountDisconnected => 'কোনো অ্যাকাউন্ট সংযুক্ত নেই';

  @override
  String get youtubeAccountDisconnectNotice =>
      'এই অ্যাকাউন্ট শুধু Hook থেকে বিচ্ছিন্ন করবেন? সংরক্ষিত প্লেলিস্ট থেকে যাবে। ফোনের Google ও MicroG অ্যাকাউন্ট সাইন আউট হবে না।';

  @override
  String get youtubeAccountSystem => 'সিস্টেম Google API';

  @override
  String get youtubeAccountServicesMissing =>
      'সামঞ্জস্যপূর্ণ সিস্টেম Google API নেই। আলাদা ইনস্টল করা ReVanced GmsCore Hook-এর সাইন-ইনের জন্য তাদের বদলে দেয় না।';

  @override
  String get youtubeAccountMicrogNotice =>
      'আলাদা ReVanced GmsCore ইনস্টল শনাক্ত হয়েছে। Hook ReVanced অ্যাকাউন্ট বা টোকেন ব্যবহার করে না। সিস্টেম MicroG সামঞ্জস্যপূর্ণ Google API দিতে পারে, তবে এই সাইন-ইন পদ্ধতির সঙ্গে সামঞ্জস্য নিশ্চিত নয়।';

  @override
  String get youtubeAccountRevancedFound => 'YouTube Music ReVanced ইনস্টল আছে';

  @override
  String get youtubeAccountPlaylists => 'অ্যাকাউন্টের প্লেলিস্ট';

  @override
  String get youtubeAccountNoPlaylists =>
      'কোনো প্রবেশযোগ্য প্লেলিস্ট নেই। YouTube Music-এর কিছু স্বয়ংক্রিয় সংগ্রহ YouTube Data API দিয়ে পাওয়া যায় না।';

  @override
  String get youtubeAccountMore => 'আরও লোড করুন';

  @override
  String get youtubeAccountPreview => 'আমদানি প্রস্তুত করুন';

  @override
  String youtubeAccountProgress(int count) {
    return 'প্রাপ্ত ট্র্যাক: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'বাদ পড়া অপ্রাপ্য এন্ট্রি: $count। এগুলি অন্য ট্র্যাকে বদলানো হয় না।';
  }

  @override
  String get youtubeAccountSetup => 'সাইন-ইন সেটআপ';

  @override
  String get youtubeAccountSetupBody =>
      'ডেভেলপারকে Google Cloud-এ YouTube Data API v3 চালু করতে হবে, com.hook.music ও ইনস্টল করা বিল্ডের স্বাক্ষর SHA-1-এর জন্য Android OAuth ক্লায়েন্ট নিবন্ধন করতে হবে এবং সম্মতি স্ক্রিন কনফিগার করতে হবে। টেস্ট মোডে অনুমোদিত ব্যবহারকারী যোগ করুন। দেখুন docs/YOUTUBE_ACCOUNT_SETUP.md। কখনও পাসওয়ার্ড, ক্লায়েন্ট সিক্রেট বা অন্য অ্যাপের টোকেন যোগ করবেন না।';

  @override
  String get youtubeAccountConfigError =>
      'এই বিল্ডের জন্য সাইন-ইন কনফিগার করা নেই। Google Cloud-এ Android OAuth ক্লায়েন্ট, প্যাকেজ নাম, SHA-1 ও অনুমোদিত টেস্ট ব্যবহারকারী পরীক্ষা করুন।';

  @override
  String get youtubeAccountPermissionError =>
      'YouTube ডেটায় পাঠের অ্যাক্সেস দেওয়া হয়নি।';

  @override
  String get youtubeAccountExpired =>
      'আপনার সেশনের মেয়াদ শেষ। অ্যাকাউন্ট পুনরায় সংযোগ করুন।';

  @override
  String get youtubeAccountNoChannel =>
      'নির্বাচিত অ্যাকাউন্টের কোনো প্রবেশযোগ্য YouTube চ্যানেল নেই।';

  @override
  String get youtubeAccountQuota => 'YouTube API কোটা শেষ। পরে চেষ্টা করুন।';

  @override
  String get youtubeAccountFailed =>
      'YouTube ডেটা আনা গেল না। সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';

  @override
  String get youtubeAccountUnsupported =>
      'অ্যাকাউন্ট সংযোগের জন্য সামঞ্জস্যপূর্ণ সিস্টেম Google API-যুক্ত অ্যান্ড্রয়েড দরকার।';

  @override
  String get importedFromYouTube => 'YouTube অ্যাকাউন্ট থেকে আমদানিকৃত';

  @override
  String get translateLyrics => 'গান অনুবাদ করুন';

  @override
  String get hideTranslation => 'অনুবাদ লুকান';

  @override
  String get cancelTranslation => 'অনুবাদ বাতিল করুন';

  @override
  String get translationLoading => 'অনুবাদ প্রস্তুত হচ্ছে…';

  @override
  String get translationAttribution =>
      'Google Translate দ্বারা স্বয়ংক্রিয়ভাবে অনূদিত';

  @override
  String get translationNotice =>
      'অনুবাদ গানের অর্থ সঠিকভাবে ধরতে নাও পারে। শব্দ-হাইলাইটিং শুধু মূলে প্রযোজ্য।';

  @override
  String get translationModelTitle => 'ভাষার মডেল ডাউনলোড করবেন?';

  @override
  String get translationModelBody =>
      'অনুবাদ আপনার ফোনেই চলে: গান কোনো সার্ভারে যায় না। প্রথম অনুবাদের জন্য Google ML Kit মডেল লাগে, যা কয়েক ডজন মেগাবাইট নেয়। ডাউনলোড আপনার বর্তমান সংযোগ ব্যবহার করে, মোবাইল ডেটা সহ। বাতিল করলে ফল লুকায়, তবে শুরু হওয়া মডেল ডাউনলোড ব্যাকগ্রাউন্ডে শেষ হতে পারে।';

  @override
  String get translationDownload => 'ডাউনলোড করে অনুবাদ করুন';

  @override
  String get translationUnavailable =>
      'অনুবাদ ব্যর্থ। মডেল ডাউনলোডের অ্যাক্সেস পরীক্ষা করে আবার চেষ্টা করুন।';

  @override
  String get translationUnsupported =>
      'ডিভাইসে অনুবাদ এখন শুধু অ্যান্ড্রয়েডে উপলব্ধ।';

  @override
  String get translationUnknownLanguage =>
      'এই গানের কোনো সমর্থিত ভাষা শনাক্ত করা গেল না।';

  @override
  String get translationSameLanguage => 'গানটি ইতিমধ্যেই নির্বাচিত ভাষায়।';

  @override
  String get translationTooLarge =>
      'এই গানটি ডিভাইসে অনুবাদের জন্য অতিরিক্ত দীর্ঘ।';

  @override
  String get translationRussian => 'রুশ ভাষায়';

  @override
  String get translationEnglish => 'ইংরেজিতে';

  @override
  String get translationTarget => 'অনুবাদের ভাষা';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get home => 'হোম';

  @override
  String get search => 'খোঁজ';

  @override
  String get library => 'লাইব্রেরি';

  @override
  String get youtubeUnavailableTitle => 'YouTube এই মুহূর্তে অপ্রাপ্য';

  @override
  String get youtubeUnavailableBody =>
      'অডিও স্ট্রিম পাওয়া যায়নি। আপনার নেটওয়ার্ক ও VPN রুট পরীক্ষা করুন: YouTube VPN-সহও অনুরোধ ফেরাতে পারে।';

  @override
  String get checkAgain => 'আবার পরীক্ষা করুন';

  @override
  String get dismiss => 'বন্ধ করুন';

  @override
  String get goodNight => 'শুভ রাত্রি';

  @override
  String get goodMorning => 'শুভ সকাল';

  @override
  String get goodAfternoon => 'শুভ অপরাহ্ন';

  @override
  String get goodEvening => 'শুভ সন্ধ্যা';

  @override
  String get themeSettings => 'চেহারার সেটিংস';

  @override
  String get onYourAir => 'আপনার সম্প্রচারে';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টি সাম্প্রতিক সংকেত',
      one: '1 টি সাম্প্রতিক সংকেত',
      zero: 'কোনো সাম্প্রতিক সংকেত নেই',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'আপনার সংগ্রহ অপেক্ষা করছে';

  @override
  String get saved => 'সংরক্ষিত';

  @override
  String get collectionEmptyDetail => 'যে সংগীতে ফিরতে চান, সেটি এখানেই থাকবে';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টি ট্র্যাক',
      one: '1 ট্র্যাক',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'ট্র্যাক, শিল্পী বা গান';

  @override
  String get searchUpper => 'খোঁজ';

  @override
  String get findFirstTrack => 'আপনার প্রথম ট্র্যাক খুঁজুন';

  @override
  String continuationAfter(String artist) {
    return '$artist-এর পরে আরও সংগীত';
  }

  @override
  String get chooseTrackWaveDetail =>
      'একটি ট্র্যাক বেছে নিন, তার মেজাজ ঘিরে আমরা ঢেউ তৈরি করব।';

  @override
  String get continueWaveLabel => 'চালিয়ে যান / 01';

  @override
  String get yourWaveLabel => 'আপনার ঢেউ / 01';

  @override
  String get continueWave => 'ঢেউ চালিয়ে যান';

  @override
  String get chooseTrack => 'ট্র্যাক বাছুন';

  @override
  String get firstTrace => 'আপনার প্রথম চিহ্ন এখানে রাখুন';

  @override
  String get favoriteWaveHint =>
      'পছন্দ সংরক্ষণ করুন, আপনার ঢেউ আরও নিখুঁত হবে।';

  @override
  String get openSearch => 'খোঁজ খুলুন';

  @override
  String get findYourMusic => 'আপনার সুর খুঁজুন।';

  @override
  String get importMusic => 'সংগীত আমদানি করুন';

  @override
  String get rememberedLyricsHint => 'যে শব্দগুলি মনে আছে…';

  @override
  String get trackArtistHint => 'ট্র্যাক বা শিল্পী — যে কোনো ভাষায়';

  @override
  String get clear => 'মুছুন';

  @override
  String get music => 'সংগীত';

  @override
  String get byLyrics => 'গান দিয়ে';

  @override
  String get allSources => 'সব উৎস';

  @override
  String get lyricsSearchCaption => 'গানের শিরোনাম নয়, তার একটি লাইন খুঁজুন।';

  @override
  String get searchingLyrics => 'চেনা লাইনগুলি খোঁজা হচ্ছে…';

  @override
  String get searchingSources => 'সংগীতের উৎসে খোঁজা হচ্ছে…';

  @override
  String get connectionFailed => 'সংযোগ করা গেল না';

  @override
  String get noMatches => 'এখনও কোনো মিল নেই';

  @override
  String get lyricsUnavailable =>
      'গান খোঁজা এখন অপ্রাপ্য। পরে চেষ্টা করুন বা শিরোনাম দিয়ে খুঁজুন।';

  @override
  String get searchUnavailable =>
      'খোঁজ ব্যর্থ। সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';

  @override
  String get lyricsNoMatches => 'অন্য লাইন চেষ্টা করুন। সব গান সূচিবদ্ধ নয়।';

  @override
  String get trackNoMatches =>
      'শিল্পী যোগ করুন বা অন্য উৎস বাছুন। কিছু সেবা আপনার নেটওয়ার্কে অপ্রাপ্য হতে পারে।';

  @override
  String get repeatSearch => 'আবার খুঁজুন';

  @override
  String get lyricMatchesUpper => 'গানের মিল';

  @override
  String get tracksUpper => 'ট্র্যাক';

  @override
  String playTrack(String title, String artist) {
    return 'চালান $title, $artist';
  }

  @override
  String get familiarLinesUpper => 'চেনা লাইন';

  @override
  String get bestMatchUpper => 'সর্বোত্তম মিল';

  @override
  String get fullVersionOnPlayback =>
      'প্লেব্যাক শুরু হলেই পূর্ণ সংস্করণ খুঁজে দেব।';

  @override
  String get forgotTitle => 'শিরোনাম ভুলে গেছেন।\nসংগীত নয়।';

  @override
  String get startAsYouRemember =>
      'নাম, শিরোনাম বা গানের একটি লাইন।\nযা মনে আছে তা দিয়েই শুরু করুন।';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => 'নাম যেমন শোনায় তেমনই খুঁজুন';

  @override
  String get rememberOnlyLine => 'শুধু একটি লাইন মনে আছে';

  @override
  String get findSongByWords => 'গানের শব্দ দিয়ে গান খুঁজুন';

  @override
  String get yourArtistsUpper => 'আপনার শিল্পীরা';

  @override
  String get language => 'ভাষা';

  @override
  String get languageCaption => 'ইন্টারফেস সঙ্গে সঙ্গে আপনার পছন্দ মানে';

  @override
  String get systemLanguage => 'সিস্টেম';

  @override
  String get russian => 'রুশ';

  @override
  String get english => 'ইংরেজি';

  @override
  String get themesAndShaders => 'থিম ও ইফেক্ট';

  @override
  String get themesSubtitle => 'চেহারা, ভাষা ও পটভূমির গতি';

  @override
  String get invalidThemeJson =>
      'থিম পড়া গেল না। JSON ফরম্যাট ও ফিল্ডের মান পরীক্ষা করুন।';

  @override
  String get exportJson => 'JSON রপ্তানি করুন';

  @override
  String get importJson => 'JSON আমদানি করুন';

  @override
  String get readyThemes => 'প্রস্তুত থিম';

  @override
  String get gpuShaders => 'পটভূমির ইফেক্ট';

  @override
  String get meshGradient => 'ট্র্যাকের রঙে নরম GPU গ্রেডিয়েন্ট';

  @override
  String get vinylNoise => 'অ্যানালগ ভিনাইল দানা (শোর)';

  @override
  String get glassBlur => 'কাচের মতো ঝাপসা (Backdrop Blur)';

  @override
  String get cornerRadius => 'ইন্টারফেস কোণের ব্যাসার্ধ';

  @override
  String get importThemeTitle => 'JSON থেকে থিম আমদানি করুন';

  @override
  String get pasteThemeJson => 'থিমের JSON কনফিগারেশন পেস্ট করুন:';

  @override
  String get cancel => 'বাতিল';

  @override
  String get apply => 'প্রয়োগ করুন';

  @override
  String get themeApplied => 'থিম সফলভাবে প্রয়োগ হয়েছে!';

  @override
  String get exportThemeTitle => 'থিম রপ্তানি (JSON)';

  @override
  String get close => 'বন্ধ';

  @override
  String get copyJson => 'JSON কপি করুন';

  @override
  String get jsonCopied => 'থিমের JSON ক্লিপবোর্ডে কপি হয়েছে!';

  @override
  String get libraryUpper => 'লাইব্রেরি';

  @override
  String get localCollection => 'স্থানীয় সংগ্রহ ও প্লেলিস্ট';

  @override
  String get importShort => 'আমদানি';

  @override
  String get favorites => 'পছন্দ';

  @override
  String get playlists => 'প্লেলিস্ট';

  @override
  String get history => 'ইতিহাস';

  @override
  String get offline => 'অফলাইন';

  @override
  String get favoritesEmpty =>
      'আপনার পছন্দগুলি খালি।\nট্র্যাকের হৃদয়ে ট্যাপ করে সেটি এখানে যোগ করুন।';

  @override
  String get historyEmpty =>
      'আপনার শোনার ইতিহাস খালি।\nখোঁজ থেকে সংগীত চালান, এখানে দেখা যাবে।';

  @override
  String get noPlaylists => 'আপনার এখনও কোনো প্লেলিস্ট নেই';

  @override
  String get importPlaylistHint =>
      'স্পটিফাই প্লেলিস্ট আমদানি করুন বা ট্র্যাক তালিকা পেস্ট করুন।';

  @override
  String get importMusicAction => 'সংগীত আমদানি করুন';

  @override
  String get playPlaylist => 'প্লেলিস্ট চালান';

  @override
  String playlistStarted(String name, int count) {
    return '«$name» বাজছে ($count ট্র্যাক)';
  }

  @override
  String get deletePlaylist => 'প্লেলিস্ট মুছুন';

  @override
  String get playAll => 'সব চালান';

  @override
  String get shuffle => 'এলোমেলো';

  @override
  String get localAudioCache => 'স্থানীয় অডিও ক্যাশ';

  @override
  String get cacheDescription =>
      'বাজানো ট্র্যাক স্থানীয়ভাবে জমা হয়, যাতে ইন্টারনেট ছাড়াই আবার শোনা যায়।';

  @override
  String deviceUsage(String size) {
    return 'এই ডিভাইসে: $size';
  }

  @override
  String get clearCache => 'সব ক্যাশ মুছুন';

  @override
  String savedTracksUpper(int count) {
    return 'সংরক্ষিত ট্র্যাক ($count):';
  }

  @override
  String get cacheFeaturesUpper => 'ক্যাশের সুবিধা:';

  @override
  String get offlineFirst => 'সম্পূর্ণ অফলাইন-প্রথম';

  @override
  String get offlineFirstDescription =>
      'আবার শোনার সময় অডিও সরাসরি ডিভাইসের ফাইল সিস্টেম থেকে লোড হয়।';

  @override
  String get maximumBitrate => 'সর্বোচ্চ বিটরেট';

  @override
  String get maximumBitrateDescription =>
      '160–256 kbps-এর পরিচ্ছন্ন Opus/M4A স্ট্রিম ট্রান্সকোডিং ছাড়া জমা হয়।';

  @override
  String get trafficAndBattery => 'ডেটা ও ব্যাটারি বাঁচান';

  @override
  String get trafficAndBatteryDescription =>
      'বারবার নেটওয়ার্ক অনুরোধ এড়ালে ফোন বেশি দিন চলে।';

  @override
  String get cacheEmpty => 'ক্যাশ খালি';

  @override
  String get cachedTracksAppear =>
      'ডাউনলোড করা ট্র্যাক এখানে স্বয়ংক্রিয়ভাবে দেখা যাবে';

  @override
  String get removeFromCache => 'ক্যাশ থেকে সরান';

  @override
  String get removeCachedTrackTitle => 'ট্র্যাক ক্যাশ থেকে সরাবেন?';

  @override
  String removeCachedTrackBody(String title) {
    return '«$title» এই ডিভাইস থেকে সরে যাবে।';
  }

  @override
  String get delete => 'মুছুন';

  @override
  String get trackRemovedFromCache => 'ট্র্যাক ক্যাশ থেকে সরানো হয়েছে';

  @override
  String get clearCacheTitle => 'ক্যাশ মুছবেন?';

  @override
  String get clearCacheBody =>
      'জমা সব অডিও ফাইল এই ডিভাইস থেকে সরে যাবে। পছন্দ ও ইতিহাস অপরিবর্তিত থাকবে।';

  @override
  String get cacheCleared => 'স্থানীয় ক্যাশ মুছে গেছে';

  @override
  String get back => 'ফিরুন';

  @override
  String get playlistActions => 'প্লেলিস্ট অ্যাকশন';

  @override
  String get playlistUpper => 'প্লেলিস্ট';

  @override
  String get playlistEmpty => 'এই প্লেলিস্টে এখনও কোনো ট্র্যাক নেই';

  @override
  String get pasteTrackList => 'ট্র্যাক তালিকা পেস্ট করুন';

  @override
  String get pasteImportLink => 'আমদানির জন্য লিংক পেস্ট করুন';

  @override
  String get tracksNotFound => 'ওই লিংকে কোনো ট্র্যাক পাওয়া যায়নি।';

  @override
  String get importError =>
      'আমদানি ব্যর্থ। লিংক ও ইন্টারনেট সংযোগ পরীক্ষা করুন।';

  @override
  String importedPlaylistStarted(int count) {
    return 'আমদানিকৃত প্লেলিস্ট বাজছে ($count ট্র্যাক)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'আমদানি ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return 'প্লেলিস্ট «$name» আপনার লাইব্রেরিতে সংরক্ষিত হয়েছে!';
  }

  @override
  String get spotifyImportSubtitle =>
      'স্পটিফাই • প্লেলিস্ট, অ্যালবাম ও ট্র্যাক';

  @override
  String get artistTrackOrCsv => 'শিল্পী — ট্র্যাক, বা Exportify CSV';

  @override
  String get pastePlaylistOrTrackLink =>
      'প্লেলিস্ট বা ট্র্যাকের লিংক পেস্ট করুন';

  @override
  String get pasteFromClipboard => 'ক্লিপবোর্ড থেকে পেস্ট করুন';

  @override
  String get link => 'লিংক';

  @override
  String get trackList => 'ট্র্যাক তালিকা';

  @override
  String get playlistName => 'প্লেলিস্টের নাম';

  @override
  String get startImport => 'আমদানি শুরু করুন';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count ট্র্যাক';
  }

  @override
  String get importedFromSpotify => 'স্পটিফাই থেকে আমদানিকৃত';

  @override
  String get importedFromDeezer => 'Deezer থেকে আমদানি করা';

  @override
  String get importIntro =>
      'আপনার প্লেলিস্ট সঙ্গে আনুন। স্পটিফাই লিংক, ট্র্যাক তালিকা বা Exportify ফাইল ব্যবহার করুন।';

  @override
  String get importTextTab => 'টেক্সট';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'ফাইল বাছুন';

  @override
  String get importFileHint =>
      'Exportify থেকে রপ্তানি করা CSV বা TXT ট্র্যাক তালিকা বাছুন। UTF-8, সর্বোচ্চ 10 MB ও 10,000 ট্র্যাক।';

  @override
  String get importFileAndroidOnly =>
      'ফাইল নির্বাচন অ্যান্ড্রয়েডে উপলব্ধ। এখানে CSV বা ট্র্যাক তালিকার বিষয়বস্তু পেস্ট করতে পারেন।';

  @override
  String get importTextHint =>
      'প্রতি লাইনে এক শিল্পী — ট্র্যাক। শিরোনাম-সহ পুরো CSV-ও পেস্ট করতে পারেন।';

  @override
  String get importPreview => 'ট্র্যাক প্রিভিউ';

  @override
  String get importedFromCsv => 'CSV থেকে আমদানিকৃত';

  @override
  String get importedFromText => 'ট্র্যাক তালিকা থেকে আমদানিকৃত';

  @override
  String importMoreTracks(int count) {
    return 'আরও $count টি';
  }

  @override
  String get importMetadataHint =>
      'প্লেলিস্ট এই ডিভাইসে সংরক্ষিত হয়। ট্র্যাক বাজানোর সময় অডিও খোঁজা হয়; আমদানি গান ডাউনলোড করে না।';

  @override
  String get importAnother => 'অন্য কিছু আমদানি করুন';

  @override
  String get importReading => 'আপনার প্লেলিস্ট পড়া হচ্ছে…';

  @override
  String get importSaving => 'লাইব্রেরিতে সংরক্ষণ হচ্ছে…';

  @override
  String get importNameRequired => 'প্লেলিস্টের নাম লিখুন।';

  @override
  String get importNameExists =>
      'এই নামে প্লেলিস্ট আগেই আছে। দুটিই রাখতে অন্য নাম বাছুন।';

  @override
  String get importSaveFailed =>
      'প্লেলিস্ট সংরক্ষণ করা গেল না। প্রিভিউ এখনও এখানেই — আবার চেষ্টা করুন।';

  @override
  String get importFileTooLarge =>
      'ফাইলটি 10 MB-এর বেশি। প্লেলিস্ট ছোট রপ্তানিতে ভাগ করুন।';

  @override
  String get importFileUnsupported => '.csv বা .txt ফাইল বাছুন।';

  @override
  String get importFileEncoding =>
      'টেক্সট এনকোডিং পড়া গেল না। ফাইল UTF-8-এ সংরক্ষণ করে আবার চেষ্টা করুন।';

  @override
  String get importCsvInvalid =>
      'CSV অসম্পূর্ণ বা ত্রুটিপূর্ণ। কলাম বা উদ্ধৃতি না বদলে আবার রপ্তানি করুন।';

  @override
  String get importCsvMissingColumns =>
      'CSV-তে Track Name ও Artist Name(s), বা Title ও Artist কলাম দরকার। মূল Exportify রপ্তানি বাছুন।';

  @override
  String get importFileEmpty =>
      'কোনো ট্র্যাক পাওয়া যায়নি। ভরা রপ্তানি বাছুন বা শিল্পী — ট্র্যাক তালিকা পেস্ট করুন।';

  @override
  String get importTooManyTracks =>
      'এক আমদানিতে সর্বোচ্চ 10,000 ট্র্যাক। এই প্লেলিস্ট ভাগ করুন; এখনও কিছু সংরক্ষিত হয়নি।';

  @override
  String get importFileReadFailed =>
      'ফাইলটি খোলা গেল না। ডিভাইসে উপলব্ধ কিনা দেখে আবার বাছুন।';

  @override
  String get importSpotifyBlocked =>
      'স্পটিফাই এই প্লেলিস্ট আপনার অঞ্চলে ভাগ করেনি। Exportify দিয়ে রপ্তানি করে CSV ফাইল বাছুন।';

  @override
  String get listen => 'চালান';

  @override
  String get addToPlaylists => 'প্লেলিস্টে যোগ করুন';

  @override
  String trackSemantics(String title, String artist) {
    return 'ট্র্যাক $title, $artist';
  }

  @override
  String get trackActions => 'ট্র্যাক অ্যাকশন';

  @override
  String get updatesTitle => 'আপডেট';

  @override
  String get accountTitle => 'অ্যাকাউন্ট';

  @override
  String get waveLoading => 'একই রকম গান খোঁজা হচ্ছে…';

  @override
  String get sleepTimer => 'ঘুমের টাইমার';

  @override
  String sleepMinutes(String value) {
    return '$value';
  }

  @override
  String get sleepUntilTrackEnd => 'ট্র্যাক শেষ পর্যন্ত';

  @override
  String get sleepCancel => 'বন্ধ করুন';

  @override
  String get dislike => 'পছন্দ নয়';

  @override
  String get dislikeRemove => 'লুকানো থেকে সরান';

  @override
  String dislikeSaved(String artist) {
    return 'লুকানো হয়েছে: $artist';
  }

  @override
  String get exportPlaylist => 'CSV রপ্তানি';

  @override
  String get playlistExported => 'প্লেলিস্ট রপ্তানি হয়েছে';

  @override
  String get exportFailed => 'রপ্তানি ব্যর্থ';

  @override
  String get downloadAll => 'সব ডাউনলোড';

  @override
  String get statsTitle => 'পরিসংখ্যান';

  @override
  String get statsPlays => 'বাজানো হয়েছে';

  @override
  String get statsFavorites => 'প্রিয়';

  @override
  String get statsPlaylists => 'প্লেলিস্ট';

  @override
  String get statsTopArtists => 'শীর্ষ শিল্পী';

  @override
  String get statsTopTracks => 'শীর্ষ ট্র্যাক';

  @override
  String resumeTitle(String device) {
    return '$device-এ চালিয়ে যান';
  }

  @override
  String get alwaysOnTop => 'উইন্ডো উপরে রাখুন';

  @override
  String get randomPick => 'আপনার জন্য এলোমেলো পছন্দ';

  @override
  String get accountCaption => 'আপনার লাইব্রেরি ডিভাইসের মধ্যে সিঙ্ক করুন';

  @override
  String get nickname => 'ডাকনাম';

  @override
  String get nicknameHint => '৩–২০ অক্ষর: অক্ষর, সংখ্যা, . _ -';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get passwordMinHint => 'কমপক্ষে ৬ অক্ষর';

  @override
  String get signIn => 'সাইন ইন';

  @override
  String get signUp => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get haveAccountToggle => 'ইতিমধ্যে অ্যাকাউন্ট আছে? সাইন ইন করুন';

  @override
  String get noAccountToggle => 'এখনও অ্যাকাউন্ট নেই? তৈরি করুন';

  @override
  String get signOut => 'সাইন আউট';

  @override
  String get syncNow => 'এখনই সিঙ্ক করুন';

  @override
  String get syncing => 'সিঙ্ক হচ্ছে…';

  @override
  String syncedAt(String time) {
    return 'সিঙ্ক হয়েছে: $time';
  }

  @override
  String get neverSynced => 'এখনও সিঙ্ক হয়নি';

  @override
  String get errorNicknameTaken => 'এই ডাকনামটি আগে থেকেই আছে';

  @override
  String get errorNicknameInvalid => 'ডাকনাম: ৩–২০ অক্ষর, অক্ষর/সংখ্যা/._-';

  @override
  String get errorInvalidCredentials => 'ডাকনাম বা পাসওয়ার্ড ভুল';

  @override
  String get errorWeakPassword => 'পাসওয়ার্ড খুব ছোট';

  @override
  String get errorNetwork => 'সংযোগ নেই';

  @override
  String get errorServer => 'সার্ভার ত্রুটি, পরে চেষ্টা করুন';

  @override
  String currentVersion(String version) {
    return 'সংস্করণ $version';
  }

  @override
  String get checkForUpdates => 'আপডেট পরীক্ষা করুন';

  @override
  String get checkingForUpdates => 'পরীক্ষা চলছে…';

  @override
  String get upToDate => 'আপনার কাছে সর্বশেষ সংস্করণ আছে';

  @override
  String updateAvailable(String version) {
    return 'সংস্করণ $version উপলব্ধ';
  }

  @override
  String get downloadingUpdate => 'আপডেট ডাউনলোড হচ্ছে…';

  @override
  String get installUpdate => 'ইনস্টল করুন';

  @override
  String get updateCheckFailed =>
      'আপডেট পরীক্ষা করা যায়নি। ইন্টারনেট পরীক্ষা করুন।';

  @override
  String get installPermissionNeeded =>
      'Hook-কে অ্যাপ ইনস্টল করার অনুমতি দিন এবং আবার ইনস্টল চাপুন।';

  @override
  String updateSize(String size) {
    return '$size MB';
  }

  @override
  String get download => 'ডাউনলোড করুন';

  @override
  String get downloading => 'ডাউনলোড হচ্ছে…';

  @override
  String get downloaded => 'ডাউনলোড হয়েছে';

  @override
  String get downloadFailed => 'ডাউনলোড করা যায়নি';

  @override
  String get removeDownload => 'ডাউনলোড সরান';

  @override
  String get downloadSavedOffline => 'অফলাইনে সংরক্ষিত';

  @override
  String get startWaveFromTrack => 'এই ট্র্যাক থেকে ঢেউ শুরু করুন';

  @override
  String get addToQueue => 'সারিতে যোগ করুন';

  @override
  String addedToQueue(String title) {
    return 'সারিতে যোগ হয়েছে: $title';
  }

  @override
  String get removeFavorite => 'পছন্দ থেকে সরান';

  @override
  String get addFavorite => 'পছন্দে যোগ করুন';

  @override
  String get addToPlaylist => 'প্লেলিস্টে যোগ করুন';

  @override
  String get goToArtist => 'শিল্পীর কাছে যান';

  @override
  String get myPlaylist => 'আমার প্লেলিস্ট';

  @override
  String get newPlaylist => 'নতুন প্লেলিস্ট';

  @override
  String get name => 'নাম';

  @override
  String get create => 'তৈরি করুন';

  @override
  String get loading => 'লোড হচ্ছে…';

  @override
  String get pause => 'বিরতি';

  @override
  String get play => 'চালান';

  @override
  String get next => 'পরবর্তী';

  @override
  String get speedAndPitch => 'গতি ও পিচ';

  @override
  String speedValue(String value) {
    return 'গতি: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'পিচ: ${value}x';
  }

  @override
  String get reset => 'রিসেট';

  @override
  String get moreActions => 'আরও অ্যাকশন';

  @override
  String get playbackQueue => 'প্লেব্যাক সারি';

  @override
  String get queueEmpty => 'সারি খালি';

  @override
  String get selectingSource => 'উৎস নির্বাচিত হচ্ছে';

  @override
  String get collapsePlayer => 'প্লেয়ার ভাঁজ করুন';

  @override
  String get nowPlayingUpper => 'এখন বাজছে';

  @override
  String get queue => 'সারি';

  @override
  String get startWave => 'ঢেউ শুরু করুন';

  @override
  String get cover => 'প্রচ্ছদ';

  @override
  String get karaokeLyrics => 'কারাওকে গান';

  @override
  String get findMusicStart => 'সংগীত খুঁজে প্লেব্যাক শুরু করুন';

  @override
  String get playbackNotStarted => 'প্লেব্যাক এখনও শুরু হয়নি';

  @override
  String get openSearchFirstTrack => 'প্রথম ট্র্যাক খুঁজতে খোঁজ খুলুন';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => 'ডিভাইসে';

  @override
  String get sourceCatalog => 'ক্যাটালগ';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'সার্ভার';

  @override
  String get serverResolver => 'রিজলভার সার্ভার';

  @override
  String get serverResolverCaption =>
      'পূর্ণ অডিও স্ট্রিম খুঁজে দেওয়া ঐচ্ছিক নিজস্ব সার্ভার। অ্যাপ খোঁজ বা ট্র্যাক ID পাঠায়; সার্ভার প্লেব্যাক URL দেয়। চুক্তি ও রেফারেন্স বাস্তবায়ন docs/REMOTE_RESOLVER.md-তে।';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'কনফিগার করা নেই';

  @override
  String get serverSave => 'সংরক্ষণ';

  @override
  String get serverDisable => 'নিষ্ক্রিয় করুন';

  @override
  String get onboardingWelcomeTitle => 'Hook-এ স্বাগতম';

  @override
  String get onboardingWelcomeCaption =>
      'সংগীত, গান ও আপনার নিজের ভিজ্যুয়াল স্টাইল। শুরু করতে ভাষা বাছুন — পরে সেটিংস থেকে বদলাতে পারবেন।';

  @override
  String get onboardingSkip => 'এড়িয়ে যান';

  @override
  String get onboardingNext => 'পরবর্তী';

  @override
  String get onboardingStart => 'শোনা শুরু করুন';

  @override
  String get onboardingMicrogTitle => 'MicroG ও Google অ্যাকাউন্ট';

  @override
  String get onboardingMicrogBody =>
      'Google সেবা ছাড়া আসা কাস্টম Android ROM-এ MicroG সেবাগুলি আবার তৈরি করে। Hook এগুলি শুধু একটি ঐচ্ছিক সুবিধার জন্য ব্যবহার করে: প্লেলিস্ট আমদানির জন্য YouTube অ্যাকাউন্ট সংযোগ। সংগীত বাজাতে MicroG বা কোনো Google সেবার প্রয়োজন নেই।';

  @override
  String get onboardingMicrogNote =>
      'প্লেব্যাক MicroG-এর উপর নির্ভর করে না। অ্যাকাউন্ট সংযোগ ঐচ্ছিক।';

  @override
  String get onboardingMicrogDownload => 'MicroG ডাউনলোড করুন';

  @override
  String get onboardingMicrogStatusChecking => 'Google সেবা পরীক্ষা করা হচ্ছে…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'এই ডিভাইসে Google সেবা আছে ($version)। অ্যাকাউন্ট আমদানি সঙ্গে সঙ্গে কাজ করবে।';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'ReVanced GmsCore শনাক্ত ($version)। সরকারি Google সাইন-ইন SDK এর সঙ্গে অসামঞ্জস্যপূর্ণ, তাই অ্যাকাউন্ট সংযোগ কাজ নাও করতে পারে। প্লেব্যাক প্রভাবিত হয় না।';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'Google সেবা পাওয়া যায়নি। YouTube অ্যাকাউন্ট থেকে প্লেলিস্ট আমদানি করতে আগে MicroG ইনস্টল করুন — বা এড়িয়ে Hook অ্যাকাউন্ট ছাড়া চালান।';

  @override
  String lyricsView(String mode) {
    return 'গানের ভিউ · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'আপনার পড়ার ছন্দ';

  @override
  String get lyricsModeSubtitle => 'গানের কাছে পৌঁছানোর তিন পথ।';

  @override
  String get lyricsModeLines => 'লাইন';

  @override
  String get lyricsModeKaraoke => 'কারাওকে';

  @override
  String get lyricsModeFocus => 'ফোকাস';

  @override
  String get lyricsModeLinesDescription => 'শান্ত গান, বর্তমান লাইন হাইলাইট';

  @override
  String get lyricsModeKaraokeDescription =>
      'শব্দগুলি ভোকালের সঙ্গে মৃদু জ্বলে ওঠে';

  @override
  String get lyricsModeFocusDescription => 'একটি বড় লাইন। আর কিছু নয়';

  @override
  String get lyricsModeSaveFailed => 'গানের ভিউ সংরক্ষণ করা গেল না।';

  @override
  String get lyricsModeFootnote =>
      'আপনার পছন্দ পরের গানের জন্য জমা থাকে। কারাওকের নিখুঁততা উৎসের ডেটার উপর: শব্দ-সময় ছাড়া হাইলাইট আন্দাজে, আর সময়-চিহ্ন ছাড়া গান থেমে থাকে।';

  @override
  String get lyricsNotFound => 'গান পাওয়া যায়নি';

  @override
  String get karaokeUnavailable => 'এই ট্র্যাকের কারাওকে গান অপ্রাপ্য';

  @override
  String get unsyncedLyrics => 'অসমলয় গান';

  @override
  String get wordSyncUpper => 'শব্দ-পর-শব্দ সিঙ্ক';

  @override
  String get lineSyncUpper => 'লাইন-পর-লাইন সিঙ্ক';

  @override
  String get adjustLyricsSync => 'গানের সিঙ্ক সমন্বয় করুন';

  @override
  String get startsSoon => 'শীঘ্রই শুরু';

  @override
  String get musicContinues => 'সংগীত চলছে';

  @override
  String get decreaseLyricsOffset => 'অফসেট ০.১ সে কমান';

  @override
  String lyricsOffset(String value) {
    return 'অফসেট: $value সে';
  }

  @override
  String get increaseLyricsOffset => 'অফসেট ০.১ সে বাড়ান';

  @override
  String get hideSetting => 'সেটিং লুকান';

  @override
  String get lyricsOffsetSaveFailed => 'গানের অফসেট সংরক্ষণ করা গেল না।';

  @override
  String get audioForbidden =>
      'অডিও সার্ভার প্রবেশ অস্বীকার করেছে (HTTP 403)। ট্র্যাক পাওয়া গেছে, কিন্তু তার স্ট্রিম অপ্রাপ্য। VPN অডিও অ্যাক্সেসের গ্যারান্টি দেয় না।';

  @override
  String get fullVersionUnavailable =>
      'উপলব্ধ উৎসে পূর্ণ সংস্করণ পাওয়া যায়নি। সংযোগ পরীক্ষা করুন বা পরে চেষ্টা করুন।';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source এই ট্র্যাক বাজাতে পারেনি। সংযোগ পরীক্ষা করুন বা পরে চেষ্টা করুন।';
  }

  @override
  String get recentQueriesUpper => 'সাম্প্রতিক অনুসন্ধান';

  @override
  String get clearHistory => 'মুছে ফেলুন';

  @override
  String get waveFromArtist => 'শিল্পীর ঢেউ';

  @override
  String get popularTracksUpper => 'জনপ্রিয় গান';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি গান',
      one: '১টি গান',
      zero: 'এখনও কোনো গান নেই',
    );
    return '$_temp0';
  }

  @override
  String get volume => 'ভলিউম';

  @override
  String get systemVolume => 'সিস্টেম';

  @override
  String get appVolume => 'Hook স্তর';

  @override
  String get mute => 'মিউট করুন';

  @override
  String get unmute => 'শব্দ চালু করুন';

  @override
  String get volumeMixer => 'শব্দ ও ভলিউম';

  @override
  String get systemVolumeCaption =>
      'Windows-এর আউটপুট লেভেল, সব অ্যাপের সঙ্গে শেয়ার করা';

  @override
  String get appVolumeCaption => 'শুধু Hook-এর ভিতরে, সিস্টেম লেভেলের উপরে';

  @override
  String get volumeKeysHint => 'Ctrl + ↑ ↓ ভলিউম · M মিউট';

  @override
  String get volumeUnavailable => 'এই ডিভাইসে সিস্টেম ভলিউম উপলব্ধ নয়';

  @override
  String get cacheFolder => 'স্টোরেজ ফোল্ডার';

  @override
  String get copyPath => 'পাথ কপি করুন';

  @override
  String get pathCopied => 'পাথ ক্লিপবোর্ডে কপি হয়েছে';

  @override
  String get previousTrack => 'আগের ট্র্যাক';

  @override
  String get repeatPlayback => 'পুনরাবৃত্তি';

  @override
  String get openPlayer => 'প্লেয়ার খুলুন';

  @override
  String get statsWeek => 'শেষ ৭ দিন';

  @override
  String get keyboardShortcuts => 'কীবোর্ড শর্টকাট';

  @override
  String get shortcutsCaption => 'টেক্সট ফিল্ড ছাড়া সব জায়গায় কাজ করে।';

  @override
  String get shortcutsSeek => '১০ সেকেন্ড লাফ';

  @override
  String get playPauseShortcut => 'চালান / বিরতি';
}
