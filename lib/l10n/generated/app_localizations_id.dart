// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'Pengaturan';

  @override
  String get settingsCaption => 'Perubahan disimpan di perangkat ini.';

  @override
  String get playerSettings => 'Pemutar';

  @override
  String get lyricsAutoHide => 'Sembunyikan kontrol saat membaca lirik';

  @override
  String get lyricsAutoHideDescription =>
      'Setelah 10 detik tanpa interaksi, panel pemutar menghilang dari layar. Gunakan tombol pulihkan untuk mengembalikannya.';

  @override
  String get showPlayerControls => 'Tampilkan kontrol pemutar';

  @override
  String get equalizer => 'Ekualiser';

  @override
  String get equalizerEnabled => 'Pemrosesan suara';

  @override
  String get equalizerPresets => 'Profil suara';

  @override
  String get equalizerFlat => 'Asli';

  @override
  String get equalizerBass => 'Bass dalam';

  @override
  String get equalizerVocal => 'Vokal';

  @override
  String get equalizerRock => 'Rock';

  @override
  String get equalizerElectronic => 'Elektronik';

  @override
  String get equalizerSoft => 'Lembut';

  @override
  String get equalizerCustom => 'Kustom';

  @override
  String get equalizerBands => 'Pita frekuensi';

  @override
  String get equalizerBassBoost => 'Penguatan bass';

  @override
  String get equalizerBassUnsupported =>
      'Penguatan bass tambahan tidak didukung. Gunakan pita frekuensi rendah.';

  @override
  String get equalizerPreamp => 'Preamp';

  @override
  String get equalizerHeadroom => 'Ruang kepala otomatis';

  @override
  String get equalizerHeadroomDescription =>
      'Menurunkan level keluaran saat menaikkan frekuensi untuk memberi ruang bagi puncak. Bukan pembatas.';

  @override
  String get equalizerWaiting =>
      'Putar sebuah lagu untuk menghubungkan ekualiser ke sesi audionya.';

  @override
  String get equalizerUnsupported =>
      'Pemrosesan suara saat ini hanya tersedia di Android.';

  @override
  String get equalizerFailed =>
      'Perangkat ini tidak dapat mengaktifkan efek audio. Musik tetap bisa diputar tanpanya.';

  @override
  String get equalizerRetry => 'Sambungkan ulang efek';

  @override
  String get equalizerLive =>
      'Perubahan langsung diterapkan dan disimpan di perangkat ini.';

  @override
  String get youtubeAccount => 'YouTube & MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'Akses baca-saja ke playlist. Masuk tidak menjamin ketersediaan audio.';

  @override
  String get youtubeAccountCompatibility => 'Kompatibilitas dan privasi';

  @override
  String get youtubeAccountSubtitle => 'Penyambungan akun dan impor playlist';

  @override
  String get youtubeAccountPrivacy =>
      'Hook meminta akses YouTube baca-saja. Masukkan kata sandi hanya di dialog sistem Google, tidak pernah di Hook. Token tidak dikirim ke server Hook mana pun dan hanya disimpan di memori. Sambungkan ulang setelah memulai ulang aplikasi.';

  @override
  String get youtubeAccountPlaybackNotice =>
      'Masuk memberi akses ke data akun, bukan ke aliran audio. Ini tidak menjamin perbaikan HTTP 403. Impor mempertahankan rekaman YouTube tanpa menggantinya dengan sumber lain.';

  @override
  String get youtubeAccountConnect => 'Sambungkan akun';

  @override
  String get youtubeAccountDisconnect => 'Putuskan di Hook';

  @override
  String get youtubeAccountDisconnected => 'Tidak ada akun tersambung';

  @override
  String get youtubeAccountDisconnectNotice =>
      'Putuskan akun ini hanya di Hook? Playlist tersimpan tetap ada. Akun Google dan MicroG di ponsel tidak ikut keluar.';

  @override
  String get youtubeAccountSystem => 'API Google sistem';

  @override
  String get youtubeAccountServicesMissing =>
      'API Google sistem yang kompatibel tidak tersedia. Instalasi ReVanced GmsCore terpisah tidak menggantikannya untuk masuk Hook.';

  @override
  String get youtubeAccountMicrogNotice =>
      'Terdeteksi instalasi ReVanced GmsCore terpisah. Hook tidak memakai akun atau token ReVanced. MicroG sistem bisa menyediakan API Google yang kompatibel, tetapi kompatibilitas dengan metode masuk ini tidak dijamin.';

  @override
  String get youtubeAccountRevancedFound => 'YouTube Music ReVanced terpasang';

  @override
  String get youtubeAccountPlaylists => 'Playlist akun';

  @override
  String get youtubeAccountNoPlaylists =>
      'Tidak ada playlist yang bisa diakses. Beberapa koleksi otomatis YouTube Music tidak tersedia melalui YouTube Data API.';

  @override
  String get youtubeAccountMore => 'Muat lebih banyak';

  @override
  String get youtubeAccountPreview => 'Siapkan impor';

  @override
  String youtubeAccountProgress(int count) {
    return 'Lagu diperoleh: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'Entri tak tersedia dilewati: $count. Semuanya tidak digantikan lagu lain.';
  }

  @override
  String get youtubeAccountSetup => 'Penyiapan masuk';

  @override
  String get youtubeAccountSetupBody =>
      'Pengembang harus mengaktifkan YouTube Data API v3 di Google Cloud, mendaftarkan klien OAuth Android untuk com.hook.music dan SHA-1 penandatanganan build terpasang, serta mengonfigurasi layar persetujuan. Tambahkan pengguna yang diizinkan dalam mode uji. Lihat docs/YOUTUBE_ACCOUNT_SETUP.md. Jangan pernah menambahkan kata sandi, rahasia klien, atau token dari aplikasi lain.';

  @override
  String get youtubeAccountConfigError =>
      'Masuk belum dikonfigurasi untuk build ini. Periksa klien OAuth Android, nama paket, SHA-1, dan pengguna uji yang diizinkan di Google Cloud.';

  @override
  String get youtubeAccountPermissionError =>
      'Akses baca ke data YouTube tidak diberikan.';

  @override
  String get youtubeAccountExpired =>
      'Sesi Anda berakhir. Sambungkan ulang akun.';

  @override
  String get youtubeAccountNoChannel =>
      'Akun yang dipilih tidak punya kanal YouTube yang bisa diakses.';

  @override
  String get youtubeAccountQuota =>
      'Kuota API YouTube terlampaui. Coba lagi nanti.';

  @override
  String get youtubeAccountFailed =>
      'Tidak dapat mengambil data YouTube. Periksa koneksi Anda dan coba lagi.';

  @override
  String get youtubeAccountUnsupported =>
      'Penyambungan akun membutuhkan Android dengan API Google sistem yang kompatibel.';

  @override
  String get importedFromYouTube => 'Diimpor dari akun YouTube';

  @override
  String get translateLyrics => 'Terjemahkan lirik';

  @override
  String get hideTranslation => 'Sembunyikan terjemahan';

  @override
  String get cancelTranslation => 'Batalkan terjemahan';

  @override
  String get translationLoading => 'Menyiapkan terjemahan…';

  @override
  String get translationAttribution =>
      'Diterjemahkan otomatis oleh Google Translate';

  @override
  String get translationNotice =>
      'Terjemahan mungkin tidak menangkap makna lagu secara akurat. Penyorotan kata hanya berlaku pada lirik asli.';

  @override
  String get translationModelTitle => 'Unduh model bahasa?';

  @override
  String get translationModelBody =>
      'Terjemahan berjalan di ponsel Anda: lirik tidak dikirim ke server. Terjemahan pertama membutuhkan model Google ML Kit yang berukuran puluhan megabita. Unduhan memakai koneksi Anda saat ini, termasuk data seluler. Membatalkan menyembunyikan hasil, tetapi unduhan model yang sudah mulai bisa selesai di latar belakang.';

  @override
  String get translationDownload => 'Unduh dan terjemahkan';

  @override
  String get translationUnavailable =>
      'Terjemahan gagal. Periksa akses ke unduhan model dan coba lagi.';

  @override
  String get translationUnsupported =>
      'Terjemahan di perangkat saat ini hanya tersedia di Android.';

  @override
  String get translationUnknownLanguage =>
      'Tidak dapat mengidentifikasi bahasa yang didukung untuk lagu ini.';

  @override
  String get translationSameLanguage =>
      'Lirik sudah dalam bahasa yang dipilih.';

  @override
  String get translationTooLarge =>
      'Lirik ini terlalu panjang untuk terjemahan di perangkat.';

  @override
  String get translationRussian => 'Ke bahasa Rusia';

  @override
  String get translationEnglish => 'Ke bahasa Inggris';

  @override
  String get translationTarget => 'Bahasa terjemahan';

  @override
  String get retry => 'Coba lagi';

  @override
  String get home => 'Beranda';

  @override
  String get search => 'Cari';

  @override
  String get library => 'Pustaka';

  @override
  String get youtubeUnavailableTitle => 'YouTube sedang tidak tersedia';

  @override
  String get youtubeUnavailableBody =>
      'Tidak bisa mendapatkan aliran audio. Periksa jaringan dan rute VPN Anda: YouTube bisa menolak permintaan bahkan dengan VPN.';

  @override
  String get checkAgain => 'Periksa lagi';

  @override
  String get dismiss => 'Tutup';

  @override
  String get goodNight => 'Selamat malam';

  @override
  String get goodMorning => 'Selamat pagi';

  @override
  String get goodAfternoon => 'Selamat siang';

  @override
  String get goodEvening => 'Selamat sore';

  @override
  String get themeSettings => 'Pengaturan tampilan';

  @override
  String get onYourAir => 'Di udara Anda';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sinyal terkini',
      one: '1 sinyal terkini',
      zero: 'Tidak ada sinyal terkini',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'Koleksi Anda menanti';

  @override
  String get saved => 'Tersimpan';

  @override
  String get collectionEmptyDetail =>
      'Musik yang ingin Anda kembali akan tetap di sini';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lagu',
      one: '1 lagu',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'Lagu, artis, atau lirik';

  @override
  String get searchUpper => 'CARI';

  @override
  String get findFirstTrack => 'Temukan lagu pertama Anda';

  @override
  String continuationAfter(String artist) {
    return 'Musik lainnya setelah $artist';
  }

  @override
  String get chooseTrackWaveDetail =>
      'Pilih sebuah lagu dan kami akan membangun gelombang sesuai suasananya.';

  @override
  String get continueWaveLabel => 'LANJUT / 01';

  @override
  String get yourWaveLabel => 'GELOMBANG ANDA / 01';

  @override
  String get continueWave => 'Lanjutkan gelombang';

  @override
  String get chooseTrack => 'Pilih lagu';

  @override
  String get firstTrace => 'Tinggalkan jejak pertama Anda di sini';

  @override
  String get favoriteWaveHint =>
      'Simpan favorit, dan gelombang Anda akan makin akurat.';

  @override
  String get openSearch => 'Buka pencarian';

  @override
  String get findYourMusic => 'Temukan suaramu.';

  @override
  String get importMusic => 'Impor musik';

  @override
  String get rememberedLyricsHint => 'Kata-kata yang Anda ingat…';

  @override
  String get trackArtistHint => 'Lagu atau artis — bahasa apa pun';

  @override
  String get clear => 'Bersihkan';

  @override
  String get music => 'Musik';

  @override
  String get byLyrics => 'Dari lirik';

  @override
  String get allSources => 'Semua sumber';

  @override
  String get lyricsSearchCaption =>
      'Cari frasa dalam lagu, bukan hanya judulnya.';

  @override
  String get searchingLyrics => 'Mencari baris yang familiar…';

  @override
  String get searchingSources => 'Mencari di sumber musik…';

  @override
  String get connectionFailed => 'Tidak bisa terhubung';

  @override
  String get noMatches => 'Belum ada kecocokan';

  @override
  String get lyricsUnavailable =>
      'Pencarian lirik sedang tidak tersedia. Coba nanti atau cari berdasarkan judul.';

  @override
  String get searchUnavailable =>
      'Pencarian gagal. Periksa koneksi Anda dan coba lagi.';

  @override
  String get lyricsNoMatches => 'Coba baris lain. Tidak semua lirik terindeks.';

  @override
  String get trackNoMatches =>
      'Tambahkan artis atau pilih sumber lain. Beberapa layanan mungkin tidak tersedia di jaringan Anda.';

  @override
  String get repeatSearch => 'Cari lagi';

  @override
  String get lyricMatchesUpper => 'KECOCOKAN LIRIK';

  @override
  String get tracksUpper => 'LAGU';

  @override
  String playTrack(String title, String artist) {
    return 'Putar $title, $artist';
  }

  @override
  String get familiarLinesUpper => 'BARIS FAMILIAR';

  @override
  String get bestMatchUpper => 'KECOCOKAN TERBAIK';

  @override
  String get fullVersionOnPlayback =>
      'Kami akan mencari versi lengkap saat pemutaran dimulai.';

  @override
  String get forgotTitle => 'Lupa judulnya.\nBukan musiknya.';

  @override
  String get startAsYouRemember =>
      'Nama, judul, atau satu baris lagu.\nMulai dari apa pun yang Anda ingat.';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => 'Cari nama sebagaimana terdengar';

  @override
  String get rememberOnlyLine => 'Saya hanya ingat satu baris';

  @override
  String get findSongByWords => 'Temukan lagu dari kata-katanya';

  @override
  String get yourArtistsUpper => 'ARTIS ANDA';

  @override
  String get language => 'Bahasa';

  @override
  String get languageCaption => 'Antarmuka langsung mengikuti pilihan Anda';

  @override
  String get systemLanguage => 'Sistem';

  @override
  String get russian => 'Rusia';

  @override
  String get english => 'Inggris';

  @override
  String get themesAndShaders => 'Tema dan efek';

  @override
  String get themesSubtitle => 'Tampilan, bahasa, dan gerakan latar';

  @override
  String get invalidThemeJson =>
      'Tema tidak bisa dibaca. Periksa format JSON dan nilai kolom.';

  @override
  String get exportJson => 'Ekspor JSON';

  @override
  String get importJson => 'Impor JSON';

  @override
  String get readyThemes => 'Preset tema';

  @override
  String get gpuShaders => 'Efek latar';

  @override
  String get meshGradient => 'Gradien GPU halus dari warna lagu';

  @override
  String get vinylNoise => 'Butiran piringan analog (Noise)';

  @override
  String get glassBlur => 'Buram kaca (Backdrop Blur)';

  @override
  String get cornerRadius => 'Radius sudut antarmuka';

  @override
  String get importThemeTitle => 'Impor tema dari JSON';

  @override
  String get pasteThemeJson => 'Tempel konfigurasi JSON tema:';

  @override
  String get cancel => 'Batal';

  @override
  String get apply => 'Terapkan';

  @override
  String get themeApplied => 'Tema berhasil diterapkan!';

  @override
  String get exportThemeTitle => 'Ekspor tema (JSON)';

  @override
  String get close => 'Tutup';

  @override
  String get copyJson => 'Salin JSON';

  @override
  String get jsonCopied => 'JSON tema tersalin ke papan klip!';

  @override
  String get libraryUpper => 'PUSTAKA';

  @override
  String get localCollection => 'Koleksi lokal dan playlist';

  @override
  String get importShort => 'Impor';

  @override
  String get favorites => 'Favorit';

  @override
  String get playlists => 'Playlist';

  @override
  String get history => 'Riwayat';

  @override
  String get offline => 'Luring';

  @override
  String get favoritesEmpty =>
      'Favorit Anda masih kosong.\nKetuk hati pada lagu untuk menambahkannya di sini.';

  @override
  String get historyEmpty =>
      'Riwayat dengar Anda kosong.\nPutar musik dari pencarian dan akan muncul di sini.';

  @override
  String get noPlaylists => 'Anda belum punya playlist';

  @override
  String get importPlaylistHint =>
      'Impor playlist Spotify atau tempel daftar lagu.';

  @override
  String get importMusicAction => 'Impor musik';

  @override
  String get playPlaylist => 'Putar playlist';

  @override
  String playlistStarted(String name, int count) {
    return 'Memutar «$name» ($count lagu)';
  }

  @override
  String get deletePlaylist => 'Hapus playlist';

  @override
  String get playAll => 'Putar semua';

  @override
  String get shuffle => 'Acak';

  @override
  String get localAudioCache => 'Cache audio lokal';

  @override
  String get cacheDescription =>
      'Lagu yang diputar disimpan lokal untuk diputar ulang tanpa koneksi internet.';

  @override
  String deviceUsage(String size) {
    return 'Di perangkat ini: $size';
  }

  @override
  String get clearCache => 'Bersihkan semua cache';

  @override
  String savedTracksUpper(int count) {
    return 'LAGU TERSIMPAN ($count):';
  }

  @override
  String get cacheFeaturesUpper => 'FITUR CACHE:';

  @override
  String get offlineFirst => 'Prioritas luring penuh';

  @override
  String get offlineFirstDescription =>
      'Saat diputar ulang, audio dimuat langsung dari sistem berkas perangkat.';

  @override
  String get maximumBitrate => 'Bitrate maksimum';

  @override
  String get maximumBitrateDescription =>
      'Aliran Opus/M4A bersih 160–256 kbps disimpan tanpa transkoding.';

  @override
  String get trafficAndBattery => 'Hemat data dan baterai';

  @override
  String get trafficAndBatteryDescription =>
      'Menghindari permintaan jaringan berulang membantu ponsel Anda bertahan lebih lama.';

  @override
  String get cacheEmpty => 'Cache kosong';

  @override
  String get cachedTracksAppear =>
      'Lagu yang diunduh akan muncul di sini otomatis';

  @override
  String get removeFromCache => 'Hapus dari cache';

  @override
  String get removeCachedTrackTitle => 'Hapus lagu dari cache?';

  @override
  String removeCachedTrackBody(String title) {
    return '«$title» akan dihapus dari perangkat ini.';
  }

  @override
  String get delete => 'Hapus';

  @override
  String get trackRemovedFromCache => 'Lagu dihapus dari cache';

  @override
  String get clearCacheTitle => 'Bersihkan cache?';

  @override
  String get clearCacheBody =>
      'Semua berkas audio tersimpan akan dihapus dari perangkat ini. Favorit dan riwayat tidak berubah.';

  @override
  String get cacheCleared => 'Cache lokal dibersihkan';

  @override
  String get back => 'Kembali';

  @override
  String get playlistActions => 'Tindakan playlist';

  @override
  String get playlistUpper => 'PLAYLIST';

  @override
  String get playlistEmpty => 'Belum ada lagu di playlist ini';

  @override
  String get pasteTrackList => 'Tempel daftar lagu';

  @override
  String get pasteImportLink => 'Tempel tautan untuk diimpor';

  @override
  String get tracksNotFound => 'Tidak ada lagu ditemukan pada tautan itu.';

  @override
  String get importError =>
      'Impor gagal. Periksa tautan dan koneksi internet Anda.';

  @override
  String importedPlaylistStarted(int count) {
    return 'Memutar playlist terimpor ($count lagu)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'Impor ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return 'Playlist «$name» tersimpan di pustaka Anda!';
  }

  @override
  String get spotifyImportSubtitle => 'Spotify • Playlist, album, dan lagu';

  @override
  String get artistTrackOrCsv => 'Artis — Lagu, atau CSV Exportify';

  @override
  String get pastePlaylistOrTrackLink => 'Tempel tautan playlist atau lagu';

  @override
  String get pasteFromClipboard => 'Tempel dari papan klip';

  @override
  String get link => 'Tautan';

  @override
  String get trackList => 'Daftar lagu';

  @override
  String get playlistName => 'Nama playlist';

  @override
  String get startImport => 'Mulai impor';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count lagu';
  }

  @override
  String get importedFromSpotify => 'Diimpor dari Spotify';

  @override
  String get importedFromDeezer => 'Diimpor dari Deezer';

  @override
  String get importIntro =>
      'Bawa playlist Anda. Gunakan tautan Spotify, daftar lagu, atau berkas Exportify.';

  @override
  String get importTextTab => 'Teks';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'Pilih berkas';

  @override
  String get importFileHint =>
      'Pilih CSV yang diekspor Exportify atau daftar lagu TXT. UTF-8, hingga 10 MB dan 10.000 lagu.';

  @override
  String get importFileAndroidOnly =>
      'Pemilihan berkas tersedia di Android. Di sini Anda bisa menempel isi CSV atau daftar lagu.';

  @override
  String get importTextHint =>
      'Satu baris Artis — Lagu. Anda juga bisa menempel CSV lengkap termasuk tajuknya.';

  @override
  String get importPreview => 'Pratinjau lagu';

  @override
  String get importedFromCsv => 'Diimpor dari CSV';

  @override
  String get importedFromText => 'Diimpor dari daftar lagu';

  @override
  String importMoreTracks(int count) {
    return 'Dan $count lainnya';
  }

  @override
  String get importMetadataHint =>
      'Playlist disimpan di perangkat ini. Audio dicari saat lagu diputar; impor tidak mengunduh lagu.';

  @override
  String get importAnother => 'Impor yang lain';

  @override
  String get importReading => 'Membaca playlist Anda…';

  @override
  String get importSaving => 'Menyimpan ke pustaka Anda…';

  @override
  String get importNameRequired => 'Masukkan nama playlist.';

  @override
  String get importNameExists =>
      'Playlist dengan nama ini sudah ada. Pilih nama lain agar keduanya tersimpan.';

  @override
  String get importSaveFailed =>
      'Playlist tidak bisa disimpan. Pratinjau Anda masih ada — coba lagi.';

  @override
  String get importFileTooLarge =>
      'Berkas ini lebih dari 10 MB. Bagi playlist menjadi ekspor yang lebih kecil.';

  @override
  String get importFileUnsupported => 'Pilih berkas .csv atau .txt.';

  @override
  String get importFileEncoding =>
      'Pengodean teks tidak bisa dibaca. Simpan berkas sebagai UTF-8 dan coba lagi.';

  @override
  String get importCsvInvalid =>
      'CSV tidak lengkap atau rusak. Ekspor ulang tanpa mengubah kolom atau tanda kutipnya.';

  @override
  String get importCsvMissingColumns =>
      'CSV membutuhkan kolom Track Name dan Artist Name(s), atau Title dan Artist. Gunakan ekspor Exportify asli.';

  @override
  String get importFileEmpty =>
      'Tidak ada lagu ditemukan. Pilih ekspor yang berisi atau tempel daftar Artis — Lagu.';

  @override
  String get importTooManyTracks =>
      'Satu impor maksimal 10.000 lagu. Bagi playlist ini; belum ada yang tersimpan.';

  @override
  String get importFileReadFailed =>
      'Berkas ini tidak bisa dibuka. Pastikan tersedia di perangkat Anda dan pilih lagi.';

  @override
  String get importSpotifyBlocked =>
      'Spotify tidak membagikan playlist ini di wilayah Anda. Ekspor dengan Exportify dan pilih berkas CSV.';

  @override
  String get listen => 'Putar';

  @override
  String get addToPlaylists => 'Tambahkan ke playlist';

  @override
  String trackSemantics(String title, String artist) {
    return 'Lagu $title, $artist';
  }

  @override
  String get trackActions => 'Tindakan lagu';

  @override
  String get updatesTitle => 'Pembaruan';

  @override
  String get accountTitle => 'Akun';

  @override
  String get waveLoading => 'Mencari lagu yang mirip…';

  @override
  String get randomPick => 'Pilihan acak untukmu';

  @override
  String get accountCaption => 'Sinkronkan pustakamu antar perangkat';

  @override
  String get nickname => 'Nama panggilan';

  @override
  String get nicknameHint => '3–20 karakter: huruf, angka, . _ -';

  @override
  String get password => 'Kata sandi';

  @override
  String get passwordMinHint => 'Setidaknya 6 karakter';

  @override
  String get signIn => 'Masuk';

  @override
  String get signUp => 'Buat akun';

  @override
  String get haveAccountToggle => 'Sudah punya akun? Masuk';

  @override
  String get noAccountToggle => 'Belum punya akun? Buat satu';

  @override
  String get signOut => 'Keluar';

  @override
  String get syncNow => 'Sinkronkan sekarang';

  @override
  String get syncing => 'Menyinkronkan…';

  @override
  String syncedAt(String time) {
    return 'Tersinkron: $time';
  }

  @override
  String get neverSynced => 'Belum pernah tersinkron';

  @override
  String get errorNicknameTaken => 'Nama panggilan itu sudah dipakai';

  @override
  String get errorNicknameInvalid => 'Nama: 3–20 karakter, huruf/angka/._-';

  @override
  String get errorInvalidCredentials => 'Nama panggilan atau kata sandi salah';

  @override
  String get errorWeakPassword => 'Kata sandi terlalu pendek';

  @override
  String get errorNetwork => 'Tidak ada koneksi';

  @override
  String get errorServer => 'Galat server, coba lagi nanti';

  @override
  String currentVersion(String version) {
    return 'Versi $version';
  }

  @override
  String get checkForUpdates => 'Periksa pembaruan';

  @override
  String get checkingForUpdates => 'Memeriksa…';

  @override
  String get upToDate => 'Kamu memakai versi terbaru';

  @override
  String updateAvailable(String version) {
    return 'Versi $version tersedia';
  }

  @override
  String get downloadingUpdate => 'Mengunduh pembaruan…';

  @override
  String get installUpdate => 'Instal';

  @override
  String get updateCheckFailed =>
      'Gagal memeriksa pembaruan. Periksa internet.';

  @override
  String get installPermissionNeeded =>
      'Izinkan Hook memasang aplikasi lalu ketuk Instal lagi.';

  @override
  String updateSize(String size) {
    return '$size MB';
  }

  @override
  String get download => 'Unduh';

  @override
  String get downloading => 'Mengunduh…';

  @override
  String get downloaded => 'Terunduh';

  @override
  String get downloadFailed => 'Gagal mengunduh';

  @override
  String get removeDownload => 'Hapus unduhan';

  @override
  String get downloadSavedOffline => 'Disimpan offline';

  @override
  String get startWaveFromTrack => 'Mulai gelombang dari lagu ini';

  @override
  String get addToQueue => 'Tambahkan ke antrean';

  @override
  String addedToQueue(String title) {
    return 'Ditambahkan ke antrean: $title';
  }

  @override
  String get removeFavorite => 'Hapus dari favorit';

  @override
  String get addFavorite => 'Tambahkan ke favorit';

  @override
  String get addToPlaylist => 'Tambahkan ke playlist';

  @override
  String get goToArtist => 'Ke artis';

  @override
  String get myPlaylist => 'Playlist saya';

  @override
  String get newPlaylist => 'Playlist baru';

  @override
  String get name => 'Nama';

  @override
  String get create => 'Buat';

  @override
  String get loading => 'Memuat…';

  @override
  String get pause => 'Jeda';

  @override
  String get play => 'Putar';

  @override
  String get next => 'Berikutnya';

  @override
  String get speedAndPitch => 'Kecepatan dan nada';

  @override
  String speedValue(String value) {
    return 'Kecepatan: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'Nada: ${value}x';
  }

  @override
  String get reset => 'Setel ulang';

  @override
  String get moreActions => 'Tindakan lainnya';

  @override
  String get playbackQueue => 'Antrean pemutaran';

  @override
  String get queueEmpty => 'Antrean kosong';

  @override
  String get selectingSource => 'Memilih sumber';

  @override
  String get collapsePlayer => 'Ciutkan pemutar';

  @override
  String get nowPlayingUpper => 'SEDANG DIPUTAR';

  @override
  String get queue => 'Antrean';

  @override
  String get startWave => 'Mulai gelombang';

  @override
  String get cover => 'Sampul';

  @override
  String get karaokeLyrics => 'Lirik karaoke';

  @override
  String get findMusicStart => 'Temukan musik dan mulai memutar';

  @override
  String get playbackNotStarted => 'Pemutaran belum dimulai';

  @override
  String get openSearchFirstTrack =>
      'Buka pencarian untuk menemukan lagu pertama Anda';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => 'Di perangkat';

  @override
  String get sourceCatalog => 'Katalog';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'Server';

  @override
  String get serverResolver => 'Server resolusi';

  @override
  String get serverResolverCaption =>
      'Server mandiri opsional yang menyelesaikan aliran audio penuh. Aplikasi mengirim pencarian atau ID lagu; server mengembalikan URL pemutaran. Kontrak dan implementasi acuan ada di docs/REMOTE_RESOLVER.md.';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'Belum dikonfigurasi';

  @override
  String get serverSave => 'Simpan';

  @override
  String get serverDisable => 'Nonaktifkan';

  @override
  String get onboardingWelcomeTitle => 'Selamat datang di Hook';

  @override
  String get onboardingWelcomeCaption =>
      'Musik, lirik, dan gaya visual Anda sendiri. Pilih bahasa untuk memulai — bisa diubah nanti di pengaturan.';

  @override
  String get onboardingSkip => 'Lewati';

  @override
  String get onboardingNext => 'Lanjut';

  @override
  String get onboardingStart => 'Mulai mendengarkan';

  @override
  String get onboardingMicrogTitle => 'MicroG dan akun Google';

  @override
  String get onboardingMicrogBody =>
      'MicroG menghadirkan kembali layanan Google pada ROM Android kustom yang lahir tanpanya. Hook memakainya hanya untuk satu fitur opsional: menyambungkan akun YouTube untuk mengimpor playlist. Memutar musik tidak pernah butuh MicroG atau layanan Google mana pun.';

  @override
  String get onboardingMicrogNote =>
      'Pemutaran tidak bergantung pada MicroG. Menyambungkan akun itu opsional.';

  @override
  String get onboardingMicrogDownload => 'Unduh MicroG';

  @override
  String get onboardingMicrogStatusChecking => 'Memeriksa layanan Google…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'Layanan Google tersedia di perangkat ini ($version). Impor akun akan langsung berfungsi.';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'Terdeteksi ReVanced GmsCore ($version). SDK masuk resmi Google tidak kompatibel dengannya, jadi penyambungan akun mungkin tidak berfungsi. Pemutaran tidak terpengaruh.';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'Layanan Google tidak ditemukan. Untuk mengimpor playlist dari akun YouTube, instal MicroG terlebih dahulu — atau lewati ini dan pakai Hook tanpa akun.';

  @override
  String lyricsView(String mode) {
    return 'Tampilan lirik · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'Irama baca Anda';

  @override
  String get lyricsModeSubtitle => 'Tiga cara mendekati lagu.';

  @override
  String get lyricsModeLines => 'Baris';

  @override
  String get lyricsModeKaraoke => 'Karaoke';

  @override
  String get lyricsModeFocus => 'Fokus';

  @override
  String get lyricsModeLinesDescription =>
      'Lirik tenang dengan baris saat ini disorot';

  @override
  String get lyricsModeKaraokeDescription =>
      'Kata-kata menyala lembut mengikuti vokal';

  @override
  String get lyricsModeFocusDescription => 'Satu baris besar. Tidak ada lagi';

  @override
  String get lyricsModeSaveFailed => 'Tampilan lirik tidak bisa disimpan.';

  @override
  String get lyricsModeFootnote =>
      'Pilihan Anda tersimpan untuk lagu berikutnya. Akurasi karaoke bergantung pada data sumber: penyorotan kata perkiraan tanpa pewaktuan per kata, dan lirik diam tanpa penanda waktu.';

  @override
  String get lyricsNotFound => 'Lirik tidak ditemukan';

  @override
  String get karaokeUnavailable =>
      'Lirik karaoke tidak tersedia untuk lagu ini';

  @override
  String get unsyncedLyrics => 'Lirik tanpa sinkronisasi';

  @override
  String get wordSyncUpper => 'SINKRON KATA PER KATA';

  @override
  String get lineSyncUpper => 'SINKRON BARIS PER BARIS';

  @override
  String get adjustLyricsSync => 'Sesuaikan sinkronisasi lirik';

  @override
  String get startsSoon => 'Segera dimulai';

  @override
  String get musicContinues => 'Musik berlanjut';

  @override
  String get decreaseLyricsOffset => 'Kurangi offset 0,1 dtk';

  @override
  String lyricsOffset(String value) {
    return 'Offset: $value dtk';
  }

  @override
  String get increaseLyricsOffset => 'Naikkan offset 0,1 dtk';

  @override
  String get hideSetting => 'Sembunyikan pengaturan';

  @override
  String get lyricsOffsetSaveFailed => 'Offset lirik tidak bisa disimpan.';

  @override
  String get audioForbidden =>
      'Server audio menolak akses (HTTP 403). Lagu ditemukan, tetapi alirannya tidak tersedia. VPN tidak menjamin akses audio.';

  @override
  String get fullVersionUnavailable =>
      'Tidak ada versi lengkap di sumber yang tersedia. Periksa koneksi atau coba nanti.';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source tidak bisa memutar lagu ini. Periksa koneksi atau coba nanti.';
  }

  @override
  String get recentQueriesUpper => 'PENCARIAN TERAKHIR';

  @override
  String get clearHistory => 'Hapus';

  @override
  String get waveFromArtist => 'Gelombang artis';

  @override
  String get popularTracksUpper => 'LAGU POPULER';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lagu',
      zero: 'belum ada lagu',
    );
    return '$_temp0';
  }
}
