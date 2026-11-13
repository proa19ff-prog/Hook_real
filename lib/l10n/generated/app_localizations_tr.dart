// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'Ayarlar';

  @override
  String get settingsCaption => 'Değişiklikler bu cihazda saklanır.';

  @override
  String get playerSettings => 'Çalar';

  @override
  String get lyricsAutoHide => 'Şarkı sözü okurken kontrolleri gizle';

  @override
  String get lyricsAutoHideDescription =>
      '10 saniye etkileşim olmadıktan sonra çalar panelleri ekrandan kayar. Geri getirmek için geri yükleme düğmesini kullanın.';

  @override
  String get showPlayerControls => 'Çalar kontrollerini göster';

  @override
  String get equalizer => 'Ekolayzer';

  @override
  String get equalizerEnabled => 'Ses işleme';

  @override
  String get equalizerPresets => 'Ses profili';

  @override
  String get equalizerFlat => 'Orijinal';

  @override
  String get equalizerBass => 'Derin bas';

  @override
  String get equalizerVocal => 'Vokal';

  @override
  String get equalizerRock => 'Rock';

  @override
  String get equalizerElectronic => 'Elektronik';

  @override
  String get equalizerSoft => 'Yumuşak';

  @override
  String get equalizerCustom => 'Özel';

  @override
  String get equalizerBands => 'Frekans bantları';

  @override
  String get equalizerBassBoost => 'Bas güçlendirme';

  @override
  String get equalizerBassUnsupported =>
      'Ek bas güçlendirme desteklenmiyor. Düşük frekans bantlarını kullanın.';

  @override
  String get equalizerPreamp => 'Ön yükseltme';

  @override
  String get equalizerHeadroom => 'Otomatik pay';

  @override
  String get equalizerHeadroomDescription =>
      'Frekans yükseltirken çıkış seviyesini azaltarak tepe seslere yer açar. Bir limiter değildir.';

  @override
  String get equalizerWaiting =>
      'Ekolayzeri ses oturumuna bağlamak için bir parça başlatın.';

  @override
  String get equalizerUnsupported =>
      'Ses işleme şu an yalnızca Android\'de kullanılabilir.';

  @override
  String get equalizerFailed =>
      'Bu cihaz ses efektlerini etkinleştiremedi. Müzik onlar olmadan da çalar.';

  @override
  String get equalizerRetry => 'Efektleri yeniden bağla';

  @override
  String get equalizerLive =>
      'Değişiklikler anında uygulanır ve bu cihazda saklanır.';

  @override
  String get youtubeAccount => 'YouTube ve MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'Play listelere salt okunur erişim. Oturum açmak sesin kullanılabilirliğini garanti etmez.';

  @override
  String get youtubeAccountCompatibility => 'Uyumluluk ve gizlilik';

  @override
  String get youtubeAccountSubtitle =>
      'Hesap bağlama ve çalma listesi içe aktarma';

  @override
  String get youtubeAccountPrivacy =>
      'Hook yalnızca salt okunur YouTube erişimi ister. Şifrenizi yalnızca Google\'ın sistem penceresine girin, asla Hook\'a değil. Belirteç hiçbir Hook sunucusuna gönderilmez ve yalnızca bellekte tutulur. Uygulamayı yeniden başlattıktan sonra yeniden bağlanın.';

  @override
  String get youtubeAccountPlaybackNotice =>
      'Oturum açmak hesap verilerine erişim verir, ses akışlarına değil. HTTP 403 sorununu çözme garantisi yoktur. İçe aktarmalar YouTube kayıtlarını başka bir kaynakla değiştirmeden korur.';

  @override
  String get youtubeAccountConnect => 'Hesabı bağla';

  @override
  String get youtubeAccountDisconnect => 'Hook\'ta bağlantıyı kes';

  @override
  String get youtubeAccountDisconnected => 'Bağlı hesap yok';

  @override
  String get youtubeAccountDisconnectNotice =>
      'Bu hesabın bağlantısı yalnızca Hook\'ta kesilsin mi? Kayıtlı çalma listeleri kalır. Telefondaki Google ve MicroG hesaplarının oturumu kapatılmaz.';

  @override
  String get youtubeAccountSystem => 'Sistem Google API\'leri';

  @override
  String get youtubeAccountServicesMissing =>
      'Uyumlu sistem Google API\'leri yok. Ayrı bir ReVanced GmsCore kurulumu Hook oturum açması için onların yerine geçmez.';

  @override
  String get youtubeAccountMicrogNotice =>
      'Ayrı bir ReVanced GmsCore kurulumu algılandı. Hook ReVanced hesaplarını veya belirteçlerini kullanmaz. Sistem MicroG\'si uyumlu Google API\'leri sağlayabilir, ancak bu oturum açma yöntemiyle uyumluluğu garanti edilmez.';

  @override
  String get youtubeAccountRevancedFound => 'YouTube Music ReVanced yüklü';

  @override
  String get youtubeAccountPlaylists => 'Hesap çalma listeleri';

  @override
  String get youtubeAccountNoPlaylists =>
      'Erişilebilir çalma listesi yok. Bazı otomatik YouTube Music derlemeleri YouTube Data API üzerinden kullanılamaz.';

  @override
  String get youtubeAccountMore => 'Daha fazla yükle';

  @override
  String get youtubeAccountPreview => 'İçe aktarmayı hazırla';

  @override
  String youtubeAccountProgress(int count) {
    return 'Alınan parçalar: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'Atlanan kullanılamayan girdiler: $count. Bunlar başka parçalarla değiştirilmez.';
  }

  @override
  String get youtubeAccountSetup => 'Oturum açma kurulumu';

  @override
  String get youtubeAccountSetupBody =>
      'Geliştiricinin Google Cloud\'da YouTube Data API v3\'ü etkinleştirmesi, com.hook.music ve yüklü derlemenin imza SHA-1\'i için bir Android OAuth istemcisi kaydetmesi ve onay ekranını yapılandırması gerekir. Test modunda izin verilen kullanıcıları ekleyin. Bakın: docs/YOUTUBE_ACCOUNT_SETUP.md. Asla parola, istemci sırrı veya başka uygulamaların belirteçlerini eklemeyin.';

  @override
  String get youtubeAccountConfigError =>
      'Oturum açma bu derleme için yapılandırılmamış. Google Cloud\'da Android OAuth istemcisini, paket adını, SHA-1\'i ve izin verilen test kullanıcılarını kontrol edin.';

  @override
  String get youtubeAccountPermissionError =>
      'YouTube verilerine okuma erişimi verilmedi.';

  @override
  String get youtubeAccountExpired =>
      'Oturumunuzun süresi doldu. Hesabı yeniden bağlayın.';

  @override
  String get youtubeAccountNoChannel =>
      'Seçilen hesabın erişilebilir bir YouTube kanalı yok.';

  @override
  String get youtubeAccountQuota =>
      'YouTube API kotası aşıldı. Daha sonra tekrar deneyin.';

  @override
  String get youtubeAccountFailed =>
      'YouTube verileri alınamadı. Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get youtubeAccountUnsupported =>
      'Hesap bağlama, uyumlu sistem Google API\'leri olan Android gerektirir.';

  @override
  String get importedFromYouTube => 'YouTube hesabından içe aktarıldı';

  @override
  String get translateLyrics => 'Sözleri çevir';

  @override
  String get hideTranslation => 'Çeviriyi gizle';

  @override
  String get cancelTranslation => 'Çeviriyi iptal et';

  @override
  String get translationLoading => 'Çeviri hazırlanıyor…';

  @override
  String get translationAttribution =>
      'Google Translate tarafından otomatik çevrildi';

  @override
  String get translationNotice =>
      'Çeviri, şarkının anlamını tam yansıtmayabilir. Kelime vurgulama yalnızca özgün metne uygulanır.';

  @override
  String get translationModelTitle => 'Dil modelleri indirilsin mi?';

  @override
  String get translationModelBody =>
      'Çeviri telefonunuzda çalışır: sözler hiçbir sunucuya gönderilmez. İlk çeviri, onlarca megabyte yer kaplayan Google ML Kit modellerini gerektirir. İndirme, mobil veri dahil mevcut bağlantınızı kullanır. İptal etmek sonucu gizler; ancak zaten başlamış bir model indirmesi arka planda tamamlanabilir.';

  @override
  String get translationDownload => 'İndir ve çevir';

  @override
  String get translationUnavailable =>
      'Çeviri başarısız oldu. Model indirmelerine erişimi kontrol edip tekrar deneyin.';

  @override
  String get translationUnsupported =>
      'Cihaz üzerinde çeviri şu an yalnızca Android\'de kullanılabilir.';

  @override
  String get translationUnknownLanguage =>
      'Bu şarkı için desteklenen bir dil tanımlanamadı.';

  @override
  String get translationSameLanguage => 'Sözler zaten seçilen dilde.';

  @override
  String get translationTooLarge =>
      'Bu sözler cihaz üzerinde çeviri için fazla uzun.';

  @override
  String get translationRussian => 'Rusçaya';

  @override
  String get translationEnglish => 'İngilizceye';

  @override
  String get translationTarget => 'Çeviri dili';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get home => 'Ana sayfa';

  @override
  String get search => 'Ara';

  @override
  String get library => 'Kitaplık';

  @override
  String get youtubeUnavailableTitle => 'YouTube şu anda kullanılamıyor';

  @override
  String get youtubeUnavailableBody =>
      'Ses akışı alınamadı. Ağınızı ve VPN rotanızı kontrol edin: YouTube istekleri VPN ile bile reddedebilir.';

  @override
  String get checkAgain => 'Yeniden kontrol et';

  @override
  String get dismiss => 'Kapat';

  @override
  String get goodNight => 'İyi geceler';

  @override
  String get goodMorning => 'Günaydın';

  @override
  String get goodAfternoon => 'İyi günler';

  @override
  String get goodEvening => 'İyi akşamlar';

  @override
  String get themeSettings => 'Görünüm ayarları';

  @override
  String get onYourAir => 'Yayınınızda';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yakın sinyal',
      one: '1 yakın sinyal',
      zero: 'Yakın sinyal yok',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'Koleksiyonunuz sizi bekliyor';

  @override
  String get saved => 'Kaydedildi';

  @override
  String get collectionEmptyDetail =>
      'Geri dönmek istediğiniz müzik burada kalacak';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parça',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'Parça, sanatçı veya söz';

  @override
  String get searchUpper => 'ARA';

  @override
  String get findFirstTrack => 'İlk parçanızı bulun';

  @override
  String continuationAfter(String artist) {
    return '$artist sonrasında daha fazla müzik';
  }

  @override
  String get chooseTrackWaveDetail =>
      'Bir parça seçin, ona dair bir dalga kuracağız.';

  @override
  String get continueWaveLabel => 'DEVAM / 01';

  @override
  String get yourWaveLabel => 'DALGANIZ / 01';

  @override
  String get continueWave => 'Dalgayı sürdür';

  @override
  String get chooseTrack => 'Bir parça seçin';

  @override
  String get firstTrace => 'İlk izinizi burada bırakın';

  @override
  String get favoriteWaveHint =>
      'Favorileri kaydedin, dalganız daha isabetli olur.';

  @override
  String get openSearch => 'Aramayı aç';

  @override
  String get findYourMusic => 'Sesinizi bulun.';

  @override
  String get importMusic => 'Müzik içe aktar';

  @override
  String get rememberedLyricsHint => 'Hatırladığınız sözler…';

  @override
  String get trackArtistHint => 'Parça veya sanatçı — herhangi bir dil';

  @override
  String get clear => 'Temizle';

  @override
  String get music => 'Müzik';

  @override
  String get byLyrics => 'Söze göre';

  @override
  String get allSources => 'Tüm kaynaklar';

  @override
  String get lyricsSearchCaption =>
      'Şarkının başlığını değil, bir dizesini arayın.';

  @override
  String get searchingLyrics => 'Tanıdık satırlar aranıyor…';

  @override
  String get searchingSources => 'Müzik kaynakları taranıyor…';

  @override
  String get connectionFailed => 'Bağlantı kurulamadı';

  @override
  String get noMatches => 'Henüz eşleşme yok';

  @override
  String get lyricsUnavailable =>
      'Söz araması şu anda kullanılamıyor. Daha sonra deneyin veya başlığa göre arayın.';

  @override
  String get searchUnavailable =>
      'Arama başarısız oldu. Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get lyricsNoMatches =>
      'Başka bir satır deneyin. Her söz dizine alınmamıştır.';

  @override
  String get trackNoMatches =>
      'Sanatçıyı ekleyin veya başka bir kaynak seçin. Bazı hizmetler ağınızda kullanılamayabilir.';

  @override
  String get repeatSearch => 'Yeniden ara';

  @override
  String get lyricMatchesUpper => 'SÖZ EŞLEŞMELERİ';

  @override
  String get tracksUpper => 'PARÇALAR';

  @override
  String playTrack(String title, String artist) {
    return '$title, $artist çal';
  }

  @override
  String get familiarLinesUpper => 'TANIDIK SATIRLAR';

  @override
  String get bestMatchUpper => 'EN İYİ EŞLEŞME';

  @override
  String get fullVersionOnPlayback =>
      'Çalma başladığında tam sürümü bulacağız.';

  @override
  String get forgotTitle => 'Başlığı unuttunuz.\nMüziği değil.';

  @override
  String get startAsYouRemember =>
      'Bir ad, başlık veya şarkıdan bir dize.\nHatırladığınız her şeyle başlayın.';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => 'Adları kulağa geldiği gibi arayın';

  @override
  String get rememberOnlyLine => 'Yalnızca bir dize hatırlıyorum';

  @override
  String get findSongByWords => 'Şarkıyı sözleriyle bulun';

  @override
  String get yourArtistsUpper => 'SANATÇILARINIZ';

  @override
  String get language => 'Dil';

  @override
  String get languageCaption => 'Arayüz seçiminizi hemen izler';

  @override
  String get systemLanguage => 'Sistem';

  @override
  String get russian => 'Rusça';

  @override
  String get english => 'İngilizce';

  @override
  String get themesAndShaders => 'Temalar ve efektler';

  @override
  String get themesSubtitle => 'Görünüm, dil ve arka plan hareketi';

  @override
  String get invalidThemeJson =>
      'Tema okunamadı. JSON biçimini ve alan değerlerini kontrol edin.';

  @override
  String get exportJson => 'JSON dışa aktar';

  @override
  String get importJson => 'JSON içe aktar';

  @override
  String get readyThemes => 'Hazır temalar';

  @override
  String get gpuShaders => 'Arka plan efektleri';

  @override
  String get meshGradient => 'Parça renklerinden yumuşak GPU geçişi';

  @override
  String get vinylNoise => 'Analog plak greni (gürültü)';

  @override
  String get glassBlur => 'Cam bulanıklığı (Backdrop Blur)';

  @override
  String get cornerRadius => 'Arayüz köşe yarıçapı';

  @override
  String get importThemeTitle => 'Temayı JSON\'dan içe aktar';

  @override
  String get pasteThemeJson => 'Temanın JSON yapılandırmasını yapıştırın:';

  @override
  String get cancel => 'İptal';

  @override
  String get apply => 'Uygula';

  @override
  String get themeApplied => 'Tema başarıyla uygulandı!';

  @override
  String get exportThemeTitle => 'Temayı dışa aktar (JSON)';

  @override
  String get close => 'Kapat';

  @override
  String get copyJson => 'JSON kopyala';

  @override
  String get jsonCopied => 'Tema JSON\'u panoya kopyalandı!';

  @override
  String get libraryUpper => 'KİTAPLIK';

  @override
  String get localCollection => 'Yerel koleksiyon ve çalma listeleri';

  @override
  String get importShort => 'İçe aktar';

  @override
  String get favorites => 'Favoriler';

  @override
  String get playlists => 'Çalma listeleri';

  @override
  String get history => 'Geçmiş';

  @override
  String get offline => 'Çevrimdışı';

  @override
  String get favoritesEmpty =>
      'Favorileriniz boş.\nBir parçanın kalbine dokunarak buraya ekleyin.';

  @override
  String get historyEmpty =>
      'Dinleme geçmişiniz boş.\nAramadan müzik çalın, burada görünecek.';

  @override
  String get noPlaylists => 'Henüz çalma listeniz yok';

  @override
  String get importPlaylistHint =>
      'Bir Spotify çalma listesi içe aktarın veya parça listesi yapıştırın.';

  @override
  String get importMusicAction => 'Müzik içe aktar';

  @override
  String get playPlaylist => 'Çalma listesini çal';

  @override
  String playlistStarted(String name, int count) {
    return '«$name» çalınıyor ($count parça)';
  }

  @override
  String get deletePlaylist => 'Çalma listesini sil';

  @override
  String get playAll => 'Tümünü çal';

  @override
  String get shuffle => 'Karıştır';

  @override
  String get localAudioCache => 'Yerel ses önbelleği';

  @override
  String get cacheDescription =>
      'Çalınan parçalar, internet olmadan anında tekrar dinlemek için yerel olarak saklanır.';

  @override
  String deviceUsage(String size) {
    return 'Bu cihazda: $size';
  }

  @override
  String get clearCache => 'Tüm önbelleği temizle';

  @override
  String savedTracksUpper(int count) {
    return 'KAYITLI PARÇALAR ($count):';
  }

  @override
  String get cacheFeaturesUpper => 'ÖNBELLEK ÖZELLİKLERİ:';

  @override
  String get offlineFirst => 'Tamamen çevrimdışı öncelikli';

  @override
  String get offlineFirstDescription =>
      'Tekrar dinlemede ses doğrudan cihazın dosya sisteminden yüklenir.';

  @override
  String get maximumBitrate => 'En yüksek bit hızı';

  @override
  String get maximumBitrateDescription =>
      '160–256 kbps temiz Opus/M4A akışları dönüştürülmeden saklanır.';

  @override
  String get trafficAndBattery => 'Veri ve pil tasarrufu';

  @override
  String get trafficAndBatteryDescription =>
      'Yinelenen ağ isteklerinden kaçınmak telefonunuzun daha uzun dayanmasını sağlar.';

  @override
  String get cacheEmpty => 'Önbellek boş';

  @override
  String get cachedTracksAppear => 'İndirilen parçalar burada otomatik görünür';

  @override
  String get removeFromCache => 'Önbellekten kaldır';

  @override
  String get removeCachedTrackTitle => 'Parça önbellekten kaldırılsın mı?';

  @override
  String removeCachedTrackBody(String title) {
    return '«$title» bu cihazdan kaldırılacak.';
  }

  @override
  String get delete => 'Sil';

  @override
  String get trackRemovedFromCache => 'Parça önbellekten kaldırıldı';

  @override
  String get clearCacheTitle => 'Önbellek temizlensin mi?';

  @override
  String get clearCacheBody =>
      'Kayıtlı tüm ses dosyaları bu cihazdan kaldırılacak. Favoriler ve geçmiş değişmez.';

  @override
  String get cacheCleared => 'Yerel önbellek temizlendi';

  @override
  String get back => 'Geri';

  @override
  String get playlistActions => 'Çalma listesi eylemleri';

  @override
  String get playlistUpper => 'ÇALMA LİSTESİ';

  @override
  String get playlistEmpty => 'Bu çalma listesinde henüz parça yok';

  @override
  String get pasteTrackList => 'Parça listesi yapıştır';

  @override
  String get pasteImportLink => 'İçe aktarmak için bir bağlantı yapıştır';

  @override
  String get tracksNotFound => 'Bu bağlantıda parça bulunamadı.';

  @override
  String get importError =>
      'İçe aktarma başarısız oldu. Bağlantıyı ve internetinizi kontrol edin.';

  @override
  String importedPlaylistStarted(int count) {
    return 'İçe aktarılan çalma listesi çalınıyor ($count parça)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'İçe aktarma ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return '«$name» çalma listesi kitaplığınıza kaydedildi!';
  }

  @override
  String get spotifyImportSubtitle =>
      'Spotify • Çalma listeleri, albümler ve parçalar';

  @override
  String get artistTrackOrCsv => 'Sanatçı — Parça ya da bir Exportify CSV\'si';

  @override
  String get pastePlaylistOrTrackLink =>
      'Çalma listesi veya parça bağlantısı yapıştır';

  @override
  String get pasteFromClipboard => 'Panodan yapıştır';

  @override
  String get link => 'Bağlantı';

  @override
  String get trackList => 'Parça listesi';

  @override
  String get playlistName => 'Çalma listesi adı';

  @override
  String get startImport => 'İçe aktarmayı başlat';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count parça';
  }

  @override
  String get importedFromSpotify => 'Spotify\'dan içe aktarıldı';

  @override
  String get importedFromDeezer => 'Deezer\'den içe aktarıldı';

  @override
  String get importIntro =>
      'Çalma listelerinizi yanınızda getirin. Bir Spotify bağlantısı, parça listesi veya Exportify dosyası kullanın.';

  @override
  String get importTextTab => 'Metin';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'Dosya seç';

  @override
  String get importFileHint =>
      'Exportify tarafından dışa aktarılan CSV\'yi ya da bir TXT parça listesini seçin. UTF-8, en fazla 10 MB ve 10.000 parça.';

  @override
  String get importFileAndroidOnly =>
      'Dosya seçimi Android\'de kullanılabilir. Burada bir CSV veya parça listesinin içeriğini yapıştırabilirsiniz.';

  @override
  String get importTextHint =>
      'Her satıra bir Sanatçı — Parça. Başlık dahil tüm CSV\'yi de yapıştırabilirsiniz.';

  @override
  String get importPreview => 'Parça önizlemesi';

  @override
  String get importedFromCsv => 'CSV\'den içe aktarıldı';

  @override
  String get importedFromText => 'Parça listesinden içe aktarıldı';

  @override
  String importMoreTracks(int count) {
    return 'Ve $count tane daha';
  }

  @override
  String get importMetadataHint =>
      'Çalma listesi bu cihazda saklanır. Ses, parça çalınırken bulunur; içe aktarma şarkı indirmez.';

  @override
  String get importAnother => 'Başka bir şey içe aktar';

  @override
  String get importReading => 'Çalma listeniz okunuyor…';

  @override
  String get importSaving => 'Kitaplığınıza kaydediliyor…';

  @override
  String get importNameRequired => 'Bir çalma listesi adı girin.';

  @override
  String get importNameExists =>
      'Bu ada sahip bir çalma listesi zaten var. İkisini de korumak için başka bir ad seçin.';

  @override
  String get importSaveFailed =>
      'Çalma listesi kaydedilemedi. Önizlemeniz hâlâ burada — tekrar deneyin.';

  @override
  String get importFileTooLarge =>
      'Bu dosya 10 MB\'ı aşıyor. Çalma listesini daha küçük dışa aktarımlara bölün.';

  @override
  String get importFileUnsupported => 'Bir .csv veya .txt dosyası seçin.';

  @override
  String get importFileEncoding =>
      'Metin kodlaması okunamadı. Dosyayı UTF-8 olarak kaydedip tekrar deneyin.';

  @override
  String get importCsvInvalid =>
      'CSV eksik veya bozuk. Sütunlarını veya tırnaklarını değiştirmeden yeniden dışa aktarın.';

  @override
  String get importCsvMissingColumns =>
      'CSV, Track Name ve Artist Name(s) ya da Title ve Artist sütunlarını gerektirir. Özgün Exportify dışa aktarımını seçin.';

  @override
  String get importFileEmpty =>
      'Hiç parça bulunamadı. Dolu bir dışa aktarım seçin veya Sanatçı — Parça listesi yapıştırın.';

  @override
  String get importTooManyTracks =>
      'Tek bir içe aktarma en fazla 10.000 parça içerebilir. Bu çalma listesini bölün; henüz hiçbir şey kaydedilmedi.';

  @override
  String get importFileReadFailed =>
      'Bu dosya açılamadı. Cihazınızda kullanılabilir olduğunu doğrulayın ve yeniden seçin.';

  @override
  String get importSpotifyBlocked =>
      'Spotify bu çalma listesini bölgenizde paylaşmadı. Exportify ile dışa aktarın ve CSV dosyasını seçin.';

  @override
  String get listen => 'Çal';

  @override
  String get addToPlaylists => 'Çalma listelerine ekle';

  @override
  String trackSemantics(String title, String artist) {
    return 'Parça $title, $artist';
  }

  @override
  String get trackActions => 'Parça eylemleri';

  @override
  String get updatesTitle => 'Güncellemeler';

  @override
  String get accountTitle => 'Hesap';

  @override
  String get waveLoading => 'Benzer şarkılar bulunuyor…';

  @override
  String get sleepTimer => 'Uyku zamanlayıcısı';

  @override
  String sleepMinutes(String value) {
    return '$value';
  }

  @override
  String get sleepUntilTrackEnd => 'Parça sonuna kadar';

  @override
  String get sleepCancel => 'Kapat';

  @override
  String get dislike => 'Bana göre değil';

  @override
  String get dislikeRemove => 'Gizlilerden çıkar';

  @override
  String dislikeSaved(String artist) {
    return 'Gizlendi: $artist';
  }

  @override
  String get exportPlaylist => 'CSV dışa aktar';

  @override
  String get playlistExported => 'Çalma listesi dışa aktarıldı';

  @override
  String get exportFailed => 'Dışa aktarma başarısız';

  @override
  String get downloadAll => 'Tümünü indir';

  @override
  String get statsTitle => 'İstatistikler';

  @override
  String get statsPlays => 'Dinleme';

  @override
  String get statsFavorites => 'Favoriler';

  @override
  String get statsPlaylists => 'Listeler';

  @override
  String get statsTopArtists => 'En çok dinlenen sanatçılar';

  @override
  String get statsTopTracks => 'En çok dinlenen parçalar';

  @override
  String resumeTitle(String device) {
    return '$device üzerinde devam et';
  }

  @override
  String get alwaysOnTop => 'Pencereyi üstte tut';

  @override
  String get randomPick => 'Senin için rastgele seçim';

  @override
  String get accountCaption => 'Kitaplığını cihazlar arasında eşitle';

  @override
  String get nickname => 'Takma ad';

  @override
  String get nicknameHint => '3–20 karakter: harfler, rakamlar, . _ -';

  @override
  String get password => 'Şifre';

  @override
  String get passwordMinHint => 'En az 6 karakter';

  @override
  String get signIn => 'Giriş yap';

  @override
  String get signUp => 'Hesap oluştur';

  @override
  String get haveAccountToggle => 'Zaten hesabın var mı? Giriş yap';

  @override
  String get noAccountToggle => 'Hesabın yok mu? Bir tane oluştur';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get syncNow => 'Şimdi eşitle';

  @override
  String get syncing => 'Eşitleniyor…';

  @override
  String syncedAt(String time) {
    return 'Eşitlendi: $time';
  }

  @override
  String get neverSynced => 'Henüz eşitlenmedi';

  @override
  String get errorNicknameTaken => 'Bu takma ad zaten alınmış';

  @override
  String get errorNicknameInvalid => 'Takma ad: 3–20 karakter, harf/rakam/._-';

  @override
  String get errorInvalidCredentials => 'Takma ad veya şifre hatalı';

  @override
  String get errorWeakPassword => 'Şifre çok kısa';

  @override
  String get errorNetwork => 'Bağlantı yok';

  @override
  String get errorServer => 'Sunucu hatası, daha sonra tekrar dene';

  @override
  String currentVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String get checkForUpdates => 'Güncellemeleri kontrol et';

  @override
  String get checkingForUpdates => 'Kontrol ediliyor…';

  @override
  String get upToDate => 'En son sürümü kullanıyorsun';

  @override
  String updateAvailable(String version) {
    return '$version sürümü mevcut';
  }

  @override
  String get downloadingUpdate => 'Güncelleme indiriliyor…';

  @override
  String get installUpdate => 'Yükle';

  @override
  String get updateCheckFailed =>
      'Güncellemeler kontrol edilemedi. İnternetini kontrol et.';

  @override
  String get installPermissionNeeded =>
      'Hook\'un uygulama yüklemesine izin ver ve tekrar Yükle\'ye dokun.';

  @override
  String updateSize(String size) {
    return '$size MB';
  }

  @override
  String get download => 'İndir';

  @override
  String get downloading => 'İndiriliyor…';

  @override
  String get downloaded => 'İndirildi';

  @override
  String get downloadFailed => 'İndirilemedi';

  @override
  String get removeDownload => 'İndirmeyi kaldır';

  @override
  String get downloadSavedOffline => 'Çevrimdışı kaydedildi';

  @override
  String get startWaveFromTrack => 'Bu parçadan bir dalga başlat';

  @override
  String get addToQueue => 'Kuyruğa ekle';

  @override
  String addedToQueue(String title) {
    return 'Kuyruğa eklendi: $title';
  }

  @override
  String get removeFavorite => 'Favorilerden çıkar';

  @override
  String get addFavorite => 'Favorilere ekle';

  @override
  String get addToPlaylist => 'Çalma listesine ekle';

  @override
  String get goToArtist => 'Sanatçıya git';

  @override
  String get myPlaylist => 'Çalma listem';

  @override
  String get newPlaylist => 'Yeni çalma listesi';

  @override
  String get name => 'Ad';

  @override
  String get create => 'Oluştur';

  @override
  String get loading => 'Yükleniyor…';

  @override
  String get pause => 'Duraklat';

  @override
  String get play => 'Çal';

  @override
  String get next => 'Sonraki';

  @override
  String get speedAndPitch => 'Hız ve perde';

  @override
  String speedValue(String value) {
    return 'Hız: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'Perde: ${value}x';
  }

  @override
  String get reset => 'Sıfırla';

  @override
  String get moreActions => 'Daha fazla eylem';

  @override
  String get playbackQueue => 'Çalma kuyruğu';

  @override
  String get queueEmpty => 'Kuyruk boş';

  @override
  String get selectingSource => 'Kaynak seçiliyor';

  @override
  String get collapsePlayer => 'Çaları daralt';

  @override
  String get nowPlayingUpper => 'ŞİMDİ ÇALIYOR';

  @override
  String get queue => 'Kuyruk';

  @override
  String get startWave => 'Dalga başlat';

  @override
  String get cover => 'Kapak';

  @override
  String get karaokeLyrics => 'Karaoke sözleri';

  @override
  String get findMusicStart => 'Müzik bulun ve çalmaya başlayın';

  @override
  String get playbackNotStarted => 'Çalma henüz başlamadı';

  @override
  String get openSearchFirstTrack => 'İlk parçanızı bulmak için aramayı açın';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => 'Cihazda';

  @override
  String get sourceCatalog => 'Katalog';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'Sunucu';

  @override
  String get serverResolver => 'Çözümleyici sunucu';

  @override
  String get serverResolverCaption =>
      'Tam ses akışlarını çözen, isteğe bağlı kendi sunucunuz. Uygulama bir arama veya parça kimliği gönderir; sunucu bir çalma URL\'si döndürür. Sözleşme ve örnek uygulama docs/REMOTE_RESOLVER.md içinde.';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'Yapılandırılmadı';

  @override
  String get serverSave => 'Kaydet';

  @override
  String get serverDisable => 'Devre dışı bırak';

  @override
  String get onboardingWelcomeTitle => 'Hook\'a hoş geldiniz';

  @override
  String get onboardingWelcomeCaption =>
      'Müzik, sözler ve kendinize ait görsel bir stil. Başlamak için bir dil seçin — ayarlardan sonra değiştirebilirsiniz.';

  @override
  String get onboardingSkip => 'Atla';

  @override
  String get onboardingNext => 'Devam';

  @override
  String get onboardingStart => 'Dinlemeye başla';

  @override
  String get onboardingMicrogTitle => 'MicroG ve Google hesabı';

  @override
  String get onboardingMicrogBody =>
      'MicroG, Google servisleri olmadan gelen özel Android ROM\'larında bu servisleri yeniden oluşturur. Hook bunları yalnızca isteğe bağlı bir özellik için kullanır: çalma listelerinizi içe aktarmak üzere bir YouTube hesabı bağlamak. Müzik çalmak için MicroG veya hiçbir Google servisi gerekmez.';

  @override
  String get onboardingMicrogNote =>
      'Çalma, MicroG\'ye bağlı değildir. Hesap bağlamak isteğe bağlıdır.';

  @override
  String get onboardingMicrogDownload => 'MicroG\'yi indir';

  @override
  String get onboardingMicrogStatusChecking =>
      'Google servisleri kontrol ediliyor…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'Google servisleri bu cihazda mevcut ($version). Hesap içe aktarma hemen çalışacak.';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'ReVanced GmsCore algılandı ($version). Resmî Google oturum açma SDK\'sı onunla uyumlu değil; hesap bağlantısı çalışmayabilir. Çalma etkilenmez.';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'Google servisleri bulunamadı. Bir YouTube hesabından çalma listesi içe aktarmak için önce MicroG\'yi yükleyin — ya da bunu atlayın ve Hook\'u hesapsız kullanın.';

  @override
  String lyricsView(String mode) {
    return 'Söz görünümü · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'Okuma ritminiz';

  @override
  String get lyricsModeSubtitle => 'Şarkıya yaklaşmanın üç yolu.';

  @override
  String get lyricsModeLines => 'Satırlar';

  @override
  String get lyricsModeKaraoke => 'Karaoke';

  @override
  String get lyricsModeFocus => 'Odak';

  @override
  String get lyricsModeLinesDescription =>
      'Geçerli satırı vurgulanan sakin sözler';

  @override
  String get lyricsModeKaraokeDescription =>
      'Kelimeler vokalle birlikte yumuşakça aydınlanır';

  @override
  String get lyricsModeFocusDescription => 'Tek büyük satır. Başka hiçbir şey';

  @override
  String get lyricsModeSaveFailed => 'Söz görünümü kaydedilemedi.';

  @override
  String get lyricsModeFootnote =>
      'Seçiminiz sonraki şarkılar için saklanır. Karaoke doğruluğu kaynak verilerine bağlıdır: kelime zamanlaması olmadan vurgulama yaklaşıktır ve zaman damgası olmadan sözler hareketsiz kalır.';

  @override
  String get lyricsNotFound => 'Sözler bulunamadı';

  @override
  String get karaokeUnavailable => 'Bu parça için karaoke sözleri yok';

  @override
  String get unsyncedLyrics => 'Senkronize edilmemiş sözler';

  @override
  String get wordSyncUpper => 'KELİME KELİME SENKRON';

  @override
  String get lineSyncUpper => 'SATIR SATIR SENKRON';

  @override
  String get adjustLyricsSync => 'Söz senkronizasyonunu ayarla';

  @override
  String get startsSoon => 'Yakında başlıyor';

  @override
  String get musicContinues => 'Müzik sürüyor';

  @override
  String get decreaseLyricsOffset => 'Kaydırmayı 0,1 sn azalt';

  @override
  String lyricsOffset(String value) {
    return 'Kaydırma: $value sn';
  }

  @override
  String get increaseLyricsOffset => 'Kaydırmayı 0,1 sn artır';

  @override
  String get hideSetting => 'Ayarı gizle';

  @override
  String get lyricsOffsetSaveFailed => 'Söz kaydırması kaydedilemedi.';

  @override
  String get audioForbidden =>
      'Ses sunucusu erişimi reddetti (HTTP 403). Parça bulundu ama akışı kullanılamıyor. Bir VPN ses erişimini garanti etmez.';

  @override
  String get fullVersionUnavailable =>
      'Kullanılabilir kaynaklarda tam sürüm bulunamadı. Bağlantınızı kontrol edin veya daha sonra deneyin.';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source bu parçayı çalamadı. Bağlantınızı kontrol edin veya daha sonra deneyin.';
  }

  @override
  String get recentQueriesUpper => 'SON ARAMALAR';

  @override
  String get clearHistory => 'Temizle';

  @override
  String get waveFromArtist => 'Sanatçı dalgası';

  @override
  String get popularTracksUpper => 'POPÜLER PARÇALAR';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parça',
      zero: 'henüz parça yok',
    );
    return '$_temp0';
  }

  @override
  String get volume => 'Ses düzeyi';

  @override
  String get systemVolume => 'Sistem';

  @override
  String get appVolume => 'Hook düzeyi';

  @override
  String get mute => 'Sessize al';

  @override
  String get unmute => 'Sesi aç';

  @override
  String get volumeMixer => 'Ses ve düzey';

  @override
  String get systemVolumeCaption =>
      'Tüm uygulamalarla paylaşılan Windows çıkış düzeyi';

  @override
  String get appVolumeCaption =>
      'Yalnızca Hook içinde, sistem düzeyinin üzerinde';

  @override
  String get volumeKeysHint => 'Ctrl + ↑ ↓ düzey · M sessiz';

  @override
  String get volumeUnavailable => 'Bu cihazda sistem ses düzeyi kullanılamıyor';

  @override
  String get cacheFolder => 'Depolama klasörü';

  @override
  String get copyPath => 'Yolu kopyala';

  @override
  String get pathCopied => 'Yol panoya kopyalandı';

  @override
  String get previousTrack => 'Önceki parça';

  @override
  String get repeatPlayback => 'Tekrarla';

  @override
  String get openPlayer => 'Oynatıcıyı aç';

  @override
  String get statsWeek => 'Son 7 gün';

  @override
  String get keyboardShortcuts => 'Klavye kısayolları';

  @override
  String get shortcutsCaption => 'Metin alanları dışında her yerde çalışır.';

  @override
  String get shortcutsSeek => '10 saniye atla';

  @override
  String get playPauseShortcut => 'Çal / duraklat';

  @override
  String get ageRestrictedTrack =>
      'Bu parça yaş sınırlı (18+). Sunucunun oturum açmış bir YouTube hesabının çerezlerine ihtiyacı var.';

  @override
  String get haptics => 'Titreşim';

  @override
  String get hapticsDescription =>
      'Bir dokunuş bir şeyi değiştirdiğinde kısa titreşim. Yalnızca Android ve iOS.';

  @override
  String get reduceMotion => 'Hareketi azalt';

  @override
  String get reduceMotionDescription =>
      'Geçişleri ve hareketli arka planları atlar. Yavaş cihazlarda veya hareket hassasiyetinde yararlıdır.';

  @override
  String get backgroundPrefetch => 'Sonraki parçaları önceden yükle';

  @override
  String get backgroundPrefetchDescription =>
      'Sonraki parçaları arka planda hazırlar, böylece geçiş anında başlar. Biraz daha veri kullanır.';

  @override
  String get playbackSettings => 'Oynatma';

  @override
  String get cookieStatus => 'YouTube çerezleri';

  @override
  String get cookieStatusReady => 'Oturum açık — 18+ parçalar oynatılabilir';

  @override
  String get cookieStatusVisitor => 'Oturum yok — 18+ parçalar reddediliyor';

  @override
  String get cookieStatusUnknown => 'Henüz denetlenmedi';

  @override
  String get cookieStatusCheck => 'Denetle';

  @override
  String get cookieStatusChecking => 'Denetleniyor…';

  @override
  String get cookieStatusUpload => 'Çerezleri yükle';

  @override
  String get cookieStatusUploading => 'Yükleniyor…';

  @override
  String cookieUploadAccepted(int cookies) {
    return '$cookies çerez yüklendi — 18+ parçalar açık';
  }

  @override
  String cookieUploadRejected(String reason) {
    return 'Sunucu dosyayı reddetti: $reason';
  }

  @override
  String get cookieUploadApology =>
      'Bu dışa aktarım oturum açmış bir oturum değil, bu yüzden 18+ parçalar yine çalmaz. Yaş doğrulaması yapılmış bir hesapla YouTube\'a giriş yapıp yeniden dışa aktarın.';

  @override
  String get cookieStatusUnreachable => 'Sunucu yanıt vermedi';

  @override
  String get errorAccountSetup =>
      'Accounts are not enabled on the server. In Supabase, turn off Authentication → Sign In / Providers → Email → «Confirm email», then try again.';

  @override
  String get errorRateLimited =>
      'Too many attempts. Wait a minute and try again.';
}
