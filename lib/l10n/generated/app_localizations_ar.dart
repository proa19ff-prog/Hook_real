// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'الإعدادات';

  @override
  String get settingsCaption => 'تُحفظ التغييرات على هذا الجهاز.';

  @override
  String get playerSettings => 'المشغّل';

  @override
  String get lyricsAutoHide => 'إخفاء عناصر التحكم أثناء قراءة الكلمات';

  @override
  String get lyricsAutoHideDescription =>
      'بعد 10 ثوانٍ من عدم التفاعل، تنزلق لوحات المشغّل خارج الشاشة. استخدم زر الاستعادة لإعادتها.';

  @override
  String get showPlayerControls => 'إظهار عناصر تحكم المشغّل';

  @override
  String get equalizer => 'مُعادِل الصوت';

  @override
  String get equalizerEnabled => 'معالجة الصوت';

  @override
  String get equalizerPresets => 'الملف الصوتي';

  @override
  String get equalizerFlat => 'الأصلي';

  @override
  String get equalizerBass => 'باس عميق';

  @override
  String get equalizerVocal => 'غناء';

  @override
  String get equalizerRock => 'روك';

  @override
  String get equalizerElectronic => 'إلكترونية';

  @override
  String get equalizerSoft => 'ناعم';

  @override
  String get equalizerCustom => 'مخصص';

  @override
  String get equalizerBands => 'نطاقات الترددات';

  @override
  String get equalizerBassBoost => 'تعزيز الباس';

  @override
  String get equalizerBassUnsupported =>
      'تعزيز الباس الإضافي غير مدعوم. استخدم نطاقات الترددات المنخفضة.';

  @override
  String get equalizerPreamp => 'التضخيم المسبق';

  @override
  String get equalizerHeadroom => 'هامش تلقائي';

  @override
  String get equalizerHeadroomDescription =>
      'يخفض مستوى الخرج عند رفع الترددات لترك مساحة للذِرَوات. ليس محدِّداً.';

  @override
  String get equalizerWaiting =>
      'شغّل مقطوعة لربط مُعادِل الصوت بجلستها الصوتية.';

  @override
  String get equalizerUnsupported =>
      'معالجة الصوت متاحة حالياً على أندرويد فقط.';

  @override
  String get equalizerFailed =>
      'تعذّر على هذا الجهاز تشغيل المؤثرات الصوتية. لا يزال بإمكان الموسيقى أن تعمل بدونها.';

  @override
  String get equalizerRetry => 'إعادة ربط المؤثرات';

  @override
  String get equalizerLive => 'تُطبَّق التغييرات فوراً وتُحفَظ على هذا الجهاز.';

  @override
  String get youtubeAccount => 'يوتيوب وMicroG';

  @override
  String get youtubeAccountReadOnly =>
      'وصول للقراءة فقط إلى قوائم التشغيل. تسجيل الدخول لا يضمن توفّر الصوت.';

  @override
  String get youtubeAccountCompatibility => 'التوافق والخصوصية';

  @override
  String get youtubeAccountSubtitle => 'ربط الحساب واستيراد قوائم التشغيل';

  @override
  String get youtubeAccountPrivacy =>
      'يطلب Hook وصولاً للقراءة فقط إلى يوتيوب. أدخل كلمة المرور في نافذة نظام Google فقط، وليس في Hook أبداً. لا يُرسَل الرمز إلى أي خادم تابع لـ Hook ويُحفَظ في الذاكرة فقط. أعد الاتصال بعد إعادة تشغيل التطبيق.';

  @override
  String get youtubeAccountPlaybackNotice =>
      'منح تسجيل الدخول إمكانية الوصول إلى بيانات الحساب، لا إلى تدفقات الصوت. لا يضمن إصلاح الخطأ 403. تحافظ عمليات الاستيراد على تسجيلات يوتيوب دون استبدالها بمصدر آخر.';

  @override
  String get youtubeAccountConnect => 'ربط الحساب';

  @override
  String get youtubeAccountDisconnect => 'فصل الحساب في Hook';

  @override
  String get youtubeAccountDisconnected => 'لا يوجد حساب مرتبط';

  @override
  String get youtubeAccountDisconnectNotice =>
      'فصل هذا الحساب في Hook فقط؟ ستبقى قوائم التشغيل المحفوظة. لن تُسجَّل الخروج حسابات Google وMicroG على الهاتف.';

  @override
  String get youtubeAccountSystem => 'واجهات Google للنظام';

  @override
  String get youtubeAccountServicesMissing =>
      'واجهات Google للنظام المتوافقة غير متوفرة. تثبيت ReVanced GmsCore منفصلاً لا يحل محلها لتسجيل الدخول في Hook.';

  @override
  String get youtubeAccountMicrogNotice =>
      'تم رصد تثبيت منفصل لـ ReVanced GmsCore. لا يستخدم Hook حسابات أو رموز ReVanced. قد يوفر MicroG النظامي واجهات Google متوافقة، لكن التوافق مع طريقة تسجيل الدخول هذه غير مضمون.';

  @override
  String get youtubeAccountRevancedFound =>
      'تطبيق YouTube Music ReVanced مثبّت';

  @override
  String get youtubeAccountPlaylists => 'قوائم تشغيل الحساب';

  @override
  String get youtubeAccountNoPlaylists =>
      'لا توجد قوائم تشغيل متاحة. بعض مجموعات YouTube Music التلقائية غير متاحة عبر YouTube Data API.';

  @override
  String get youtubeAccountMore => 'تحميل المزيد';

  @override
  String get youtubeAccountPreview => 'تجهيز الاستيراد';

  @override
  String youtubeAccountProgress(int count) {
    return 'المقاطع المستردة: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'إدخالات غير متاحة تم تخطيها: $count. لا تُستبدل بمقاطع أخرى.';
  }

  @override
  String get youtubeAccountSetup => 'إعداد تسجيل الدخول';

  @override
  String get youtubeAccountSetupBody =>
      'على المطوّر تفعيل YouTube Data API v3 في Google Cloud، وتسجيل عميل OAuth لأندرويد باسم com.hook.music وببصمة SHA-1 لتوقيع النسخة المثبَّتة، وضبط شاشة الموافقة. أضف المستخدمين المسموح لهم في وضع الاختبار. راجع docs/YOUTUBE_ACCOUNT_SETUP.md. لا تضِف كلمات مرور أو أسرار عملاء أو رموزاً من تطبيقات أخرى مطلقاً.';

  @override
  String get youtubeAccountConfigError =>
      'تسجيل الدخول غير مضبوط لهذه النسخة. تحقق من عميل OAuth لأندرويد واسم الحزمة وSHA-1 والمستخدمين التجريبيين المسموح لهم في Google Cloud.';

  @override
  String get youtubeAccountPermissionError =>
      'لم يُمنَح الوصول للقراءة إلى بيانات يوتيوب.';

  @override
  String get youtubeAccountExpired => 'انتهت جلستك. أعد ربط الحساب.';

  @override
  String get youtubeAccountNoChannel =>
      'الحساب المحدد لا يملك قناة يوتيوب متاحة.';

  @override
  String get youtubeAccountQuota => 'تم تجاوز حصة واجهة يوتيوب. حاول لاحقاً.';

  @override
  String get youtubeAccountFailed =>
      'تعذّر جلب بيانات يوتيوب. تحقق من اتصالك وحاول مجدداً.';

  @override
  String get youtubeAccountUnsupported =>
      'يتطلب ربط الحساب أندرويد مع واجهات Google للنظام المتوافقة.';

  @override
  String get importedFromYouTube => 'مستورد من حساب يوتيوب';

  @override
  String get translateLyrics => 'ترجمة الكلمات';

  @override
  String get hideTranslation => 'إخفاء الترجمة';

  @override
  String get cancelTranslation => 'إلغاء الترجمة';

  @override
  String get translationLoading => 'جارٍ تجهيز الترجمة…';

  @override
  String get translationAttribution => 'مترجم آلياً بواسطة Google Translate';

  @override
  String get translationNotice =>
      'قد لا تنقل الترجمة معنى الأغنية بدقة. يقتصر تمييز الكلمات على النص الأصلي.';

  @override
  String get translationModelTitle => 'تنزيل نماذج اللغة؟';

  @override
  String get translationModelBody =>
      'تعمل الترجمة على هاتفك: لا تُرسَل الكلمات إلى أي خادم. تحتاج الترجمة الأولى إلى نماذج Google ML Kit التي تستهلك عشرات الميغابايت. يستخدم التنزيل اتصالك الحالي، بما فيه بيانات الجوال. الإلغاء يخفي النتيجة، لكن تنزيلاً بدأ فعلاً قد يكتمل في الخلفية.';

  @override
  String get translationDownload => 'تنزيل وترجمة';

  @override
  String get translationUnavailable =>
      'فشلت الترجمة. تحقق من إمكانية تنزيل النماذج وحاول مجدداً.';

  @override
  String get translationUnsupported =>
      'الترجمة على الجهاز متاحة حالياً على أندرويد فقط.';

  @override
  String get translationUnknownLanguage =>
      'تعذّر تحديد لغة مدعومة لهذه الأغنية.';

  @override
  String get translationSameLanguage => 'الكلمات بالفعل باللغة المحددة.';

  @override
  String get translationTooLarge =>
      'هذه الكلمات أطول من أن تُترجَم على الجهاز.';

  @override
  String get translationRussian => 'إلى الروسية';

  @override
  String get translationEnglish => 'إلى الإنجليزية';

  @override
  String get translationTarget => 'لغة الترجمة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get home => 'الرئيسية';

  @override
  String get search => 'بحث';

  @override
  String get library => 'المكتبة';

  @override
  String get youtubeUnavailableTitle => 'يوتيوب غير متاح حالياً';

  @override
  String get youtubeUnavailableBody =>
      'تعذّر الحصول على تدفق صوتي. تحقق من شبكتك ومسار VPN: قد يرفض يوتيوب الطلبات حتى مع VPN.';

  @override
  String get checkAgain => 'تحقق مجدداً';

  @override
  String get dismiss => 'تجاهل';

  @override
  String get goodNight => 'تصبح على خير';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get themeSettings => 'إعدادات المظهر';

  @override
  String get onYourAir => 'على هوائك';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إشارة حديثة',
      many: '$count إشارة حديثة',
      few: '$count إشارات حديثة',
      two: 'إشارتان حديثتان',
      one: 'إشارة حديثة واحدة',
      zero: 'لا إشارات حديثة',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'مجموعتك تنتظرك';

  @override
  String get saved => 'محفوظ';

  @override
  String get collectionEmptyDetail =>
      'الموسيقى التي تريد العودة إليها ستبقى هنا';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مقطوعة',
      many: '$count مقطوعة',
      few: '$count مقاطع',
      two: 'مقطوعتان',
      one: 'مقطوعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'مقطوعة أو فنان أو كلمات';

  @override
  String get searchUpper => 'بحث';

  @override
  String get findFirstTrack => 'اعثر على مقطوعتك الأولى';

  @override
  String continuationAfter(String artist) {
    return 'موسيقى أخرى بعد $artist';
  }

  @override
  String get chooseTrackWaveDetail => 'اختر مقطوعة وسنبنى موجة حول مزاجها.';

  @override
  String get continueWaveLabel => 'متابعة / 01';

  @override
  String get yourWaveLabel => 'موجتك / 01';

  @override
  String get continueWave => 'متابعة الموجة';

  @override
  String get chooseTrack => 'اختر مقطوعة';

  @override
  String get firstTrace => 'اترك أثرك الأول هنا';

  @override
  String get favoriteWaveHint => 'احفظ المفضلة وستصبح موجتك أدق.';

  @override
  String get openSearch => 'افتح البحث';

  @override
  String get findYourMusic => 'اعثر على صوتك.';

  @override
  String get importMusic => 'استيراد الموسيقى';

  @override
  String get rememberedLyricsHint => 'الكلمات التي تذكرها…';

  @override
  String get trackArtistHint => 'مقطوعة أو فنان — بأي لغة';

  @override
  String get clear => 'مسح';

  @override
  String get music => 'موسيقى';

  @override
  String get byLyrics => 'بالكلمات';

  @override
  String get allSources => 'كل المصادر';

  @override
  String get lyricsSearchCaption =>
      'ابحث عن عبارة من الأغنية، لا عن عنوانها فقط.';

  @override
  String get searchingLyrics => 'البحث عن أسطر مألوفة…';

  @override
  String get searchingSources => 'البحث في مصادر الموسيقى…';

  @override
  String get connectionFailed => 'تعذّر الاتصال';

  @override
  String get noMatches => 'لا تطابقات بعد';

  @override
  String get lyricsUnavailable =>
      'البحث في الكلمات غير متاح الآن. جرّب لاحقاً أو ابحث بالعنوان.';

  @override
  String get searchUnavailable => 'فشل البحث. تحقق من اتصالك وحاول مجدداً.';

  @override
  String get lyricsNoMatches => 'جرّب سطراً آخر. ليست كل الكلمات مفهرسة.';

  @override
  String get trackNoMatches =>
      'أضف اسم الفنان أو اختر مصدراً آخر. قد تكون بعض الخدمات غير متاحة على شبكتك.';

  @override
  String get repeatSearch => 'ابحث مجدداً';

  @override
  String get lyricMatchesUpper => 'تطابقات الكلمات';

  @override
  String get tracksUpper => 'المقاطع';

  @override
  String playTrack(String title, String artist) {
    return 'تشغيل $title لـ $artist';
  }

  @override
  String get familiarLinesUpper => 'أسطر مألوفة';

  @override
  String get bestMatchUpper => 'أفضل تطابق';

  @override
  String get fullVersionOnPlayback => 'سنجد النسخة الكاملة عند بدء التشغيل.';

  @override
  String get forgotTitle => 'نسيتَ العنوان.\nلا الموسيقى.';

  @override
  String get startAsYouRemember =>
      'اسم أو عنوان أو سطر من الأغنية.\nابدأ بما تتذكره.';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => 'ابحث عن الأسماء كما تُنطَق';

  @override
  String get rememberOnlyLine => 'أتذكر سطراً واحداً فقط';

  @override
  String get findSongByWords => 'اعثر على أغنية بكلماتها';

  @override
  String get yourArtistsUpper => 'فنانونك';

  @override
  String get language => 'اللغة';

  @override
  String get languageCaption => 'تتبع الواجهة اختيارك فوراً';

  @override
  String get systemLanguage => 'النظام';

  @override
  String get russian => 'الروسية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get themesAndShaders => 'السمات والتأثيرات';

  @override
  String get themesSubtitle => 'المظهر واللغة وحركة الخلفية';

  @override
  String get invalidThemeJson =>
      'تعذّرت قراءة السمة. تحقق من تنسيق JSON وقيم الحقول.';

  @override
  String get exportJson => 'تصدير JSON';

  @override
  String get importJson => 'استيراد JSON';

  @override
  String get readyThemes => 'سمات جاهزة';

  @override
  String get gpuShaders => 'تأثيرات الخلفية';

  @override
  String get meshGradient => 'تدرّج GPU ناعم مأخوذ من ألوان المقطوعة';

  @override
  String get vinylNoise => 'حبيبات الفينيل التناظرية (ضجيج)';

  @override
  String get glassBlur => 'ضبابية زجاجية (Backdrop Blur)';

  @override
  String get cornerRadius => 'انحناء زوايا الواجهة';

  @override
  String get importThemeTitle => 'استيراد سمة من JSON';

  @override
  String get pasteThemeJson => 'الصق إعدادات السمة بصيغة JSON:';

  @override
  String get cancel => 'إلغاء';

  @override
  String get apply => 'تطبيق';

  @override
  String get themeApplied => 'طُبِّقت السمة بنجاح!';

  @override
  String get exportThemeTitle => 'تصدير السمة (JSON)';

  @override
  String get close => 'إغلاق';

  @override
  String get copyJson => 'نسخ JSON';

  @override
  String get jsonCopied => 'نُسِخ JSON السمة إلى الحافظة!';

  @override
  String get libraryUpper => 'المكتبة';

  @override
  String get localCollection => 'المجموعة المحلية وقوائم التشغيل';

  @override
  String get importShort => 'استيراد';

  @override
  String get favorites => 'المفضلة';

  @override
  String get playlists => 'قوائم التشغيل';

  @override
  String get history => 'السجل';

  @override
  String get offline => 'دون اتصال';

  @override
  String get favoritesEmpty =>
      'مفضلتك فارغة.\nانقر على القلب عند مقطوعة لإضافتها هنا.';

  @override
  String get historyEmpty =>
      'سجل استماعك فارغ.\nشغّل موسيقى من البحث وستظهر هنا.';

  @override
  String get noPlaylists => 'لا تملك قوائم تشغيل بعد';

  @override
  String get importPlaylistHint =>
      'استورد قائمة تشغيل من سبوتيفاي أو الصق قائمة مقاطع.';

  @override
  String get importMusicAction => 'استيراد الموسيقى';

  @override
  String get playPlaylist => 'تشغيل القائمة';

  @override
  String playlistStarted(String name, int count) {
    return 'يتم تشغيل «$name» ($count مقاطع)';
  }

  @override
  String get deletePlaylist => 'حذف قائمة التشغيل';

  @override
  String get playAll => 'تشغيل الكل';

  @override
  String get shuffle => 'عشوائي';

  @override
  String get localAudioCache => 'ذاكرة الصوت المحلية';

  @override
  String get cacheDescription =>
      'تُحفَظ المقاطع المشغَّلة محلياً لإعادة الاستماع الفوري دون اتصال.';

  @override
  String deviceUsage(String size) {
    return 'على هذا الجهاز: $size';
  }

  @override
  String get clearCache => 'محو كل ذاكرة التخزين المؤقت';

  @override
  String savedTracksUpper(int count) {
    return 'المقاطع المحفوظة ($count):';
  }

  @override
  String get cacheFeaturesUpper => 'ميزات ذاكرة التخزين المؤقت:';

  @override
  String get offlineFirst => 'الأسبقية للاستخدام دون اتصال';

  @override
  String get offlineFirstDescription =>
      'عند إعادة الاستماع يُحمَّل الصوت مباشرة من نظام ملفات الجهاز.';

  @override
  String get maximumBitrate => 'أقصى معدل بت';

  @override
  String get maximumBitrateDescription =>
      'تُحفَظ تدفقات Opus/M4A النظيفة بمعدل 160–256 كيلوبت/ث دون إعادة ترميز.';

  @override
  String get trafficAndBattery => 'وفّر البيانات والبطارية';

  @override
  String get trafficAndBatteryDescription =>
      'تجنّب الطلبات الشبكية المتكررة يجعل هاتفك يدوم أطول.';

  @override
  String get cacheEmpty => 'ذاكرة التخزين المؤقت فارغة';

  @override
  String get cachedTracksAppear => 'ستظهر المقاطع المنزَّلة هنا تلقائياً';

  @override
  String get removeFromCache => 'إزالة من الذاكرة المؤقتة';

  @override
  String get removeCachedTrackTitle => 'إزالة المقطوعة من الذاكرة المؤقتة؟';

  @override
  String removeCachedTrackBody(String title) {
    return 'ستُزال «$title» من هذا الجهاز.';
  }

  @override
  String get delete => 'حذف';

  @override
  String get trackRemovedFromCache => 'أُزيلت المقطوعة من الذاكرة المؤقتة';

  @override
  String get clearCacheTitle => 'محو الذاكرة المؤقتة؟';

  @override
  String get clearCacheBody =>
      'ستُحذَف جميع ملفات الصوت المحفوظة من هذا الجهاز. لن تتغير المفضلة والسجل.';

  @override
  String get cacheCleared => 'مُحِيَت الذاكرة المؤقتة المحلية';

  @override
  String get back => 'رجوع';

  @override
  String get playlistActions => 'إجراءات القائمة';

  @override
  String get playlistUpper => 'قائمة التشغيل';

  @override
  String get playlistEmpty => 'لا توجد مقاطع في هذه القائمة بعد';

  @override
  String get pasteTrackList => 'الصق قائمة مقاطع';

  @override
  String get pasteImportLink => 'الصق رابطاً لاستيراده';

  @override
  String get tracksNotFound => 'لم يُعثَر على مقاطع في ذلك الرابط.';

  @override
  String get importError => 'فشل الاستيراد. تحقق من الرابط واتصالك بالإنترنت.';

  @override
  String importedPlaylistStarted(int count) {
    return 'يتم تشغيل قائمة مستوردة ($count مقاطع)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'استيراد ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return 'حُفِظت قائمة التشغيل «$name» في مكتبتك!';
  }

  @override
  String get spotifyImportSubtitle =>
      'سبوتيفاي • قوائم التشغيل والألبومات والمقاطع';

  @override
  String get artistTrackOrCsv => 'فنان — مقطوعة، أو ملف CSV من Exportify';

  @override
  String get pastePlaylistOrTrackLink => 'الصق رابط قائمة تشغيل أو مقطوعة';

  @override
  String get pasteFromClipboard => 'لصق من الحافظة';

  @override
  String get link => 'الرابط';

  @override
  String get trackList => 'قائمة المقاطع';

  @override
  String get playlistName => 'اسم قائمة التشغيل';

  @override
  String get startImport => 'بدء الاستيراد';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count مقاطع';
  }

  @override
  String get importedFromSpotify => 'مستورد من سبوتيفاي';

  @override
  String get importedFromDeezer => 'مستورد من ديزر';

  @override
  String get importIntro =>
      'أحضر قوائم تشغيلك معك. استخدم رابط سبوتيفاي أو قائمة مقاطع أو ملف Exportify.';

  @override
  String get importTextTab => 'نص';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'اختيار ملف';

  @override
  String get importFileHint =>
      'اختر ملف CSV المصدَّر من Exportify أو قائمة مقاطع TXT. UTF-8، حتى 10 ميغابايت و10,000 مقطوعة.';

  @override
  String get importFileAndroidOnly =>
      'اختيار الملفات متاح على أندرويد. هنا يمكنك لصق محتوى CSV أو قائمة مقاطع.';

  @override
  String get importTextHint =>
      'سطر لكل «فنان — مقطوعة». يمكنك أيضاً لصق ملف CSV كاملاً مع ترويسته.';

  @override
  String get importPreview => 'معاينة المقاطع';

  @override
  String get importedFromCsv => 'مستورد من CSV';

  @override
  String get importedFromText => 'مستورد من قائمة مقاطع';

  @override
  String importMoreTracks(int count) {
    return 'و$count أخرى';
  }

  @override
  String get importMetadataHint =>
      'تُحفَظ قائمة التشغيل على هذا الجهاز. يُبحَث عن الصوت عند تشغيل المقطوعة؛ الاستيراد لا ينزّل أغاني.';

  @override
  String get importAnother => 'استيراد شيء آخر';

  @override
  String get importReading => 'جارٍ قراءة قائمتك…';

  @override
  String get importSaving => 'جارٍ الحفظ في مكتبتك…';

  @override
  String get importNameRequired => 'أدخل اسم قائمة التشغيل.';

  @override
  String get importNameExists =>
      'توجد قائمة بهذا الاسم بالفعل. اختر اسماً آخر للاحتفاظ بالاثنتين.';

  @override
  String get importSaveFailed =>
      'تعذّر حفظ القائمة. معاينتك ما تزال هنا — حاول مجدداً.';

  @override
  String get importFileTooLarge =>
      'هذا الملف يتجاوز 10 ميغابايت. قسّم القائمة إلى تصديرات أصغر.';

  @override
  String get importFileUnsupported => 'اختر ملف .csv أو .txt.';

  @override
  String get importFileEncoding =>
      'تعذّرت قراءة ترميز النص. احفظ الملف بترميز UTF-8 وحاول مجدداً.';

  @override
  String get importCsvInvalid =>
      'ملف CSV غير مكتمل أو مشوه. أعد تصديره دون تعديل أعمدته أو علامات التنصيص.';

  @override
  String get importCsvMissingColumns =>
      'يحتاج ملف CSV إلى عمودَي Track Name وArtist Name(s) أو Title وArtist. استخدم تصدير Exportify الأصلي.';

  @override
  String get importFileEmpty =>
      'لم يُعثَر على مقاطع. اختر تصديراً مملوءاً أو الصق قائمة «فنان — مقطوعة».';

  @override
  String get importTooManyTracks =>
      'يمكن لاستيراد واحد أن يحوي حتى 10,000 مقطوعة. قسّم هذه القائمة؛ لم يُحفَظ شيء بعد.';

  @override
  String get importFileReadFailed =>
      'تعذّر فتح الملف. تأكد من توفره على جهازك واختره مجدداً.';

  @override
  String get importSpotifyBlocked =>
      'لم تشارك سبوتيفاي هذه القائمة في منطقتك. صدِّرها عبر Exportify واختر ملف CSV بدلاً من ذلك.';

  @override
  String get listen => 'تشغيل';

  @override
  String get addToPlaylists => 'إضافة إلى قوائم التشغيل';

  @override
  String trackSemantics(String title, String artist) {
    return 'مقطوعة $title، $artist';
  }

  @override
  String get trackActions => 'إجراءات المقطوعة';

  @override
  String get updatesTitle => 'التحديثات';

  @override
  String get accountTitle => 'الحساب';

  @override
  String get waveLoading => 'جارٍ البحث عن أغانٍ مشابهة…';

  @override
  String get sleepTimer => 'مؤقت النوم';

  @override
  String sleepMinutes(String value) {
    return '$value';
  }

  @override
  String get sleepUntilTrackEnd => 'حتى نهاية المقطوعة';

  @override
  String get sleepCancel => 'إيقاف';

  @override
  String get dislike => 'لا يعجبني';

  @override
  String get dislikeRemove => 'إزالة من المخفي';

  @override
  String dislikeSaved(String artist) {
    return 'تم إخفاء: $artist';
  }

  @override
  String get exportPlaylist => 'تصدير CSV';

  @override
  String get playlistExported => 'تم تصدير القائمة';

  @override
  String get exportFailed => 'فشل التصدير';

  @override
  String get downloadAll => 'تنزيل الكل';

  @override
  String get statsTitle => 'الإحصائيات';

  @override
  String get statsPlays => 'مرات التشغيل';

  @override
  String get statsFavorites => 'المفضلة';

  @override
  String get statsPlaylists => 'القوائم';

  @override
  String get statsTopArtists => 'أفضل الفنانين';

  @override
  String get statsTopTracks => 'أفضل المقاطع';

  @override
  String resumeTitle(String device) {
    return 'متابعة على $device';
  }

  @override
  String get alwaysOnTop => 'إبقاء النافذة في الأعلى';

  @override
  String get randomPick => 'اختيار عشوائي لك';

  @override
  String get accountCaption => 'مزامنة مكتبتك بين الأجهزة';

  @override
  String get nickname => 'الاسم المستعار';

  @override
  String get nicknameHint => '٣–٢٠ حرفًا: أحرف وأرقام و . _ -';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordMinHint => '٦ أحرف على الأقل';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get haveAccountToggle => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get noAccountToggle => 'لا تملك حسابًا بعد؟ أنشئ واحدًا';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get syncNow => 'مزامنة الآن';

  @override
  String get syncing => 'جارٍ المزامنة…';

  @override
  String syncedAt(String time) {
    return 'تمت المزامنة: $time';
  }

  @override
  String get neverSynced => 'لم تتم المزامنة بعد';

  @override
  String get errorNicknameTaken => 'هذا الاسم مستعار محجوز';

  @override
  String get errorNicknameInvalid => 'الاسم: ٣–٢٠ حرفًا، أحرف/أرقام/._-';

  @override
  String get errorInvalidCredentials => 'اسم أو كلمة مرور خاطئة';

  @override
  String get errorWeakPassword => 'كلمة المرور قصيرة جدًا';

  @override
  String get errorNetwork => 'لا يوجد اتصال';

  @override
  String get errorServer => 'خطأ في الخادم، حاول لاحقًا';

  @override
  String currentVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get checkForUpdates => 'التحقق من التحديثات';

  @override
  String get checkingForUpdates => 'جارٍ التحقق…';

  @override
  String get upToDate => 'لديك أحدث إصدار';

  @override
  String updateAvailable(String version) {
    return 'الإصدار $version متاح';
  }

  @override
  String get downloadingUpdate => 'جارٍ تنزيل التحديث…';

  @override
  String get installUpdate => 'تثبيت';

  @override
  String get updateCheckFailed => 'تعذّر التحقق من التحديثات. تحقق من اتصالك.';

  @override
  String get installPermissionNeeded =>
      'اسمح لـ Hook بتثبيت التطبيقات ثم اضغط تثبيت مرة أخرى.';

  @override
  String updateSize(String size) {
    return '$size م.ب';
  }

  @override
  String get download => 'تنزيل';

  @override
  String get downloading => 'جارٍ التنزيل…';

  @override
  String get downloaded => 'تم التنزيل';

  @override
  String get downloadFailed => 'تعذّر التنزيل';

  @override
  String get removeDownload => 'إزالة التنزيل';

  @override
  String get downloadSavedOffline => 'محفوظ دون اتصال';

  @override
  String get startWaveFromTrack => 'بدء موجة من هذه المقطوعة';

  @override
  String get addToQueue => 'إضافة إلى قائمة الانتظار';

  @override
  String addedToQueue(String title) {
    return 'أُضيف إلى قائمة الانتظار: $title';
  }

  @override
  String get removeFavorite => 'إزالة من المفضلة';

  @override
  String get addFavorite => 'إضافة إلى المفضلة';

  @override
  String get addToPlaylist => 'إضافة إلى قائمة تشغيل';

  @override
  String get goToArtist => 'الانتقال إلى الفنان';

  @override
  String get myPlaylist => 'قائمتي';

  @override
  String get newPlaylist => 'قائمة جديدة';

  @override
  String get name => 'الاسم';

  @override
  String get create => 'إنشاء';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get play => 'تشغيل';

  @override
  String get next => 'التالي';

  @override
  String get speedAndPitch => 'السرعة والطبقة';

  @override
  String speedValue(String value) {
    return 'السرعة: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'الطبقة: ${value}x';
  }

  @override
  String get reset => 'إعادة ضبط';

  @override
  String get moreActions => 'إجراءات أخرى';

  @override
  String get playbackQueue => 'قائمة انتظار التشغيل';

  @override
  String get queueEmpty => 'قائمة الانتظار فارغة';

  @override
  String get selectingSource => 'جارٍ اختيار المصدر';

  @override
  String get collapsePlayer => 'تصغير المشغّل';

  @override
  String get nowPlayingUpper => 'يُشغَّل الآن';

  @override
  String get queue => 'قائمة الانتظار';

  @override
  String get startWave => 'بدء الموجة';

  @override
  String get cover => 'الغلاف';

  @override
  String get karaokeLyrics => 'كلمات كاريوكي';

  @override
  String get findMusicStart => 'اعثر على موسيقى وابدأ التشغيل';

  @override
  String get playbackNotStarted => 'لم يبدأ التشغيل بعد';

  @override
  String get openSearchFirstTrack => 'افتح البحث لتعثر على مقطوعتك الأولى';

  @override
  String get sourceSoundCloud => 'ساوندكلاود';

  @override
  String get sourceDevice => 'على الجهاز';

  @override
  String get sourceCatalog => 'الكتالوج';

  @override
  String get sourceYouTube => 'يوتيوب';

  @override
  String get sourceAudius => 'أوديوس';

  @override
  String get sourceServer => 'الخادم';

  @override
  String get serverResolver => 'خادم التحليل';

  @override
  String get serverResolverCaption =>
      'خادم ذاتي الاستضافة اختياري يحلل تدفقات صوتية كاملة. يرسل التطبيق بحثاً أو معرّف مقطوعة؛ ويعيد الخادم رابط تشغيل. العقد والتنفيذ المرجعي في docs/REMOTE_RESOLVER.md.';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'غير مضبوط';

  @override
  String get serverSave => 'حفظ';

  @override
  String get serverDisable => 'تعطيل';

  @override
  String get onboardingWelcomeTitle => 'مرحباً بك في Hook';

  @override
  String get onboardingWelcomeCaption =>
      'موسيقى وكلمات وأسلوب بصري من صنعك. اختر لغة للبدء — يمكنك تغييرها لاحقاً في الإعدادات.';

  @override
  String get onboardingSkip => 'تخطٍّ';

  @override
  String get onboardingNext => 'متابعة';

  @override
  String get onboardingStart => 'ابدأ الاستماع';

  @override
  String get onboardingMicrogTitle => 'MicroG وحساب Google';

  @override
  String get onboardingMicrogBody =>
      'يعيد MicroG بناء خدمات Google على نسخ أندرويد المخصصة التي تأتي بدونها. لا يستخدمها Hook إلا لميزة اختيارية واحدة: ربط حساب يوتيوب لاستيراد قوائم التشغيل. تشغيل الموسيقى لا يتطلب MicroG ولا أي خدمة من Google أبداً.';

  @override
  String get onboardingMicrogNote =>
      'لا يعتمد التشغيل على MicroG. ربط الحساب أمر اختياري.';

  @override
  String get onboardingMicrogDownload => 'تنزيل MicroG';

  @override
  String get onboardingMicrogStatusChecking => 'جارٍ فحص خدمات Google…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'خدمات Google متوفرة على هذا الجهاز ($version). سيعمل استيراد الحساب فوراً.';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'رُصد ReVanced GmsCore ($version). حزمة تسجيل الدخول الرسمية من Google غير متوافقة معه، لذا قد لا يعمل ربط الحساب. التشغيل لا يتأثر.';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'لم تُعثَر على خدمات Google. لاستيراد قوائم التشغيل من حساب يوتيوب، ثبّت MicroG أولاً — أو تخطَّ هذا واستخدم Hook بدون حساب.';

  @override
  String lyricsView(String mode) {
    return 'عرض الكلمات · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'إيقاع قراءتك';

  @override
  String get lyricsModeSubtitle => 'ثلاث طرق للاقتراب من الأغنية.';

  @override
  String get lyricsModeLines => 'أسطر';

  @override
  String get lyricsModeKaraoke => 'كاريوكي';

  @override
  String get lyricsModeFocus => 'تركيز';

  @override
  String get lyricsModeLinesDescription => 'كلمات هادئة مع تمييز السطر الحالي';

  @override
  String get lyricsModeKaraokeDescription => 'تضيء الكلمات بسلاسة مع الغناء';

  @override
  String get lyricsModeFocusDescription => 'سطر كبير واحد. لا شيء آخر';

  @override
  String get lyricsModeSaveFailed => 'تعذّر حفظ عرض الكلمات.';

  @override
  String get lyricsModeFootnote =>
      'يُحفَظ اختيارك للأغاني القادمة. تعتمد دقة الكاريوكي على بيانات المصدر: تمييز الكلمات تقريبي دون توقيت لكل كلمة، وتبقى الكلمات ثابتة دون طوابع زمنية.';

  @override
  String get lyricsNotFound => 'لم تُعثَر على الكلمات';

  @override
  String get karaokeUnavailable => 'كلمات الكاريوكي غير متاحة لهذه المقطوعة';

  @override
  String get unsyncedLyrics => 'كلمات غير متزامنة';

  @override
  String get wordSyncUpper => 'مزامنة كلمة بكلمة';

  @override
  String get lineSyncUpper => 'مزامنة سطراً بسطر';

  @override
  String get adjustLyricsSync => 'ضبط مزامنة الكلمات';

  @override
  String get startsSoon => 'تبدأ قريباً';

  @override
  String get musicContinues => 'تستمر الموسيقى';

  @override
  String get decreaseLyricsOffset => 'تقليل الإزاحة بمقدار 0.1 ثانية';

  @override
  String lyricsOffset(String value) {
    return 'الإزاحة: $value ث';
  }

  @override
  String get increaseLyricsOffset => 'زيادة الإزاحة بمقدار 0.1 ثانية';

  @override
  String get hideSetting => 'إخفاء الإعداد';

  @override
  String get lyricsOffsetSaveFailed => 'تعذّر حفظ إزاحة الكلمات.';

  @override
  String get audioForbidden =>
      'رفض خادم الصوت الوصول (HTTP 403). وُجدت المقطوعة لكن تدفقها غير متاح. لا يضمن VPN الوصول إلى الصوت.';

  @override
  String get fullVersionUnavailable =>
      'لم يُعثَر على نسخة كاملة في المصادر المتاحة. تحقق من اتصالك أو حاول لاحقاً.';

  @override
  String sourcePlaybackFailed(String source) {
    return 'لم يتمكن $source من تشغيل هذه المقطوعة. تحقق من اتصالك أو حاول لاحقاً.';
  }

  @override
  String get recentQueriesUpper => 'عمليات البحث الأخيرة';

  @override
  String get clearHistory => 'مسح';

  @override
  String get waveFromArtist => 'موجة الفنان';

  @override
  String get popularTracksUpper => 'أشهر الأغاني';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أغنية',
      many: '$count أغنية',
      few: '$count أغانٍ',
      two: 'أغنيتان',
      one: 'أغنية واحدة',
      zero: 'لا أغانٍ بعد',
    );
    return '$_temp0';
  }

  @override
  String get volume => 'مستوى الصوت';

  @override
  String get systemVolume => 'النظام';

  @override
  String get appVolume => 'مستوى Hook';

  @override
  String get mute => 'كتم الصوت';

  @override
  String get unmute => 'تشغيل الصوت';

  @override
  String get volumeMixer => 'الصوت ومستواه';

  @override
  String get systemVolumeCaption =>
      'مستوى إخراج Windows المشترك مع كل التطبيقات';

  @override
  String get appVolumeCaption => 'داخل Hook فقط، فوق مستوى النظام';

  @override
  String get volumeKeysHint => 'Ctrl + ↑ ↓ الصوت · M كتم';

  @override
  String get volumeUnavailable => 'مستوى صوت النظام غير متاح على هذا الجهاز';

  @override
  String get cacheFolder => 'مجلد التخزين';

  @override
  String get copyPath => 'نسخ المسار';

  @override
  String get pathCopied => 'تم نسخ المسار إلى الحافظة';

  @override
  String get previousTrack => 'المقطع السابق';

  @override
  String get repeatPlayback => 'تكرار';

  @override
  String get openPlayer => 'فتح المشغل';

  @override
  String get statsWeek => 'آخر 7 أيام';

  @override
  String get keyboardShortcuts => 'اختصارات لوحة المفاتيح';

  @override
  String get shortcutsCaption => 'تعمل في كل مكان عدا حقول النص.';

  @override
  String get shortcutsSeek => 'التقديم 10 ثوانٍ';

  @override
  String get playPauseShortcut => 'تشغيل / إيقاف مؤقت';

  @override
  String get ageRestrictedTrack =>
      'هذا المقطع مقيّد بالعمر (+18). يحتاج الخادم إلى ملفات تعريف ارتباط من حساب YouTube مسجّل الدخول.';

  @override
  String get haptics => 'اهتزاز اللمس';

  @override
  String get hapticsDescription =>
      'اهتزاز قصير عندما تغيّر اللمسة شيئًا. على Android و iOS فقط.';

  @override
  String get reduceMotion => 'تقليل الحركة';

  @override
  String get reduceMotionDescription =>
      'يتجاوز الانتقالات والخلفيات المتحركة. مفيد على الأجهزة البطيئة أو عند الحساسية للحركة.';

  @override
  String get backgroundPrefetch => 'تحميل المقاطع التالية مسبقًا';

  @override
  String get backgroundPrefetchDescription =>
      'يهيّئ المقاطع التالية في الخلفية لينتقل التشغيل فورًا. يستهلك بيانات أكثر قليلًا.';

  @override
  String get playbackSettings => 'التشغيل';

  @override
  String get cookieStatus => 'ملفات تعريف ارتباط YouTube';

  @override
  String get cookieStatusReady => 'تم تسجيل الدخول — يمكن تشغيل المقاطع +18';

  @override
  String get cookieStatusVisitor => 'لم يتم تسجيل الدخول — تُرفض المقاطع +18';

  @override
  String get cookieStatusUnknown => 'لم يُفحص بعد';

  @override
  String get cookieStatusCheck => 'فحص';

  @override
  String get cookieStatusChecking => 'جارٍ الفحص…';

  @override
  String get cookieStatusUpload => 'تحميل ملف الكوكيز';

  @override
  String get cookieStatusUploading => 'جارٍ التحميل…';

  @override
  String cookieUploadAccepted(int cookies) {
    return 'تم تحميل $cookies من ملفات الكوكيز — المقاطع +18 متاحة';
  }

  @override
  String cookieUploadRejected(String reason) {
    return 'رفض الخادم الملف: $reason';
  }

  @override
  String get cookieUploadApology =>
      'هذا التصدير ليس جلسة مسجَّلة، لذا لن تعمل المقاطع +18. سجّل الدخول إلى YouTube بحساب موثّق العمر ثم صدّر من جديد.';

  @override
  String get cookieStatusUnreachable => 'لم يستجب الخادم';
}
