// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'การตั้งค่า';

  @override
  String get settingsCaption => 'การเปลี่ยนแปลงจะถูกบันทึกไว้บนอุปกรณ์นี้';

  @override
  String get playerSettings => 'เครื่องเล่น';

  @override
  String get lyricsAutoHide => 'ซ่อนปุ่มควบคุมขณะอ่านเนื้อเพลง';

  @override
  String get lyricsAutoHideDescription =>
      'หลังจากไม่มีการสัมผัส 10 วินาที แผงของเครื่องเล่นจะเลื่อนออกจากจอ ใช้ปุ่มกู้คืนเพื่อดึงกลับมา';

  @override
  String get showPlayerControls => 'แสดงปุ่มควบคุมเครื่องเล่น';

  @override
  String get equalizer => 'อีควอไลเซอร์';

  @override
  String get equalizerEnabled => 'การประมวลผลเสียง';

  @override
  String get equalizerPresets => 'โปรไฟล์เสียง';

  @override
  String get equalizerFlat => 'ดั้งเดิม';

  @override
  String get equalizerBass => 'เบสลึก';

  @override
  String get equalizerVocal => 'เสียงร้อง';

  @override
  String get equalizerRock => 'ร็อก';

  @override
  String get equalizerElectronic => 'อิเล็กทรอนิกส์';

  @override
  String get equalizerSoft => 'นุ่มนวล';

  @override
  String get equalizerCustom => 'กำหนดเอง';

  @override
  String get equalizerBands => 'แถบความถี่';

  @override
  String get equalizerBassBoost => 'เพิ่มเบส';

  @override
  String get equalizerBassUnsupported =>
      'ไม่รองรับการเพิ่มเบสเพิ่มเติม ใช้แถบความถี่ต่ำแทน';

  @override
  String get equalizerPreamp => 'พรีแอมป์';

  @override
  String get equalizerHeadroom => 'ระยะหัวอัตโนมัติ';

  @override
  String get equalizerHeadroomDescription =>
      'ลดระดับเสียงออกเมื่อเพิ่มความถี่ เพื่อเว้นที่ว่างให้เสียงพีค ไม่ใช่ลิมิเตอร์';

  @override
  String get equalizerWaiting =>
      'เปิดเพลงสักเพลงเพื่อเชื่อมอีควอไลเซอร์เข้ากับเซสชันเสียง';

  @override
  String get equalizerUnsupported =>
      'การประมวลผลเสียงตอนนี้ใช้ได้บน Android เท่านั้น';

  @override
  String get equalizerFailed =>
      'อุปกรณ์นี้เปิดเอฟเฟกต์เสียงไม่สำเร็จ แต่เพลงยังเล่นได้โดยไม่มีมัน';

  @override
  String get equalizerRetry => 'เชื่อมเอฟเฟกต์อีกครั้ง';

  @override
  String get equalizerLive => 'การเปลี่ยนแปลงมีผลทันทีและบันทึกไว้บนอุปกรณ์นี้';

  @override
  String get youtubeAccount => 'YouTube และ MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'เข้าถึงเพลย์ลิสต์แบบอ่านอย่างเดียว การล็อกอินไม่รับประกันว่าเสียงจะพร้อมใช้';

  @override
  String get youtubeAccountCompatibility => 'ความเข้ากันได้และความเป็นส่วนตัว';

  @override
  String get youtubeAccountSubtitle => 'เชื่อมบัญชีและนำเข้าเพลย์ลิสต์';

  @override
  String get youtubeAccountPrivacy =>
      'Hook ขอสิทธิ์เข้าถึง YouTube แบบอ่านอย่างเดียว กรอกรหัสผ่านในหน้าต่างระบบของ Google เท่านั้น ห้ามกรอกใน Hook โทเคนจะไม่ถูกส่งไปเซิร์ฟเวอร์ของ Hook และเก็บไว้ในหน่วยความจำเท่านั้น เชื่อมต่อใหม่หลังรีสตาร์ทแอป';

  @override
  String get youtubeAccountPlaybackNotice =>
      'การล็อกอินให้สิทธิ์เข้าถึงข้อมูลบัญชี ไม่ใช่สตรีมเสียง และไม่รับประกันการแก้ HTTP 403 การนำเข้าจะคงการบันทึกจาก YouTube ไว้โดยไม่แทนที่ด้วยแหล่งอื่น';

  @override
  String get youtubeAccountConnect => 'เชื่อมบัญชี';

  @override
  String get youtubeAccountDisconnect => 'ยกเลิกการเชื่อมต่อใน Hook';

  @override
  String get youtubeAccountDisconnected => 'ยังไม่ได้เชื่อมบัญชี';

  @override
  String get youtubeAccountDisconnectNotice =>
      'ยกเลิกการเชื่อมบัญชีนี้เฉพาะใน Hook? เพลย์ลิสต์ที่บันทึกไว้จะยังอยู่ บัญชี Google และ MicroG บนโทรศัพท์จะไม่ถูกออกจากระบบ';

  @override
  String get youtubeAccountSystem => 'Google API ของระบบ';

  @override
  String get youtubeAccountServicesMissing =>
      'ไม่มี Google API ของระบบที่เข้ากันได้ การติดตั้ง ReVanced GmsCore แยกต่างหากไม่สามารถแทนที่ได้สำหรับการล็อกอินของ Hook';

  @override
  String get youtubeAccountMicrogNotice =>
      'ตรวจพบการติดตั้ง ReVanced GmsCore แยกต่างหาก Hook ไม่ใช้บัญชีหรือโทเคนของ ReVanced MicroG ของระบบอาจให้ Google API ที่เข้ากันได้ แต่ไม่รับประกันความเข้ากันกับวิธีล็อกอินนี้';

  @override
  String get youtubeAccountRevancedFound =>
      'ติดตั้ง YouTube Music ReVanced แล้ว';

  @override
  String get youtubeAccountPlaylists => 'เพลย์ลิสต์ของบัญชี';

  @override
  String get youtubeAccountNoPlaylists =>
      'ไม่มีเพลย์ลิสต์ที่เข้าถึงได้ บางคอลเลกชันอัตโนมัติของ YouTube Music ไม่สามารถใช้ผ่าน YouTube Data API ได้';

  @override
  String get youtubeAccountMore => 'โหลดเพิ่ม';

  @override
  String get youtubeAccountPreview => 'เตรียมนำเข้า';

  @override
  String youtubeAccountProgress(int count) {
    return 'ได้รับเพลงแล้ว: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'ข้ามรายการที่ใช้ไม่ได้: $count รายการ จะไม่ถูกแทนที่ด้วยเพลงอื่น';
  }

  @override
  String get youtubeAccountSetup => 'ตั้งค่าการล็อกอิน';

  @override
  String get youtubeAccountSetupBody =>
      'นักพัฒนาต้องเปิดใช้ YouTube Data API v3 ใน Google Cloud, ลงทะเบียน OAuth ไคลเอนต์ Android สำหรับ com.hook.music และ SHA-1 การลงนามของบิลด์ที่ติดตั้ง และตั้งค่าหน้าขอความยินยอม เพิ่มผู้ใช้ที่อนุญาตในโหมดทดสอบ ดู docs/YOUTUBE_ACCOUNT_SETUP.md ห้ามเพิ่มรหัสผ่าน, ความลับไคลเอนต์ หรือโทเคนจากแอปอื่นเด็ดขาด';

  @override
  String get youtubeAccountConfigError =>
      'ยังไม่ได้ตั้งค่าการล็อกอินสำหรับบิลด์นี้ ตรวจสอบ OAuth ไคลเอนต์ Android, ชื่อแพ็กเกจ, SHA-1 และผู้ใช้ทดสอบที่อนุญาตใน Google Cloud';

  @override
  String get youtubeAccountPermissionError =>
      'ไม่ได้รับสิทธิ์อ่านข้อมูล YouTube';

  @override
  String get youtubeAccountExpired => 'เซสชันหมดอายุ เชื่อมบัญชีใหม่อีกครั้ง';

  @override
  String get youtubeAccountNoChannel =>
      'บัญชีที่เลือกไม่มีช่อง YouTube ที่เข้าถึงได้';

  @override
  String get youtubeAccountQuota =>
      'โควตา YouTube API เกินขีดจำกัด ลองอีกครั้งภายหลัง';

  @override
  String get youtubeAccountFailed =>
      'ดึงข้อมูล YouTube ไม่สำเร็จ ตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง';

  @override
  String get youtubeAccountUnsupported =>
      'การเชื่อมบัญชีต้องการ Android ที่มี Google API ของระบบที่เข้ากันได้';

  @override
  String get importedFromYouTube => 'นำเข้าจากบัญชี YouTube';

  @override
  String get translateLyrics => 'แปลเนื้อเพลง';

  @override
  String get hideTranslation => 'ซ่อนคำแปล';

  @override
  String get cancelTranslation => 'ยกเลิกการแปล';

  @override
  String get translationLoading => 'กำลังเตรียมคำแปล…';

  @override
  String get translationAttribution => 'แปลโดยอัตโนมัติด้วย Google Translate';

  @override
  String get translationNotice =>
      'คำแปลอาจไม่สื่อความหมายของเพลงได้ตรง เน้นคำแบบคาราโอเกะใช้ได้กับต้นฉบับเท่านั้น';

  @override
  String get translationModelTitle => 'ดาวน์โหลดโมเดลภาษา?';

  @override
  String get translationModelBody =>
      'การแปลทำงานบนโทรศัพท์ของคุณ: เนื้อเพลงไม่ถูกส่งไปเซิร์ฟเวอร์ การแปลครั้งแรกต้องใช้โมเดล Google ML Kit ซึ่งกินพื้นที่สิบกว่าเมกะไบต์ การดาวน์โหลดใช้การเชื่อมต่อปัจจุบันรวมถึงเน็ตมือถือ ยกเลิกจะซ่อนผลลัพธ์ แต่การดาวน์โหลดที่เริ่มแล้วอาจเสร็จในเบื้องหลัง';

  @override
  String get translationDownload => 'ดาวน์โหลดและแปล';

  @override
  String get translationUnavailable =>
      'แปลไม่สำเร็จ ตรวจสอบการเข้าถึงการดาวน์โหลดโมเดลแล้วลองอีกครั้ง';

  @override
  String get translationUnsupported =>
      'การแปลบนอุปกรณ์ตอนนี้ใช้ได้บน Android เท่านั้น';

  @override
  String get translationUnknownLanguage => 'ระบุภาษาที่รองรับของเพลงนี้ไม่ได้';

  @override
  String get translationSameLanguage => 'เนื้อเพลงเป็นภาษาที่เลือกอยู่แล้ว';

  @override
  String get translationTooLarge => 'เนื้อเพลงนี้ยาวเกินกว่าจะแปลบนอุปกรณ์';

  @override
  String get translationRussian => 'เป็นภาษารัสเซีย';

  @override
  String get translationEnglish => 'เป็นภาษาอังกฤษ';

  @override
  String get translationTarget => 'ภาษาคำแปล';

  @override
  String get retry => 'ลองอีกครั้ง';

  @override
  String get home => 'หน้าแรก';

  @override
  String get search => 'ค้นหา';

  @override
  String get library => 'คลัง';

  @override
  String get youtubeUnavailableTitle => 'YouTube ไม่พร้อมใช้งานในขณะนี้';

  @override
  String get youtubeUnavailableBody =>
      'ไม่ได้รับสตรีมเสียง ตรวจสอบเครือข่ายและเส้นทาง VPN ของคุณ: YouTube อาจปฏิเสธคำขอแม้มี VPN';

  @override
  String get checkAgain => 'ตรวจสอบอีกครั้ง';

  @override
  String get dismiss => 'ปิด';

  @override
  String get goodNight => 'ราตรีสวัสดิ์';

  @override
  String get goodMorning => 'อรุณสวัสดิ์';

  @override
  String get goodAfternoon => 'สวัสดียามบ่าย';

  @override
  String get goodEvening => 'สวัสดียามเย็น';

  @override
  String get themeSettings => 'ตั้งค่าหน้าตา';

  @override
  String get onYourAir => 'บนคลื่นของคุณ';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'สัญญาณล่าสุด $count รายการ',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'คอลเลกชันของคุณกำลังรออยู่';

  @override
  String get saved => 'บันทึกแล้ว';

  @override
  String get collectionEmptyDetail => 'เพลงที่อยากกลับมาฟังจะอยู่ที่นี่';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count เพลง',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'เพลง ศิลปิน หรือเนื้อร้อง';

  @override
  String get searchUpper => 'ค้นหา';

  @override
  String get findFirstTrack => 'หาเพลงแรกของคุณ';

  @override
  String continuationAfter(String artist) {
    return 'เพลงเพิ่มเติมหลังจาก $artist';
  }

  @override
  String get chooseTrackWaveDetail =>
      'เลือกเพลงหนึ่งเพลง เราจะสร้างคลื่นตามอารมณ์ของมันให้';

  @override
  String get continueWaveLabel => 'ดำเนินต่อ / 01';

  @override
  String get yourWaveLabel => 'คลื่นของคุณ / 01';

  @override
  String get continueWave => 'ฟังคลื่นต่อ';

  @override
  String get chooseTrack => 'เลือกเพลง';

  @override
  String get firstTrace => 'ฝากรอยแรกของคุณไว้ที่นี่';

  @override
  String get favoriteWaveHint => 'บันทึกรายการโปรด คลื่นของคุณจะแม่นยำขึ้น';

  @override
  String get openSearch => 'เปิดหน้าค้นหา';

  @override
  String get findYourMusic => 'ค้นพบเสียงของคุณ';

  @override
  String get importMusic => 'นำเข้าเพลง';

  @override
  String get rememberedLyricsHint => 'คำที่คุณจำได้…';

  @override
  String get trackArtistHint => 'เพลงหรือศิลปิน — ภาษาใดก็ได้';

  @override
  String get clear => 'ล้าง';

  @override
  String get music => 'เพลง';

  @override
  String get byLyrics => 'จากเนื้อร้อง';

  @override
  String get allSources => 'ทุกแหล่ง';

  @override
  String get lyricsSearchCaption => 'ค้นหาวลีในเพลง ไม่ใช่แค่ชื่อเพลง';

  @override
  String get searchingLyrics => 'กำลังหาบทร้องที่คุ้นเคย…';

  @override
  String get searchingSources => 'กำลังค้นหาจากแหล่งเพลง…';

  @override
  String get connectionFailed => 'เชื่อมต่อไม่สำเร็จ';

  @override
  String get noMatches => 'ยังไม่มีผลที่ตรง';

  @override
  String get lyricsUnavailable =>
      'การค้นหาเนื้อเพลงไม่พร้อมใช้ตอนนี้ ลองภายหลังหรือค้นจากชื่อเพลง';

  @override
  String get searchUnavailable =>
      'ค้นหาไม่สำเร็จ ตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง';

  @override
  String get lyricsNoMatches => 'ลองบทอื่นดู ไม่ใช่ทุกเนื้อเพลงถูกจัดทำดัชนี';

  @override
  String get trackNoMatches =>
      'เพิ่มชื่อศิลปินหรือเลือกแหล่งอื่น บางบริการอาจใช้ไม่ได้บนเครือข่ายของคุณ';

  @override
  String get repeatSearch => 'ค้นหาอีกครั้ง';

  @override
  String get lyricMatchesUpper => 'ผลเนื้อร้องที่ตรง';

  @override
  String get tracksUpper => 'เพลง';

  @override
  String playTrack(String title, String artist) {
    return 'เล่น $title, $artist';
  }

  @override
  String get familiarLinesUpper => 'บทที่คุ้นเคย';

  @override
  String get bestMatchUpper => 'ผลที่ตรงที่สุด';

  @override
  String get fullVersionOnPlayback => 'เราจะหาเวอร์ชันเต็มเมื่อเริ่มเล่น';

  @override
  String get forgotTitle => 'ลืมชื่อเพลง\nแต่ไม่ลืมเมโลดี้';

  @override
  String get startAsYouRemember =>
      'ชื่อ ชื่อเพลง หรือบทร้องสักบรรทัด\nเริ่มจากอะไรก็ได้ที่จำได้';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => 'ค้นหาชื่อตามที่มันออกเสียง';

  @override
  String get rememberOnlyLine => 'จำได้แค่บทร้องบรรทัดเดียว';

  @override
  String get findSongByWords => 'หาเพลงจากคำในเนื้อร้อง';

  @override
  String get yourArtistsUpper => 'ศิลปินของคุณ';

  @override
  String get language => 'ภาษา';

  @override
  String get languageCaption => 'อินเทอร์เฟซปรับตามที่คุณเลือกทันที';

  @override
  String get systemLanguage => 'ตามระบบ';

  @override
  String get russian => 'รัสเซีย';

  @override
  String get english => 'อังกฤษ';

  @override
  String get themesAndShaders => 'ธีมและเอฟเฟกต์';

  @override
  String get themesSubtitle => 'หน้าตา ภาษา และการเคลื่อนไหวของพื้นหลัง';

  @override
  String get invalidThemeJson =>
      'อ่านธีมไม่ได้ ตรวจสอบรูปแบบ JSON และค่าของฟิลด์';

  @override
  String get exportJson => 'ส่งออก JSON';

  @override
  String get importJson => 'นำเข้า JSON';

  @override
  String get readyThemes => 'ธีมสำเร็จรูป';

  @override
  String get gpuShaders => 'เอฟเฟกต์พื้นหลัง';

  @override
  String get meshGradient => 'เกรเดียนต์ GPU นุ่มนวลจากสีของเพลง';

  @override
  String get vinylNoise => 'เกรนแผ่นเสียงแอนะล็อก (Noise)';

  @override
  String get glassBlur => 'เบลอแบบกระจก (Backdrop Blur)';

  @override
  String get cornerRadius => 'รัศมีมุมโค้งของอินเทอร์เฟซ';

  @override
  String get importThemeTitle => 'นำเข้าธีมจาก JSON';

  @override
  String get pasteThemeJson => 'วางคอนฟิก JSON ของธีม:';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get apply => 'ใช้';

  @override
  String get themeApplied => 'ใช้ธีมสำเร็จ!';

  @override
  String get exportThemeTitle => 'ส่งออกธีม (JSON)';

  @override
  String get close => 'ปิด';

  @override
  String get copyJson => 'คัดลอก JSON';

  @override
  String get jsonCopied => 'คัดลอก JSON ธีมไปยังคลิปบอร์ดแล้ว!';

  @override
  String get libraryUpper => 'คลัง';

  @override
  String get localCollection => 'คอลเลกชันในเครื่องและเพลย์ลิสต์';

  @override
  String get importShort => 'นำเข้า';

  @override
  String get favorites => 'รายการโปรด';

  @override
  String get playlists => 'เพลย์ลิสต์';

  @override
  String get history => 'ประวัติ';

  @override
  String get offline => 'ออฟไลน์';

  @override
  String get favoritesEmpty =>
      'รายการโปรดของคุณยังว่างอยู่\nแตะหัวใจบนเพลงเพื่อเพิ่มเข้ามาที่นี่';

  @override
  String get historyEmpty =>
      'ประวัติการฟังของคุณยังว่างอยู่\nเล่นเพลงจากหน้าค้นหา แล้วมันจะมาปรากฏที่นี่';

  @override
  String get noPlaylists => 'คุณยังไม่มีเพลย์ลิสต์';

  @override
  String get importPlaylistHint =>
      'นำเข้าเพลย์ลิสต์ Spotify หรือวางรายชื่อเพลง';

  @override
  String get importMusicAction => 'นำเข้าเพลง';

  @override
  String get playPlaylist => 'เล่นเพลย์ลิสต์';

  @override
  String playlistStarted(String name, int count) {
    return 'กำลังเล่น «$name» ($count เพลง)';
  }

  @override
  String get deletePlaylist => 'ลบเพลย์ลิสต์';

  @override
  String get playAll => 'เล่นทั้งหมด';

  @override
  String get shuffle => 'สุ่มเพลง';

  @override
  String get localAudioCache => 'แคชเสียงในเครื่อง';

  @override
  String get cacheDescription =>
      'เพลงที่เล่นแล้วถูกเก็บไว้ในเครื่องเพื่อเปิดซ้ำได้ทันทีโดยไม่ต้องใช้เน็ต';

  @override
  String deviceUsage(String size) {
    return 'บนอุปกรณ์นี้: $size';
  }

  @override
  String get clearCache => 'ล้างแคชทั้งหมด';

  @override
  String savedTracksUpper(int count) {
    return 'เพลงที่บันทึกไว้ ($count):';
  }

  @override
  String get cacheFeaturesUpper => 'คุณสมบัติแคช:';

  @override
  String get offlineFirst => 'ออฟไลน์เป็นอันดับแรกเต็มรูปแบบ';

  @override
  String get offlineFirstDescription =>
      'เมื่อเปิดซ้ำ เสียงจะโหลดโดยตรงจากระบบไฟล์ของอุปกรณ์';

  @override
  String get maximumBitrate => 'บิตเรตสูงสุด';

  @override
  String get maximumBitrateDescription =>
      'สตรีม Opus/M4A สะอาดที่ 160–256 kbps ถูกเก็บโดยไม่แปลงรหัส';

  @override
  String get trafficAndBattery => 'ประหยัดเน็ตและแบตเตอรี่';

  @override
  String get trafficAndBatteryDescription =>
      'หลีกเลี่ยงคำขอเครือข่ายซ้ำ ๆ ช่วยให้โทรศัพท์ของคุณอยู่ได้นานขึ้น';

  @override
  String get cacheEmpty => 'แคชว่างเปล่า';

  @override
  String get cachedTracksAppear => 'เพลงที่ดาวน์โหลดจะปรากฏที่นี่โดยอัตโนมัติ';

  @override
  String get removeFromCache => 'ลบออกจากแคช';

  @override
  String get removeCachedTrackTitle => 'ลบเพลงออกจากแคช?';

  @override
  String removeCachedTrackBody(String title) {
    return '«$title» จะถูกลบออกจากอุปกรณ์นี้';
  }

  @override
  String get delete => 'ลบ';

  @override
  String get trackRemovedFromCache => 'ลบเพลงออกจากแคชแล้ว';

  @override
  String get clearCacheTitle => 'ล้างแคช?';

  @override
  String get clearCacheBody =>
      'ไฟล์เสียงที่บันทึกไว้ทั้งหมดจะถูกลบออกจากอุปกรณ์นี้ รายการโปรดและประวัติจะไม่เปลี่ยน';

  @override
  String get cacheCleared => 'ล้างแคชในเครื่องแล้ว';

  @override
  String get back => 'ย้อนกลับ';

  @override
  String get playlistActions => 'การกระทำกับเพลย์ลิสต์';

  @override
  String get playlistUpper => 'เพลย์ลิสต์';

  @override
  String get playlistEmpty => 'เพลย์ลิสต์นี้ยังไม่มีเพลง';

  @override
  String get pasteTrackList => 'วางรายชื่อเพลง';

  @override
  String get pasteImportLink => 'วางลิงก์เพื่อนำเข้า';

  @override
  String get tracksNotFound => 'ไม่พบเพลงจากลิงก์นั้น';

  @override
  String get importError => 'นำเข้าไม่สำเร็จ ตรวจสอบลิงก์และอินเทอร์เน็ตของคุณ';

  @override
  String importedPlaylistStarted(int count) {
    return 'กำลังเล่นเพลย์ลิสต์ที่นำเข้า ($count เพลง)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'นำเข้า ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return 'บันทึกเพลย์ลิสต์ «$name» ไว้ในคลังของคุณแล้ว!';
  }

  @override
  String get spotifyImportSubtitle => 'Spotify • เพลย์ลิสต์ อัลบั้ม และเพลง';

  @override
  String get artistTrackOrCsv => 'ศิลปิน — เพลง หรือ CSV จาก Exportify';

  @override
  String get pastePlaylistOrTrackLink => 'วางลิงก์เพลย์ลิสต์หรือเพลง';

  @override
  String get pasteFromClipboard => 'วางจากคลิปบอร์ด';

  @override
  String get link => 'ลิงก์';

  @override
  String get trackList => 'รายชื่อเพลง';

  @override
  String get playlistName => 'ชื่อเพลย์ลิสต์';

  @override
  String get startImport => 'เริ่มนำเข้า';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count เพลง';
  }

  @override
  String get importedFromSpotify => 'นำเข้าจาก Spotify';

  @override
  String get importIntro =>
      'พาเพลย์ลิสต์ของคุณมาด้วย ใช้ลิงก์ Spotify, รายชื่อเพลง หรือไฟล์ Exportify';

  @override
  String get importTextTab => 'ข้อความ';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'เลือกไฟล์';

  @override
  String get importFileHint =>
      'เลือก CSV ที่ส่งออกจาก Exportify หรือรายชื่อเพลงไฟล์ TXT UTF-8, ไม่เกิน 10 MB และ 10,000 เพลง';

  @override
  String get importFileAndroidOnly =>
      'การเลือกไฟล์ใช้ได้บน Android ที่นี่คุณวางเนื้อหา CSV หรือรายชื่อเพลงได้';

  @override
  String get importTextHint =>
      'หนึ่งบรรทัดต่อหนึ่งคู่ ศิลปิน — เพลง วาง CSV ทั้งไฟล์พร้อมหัวตารางก็ได้';

  @override
  String get importPreview => 'พรีวิวเพลง';

  @override
  String get importedFromCsv => 'นำเข้าจาก CSV';

  @override
  String get importedFromText => 'นำเข้าจากรายชื่อเพลง';

  @override
  String importMoreTracks(int count) {
    return 'และอีก $count เพลง';
  }

  @override
  String get importMetadataHint =>
      'เพลย์ลิสต์ถูกบันทึกบนอุปกรณ์นี้ เสียงจะถูกค้นหาตอนเล่นเพลง การนำเข้าไม่ได้ดาวน์โหลดเพลง';

  @override
  String get importAnother => 'นำเข้าอย่างอื่น';

  @override
  String get importReading => 'กำลังอ่านเพลย์ลิสต์ของคุณ…';

  @override
  String get importSaving => 'กำลังบันทึกลงคลัง…';

  @override
  String get importNameRequired => 'กรอกชื่อเพลย์ลิสต์';

  @override
  String get importNameExists =>
      'มีเพลย์ลิสต์ชื่อนี้อยู่แล้ว เลือกชื่ออื่นเพื่อเก็บทั้งสองไว้';

  @override
  String get importSaveFailed =>
      'บันทึกเพลย์ลิสต์ไม่สำเร็จ พรีวิวของคุณยังอยู่ — ลองอีกครั้ง';

  @override
  String get importFileTooLarge =>
      'ไฟล์นี้เกิน 10 MB แบ่งเพลย์ลิสต์เป็นไฟล์ส่งออกที่เล็กกว่า';

  @override
  String get importFileUnsupported => 'เลือกไฟล์ .csv หรือ .txt';

  @override
  String get importFileEncoding =>
      'อ่านการเข้ารหัสข้อความไม่ได้ บันทึกไฟล์เป็น UTF-8 แล้วลองอีกครั้ง';

  @override
  String get importCsvInvalid =>
      'CSV ไม่สมบูรณ์หรือเสียหาย ส่งออกใหม่โดยไม่แก้คอลัมน์หรือเครื่องหมายคำพูด';

  @override
  String get importCsvMissingColumns =>
      'CSV ต้องมีคอลัมน์ Track Name และ Artist Name(s) หรือ Title และ Artist ใช้ไฟล์ส่งออก Exportify ต้นฉบับ';

  @override
  String get importFileEmpty =>
      'ไม่พบเพลง เลือกไฟล์ส่งออกที่มีข้อมูล หรือวางรายการ ศิลปิน — เพลง';

  @override
  String get importTooManyTracks =>
      'การนำเข้าหนึ่งครั้งมีได้สูงสุด 10,000 เพลง แบ่งเพลย์ลิสต์นี้ ยังไม่มีอะไรถูกบันทึก';

  @override
  String get importFileReadFailed =>
      'เปิดไฟล์นี้ไม่ได้ ตรวจสอบว่ามีอยู่บนอุปกรณ์ของคุณแล้วเลือกใหม่';

  @override
  String get importSpotifyBlocked =>
      'Spotify ไม่ได้แชร์เพลย์ลิสต์นี้ในภูมิภาคของคุณ ส่งออกด้วย Exportify แล้วเลือกไฟล์ CSV แทน';

  @override
  String get listen => 'เล่น';

  @override
  String get addToPlaylists => 'เพิ่มในเพลย์ลิสต์';

  @override
  String trackSemantics(String title, String artist) {
    return 'เพลง $title, $artist';
  }

  @override
  String get trackActions => 'การกระทำกับเพลง';

  @override
  String get download => 'ดาวน์โหลด';

  @override
  String get downloading => 'กำลังดาวน์โหลด…';

  @override
  String get downloaded => 'ดาวน์โหลดแล้ว';

  @override
  String get downloadFailed => 'ดาวน์โหลดไม่สำเร็จ';

  @override
  String get removeDownload => 'ลบการดาวน์โหลด';

  @override
  String get downloadSavedOffline => 'บันทึกออฟไลน์แล้ว';

  @override
  String get startWaveFromTrack => 'เริ่มคลื่นจากเพลงนี้';

  @override
  String get addToQueue => 'เพิ่มในคิว';

  @override
  String addedToQueue(String title) {
    return 'เพิ่มในคิวแล้ว: $title';
  }

  @override
  String get removeFavorite => 'เอาออกจากรายการโปรด';

  @override
  String get addFavorite => 'เพิ่มในรายการโปรด';

  @override
  String get addToPlaylist => 'เพิ่มในเพลย์ลิสต์';

  @override
  String get goToArtist => 'ไปที่ศิลปิน';

  @override
  String get myPlaylist => 'เพลย์ลิสต์ของฉัน';

  @override
  String get newPlaylist => 'เพลย์ลิสต์ใหม่';

  @override
  String get name => 'ชื่อ';

  @override
  String get create => 'สร้าง';

  @override
  String get loading => 'กำลังโหลด…';

  @override
  String get pause => 'พัก';

  @override
  String get play => 'เล่น';

  @override
  String get next => 'ถัดไป';

  @override
  String get speedAndPitch => 'ความเร็วและระดับเสียง';

  @override
  String speedValue(String value) {
    return 'ความเร็ว: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'ระดับเสียง: ${value}x';
  }

  @override
  String get reset => 'รีเซ็ต';

  @override
  String get moreActions => 'การกระทำอื่น ๆ';

  @override
  String get playbackQueue => 'คิวการเล่น';

  @override
  String get queueEmpty => 'คิวว่างเปล่า';

  @override
  String get selectingSource => 'กำลังเลือกแหล่ง';

  @override
  String get collapsePlayer => 'ย่อเครื่องเล่น';

  @override
  String get nowPlayingUpper => 'กำลังเล่น';

  @override
  String get queue => 'คิว';

  @override
  String get startWave => 'เริ่มคลื่น';

  @override
  String get cover => 'ปก';

  @override
  String get karaokeLyrics => 'เนื้อร้องคาราโอเกะ';

  @override
  String get findMusicStart => 'หาเพลงแล้วเริ่มเล่น';

  @override
  String get playbackNotStarted => 'ยังไม่ได้เริ่มเล่น';

  @override
  String get openSearchFirstTrack => 'เปิดหน้าค้นหาเพื่อหาเพลงแรกของคุณ';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => 'ในเครื่อง';

  @override
  String get sourceCatalog => 'แคตตาล็อก';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'เซิร์ฟเวอร์';

  @override
  String get serverResolver => 'เซิร์ฟเวอร์ตัวค้นเสียง';

  @override
  String get serverResolverCaption =>
      'เซิร์ฟเวอร์ที่คุณโฮสต์เอง (ไม่บังคับ) สำหรับค้นหาสตรีมเสียงแบบเต็ม แอปส่งคำค้นหรือ ID เพลง เซิร์ฟเวอร์ตอบ URL สำหรับเล่น ข้อกำหนดและตัวอย่างการทำงานอยู่ใน docs/REMOTE_RESOLVER.md';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'ยังไม่ได้ตั้งค่า';

  @override
  String get serverSave => 'บันทึก';

  @override
  String get serverDisable => 'ปิดใช้งาน';

  @override
  String get onboardingWelcomeTitle => 'ยินดีต้อนรับสู่ Hook';

  @override
  String get onboardingWelcomeCaption =>
      'เพลง เนื้อร้อง และสไตล์ภาพของคุณเอง เลือกภาษาเพื่อเริ่มต้น — เปลี่ยนได้ทีหลังในการตั้งค่า';

  @override
  String get onboardingSkip => 'ข้าม';

  @override
  String get onboardingNext => 'ต่อไป';

  @override
  String get onboardingStart => 'เริ่มฟัง';

  @override
  String get onboardingMicrogTitle => 'MicroG และบัญชี Google';

  @override
  String get onboardingMicrogBody =>
      'MicroG สร้างบริการ Google ขึ้นมาใหม่บน ROM Android ดัดแปลงที่ไม่มีมาแต่แรก Hook ใช้บริการเหล่านี้เพียงฟีเจอร์เสริมเดียว คือเชื่อมบัญชี YouTube เพื่อนำเข้าเพลย์ลิสต์ การฟังเพลงไม่เคยต้องใช้ MicroG หรือบริการ Google ใด ๆ';

  @override
  String get onboardingMicrogNote =>
      'การเล่นเพลงไม่ขึ้นกับ MicroG การเชื่อมบัญชีเป็นทางเลือก';

  @override
  String get onboardingMicrogDownload => 'ดาวน์โหลด MicroG';

  @override
  String get onboardingMicrogStatusChecking => 'กำลังตรวจสอบบริการ Google…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'มีบริการ Google อยู่บนอุปกรณ์นี้ ($version) การนำเข้าบัญชีจะใช้ได้ทันที';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'ตรวจพบ ReVanced GmsCore ($version) SDK ล็อกอินของ Google อย่างเป็นทางการไม่เข้ากันกับมัน การเชื่อมบัญชีจึงอาจใช้ไม่ได้ การเล่นเพลงไม่ได้รับผลกระทบ';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'ไม่พบบริการ Google หากต้องการนำเข้าเพลย์ลิสต์จากบัญชี YouTube ให้ติดตั้ง MicroG ก่อน — หรือข้ามส่วนนี้ไปและใช้ Hook โดยไม่มีบัญชี';

  @override
  String lyricsView(String mode) {
    return 'มุมมองเนื้อร้อง · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'จังหวะการอ่านของคุณ';

  @override
  String get lyricsModeSubtitle => 'สามวิธีเข้าใกล้เพลง';

  @override
  String get lyricsModeLines => 'บรรทัด';

  @override
  String get lyricsModeKaraoke => 'คาราโอเกะ';

  @override
  String get lyricsModeFocus => 'โฟกัส';

  @override
  String get lyricsModeLinesDescription =>
      'เนื้อร้องเรียบ ๆ พร้อมไฮไลต์บรรทัดปัจจุบัน';

  @override
  String get lyricsModeKaraokeDescription =>
      'คำต่าง ๆ สว่างขึ้นพร้อมเสียงร้องอย่างนุ่มนวล';

  @override
  String get lyricsModeFocusDescription =>
      'บรรทัดใหญ่บรรทัดเดียว ไม่มีอย่างอื่น';

  @override
  String get lyricsModeSaveFailed => 'บันทึกมุมมองเนื้อร้องไม่สำเร็จ';

  @override
  String get lyricsModeFootnote =>
      'ตัวเลือกของคุณถูกบันทึกไว้สำหรับเพลงถัดไป ความแม่นของคาราโอเกะขึ้นกับข้อมูลต้นทาง: เน้นคำเป็นประมาณหากไม่มีเวลาต่อคำ และเนื้อร้องจะหยุดนิ่งหากไม่มีตราเวลา';

  @override
  String get lyricsNotFound => 'ไม่พบเนื้อร้อง';

  @override
  String get karaokeUnavailable => 'เนื้อร้องคาราโอเกะไม่มีสำหรับเพลงนี้';

  @override
  String get unsyncedLyrics => 'เนื้อร้องที่ยังไม่ซิงก์';

  @override
  String get wordSyncUpper => 'ซิงก์ทีละคำ';

  @override
  String get lineSyncUpper => 'ซิงก์ทีละบรรทัด';

  @override
  String get adjustLyricsSync => 'ปรับการซิงก์เนื้อร้อง';

  @override
  String get startsSoon => 'กำลังจะเริ่ม';

  @override
  String get musicContinues => 'เพลงเล่นต่อไป';

  @override
  String get decreaseLyricsOffset => 'ลดออฟเซ็ต 0.1 วินาที';

  @override
  String lyricsOffset(String value) {
    return 'ออฟเซ็ต: $value วินาที';
  }

  @override
  String get increaseLyricsOffset => 'เพิ่มออฟเซ็ต 0.1 วินาที';

  @override
  String get hideSetting => 'ซ่อนการตั้งค่า';

  @override
  String get lyricsOffsetSaveFailed => 'บันทึกออฟเซ็ตเนื้อร้องไม่สำเร็จ';

  @override
  String get audioForbidden =>
      'เซิร์ฟเวอร์เสียงปฏิเสธการเข้าถึง (HTTP 403) เพลงถูกพบแต่สตรีมใช้ไม่ได้ VPN ไม่รับประกันการเข้าถึงเสียง';

  @override
  String get fullVersionUnavailable =>
      'ไม่พบเวอร์ชันเต็มจากแหล่งที่มี ตรวจสอบการเชื่อมต่อหรือลองภายหลัง';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source เล่นเพลงนี้ไม่ได้ ตรวจสอบการเชื่อมต่อหรือลองภายหลัง';
  }

  @override
  String get recentQueriesUpper => 'การค้นหาล่าสุด';

  @override
  String get clearHistory => 'ล้าง';

  @override
  String get waveFromArtist => 'คลื่นจากศิลปิน';

  @override
  String get popularTracksUpper => 'เพลงยอดนิยม';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count เพลง',
      zero: 'ยังไม่มีเพลง',
    );
    return '$_temp0';
  }
}
