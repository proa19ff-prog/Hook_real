// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get settingsCaption => 'बदलाव इस डिवाइस पर सहेजे जाते हैं।';

  @override
  String get playerSettings => 'प्लेयर';

  @override
  String get lyricsAutoHide => 'गीत पढ़ते समय नियंत्रण छिपाएँ';

  @override
  String get lyricsAutoHideDescription =>
      '10 सेकंड की कोई क्रिया न होने पर प्लेयर के पैनल सरक कर हट जाते हैं। उन्हें वापस लाने के लिए रिस्टोर बटन का उपयोग करें।';

  @override
  String get showPlayerControls => 'प्लेयर नियंत्रण दिखाएँ';

  @override
  String get equalizer => 'इक्वलाइज़र';

  @override
  String get equalizerEnabled => 'ध्वनि प्रोसेसिंग';

  @override
  String get equalizerPresets => 'ध्वनि प्रोफ़ाइल';

  @override
  String get equalizerFlat => 'मूल';

  @override
  String get equalizerBass => 'गहरा बेस';

  @override
  String get equalizerVocal => 'वोकल';

  @override
  String get equalizerRock => 'रॉक';

  @override
  String get equalizerElectronic => 'इलेक्ट्रॉनिक';

  @override
  String get equalizerSoft => 'कोमल';

  @override
  String get equalizerCustom => 'कस्टम';

  @override
  String get equalizerBands => 'फ़्रीक्वेंसी बैंड';

  @override
  String get equalizerBassBoost => 'बेस बूस्ट';

  @override
  String get equalizerBassUnsupported =>
      'अतिरिक्त बेस बूस्ट समर्थित नहीं है। निम्न-आवृत्ति बैंड का उपयोग करें।';

  @override
  String get equalizerPreamp => 'प्री-एम्प';

  @override
  String get equalizerHeadroom => 'स्वतः हेडरूम';

  @override
  String get equalizerHeadroomDescription =>
      'शिखरों के लिए जगह छोड़ने के लिए आवृत्तियाँ बढ़ाते समय आउटपुट स्तर घटाता है। यह लिमिटर नहीं है।';

  @override
  String get equalizerWaiting =>
      'इक्वलाइज़र को उसके ऑडियो सेशन से जोड़ने के लिए कोई ट्रैक चलाएँ।';

  @override
  String get equalizerUnsupported =>
      'ध्वनि प्रोसेसिंग अभी केवल Android पर उपलब्ध है।';

  @override
  String get equalizerFailed =>
      'इस डिवाइस पर ऑडियो इफ़ेक्ट चालू नहीं हो सके। संगीत उनके बिना भी चल सकता है।';

  @override
  String get equalizerRetry => 'इफ़ेक्ट फिर से जोड़ें';

  @override
  String get equalizerLive =>
      'बदलाव तुरंत लागू होते हैं और इस डिवाइस पर सहेजे जाते हैं।';

  @override
  String get youtubeAccount => 'YouTube और MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'प्लेलिस्ट तक केवल-पढ़ने की पहुँच। साइन इन करने से ऑडियो की उपलब्धता की गारंटी नहीं मिलती।';

  @override
  String get youtubeAccountCompatibility => 'संगतता और गोपनीयता';

  @override
  String get youtubeAccountSubtitle => 'खाता जोड़ना और प्लेलिस्ट आयात';

  @override
  String get youtubeAccountPrivacy =>
      'Hook YouTube की केवल-पढ़ने की पहुँच माँगता है। अपना पासवर्ड केवल Google के सिस्टम संवाद में डालें, Hook में कभी नहीं। टोकन किसी Hook सर्वर पर नहीं भेजा जाता और केवल मेमोरी में रहता है। ऐप पुनः आरंभ करने के बाद दोबारा कनेक्ट करें।';

  @override
  String get youtubeAccountPlaybackNotice =>
      'साइन इन से खाते के डेटा की पहुँच मिलती है, ऑडियो स्ट्रीम की नहीं। यह HTTP 403 ठीक करने की गारंटी नहीं देता। आयात YouTube रिकॉर्डिंग को किसी दूसरे स्रोत से बदले बिना सुरक्षित रखते हैं।';

  @override
  String get youtubeAccountConnect => 'खाता जोड़ें';

  @override
  String get youtubeAccountDisconnect => 'Hook में डिस्कनेक्ट करें';

  @override
  String get youtubeAccountDisconnected => 'कोई खाता जुड़ा नहीं है';

  @override
  String get youtubeAccountDisconnectNotice =>
      'यह खाता केवल Hook से डिस्कनेक्ट करें? सहेजी गई प्लेलिस्ट बनी रहेंगी। फ़ोन के Google और MicroG खातों से साइन आउट नहीं होगा।';

  @override
  String get youtubeAccountSystem => 'सिस्टम Google API';

  @override
  String get youtubeAccountServicesMissing =>
      'संगत सिस्टम Google API उपलब्ध नहीं हैं। अलग से इंस्टॉल किया ReVanced GmsCore Hook के साइन-इन के लिए उनकी जगह नहीं लेता।';

  @override
  String get youtubeAccountMicrogNotice =>
      'अलग से इंस्टॉल किया ReVanced GmsCore मिला। Hook ReVanced खाते या टोकन उपयोग नहीं करता। सिस्टम MicroG संगत Google API दे सकता है, पर इस साइन-इन विधि के साथ संगतता की गारंटी नहीं है।';

  @override
  String get youtubeAccountRevancedFound => 'YouTube Music ReVanced इंस्टॉल है';

  @override
  String get youtubeAccountPlaylists => 'खाते की प्लेलिस्ट';

  @override
  String get youtubeAccountNoPlaylists =>
      'कोई सुलभ प्लेलिस्ट नहीं। YouTube Music के कुछ स्वतः संग्रह YouTube Data API के ज़रिए उपलब्ध नहीं होते।';

  @override
  String get youtubeAccountMore => 'और लोड करें';

  @override
  String get youtubeAccountPreview => 'आयात तैयार करें';

  @override
  String youtubeAccountProgress(int count) {
    return 'मिले ट्रैक: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'छोड़े गए अनुपलब्ध प्रविष्टियाँ: $count। इन्हें दूसरे ट्रैक से नहीं बदला जाता।';
  }

  @override
  String get youtubeAccountSetup => 'साइन-इन सेटअप';

  @override
  String get youtubeAccountSetupBody =>
      'डेवलपर को Google Cloud में YouTube Data API v3 सक्रिय करना होगा, com.hook.music और इंस्टॉल बिल्ड के हस्ताक्षर SHA-1 के लिए Android OAuth क्लाइंट पंजीकृत करना होगा, और सहमति स्क्रीन कॉन्फ़िगर करनी होगी। टेस्ट मोड में अनुमत उपयोगकर्ता जोड़ें। देखें docs/YOUTUBE_ACCOUNT_SETUP.md। पासवर्ड, क्लाइंट सीक्रेट या दूसरे ऐप्स के टोकन कभी न जोड़ें।';

  @override
  String get youtubeAccountConfigError =>
      'इस बिल्ड के लिए साइन-इन कॉन्फ़िगर नहीं है। Google Cloud में Android OAuth क्लाइंट, पैकेज नाम, SHA-1 और अनुमत टेस्ट उपयोगकर्ता जाँचें।';

  @override
  String get youtubeAccountPermissionError =>
      'YouTube डेटा तक पढ़ने की पहुँच नहीं दी गई।';

  @override
  String get youtubeAccountExpired =>
      'आपका सेशन समाप्त हो गया। खाता दोबारा जोड़ें।';

  @override
  String get youtubeAccountNoChannel =>
      'चुने खाते की कोई सुलभ YouTube चैनल नहीं है।';

  @override
  String get youtubeAccountQuota =>
      'YouTube API कोटा समाप्त। बाद में प्रयास करें।';

  @override
  String get youtubeAccountFailed =>
      'YouTube डेटा नहीं मिल सका। अपना कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get youtubeAccountUnsupported =>
      'खाता जोड़ने के लिए संगत सिस्टम Google API वाला Android चाहिए।';

  @override
  String get importedFromYouTube => 'YouTube खाते से आयातित';

  @override
  String get translateLyrics => 'गीत का अनुवाद करें';

  @override
  String get hideTranslation => 'अनुवाद छिपाएँ';

  @override
  String get cancelTranslation => 'अनुवाद रद्द करें';

  @override
  String get translationLoading => 'अनुवाद तैयार हो रहा है…';

  @override
  String get translationAttribution => 'Google Translate द्वारा स्वतः अनुवादित';

  @override
  String get translationNotice =>
      'अनुवाद गीत का अर्थ पूरी तरह नहीं पकड़ सकता। शब्द-हाइलाइटिंग केवल मूल पर लागू होती है।';

  @override
  String get translationModelTitle => 'भाषा मॉडल डाउनलोड करें?';

  @override
  String get translationModelBody =>
      'अनुवाद आपके फ़ोन पर चलता है: गीत किसी सर्वर पर नहीं भेजा जाता। पहले अनुवाद के लिए Google ML Kit मॉडल चाहिए, जो दसियों मेगाबाइट लेते हैं। डाउनलोड आपके मौजूदा कनेक्शन से होगा, मोबाइल डेटा सहित। रद्द करने पर परिणाम छिप जाता है, पर शुरू हुआ मॉडल डाउनलोड बैकग्राउंड में पूरा हो सकता है।';

  @override
  String get translationDownload => 'डाउनलोड कर अनुवाद करें';

  @override
  String get translationUnavailable =>
      'अनुवाद विफल। मॉडल डाउनलोड की पहुँच जाँचें और फिर कोशिश करें।';

  @override
  String get translationUnsupported =>
      'डिवाइस पर अनुवाद अभी केवल Android पर उपलब्ध है।';

  @override
  String get translationUnknownLanguage =>
      'इस गीत की कोई समर्थित भाषा पहचानी नहीं जा सकी।';

  @override
  String get translationSameLanguage => 'गीत पहले से चुनी भाषा में है।';

  @override
  String get translationTooLarge => 'यह गीत डिवाइस-अनुवाद के लिए बहुत लंबा है।';

  @override
  String get translationRussian => 'रूसी में';

  @override
  String get translationEnglish => 'अंग्रेज़ी में';

  @override
  String get translationTarget => 'अनुवाद भाषा';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get home => 'होम';

  @override
  String get search => 'खोज';

  @override
  String get library => 'लाइब्रेरी';

  @override
  String get youtubeUnavailableTitle => 'YouTube अभी उपलब्ध नहीं है';

  @override
  String get youtubeUnavailableBody =>
      'ऑडियो स्ट्रीम नहीं मिला। अपना नेटवर्क और VPN रूट जाँचें: YouTube VPN के साथ भी अनुरोध अस्वीकार कर सकता है।';

  @override
  String get checkAgain => 'फिर जाँचें';

  @override
  String get dismiss => 'हटाएँ';

  @override
  String get goodNight => 'शुभ रात्रि';

  @override
  String get goodMorning => 'सुप्रभात';

  @override
  String get goodAfternoon => 'नमस्कार';

  @override
  String get goodEvening => 'शुभ संध्या';

  @override
  String get themeSettings => 'रूप-रंग सेटिंग्स';

  @override
  String get onYourAir => 'आपकी हवा पर';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count हालिया सिग्नल',
      one: '1 हालिया सिग्नल',
      zero: 'कोई हालिया सिग्नल नहीं',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'आपका संग्रह इंतज़ार कर रहा है';

  @override
  String get saved => 'सहेजा गया';

  @override
  String get collectionEmptyDetail => 'जिस संगीत पर लौटना है, वह यहीं रहेगा';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ट्रैक',
      one: '1 ट्रैक',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'ट्रैक, कलाकार या गीत';

  @override
  String get searchUpper => 'खोज';

  @override
  String get findFirstTrack => 'अपना पहला ट्रैक खोजें';

  @override
  String continuationAfter(String artist) {
    return '$artist के बाद और संगीत';
  }

  @override
  String get chooseTrackWaveDetail =>
      'एक ट्रैक चुनें, हम उसके मूड के इर्द-गिर्द वेव बनाएँगे।';

  @override
  String get continueWaveLabel => 'जारी रखें / 01';

  @override
  String get yourWaveLabel => 'आपकी वेव / 01';

  @override
  String get continueWave => 'वेव जारी रखें';

  @override
  String get chooseTrack => 'ट्रैक चुनें';

  @override
  String get firstTrace => 'अपनी पहली छाप यहाँ छोड़ें';

  @override
  String get favoriteWaveHint => 'पसंदीदा सहेजें, आपकी वेव और सटीक बनेगी।';

  @override
  String get openSearch => 'खोज खोलें';

  @override
  String get findYourMusic => 'अपनी धुन खोजें।';

  @override
  String get importMusic => 'संगीत आयात करें';

  @override
  String get rememberedLyricsHint => 'वे शब्द जो याद हैं…';

  @override
  String get trackArtistHint => 'ट्रैक या कलाकार — किसी भी भाषा में';

  @override
  String get clear => 'साफ़ करें';

  @override
  String get music => 'संगीत';

  @override
  String get byLyrics => 'गीत से';

  @override
  String get allSources => 'सभी स्रोत';

  @override
  String get lyricsSearchCaption =>
      'गीत के शीर्षक की नहीं, उसकी किसी पंक्ति को खोजें।';

  @override
  String get searchingLyrics => 'परिचित पंक्तियाँ खोज रहे हैं…';

  @override
  String get searchingSources => 'संगीत स्रोतों में खोज रहे हैं…';

  @override
  String get connectionFailed => 'कनेक्ट नहीं हो सका';

  @override
  String get noMatches => 'अभी कोई मैच नहीं';

  @override
  String get lyricsUnavailable =>
      'गीत खोज अभी उपलब्ध नहीं है। बाद में कोशिश करें या शीर्षक से खोजें।';

  @override
  String get searchUnavailable => 'खोज विफल। कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get lyricsNoMatches =>
      'दूसरी पंक्ति आज़माएँ। हर गीत अनुक्रमित नहीं है।';

  @override
  String get trackNoMatches =>
      'कलाकार जोड़ें या दूसरा स्रोत चुनें। कुछ सेवाएँ आपके नेटवर्क पर उपलब्ध नहीं हो सकतीं।';

  @override
  String get repeatSearch => 'दोबारा खोजें';

  @override
  String get lyricMatchesUpper => 'गीत मैच';

  @override
  String get tracksUpper => 'ट्रैक';

  @override
  String playTrack(String title, String artist) {
    return 'चलाएँ $title, $artist';
  }

  @override
  String get familiarLinesUpper => 'परिचित पंक्तियाँ';

  @override
  String get bestMatchUpper => 'सर्वोत्तम मैच';

  @override
  String get fullVersionOnPlayback =>
      'प्लेबैक शुरू होते ही पूरा संस्करण खोजेंगे।';

  @override
  String get forgotTitle => 'शीर्षक भूल गए।\nसंगीत नहीं।';

  @override
  String get startAsYouRemember =>
      'नाम, शीर्षक या गीत की कोई पंक्ति।\nजो याद हो, वहीं से शुरू करें।';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => 'नाम उसी तरह खोजें जैसे वे सुनाई देते हैं';

  @override
  String get rememberOnlyLine => 'मुझे केवल एक पंक्ति याद है';

  @override
  String get findSongByWords => 'गीत को उसके शब्दों से खोजें';

  @override
  String get yourArtistsUpper => 'आपके कलाकार';

  @override
  String get language => 'भाषा';

  @override
  String get languageCaption => 'इंटरफ़ेस तुरंत आपकी पसंद पर चलता है';

  @override
  String get systemLanguage => 'सिस्टम';

  @override
  String get russian => 'रूसी';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get themesAndShaders => 'थीम और इफ़ेक्ट';

  @override
  String get themesSubtitle => 'रूप-रंग, भाषा और पृष्ठभूमि की गति';

  @override
  String get invalidThemeJson =>
      'थीम नहीं पढ़ी जा सकी। JSON प्रारूप और फ़ील्ड मान जाँचें।';

  @override
  String get exportJson => 'JSON निर्यात करें';

  @override
  String get importJson => 'JSON आयात करें';

  @override
  String get readyThemes => 'तैयार थीम';

  @override
  String get gpuShaders => 'पृष्ठभूमि इफ़ेक्ट';

  @override
  String get meshGradient => 'ट्रैक के रंगों पर आधारित कोमल GPU ग्रेडिएंट';

  @override
  String get vinylNoise => 'एनालॉग वाइनिल शोर (Noise)';

  @override
  String get glassBlur => 'काँच जैसी धुंधली (Backdrop Blur)';

  @override
  String get cornerRadius => 'इंटरफ़ेस कोनों की त्रिज्या';

  @override
  String get importThemeTitle => 'JSON से थीम आयात करें';

  @override
  String get pasteThemeJson => 'थीम का JSON कॉन्फ़िगरेशन पेस्ट करें:';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get apply => 'लागू करें';

  @override
  String get themeApplied => 'थीम सफलतापूर्वक लागू!';

  @override
  String get exportThemeTitle => 'थीम निर्यात करें (JSON)';

  @override
  String get close => 'बंद करें';

  @override
  String get copyJson => 'JSON कॉपी करें';

  @override
  String get jsonCopied => 'थीम का JSON क्लिपबोर्ड पर कॉपी हुआ!';

  @override
  String get libraryUpper => 'लाइब्रेरी';

  @override
  String get localCollection => 'स्थानीय संग्रह और प्लेलिस्ट';

  @override
  String get importShort => 'आयात';

  @override
  String get favorites => 'पसंदीदा';

  @override
  String get playlists => 'प्लेलिस्ट';

  @override
  String get history => 'इतिहास';

  @override
  String get offline => 'ऑफ़लाइन';

  @override
  String get favoritesEmpty =>
      'आपके पसंदीदा खाली हैं।\nट्रैक पर दिल को टैप करके उसे यहाँ जोड़ें।';

  @override
  String get historyEmpty =>
      'आपका सुनने का इतिहास खाली है।\nखोज से संगीत चलाएँ, वह यहाँ दिखेगा।';

  @override
  String get noPlaylists => 'आपके पास अभी कोई प्लेलिस्ट नहीं';

  @override
  String get importPlaylistHint =>
      'स्पॉटिफ़ाई प्लेलिस्ट आयात करें या ट्रैक सूची पेस्ट करें।';

  @override
  String get importMusicAction => 'संगीत आयात करें';

  @override
  String get playPlaylist => 'प्लेलिस्ट चलाएँ';

  @override
  String playlistStarted(String name, int count) {
    return '«$name» बज रही है ($count ट्रैक)';
  }

  @override
  String get deletePlaylist => 'प्लेलिस्ट हटाएँ';

  @override
  String get playAll => 'सभी चलाएँ';

  @override
  String get shuffle => 'शफ़ल';

  @override
  String get localAudioCache => 'स्थानीय ऑडियो कैश';

  @override
  String get cacheDescription =>
      'बजे ट्रैक स्थानीय रूप से सहेजे जाते हैं ताकि बिना इंटरनेट फिर सुनाए जा सकें।';

  @override
  String deviceUsage(String size) {
    return 'इस डिवाइस पर: $size';
  }

  @override
  String get clearCache => 'पूरा कैश साफ़ करें';

  @override
  String savedTracksUpper(int count) {
    return 'सहेजे ट्रैक ($count):';
  }

  @override
  String get cacheFeaturesUpper => 'कैश सुविधाएँ:';

  @override
  String get offlineFirst => 'पूर्णतः ऑफ़लाइन-प्रथम';

  @override
  String get offlineFirstDescription =>
      'दोबारा सुनने पर ऑडियो सीधे डिवाइस की फ़ाइल प्रणाली से लोड होता है।';

  @override
  String get maximumBitrate => 'अधिकतम बिटरेट';

  @override
  String get maximumBitrateDescription =>
      '160–256 kbps के साफ़ Opus/M4A स्ट्रीम बिना ट्रांसकोडिंग सहेजे जाते हैं।';

  @override
  String get trafficAndBattery => 'डेटा और बैटरी बचाएँ';

  @override
  String get trafficAndBatteryDescription =>
      'बार-बार नेटवर्क अनुरोध टालने से फ़ोन अधिक देर चलता है।';

  @override
  String get cacheEmpty => 'कैश खाली है';

  @override
  String get cachedTracksAppear => 'डाउनलोड किए ट्रैक यहाँ स्वतः दिखेंगे';

  @override
  String get removeFromCache => 'कैश से हटाएँ';

  @override
  String get removeCachedTrackTitle => 'ट्रैक कैश से हटाएँ?';

  @override
  String removeCachedTrackBody(String title) {
    return '«$title» इस डिवाइस से हट जाएगा।';
  }

  @override
  String get delete => 'हटाएँ';

  @override
  String get trackRemovedFromCache => 'ट्रैक कैश से हट गया';

  @override
  String get clearCacheTitle => 'कैश साफ़ करें?';

  @override
  String get clearCacheBody =>
      'सहेजी सभी ऑडियो फ़ाइलें इस डिवाइस से हट जाएँगी। पसंदीदा और इतिहास नहीं बदलेंगे।';

  @override
  String get cacheCleared => 'स्थानीय कैश साफ़';

  @override
  String get back => 'वापस';

  @override
  String get playlistActions => 'प्लेलिस्ट क्रियाएँ';

  @override
  String get playlistUpper => 'प्लेलिस्ट';

  @override
  String get playlistEmpty => 'इस प्लेलिस्ट में अभी कोई ट्रैक नहीं';

  @override
  String get pasteTrackList => 'ट्रैक सूची पेस्ट करें';

  @override
  String get pasteImportLink => 'आयात के लिए लिंक पेस्ट करें';

  @override
  String get tracksNotFound => 'उस लिंक पर कोई ट्रैक नहीं मिला।';

  @override
  String get importError => 'आयात विफल। लिंक और अपना इंटरनेट कनेक्शन जाँचें।';

  @override
  String importedPlaylistStarted(int count) {
    return 'आयातित प्लेलिस्ट बज रही है ($count ट्रैक)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'आयात ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return 'प्लेलिस्ट «$name» आपकी लाइब्रेरी में सहेजी गई!';
  }

  @override
  String get spotifyImportSubtitle => 'स्पॉटिफ़ाई • प्लेलिस्ट, एल्बम और ट्रैक';

  @override
  String get artistTrackOrCsv => 'कलाकार — ट्रैक, या Exportify CSV';

  @override
  String get pastePlaylistOrTrackLink => 'प्लेलिस्ट या ट्रैक लिंक पेस्ट करें';

  @override
  String get pasteFromClipboard => 'क्लिपबोर्ड से पेस्ट करें';

  @override
  String get link => 'लिंक';

  @override
  String get trackList => 'ट्रैक सूची';

  @override
  String get playlistName => 'प्लेलिस्ट का नाम';

  @override
  String get startImport => 'आयात शुरू करें';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count ट्रैक';
  }

  @override
  String get importedFromSpotify => 'स्पॉटिफ़ाई से आयातित';

  @override
  String get importedFromDeezer => 'Deezer से आयातित';

  @override
  String get importIntro =>
      'अपनी प्लेलिस्ट साथ लाएँ। स्पॉटिफ़ाई लिंक, ट्रैक सूची या Exportify फ़ाइल का उपयोग करें।';

  @override
  String get importTextTab => 'टेक्स्ट';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'फ़ाइल चुनें';

  @override
  String get importFileHint =>
      'Exportify से निर्यातित CSV या TXT ट्रैक सूची चुनें। UTF-8, 10 MB और 10,000 ट्रैक तक।';

  @override
  String get importFileAndroidOnly =>
      'फ़ाइल चयन Android पर उपलब्ध है। यहाँ आप CSV या ट्रैक सूची की सामग्री पेस्ट कर सकते हैं।';

  @override
  String get importTextHint =>
      'हर पंक्ति में एक कलाकार — ट्रैक। पूरा CSV शीर्षक-पंक्ति सहित भी पेस्ट कर सकते हैं।';

  @override
  String get importPreview => 'ट्रैक पूर्वावलोकन';

  @override
  String get importedFromCsv => 'CSV से आयातित';

  @override
  String get importedFromText => 'ट्रैक सूची से आयातित';

  @override
  String importMoreTracks(int count) {
    return 'और $count और';
  }

  @override
  String get importMetadataHint =>
      'प्लेलिस्ट इस डिवाइस पर सहेजी जाती है। ऑडियो ट्रैक चलाते समय खोजा जाता है; आयात गाने डाउनलोड नहीं करता।';

  @override
  String get importAnother => 'कुछ और आयात करें';

  @override
  String get importReading => 'आपकी प्लेलिस्ट पढ़ी जा रही है…';

  @override
  String get importSaving => 'लाइब्रेरी में सहेजा जा रहा है…';

  @override
  String get importNameRequired => 'प्लेलिस्ट का नाम दर्ज करें।';

  @override
  String get importNameExists =>
      'इस नाम की प्लेलिस्ट पहले से है। दोनों रखने के लिए दूसरा नाम चुनें।';

  @override
  String get importSaveFailed =>
      'प्लेलिस्ट सहेजी नहीं जा सकी। आपका पूर्वावलोकन यहीं है — फिर कोशिश करें।';

  @override
  String get importFileTooLarge =>
      'यह फ़ाइल 10 MB से बड़ी है। प्लेलिस्ट को छोटे निर्यातों में बाँटें।';

  @override
  String get importFileUnsupported => '.csv या .txt फ़ाइल चुनें।';

  @override
  String get importFileEncoding =>
      'टेक्स्ट एनकोडिंग नहीं पढ़ी जा सकी। फ़ाइल UTF-8 में सहेजकर फिर कोशिश करें।';

  @override
  String get importCsvInvalid =>
      'CSV अधूरी या त्रुटिपूर्ण है। स्तंभ या उद्धरण बदले बिना दोबारा निर्यात करें।';

  @override
  String get importCsvMissingColumns =>
      'CSV को Track Name और Artist Name(s), या Title और Artist स्तंभ चाहिए। मूल Exportify निर्यात चुनें।';

  @override
  String get importFileEmpty =>
      'कोई ट्रैक नहीं मिला। भरा हुआ निर्यात चुनें या कलाकार — ट्रैक सूची पेस्ट करें।';

  @override
  String get importTooManyTracks =>
      'एक आयात में अधिकतम 10,000 ट्रैक हो सकते हैं। इस प्लेलिस्ट को बाँटें; अभी कुछ सहेजा नहीं गया।';

  @override
  String get importFileReadFailed =>
      'यह फ़ाइल नहीं खुली। जाँचें कि वह डिवाइस पर उपलब्ध है और दोबारा चुनें।';

  @override
  String get importSpotifyBlocked =>
      'स्पॉटिफ़ाई ने यह प्लेलिस्ट आपके क्षेत्र में साझा नहीं की। उसे Exportify से निर्यात करके CSV फ़ाइल चुनें।';

  @override
  String get listen => 'चलाएँ';

  @override
  String get addToPlaylists => 'प्लेलिस्ट में जोड़ें';

  @override
  String trackSemantics(String title, String artist) {
    return 'ट्रैक $title, $artist';
  }

  @override
  String get trackActions => 'ट्रैक क्रियाएँ';

  @override
  String get updatesTitle => 'अपडेट';

  @override
  String get accountTitle => 'खाता';

  @override
  String get waveLoading => 'मिलते-जुलते गाने खोजे जा रहे हैं…';

  @override
  String get randomPick => 'आपके लिए यादृच्छिक चयन';

  @override
  String get accountCaption => 'अपनी लाइब्रेरी डिवाइसेस के बीच सिंक करें';

  @override
  String get nickname => 'उपनाम';

  @override
  String get nicknameHint => '3–20 वर्ण: अक्षर, अंक, . _ -';

  @override
  String get password => 'पासवर्ड';

  @override
  String get passwordMinHint => 'कम से कम 6 वर्ण';

  @override
  String get signIn => 'साइन इन';

  @override
  String get signUp => 'खाता बनाएँ';

  @override
  String get haveAccountToggle => 'पहले से खाता है? साइन इन करें';

  @override
  String get noAccountToggle => 'अभी खाता नहीं है? बनाएँ';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get syncNow => 'अभी सिंक करें';

  @override
  String get syncing => 'सिंक हो रहा है…';

  @override
  String syncedAt(String time) {
    return 'सिंक हुआ: $time';
  }

  @override
  String get neverSynced => 'अभी तक सिंक नहीं हुआ';

  @override
  String get errorNicknameTaken => 'यह उपनाम पहले से लिया गया है';

  @override
  String get errorNicknameInvalid => 'उपनाम: 3–20 वर्ण, अक्षर/अंक/._-';

  @override
  String get errorInvalidCredentials => 'उपनाम या पासवर्ड गलत है';

  @override
  String get errorWeakPassword => 'पासवर्ड बहुत छोटा है';

  @override
  String get errorNetwork => 'कोई कनेक्शन नहीं';

  @override
  String get errorServer => 'सर्वर त्रुटि, बाद में कोशिश करें';

  @override
  String currentVersion(String version) {
    return 'संस्करण $version';
  }

  @override
  String get checkForUpdates => 'अपडेट जांचें';

  @override
  String get checkingForUpdates => 'जांच हो रही है…';

  @override
  String get upToDate => 'आपके पास नवीनतम संस्करण है';

  @override
  String updateAvailable(String version) {
    return 'संस्करण $version उपलब्ध है';
  }

  @override
  String get downloadingUpdate => 'अपडेट डाउनलोड हो रहा है…';

  @override
  String get installUpdate => 'इंस्टॉल करें';

  @override
  String get updateCheckFailed => 'अपडेट जांच नहीं हो सकी। इंटरनेट जांचें।';

  @override
  String get installPermissionNeeded =>
      'Hook को ऐप्स इंस्टॉल करने की अनुमति दें और फिर से इंस्टॉल करें।';

  @override
  String updateSize(String size) {
    return '$size MB';
  }

  @override
  String get download => 'डाउनलोड करें';

  @override
  String get downloading => 'डाउनलोड हो रहा है…';

  @override
  String get downloaded => 'डाउनलोड हो गया';

  @override
  String get downloadFailed => 'डाउनलोड नहीं हो सका';

  @override
  String get removeDownload => 'डाउनलोड हटाएँ';

  @override
  String get downloadSavedOffline => 'ऑफ़लाइन सहेजा गया';

  @override
  String get startWaveFromTrack => 'इस ट्रैक से वेव शुरू करें';

  @override
  String get addToQueue => 'क्यू में जोड़ें';

  @override
  String addedToQueue(String title) {
    return 'क्यू में जोड़ा: $title';
  }

  @override
  String get removeFavorite => 'पसंदीदा से हटाएँ';

  @override
  String get addFavorite => 'पसंदीदा में जोड़ें';

  @override
  String get addToPlaylist => 'प्लेलिस्ट में जोड़ें';

  @override
  String get goToArtist => 'कलाकार पर जाएँ';

  @override
  String get myPlaylist => 'मेरी प्लेलिस्ट';

  @override
  String get newPlaylist => 'नई प्लेलिस्ट';

  @override
  String get name => 'नाम';

  @override
  String get create => 'बनाएँ';

  @override
  String get loading => 'लोड हो रहा है…';

  @override
  String get pause => 'रोकें';

  @override
  String get play => 'चलाएँ';

  @override
  String get next => 'अगला';

  @override
  String get speedAndPitch => 'गति और पिच';

  @override
  String speedValue(String value) {
    return 'गति: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'पिच: ${value}x';
  }

  @override
  String get reset => 'रीसेट';

  @override
  String get moreActions => 'अधिक क्रियाएँ';

  @override
  String get playbackQueue => 'प्लेबैक क्यू';

  @override
  String get queueEmpty => 'क्यू खाली है';

  @override
  String get selectingSource => 'स्रोत चुना जा रहा है';

  @override
  String get collapsePlayer => 'प्लेयर सिकोड़ें';

  @override
  String get nowPlayingUpper => 'अभी बज रहा है';

  @override
  String get queue => 'क्यू';

  @override
  String get startWave => 'वेव शुरू करें';

  @override
  String get cover => 'आर्टवर्क';

  @override
  String get karaokeLyrics => 'कराओके गीत';

  @override
  String get findMusicStart => 'संगीत खोजें और प्लेबैक शुरू करें';

  @override
  String get playbackNotStarted => 'प्लेबैक शुरू नहीं हुआ';

  @override
  String get openSearchFirstTrack => 'अपना पहला ट्रैक खोजने के लिए खोज खोलें';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => 'डिवाइस पर';

  @override
  String get sourceCatalog => 'कैटलॉग';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'सर्वर';

  @override
  String get serverResolver => 'रिज़ॉल्वर सर्वर';

  @override
  String get serverResolverCaption =>
      'पूरे ऑडियो स्ट्रीम हल करने वाला वैकल्पिक स्व-होस्टेड सर्वर। ऐप खोज या ट्रैक ID भेजता है; सर्वर प्लेबैक URL लौटाता है। अनुबंध और संदर्भ कार्यान्वयन docs/REMOTE_RESOLVER.md में।';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'कॉन्फ़िगर नहीं';

  @override
  String get serverSave => 'सहेजें';

  @override
  String get serverDisable => 'अक्षम करें';

  @override
  String get onboardingWelcomeTitle => 'Hook में आपका स्वागत है';

  @override
  String get onboardingWelcomeCaption =>
      'संगीत, गीत और आपकी अपनी दृश्य शैली। शुरू करने के लिए भाषा चुनें — बाद में सेटिंग्स से बदल सकते हैं।';

  @override
  String get onboardingSkip => 'छोड़ें';

  @override
  String get onboardingNext => 'आगे';

  @override
  String get onboardingStart => 'सुनना शुरू करें';

  @override
  String get onboardingMicrogTitle => 'MicroG और Google खाता';

  @override
  String get onboardingMicrogBody =>
      'MicroG बिना Google सेवाओं वाले कस्टम Android ROM पर वे सेवाएँ फिर से बना देता है। Hook उन्हें केवल एक वैकल्पिक सुविधा के लिए उपयोग करता है: आपकी प्लेलिस्ट आयात करने के लिए YouTube खाता जोड़ना। संगीत चलाने के लिए MicroG या किसी Google सेवा की आवश्यकता कभी नहीं होती।';

  @override
  String get onboardingMicrogNote =>
      'प्लेबैक MicroG पर निर्भर नहीं है। खाता जोड़ना वैकल्पिक है।';

  @override
  String get onboardingMicrogDownload => 'MicroG डाउनलोड करें';

  @override
  String get onboardingMicrogStatusChecking =>
      'Google सेवाएँ जाँची जा रही हैं…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'इस डिवाइस पर Google सेवाएँ मौजूद हैं ($version)। खाता आयात तुरंत काम करेगा।';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'ReVanced GmsCore मिला ($version)। आधिकारिक Google साइन-इन SDK उसके साथ संगत नहीं है, इसलिए खाता जोड़ना काम न करे। प्लेबैक पर असर नहीं।';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'Google सेवाएँ नहीं मिलीं। YouTube खाते से प्लेलिस्ट आयात करने के लिए पहले MicroG इंस्टॉल करें — या इसे छोड़ें और Hook बिना खाते उपयोग करें।';

  @override
  String lyricsView(String mode) {
    return 'गीत दृश्य · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'आपकी पढ़ने की लय';

  @override
  String get lyricsModeSubtitle => 'गीत के नज़दीक जाने के तीन तरीके।';

  @override
  String get lyricsModeLines => 'पंक्तियाँ';

  @override
  String get lyricsModeKaraoke => 'कराओके';

  @override
  String get lyricsModeFocus => 'फ़ोकस';

  @override
  String get lyricsModeLinesDescription => 'शांत गीत, मौजूदा पंक्ति हाइलाइट';

  @override
  String get lyricsModeKaraokeDescription =>
      'शब्द वोकल के साथ सहज रोशन होते हैं';

  @override
  String get lyricsModeFocusDescription => 'एक बड़ी पंक्ति। बस।';

  @override
  String get lyricsModeSaveFailed => 'गीत दृश्य सहेजा नहीं जा सका।';

  @override
  String get lyricsModeFootnote =>
      'आपकी पसंद अगले गानों के लिए सहेजी जाती है। कराओके की सटीकता स्रोत डेटा पर है: शब्द-समय के बिना हाइलाइटिंग अनुमानित है, और समय-मुद्राओं के बिना गीत रुका रहता है।';

  @override
  String get lyricsNotFound => 'गीत नहीं मिला';

  @override
  String get karaokeUnavailable => 'इस ट्रैक के लिए कराओके गीत उपलब्ध नहीं';

  @override
  String get unsyncedLyrics => 'असमकालिक गीत';

  @override
  String get wordSyncUpper => 'शब्द-दर-शब्द सिंक';

  @override
  String get lineSyncUpper => 'पंक्ति-दर-पंक्ति सिंक';

  @override
  String get adjustLyricsSync => 'गीत सिंक समायोजित करें';

  @override
  String get startsSoon => 'शीघ्र शुरू';

  @override
  String get musicContinues => 'संगीत जारी';

  @override
  String get decreaseLyricsOffset => 'ऑफ़सेट 0.1 से घटाएँ';

  @override
  String lyricsOffset(String value) {
    return 'ऑफ़सेट: $value से';
  }

  @override
  String get increaseLyricsOffset => 'ऑफ़सेट 0.1 से बढ़ाएँ';

  @override
  String get hideSetting => 'सेटिंग छिपाएँ';

  @override
  String get lyricsOffsetSaveFailed => 'गीत ऑफ़सेट सहेजा नहीं जा सका।';

  @override
  String get audioForbidden =>
      'ऑडियो सर्वर ने पहुँच अस्वीकार की (HTTP 403)। ट्रैक मिला, पर उसकी स्ट्रीम उपलब्ध नहीं। VPN ऑडियो पहुँच की गारंटी नहीं देता।';

  @override
  String get fullVersionUnavailable =>
      'उपलब्ध स्रोतों में पूरा संस्करण नहीं मिला। कनेक्शन जाँचें या बाद में कोशिश करें।';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source यह ट्रैक नहीं चला सका। कनेक्शन जाँचें या बाद में कोशिश करें।';
  }

  @override
  String get recentQueriesUpper => 'हाल की खोजें';

  @override
  String get clearHistory => 'साफ़ करें';

  @override
  String get waveFromArtist => 'आर्टिस्ट वेव';

  @override
  String get popularTracksUpper => 'लोकप्रिय गाने';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गाने',
      one: '1 गाना',
      zero: 'अभी कोई गाने नहीं',
    );
    return '$_temp0';
  }
}
