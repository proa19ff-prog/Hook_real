// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'Cài đặt';

  @override
  String get settingsCaption => 'Các thay đổi được lưu trên thiết bị này.';

  @override
  String get playerSettings => 'Trình phát';

  @override
  String get lyricsAutoHide => 'Ẩn điều khiển khi đọc lời bài hát';

  @override
  String get lyricsAutoHideDescription =>
      'Sau 10 giây không tương tác, các bảng điều khiển sẽ trượt khỏi màn hình. Dùng nút khôi phục để đưa chúng trở lại.';

  @override
  String get showPlayerControls => 'Hiện điều khiển trình phát';

  @override
  String get equalizer => 'Bộ chỉnh âm';

  @override
  String get equalizerEnabled => 'Xử lý âm thanh';

  @override
  String get equalizerPresets => 'Hồ sơ âm thanh';

  @override
  String get equalizerFlat => 'Nguyên bản';

  @override
  String get equalizerBass => 'Trầm sâu';

  @override
  String get equalizerVocal => 'Giọng hát';

  @override
  String get equalizerRock => 'Rock';

  @override
  String get equalizerElectronic => 'Điện tử';

  @override
  String get equalizerSoft => 'Nhẹ nhàng';

  @override
  String get equalizerCustom => 'Tùy chỉnh';

  @override
  String get equalizerBands => 'Dải tần số';

  @override
  String get equalizerBassBoost => 'Tăng cường trầm';

  @override
  String get equalizerBassUnsupported =>
      'Tăng cường trầm bổ sung không được hỗ trợ. Hãy dùng các dải tần thấp.';

  @override
  String get equalizerPreamp => 'Khuếch đại trước';

  @override
  String get equalizerHeadroom => 'Đầu vào dự phòng tự động';

  @override
  String get equalizerHeadroomDescription =>
      'Giảm mức đầu ra khi tăng cường tần số để chừa chỗ cho đỉnh âm. Không phải bộ giới hạn.';

  @override
  String get equalizerWaiting =>
      'Phát một bài hát để kết nối bộ chỉnh âm với phiên âm thanh của nó.';

  @override
  String get equalizerUnsupported =>
      'Xử lý âm thanh hiện chỉ khả dụng trên Android.';

  @override
  String get equalizerFailed =>
      'Thiết bị này không thể bật hiệu ứng âm thanh. Nhạc vẫn phát bình thường mà không cần chúng.';

  @override
  String get equalizerRetry => 'Kết nối lại hiệu ứng';

  @override
  String get equalizerLive =>
      'Thay đổi áp dụng ngay và được lưu trên thiết bị này.';

  @override
  String get youtubeAccount => 'YouTube & MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'Truy cập danh sách phát chỉ để đọc. Đăng nhập không đảm bảo có âm thanh.';

  @override
  String get youtubeAccountCompatibility => 'Tương thích và quyền riêng tư';

  @override
  String get youtubeAccountSubtitle =>
      'Kết nối tài khoản và nhập danh sách phát';

  @override
  String get youtubeAccountPrivacy =>
      'Hook chỉ yêu cầu quyền đọc YouTube. Chỉ nhập mật khẩu trong hộp thoại hệ thống của Google, không bao giờ nhập trong Hook. Mã thông báo không được gửi tới bất kỳ máy chủ Hook nào và chỉ lưu trong bộ nhớ. Kết nối lại sau khi khởi động lại ứng dụng.';

  @override
  String get youtubeAccountPlaybackNotice =>
      'Đăng nhập cấp quyền truy cập dữ liệu tài khoản, không phải luồng âm thanh. Không đảm bảo sửa lỗi HTTP 403. Việc nhập giữ nguyên bản ghi YouTube thay vì thay bằng nguồn khác.';

  @override
  String get youtubeAccountConnect => 'Kết nối tài khoản';

  @override
  String get youtubeAccountDisconnect => 'Ngắt kết nối trong Hook';

  @override
  String get youtubeAccountDisconnected => 'Chưa kết nối tài khoản';

  @override
  String get youtubeAccountDisconnectNotice =>
      'Ngắt tài khoản này chỉ trong Hook? Danh sách phát đã lưu vẫn giữ nguyên. Tài khoản Google và MicroG trên điện thoại không bị đăng xuất.';

  @override
  String get youtubeAccountSystem => 'API Google hệ thống';

  @override
  String get youtubeAccountServicesMissing =>
      'Thiếu API Google hệ thống tương thích. Bản cài đặt ReVanced GmsCore riêng không thay thế chúng cho đăng nhập của Hook.';

  @override
  String get youtubeAccountMicrogNotice =>
      'Phát hiện bản cài đặt ReVanced GmsCore riêng. Hook không dùng tài khoản hay mã thông báo ReVanced. MicroG hệ thống có thể cung cấp API Google tương thích, nhưng tính tương thích với phương thức đăng nhập này không được đảm bảo.';

  @override
  String get youtubeAccountRevancedFound =>
      'YouTube Music ReVanced đã được cài đặt';

  @override
  String get youtubeAccountPlaylists => 'Danh sách phát của tài khoản';

  @override
  String get youtubeAccountNoPlaylists =>
      'Không có danh sách phát nào truy cập được. Một số bộ sưu tập tự động của YouTube Music không có sẵn qua YouTube Data API.';

  @override
  String get youtubeAccountMore => 'Tải thêm';

  @override
  String get youtubeAccountPreview => 'Chuẩn bị nhập';

  @override
  String youtubeAccountProgress(int count) {
    return 'Đã lấy được bản nhạc: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'Đã bỏ qua mục không khả dụng: $count. Chúng không bị thay bằng bản nhạc khác.';
  }

  @override
  String get youtubeAccountSetup => 'Thiết lập đăng nhập';

  @override
  String get youtubeAccountSetupBody =>
      'Nhà phát triển cần bật YouTube Data API v3 trong Google Cloud, đăng ký ứng dụng OAuth Android cho com.hook.music với SHA-1 ký của bản cài đặt, và cấu hình màn hình đồng ý. Thêm người dùng được phép ở chế độ kiểm thử. Xem docs/YOUTUBE_ACCOUNT_SETUP.md. Không bao giờ thêm mật khẩu, bí mật ứng dụng hay mã thông báo từ ứng dụng khác.';

  @override
  String get youtubeAccountConfigError =>
      'Đăng nhập chưa được cấu hình cho bản dựng này. Hãy kiểm tra ứng dụng OAuth Android, tên gói, SHA-1 và người dùng kiểm thử được phép trong Google Cloud.';

  @override
  String get youtubeAccountPermissionError =>
      'Quyền đọc dữ liệu YouTube chưa được cấp.';

  @override
  String get youtubeAccountExpired =>
      'Phiên của bạn đã hết hạn. Kết nối lại tài khoản.';

  @override
  String get youtubeAccountNoChannel =>
      'Tài khoản đã chọn không có kênh YouTube nào truy cập được.';

  @override
  String get youtubeAccountQuota => 'Đã vượt hạn mức API YouTube. Thử lại sau.';

  @override
  String get youtubeAccountFailed =>
      'Không lấy được dữ liệu YouTube. Kiểm tra kết nối và thử lại.';

  @override
  String get youtubeAccountUnsupported =>
      'Kết nối tài khoản yêu cầu Android có API Google hệ thống tương thích.';

  @override
  String get importedFromYouTube => 'Đã nhập từ tài khoản YouTube';

  @override
  String get translateLyrics => 'Dịch lời bài hát';

  @override
  String get hideTranslation => 'Ẩn bản dịch';

  @override
  String get cancelTranslation => 'Hủy dịch';

  @override
  String get translationLoading => 'Đang chuẩn bị bản dịch…';

  @override
  String get translationAttribution => 'Tự động dịch bởi Google Dịch';

  @override
  String get translationNotice =>
      'Bản dịch có thể không nắm trọn ý nghĩa bài hát. Việc tô sáng từng từ chỉ áp dụng cho bản gốc.';

  @override
  String get translationModelTitle => 'Tải xuống mô hình ngôn ngữ?';

  @override
  String get translationModelBody =>
      'Bản dịch chạy ngay trên điện thoại của bạn: lời bài hát không được gửi tới máy chủ. Lần dịch đầu tiên cần các mô hình Google ML Kit, chiếm hàng chục megabyte. Tải xuống dùng kết nối hiện tại của bạn, kể cả dữ liệu di động. Hủy sẽ ẩn kết quả, nhưng bản tải đã bắt đầu có thể hoàn tất dưới nền.';

  @override
  String get translationDownload => 'Tải xuống và dịch';

  @override
  String get translationUnavailable =>
      'Dịch thất bại. Kiểm tra quyền tải mô hình và thử lại.';

  @override
  String get translationUnsupported =>
      'Dịch trên thiết bị hiện chỉ khả dụng trên Android.';

  @override
  String get translationUnknownLanguage =>
      'Không xác định được ngôn ngữ được hỗ trợ của bài hát này.';

  @override
  String get translationSameLanguage => 'Lời bài hát đã ở ngôn ngữ đã chọn.';

  @override
  String get translationTooLarge =>
      'Lời bài hát này quá dài để dịch trên thiết bị.';

  @override
  String get translationRussian => 'Sang tiếng Nga';

  @override
  String get translationEnglish => 'Sang tiếng Anh';

  @override
  String get translationTarget => 'Ngôn ngữ dịch';

  @override
  String get retry => 'Thử lại';

  @override
  String get home => 'Trang chủ';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get library => 'Thư viện';

  @override
  String get youtubeUnavailableTitle => 'YouTube hiện không khả dụng';

  @override
  String get youtubeUnavailableBody =>
      'Không lấy được luồng âm thanh. Kiểm tra mạng và đường VPN của bạn: YouTube có thể từ chối yêu cầu kể cả khi có VPN.';

  @override
  String get checkAgain => 'Kiểm tra lại';

  @override
  String get dismiss => 'Đóng';

  @override
  String get goodNight => 'Chúc ngủ ngon';

  @override
  String get goodMorning => 'Chào buổi sáng';

  @override
  String get goodAfternoon => 'Chào buổi chiều';

  @override
  String get goodEvening => 'Chào buổi tối';

  @override
  String get themeSettings => 'Cài đặt giao diện';

  @override
  String get onYourAir => 'Trên sóng của bạn';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tín hiệu gần đây',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'Bộ sưu tập của bạn đang chờ';

  @override
  String get saved => 'Đã lưu';

  @override
  String get collectionEmptyDetail => 'Âm nhạc bạn muốn quay lại sẽ ở lại đây';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bản nhạc',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'Bản nhạc, nghệ sĩ hoặc lời hát';

  @override
  String get searchUpper => 'TÌM KIẾM';

  @override
  String get findFirstTrack => 'Tìm bản nhạc đầu tiên của bạn';

  @override
  String continuationAfter(String artist) {
    return 'Thêm nhạc sau $artist';
  }

  @override
  String get chooseTrackWaveDetail =>
      'Chọn một bản nhạc, chúng tôi sẽ dệt một làn sóng quanh cảm xúc của nó.';

  @override
  String get continueWaveLabel => 'TIẾP TỤC / 01';

  @override
  String get yourWaveLabel => 'LÀN SÓNG CỦA BẠN / 01';

  @override
  String get continueWave => 'Tiếp tục làn sóng';

  @override
  String get chooseTrack => 'Chọn bản nhạc';

  @override
  String get firstTrace => 'Để lại dấu vết đầu tiên của bạn tại đây';

  @override
  String get favoriteWaveHint =>
      'Lưu yêu thích, làn sóng của bạn sẽ chuẩn hơn.';

  @override
  String get openSearch => 'Mở tìm kiếm';

  @override
  String get findYourMusic => 'Tìm âm thanh của riêng bạn.';

  @override
  String get importMusic => 'Nhập nhạc';

  @override
  String get rememberedLyricsHint => 'Những từ bạn còn nhớ…';

  @override
  String get trackArtistHint =>
      'Bản nhạc hoặc nghệ sĩ — ngôn ngữ nào cũng được';

  @override
  String get clear => 'Xóa';

  @override
  String get music => 'Nhạc';

  @override
  String get byLyrics => 'Theo lời hát';

  @override
  String get allSources => 'Tất cả nguồn';

  @override
  String get lyricsSearchCaption =>
      'Tìm một câu trong bài hát, chứ không chỉ tiêu đề.';

  @override
  String get searchingLyrics => 'Đang tìm những câu quen thuộc…';

  @override
  String get searchingSources => 'Đang tìm trong các nguồn nhạc…';

  @override
  String get connectionFailed => 'Không thể kết nối';

  @override
  String get noMatches => 'Chưa có kết quả khớp';

  @override
  String get lyricsUnavailable =>
      'Tìm kiếm lời hát hiện không khả dụng. Thử lại sau hoặc tìm theo tiêu đề.';

  @override
  String get searchUnavailable =>
      'Tìm kiếm thất bại. Kiểm tra kết nối và thử lại.';

  @override
  String get lyricsNoMatches =>
      'Thử câu khác. Không phải lời bài hát nào cũng được đánh chỉ mục.';

  @override
  String get trackNoMatches =>
      'Thêm tên nghệ sĩ hoặc chọn nguồn khác. Một số dịch vụ có thể không truy cập được trên mạng của bạn.';

  @override
  String get repeatSearch => 'Tìm lại';

  @override
  String get lyricMatchesUpper => 'KHỚP LỜI HÁT';

  @override
  String get tracksUpper => 'BẢN NHẠC';

  @override
  String playTrack(String title, String artist) {
    return 'Phát $title, $artist';
  }

  @override
  String get familiarLinesUpper => 'CÂU QUEN THUỘC';

  @override
  String get bestMatchUpper => 'KHỚP TỐT NHẤT';

  @override
  String get fullVersionOnPlayback =>
      'Chúng tôi sẽ tìm bản đầy đủ khi phát bắt đầu.';

  @override
  String get forgotTitle => 'Quên tiêu đề.\nNhưng không quên giai điệu.';

  @override
  String get startAsYouRemember =>
      'Tên, tiêu đề hay một câu trong bài.\nBắt đầu từ điều bạn còn nhớ.';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => 'Tìm tên theo cách chúng nghe';

  @override
  String get rememberOnlyLine => 'Tôi chỉ nhớ một câu';

  @override
  String get findSongByWords => 'Tìm bài hát qua lời của nó';

  @override
  String get yourArtistsUpper => 'NGHỆ SĨ CỦA BẠN';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageCaption => 'Giao diện theo lựa chọn của bạn ngay lập tức';

  @override
  String get systemLanguage => 'Hệ thống';

  @override
  String get russian => 'Tiếng Nga';

  @override
  String get english => 'Tiếng Anh';

  @override
  String get themesAndShaders => 'Chủ đề và hiệu ứng';

  @override
  String get themesSubtitle => 'Diện mạo, ngôn ngữ và chuyển động nền';

  @override
  String get invalidThemeJson =>
      'Không đọc được chủ đề. Kiểm tra định dạng JSON và giá trị các trường.';

  @override
  String get exportJson => 'Xuất JSON';

  @override
  String get importJson => 'Nhập JSON';

  @override
  String get readyThemes => 'Chủ đề dựng sẵn';

  @override
  String get gpuShaders => 'Hiệu ứng nền';

  @override
  String get meshGradient => 'Dải màu GPU mượt dựa trên màu bản nhạc';

  @override
  String get vinylNoise => 'Hạt đĩa than analog (tiếng ồn)';

  @override
  String get glassBlur => 'Làm mờ kính (Backdrop Blur)';

  @override
  String get cornerRadius => 'Bo góc giao diện';

  @override
  String get importThemeTitle => 'Nhập chủ đề từ JSON';

  @override
  String get pasteThemeJson => 'Dán cấu hình JSON của chủ đề:';

  @override
  String get cancel => 'Hủy';

  @override
  String get apply => 'Áp dụng';

  @override
  String get themeApplied => 'Đã áp dụng chủ đề thành công!';

  @override
  String get exportThemeTitle => 'Xuất chủ đề (JSON)';

  @override
  String get close => 'Đóng';

  @override
  String get copyJson => 'Sao chép JSON';

  @override
  String get jsonCopied => 'Đã sao chép JSON chủ đề vào bộ nhớ tạm!';

  @override
  String get libraryUpper => 'THƯ VIỆN';

  @override
  String get localCollection => 'Bộ sưu tập tại máy và danh sách phát';

  @override
  String get importShort => 'Nhập';

  @override
  String get favorites => 'Yêu thích';

  @override
  String get playlists => 'Danh sách phát';

  @override
  String get history => 'Lịch sử';

  @override
  String get offline => 'Ngoại tuyến';

  @override
  String get favoritesEmpty =>
      'Mục yêu thích đang trống.\nChạm trái tim trên bản nhạc để thêm vào đây.';

  @override
  String get historyEmpty =>
      'Lịch sử nghe của bạn đang trống.\nPhát nhạc từ tìm kiếm, nó sẽ xuất hiện ở đây.';

  @override
  String get noPlaylists => 'Bạn chưa có danh sách phát nào';

  @override
  String get importPlaylistHint =>
      'Nhập danh sách phát Spotify hoặc dán danh sách bản nhạc.';

  @override
  String get importMusicAction => 'Nhập nhạc';

  @override
  String get playPlaylist => 'Phát danh sách';

  @override
  String playlistStarted(String name, int count) {
    return 'Đang phát «$name» ($count bản nhạc)';
  }

  @override
  String get deletePlaylist => 'Xóa danh sách phát';

  @override
  String get playAll => 'Phát tất cả';

  @override
  String get shuffle => 'Phát ngẫu nhiên';

  @override
  String get localAudioCache => 'Bộ nhớ đệm âm thanh cục bộ';

  @override
  String get cacheDescription =>
      'Bản nhạc đã phát được lưu cục bộ để nghe lại ngay không cần mạng.';

  @override
  String deviceUsage(String size) {
    return 'Trên thiết bị này: $size';
  }

  @override
  String get clearCache => 'Xóa toàn bộ bộ nhớ đệm';

  @override
  String savedTracksUpper(int count) {
    return 'BẢN NHẠC ĐÃ LƯU ($count):';
  }

  @override
  String get cacheFeaturesUpper => 'TÍNH NĂNG BỘ ĐỆM:';

  @override
  String get offlineFirst => 'Ưu tiên ngoại tuyến trọn vẹn';

  @override
  String get offlineFirstDescription =>
      'Khi nghe lại, âm thanh tải thẳng từ hệ thống tệp của thiết bị.';

  @override
  String get maximumBitrate => 'Bitrate tối đa';

  @override
  String get maximumBitrateDescription =>
      'Luồng Opus/M4A sạch 160–256 kbps được lưu không chuyển mã.';

  @override
  String get trafficAndBattery => 'Tiết kiệm dữ liệu và pin';

  @override
  String get trafficAndBatteryDescription =>
      'Tránh các yêu cầu mạng lặp lại giúp điện thoại của bạn dùng bền hơn.';

  @override
  String get cacheEmpty => 'Bộ nhớ đệm trống';

  @override
  String get cachedTracksAppear => 'Bản nhạc đã tải sẽ tự động xuất hiện ở đây';

  @override
  String get removeFromCache => 'Xóa khỏi bộ nhớ đệm';

  @override
  String get removeCachedTrackTitle => 'Xóa bản nhạc khỏi bộ nhớ đệm?';

  @override
  String removeCachedTrackBody(String title) {
    return '«$title» sẽ bị xóa khỏi thiết bị này.';
  }

  @override
  String get delete => 'Xóa';

  @override
  String get trackRemovedFromCache => 'Đã xóa bản nhạc khỏi bộ nhớ đệm';

  @override
  String get clearCacheTitle => 'Xóa bộ nhớ đệm?';

  @override
  String get clearCacheBody =>
      'Toàn bộ tệp âm thanh đã lưu sẽ bị xóa khỏi thiết bị. Yêu thích và lịch sử không đổi.';

  @override
  String get cacheCleared => 'Đã xóa bộ nhớ đệm cục bộ';

  @override
  String get back => 'Quay lại';

  @override
  String get playlistActions => 'Thao tác danh sách phát';

  @override
  String get playlistUpper => 'DANH SÁCH PHÁT';

  @override
  String get playlistEmpty => 'Danh sách phát này chưa có bản nhạc nào';

  @override
  String get pasteTrackList => 'Dán danh sách bản nhạc';

  @override
  String get pasteImportLink => 'Dán liên kết để nhập';

  @override
  String get tracksNotFound => 'Không tìm thấy bản nhạc nào tại liên kết đó.';

  @override
  String get importError =>
      'Nhập thất bại. Kiểm tra liên kết và kết nối internet của bạn.';

  @override
  String importedPlaylistStarted(int count) {
    return 'Đang phát danh sách đã nhập ($count bản nhạc)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'Nhập ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return 'Đã lưu danh sách phát «$name» vào thư viện của bạn!';
  }

  @override
  String get spotifyImportSubtitle =>
      'Spotify • Danh sách phát, album và bản nhạc';

  @override
  String get artistTrackOrCsv =>
      'Nghệ sĩ — Bản nhạc, hoặc tệp CSV của Exportify';

  @override
  String get pastePlaylistOrTrackLink =>
      'Dán liên kết danh sách phát hoặc bản nhạc';

  @override
  String get pasteFromClipboard => 'Dán từ bộ nhớ tạm';

  @override
  String get link => 'Liên kết';

  @override
  String get trackList => 'Danh sách bản nhạc';

  @override
  String get playlistName => 'Tên danh sách phát';

  @override
  String get startImport => 'Bắt đầu nhập';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count bản nhạc';
  }

  @override
  String get importedFromSpotify => 'Đã nhập từ Spotify';

  @override
  String get importedFromDeezer => 'Nhập từ Deezer';

  @override
  String get importIntro =>
      'Mang danh sách phát của bạn theo. Dùng liên kết Spotify, danh sách bản nhạc hoặc tệp Exportify.';

  @override
  String get importTextTab => 'Văn bản';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'Chọn tệp';

  @override
  String get importFileHint =>
      'Chọn CSV xuất từ Exportify hoặc danh sách bản nhạc TXT. UTF-8, tối đa 10 MB và 10.000 bản nhạc.';

  @override
  String get importFileAndroidOnly =>
      'Chọn tệp chỉ khả dụng trên Android. Tại đây bạn có thể dán nội dung CSV hoặc danh sách bản nhạc.';

  @override
  String get importTextHint =>
      'Mỗi dòng một cặp Nghệ sĩ — Bản nhạc. Bạn cũng có thể dán nguyên CSV, kể cả dòng tiêu đề.';

  @override
  String get importPreview => 'Xem trước bản nhạc';

  @override
  String get importedFromCsv => 'Đã nhập từ CSV';

  @override
  String get importedFromText => 'Đã nhập từ danh sách bản nhạc';

  @override
  String importMoreTracks(int count) {
    return 'Và $count bản nữa';
  }

  @override
  String get importMetadataHint =>
      'Danh sách phát được lưu trên thiết bị này. Âm thanh được tìm khi phát bản nhạc; nhập không tải xuống bài hát.';

  @override
  String get importAnother => 'Nhập nội dung khác';

  @override
  String get importReading => 'Đang đọc danh sách của bạn…';

  @override
  String get importSaving => 'Đang lưu vào thư viện…';

  @override
  String get importNameRequired => 'Nhập tên danh sách phát.';

  @override
  String get importNameExists =>
      'Đã có danh sách phát trùng tên. Chọn tên khác để giữ cả hai.';

  @override
  String get importSaveFailed =>
      'Không lưu được danh sách phát. Bản xem trước vẫn còn đây — thử lại nhé.';

  @override
  String get importFileTooLarge =>
      'Tệp này vượt quá 10 MB. Chia danh sách thành các bản xuất nhỏ hơn.';

  @override
  String get importFileUnsupported => 'Chọn tệp .csv hoặc .txt.';

  @override
  String get importFileEncoding =>
      'Không đọc được mã hóa văn bản. Lưu tệp dạng UTF-8 rồi thử lại.';

  @override
  String get importCsvInvalid =>
      'CSV không đầy đủ hoặc sai định dạng. Xuất lại mà không chỉnh cột hay dấu ngoặc kép.';

  @override
  String get importCsvMissingColumns =>
      'CSV cần cột Track Name và Artist Name(s), hoặc Title và Artist. Hãy dùng bản xuất Exportify gốc.';

  @override
  String get importFileEmpty =>
      'Không tìm thấy bản nhạc nào. Chọn bản xuất có nội dung hoặc dán danh sách Nghệ sĩ — Bản nhạc.';

  @override
  String get importTooManyTracks =>
      'Mỗi lần nhập tối đa 10.000 bản nhạc. Hãy chia danh sách này; chưa có gì được lưu.';

  @override
  String get importFileReadFailed =>
      'Không mở được tệp này. Kiểm tra tệp có sẵn trên thiết bị rồi chọn lại.';

  @override
  String get importSpotifyBlocked =>
      'Spotify không chia sẻ danh sách phát này ở khu vực của bạn. Hãy xuất bằng Exportify rồi chọn tệp CSV.';

  @override
  String get listen => 'Phát';

  @override
  String get addToPlaylists => 'Thêm vào danh sách phát';

  @override
  String trackSemantics(String title, String artist) {
    return 'Bản nhạc $title, $artist';
  }

  @override
  String get trackActions => 'Thao tác bản nhạc';

  @override
  String get updatesTitle => 'Cập nhật';

  @override
  String get accountTitle => 'Tài khoản';

  @override
  String get waveLoading => 'Đang tìm bài hát tương tự…';

  @override
  String get sleepTimer => 'Hẹn giờ ngủ';

  @override
  String sleepMinutes(String value) {
    return '$value';
  }

  @override
  String get sleepUntilTrackEnd => 'Đến hết bài';

  @override
  String get sleepCancel => 'Tắt';

  @override
  String get dislike => 'Không thích';

  @override
  String get dislikeRemove => 'Bỏ khỏi ẩn';

  @override
  String dislikeSaved(String artist) {
    return 'Đã ẩn: $artist';
  }

  @override
  String get exportPlaylist => 'Xuất CSV';

  @override
  String get playlistExported => 'Đã xuất playlist';

  @override
  String get exportFailed => 'Xuất thất bại';

  @override
  String get downloadAll => 'Tải tất cả';

  @override
  String get statsTitle => 'Thống kê';

  @override
  String get statsPlays => 'Lượt nghe';

  @override
  String get statsFavorites => 'Yêu thích';

  @override
  String get statsPlaylists => 'Playlist';

  @override
  String get statsTopArtists => 'Nghệ sĩ hàng đầu';

  @override
  String get statsTopTracks => 'Bài hát hàng đầu';

  @override
  String resumeTitle(String device) {
    return 'Tiếp tục trên $device';
  }

  @override
  String get alwaysOnTop => 'Giữ cửa sổ trên cùng';

  @override
  String get randomPick => 'Chọn ngẫu nhiên cho bạn';

  @override
  String get accountCaption => 'Đồng bộ thư viện giữa các thiết bị';

  @override
  String get nickname => 'Biệt danh';

  @override
  String get nicknameHint => '3–20 ký tự: chữ cái, chữ số, . _ -';

  @override
  String get password => 'Mật khẩu';

  @override
  String get passwordMinHint => 'Ít nhất 6 ký tự';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get signUp => 'Tạo tài khoản';

  @override
  String get haveAccountToggle => 'Đã có tài khoản? Đăng nhập';

  @override
  String get noAccountToggle => 'Chưa có tài khoản? Tạo một cái';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get syncNow => 'Đồng bộ ngay';

  @override
  String get syncing => 'Đang đồng bộ…';

  @override
  String syncedAt(String time) {
    return 'Đã đồng bộ: $time';
  }

  @override
  String get neverSynced => 'Chưa từng đồng bộ';

  @override
  String get errorNicknameTaken => 'Biệt danh này đã có người dùng';

  @override
  String get errorNicknameInvalid => 'Biệt danh: 3–20 ký tự, chữ/chữ số/._-';

  @override
  String get errorInvalidCredentials => 'Sai biệt danh hoặc mật khẩu';

  @override
  String get errorWeakPassword => 'Mật khẩu quá ngắn';

  @override
  String get errorNetwork => 'Không có kết nối';

  @override
  String get errorServer => 'Lỗi máy chủ, thử lại sau';

  @override
  String currentVersion(String version) {
    return 'Phiên bản $version';
  }

  @override
  String get checkForUpdates => 'Kiểm tra cập nhật';

  @override
  String get checkingForUpdates => 'Đang kiểm tra…';

  @override
  String get upToDate => 'Bạn đang dùng phiên bản mới nhất';

  @override
  String updateAvailable(String version) {
    return 'Phiên bản $version đã có sẵn';
  }

  @override
  String get downloadingUpdate => 'Đang tải bản cập nhật…';

  @override
  String get installUpdate => 'Cài đặt';

  @override
  String get updateCheckFailed => 'Không thể kiểm tra cập nhật. Kiểm tra mạng.';

  @override
  String get installPermissionNeeded =>
      'Cho phép Hook cài đặt ứng dụng rồi nhấn Cài đặt lần nữa.';

  @override
  String updateSize(String size) {
    return '$size MB';
  }

  @override
  String get download => 'Tải xuống';

  @override
  String get downloading => 'Đang tải…';

  @override
  String get downloaded => 'Đã tải';

  @override
  String get downloadFailed => 'Không thể tải xuống';

  @override
  String get removeDownload => 'Xóa bản tải xuống';

  @override
  String get downloadSavedOffline => 'Đã lưu ngoại tuyến';

  @override
  String get startWaveFromTrack => 'Bắt đầu làn sóng từ bản nhạc này';

  @override
  String get addToQueue => 'Thêm vào hàng đợi';

  @override
  String addedToQueue(String title) {
    return 'Đã thêm vào hàng đợi: $title';
  }

  @override
  String get removeFavorite => 'Bỏ khỏi yêu thích';

  @override
  String get addFavorite => 'Thêm vào yêu thích';

  @override
  String get addToPlaylist => 'Thêm vào danh sách phát';

  @override
  String get goToArtist => 'Đến nghệ sĩ';

  @override
  String get myPlaylist => 'Danh sách của tôi';

  @override
  String get newPlaylist => 'Danh sách phát mới';

  @override
  String get name => 'Tên';

  @override
  String get create => 'Tạo';

  @override
  String get loading => 'Đang tải…';

  @override
  String get pause => 'Tạm dừng';

  @override
  String get play => 'Phát';

  @override
  String get next => 'Tiếp';

  @override
  String get speedAndPitch => 'Tốc độ và cao độ';

  @override
  String speedValue(String value) {
    return 'Tốc độ: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'Cao độ: ${value}x';
  }

  @override
  String get reset => 'Đặt lại';

  @override
  String get moreActions => 'Thao tác khác';

  @override
  String get playbackQueue => 'Hàng đợi phát';

  @override
  String get queueEmpty => 'Hàng đợi trống';

  @override
  String get selectingSource => 'Đang chọn nguồn';

  @override
  String get collapsePlayer => 'Thu gọn trình phát';

  @override
  String get nowPlayingUpper => 'ĐANG PHÁT';

  @override
  String get queue => 'Hàng đợi';

  @override
  String get startWave => 'Bắt đầu làn sóng';

  @override
  String get cover => 'Bìa';

  @override
  String get karaokeLyrics => 'Lời karaoke';

  @override
  String get findMusicStart => 'Tìm nhạc và bắt đầu phát';

  @override
  String get playbackNotStarted => 'Chưa bắt đầu phát';

  @override
  String get openSearchFirstTrack =>
      'Mở tìm kiếm để tìm bản nhạc đầu tiên của bạn';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => 'Trên thiết bị';

  @override
  String get sourceCatalog => 'Danh mục';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'Máy chủ';

  @override
  String get serverResolver => 'Máy chủ phân giải';

  @override
  String get serverResolverCaption =>
      'Máy chủ tự vận hành tùy chọn để phân giải luồng âm thanh đầy đủ. Ứng dụng gửi truy vấn tìm kiếm hoặc ID bản nhạc; máy chủ trả về URL phát. Bản cam kết và hiện thực tham khảo nằm trong docs/REMOTE_RESOLVER.md.';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'Chưa cấu hình';

  @override
  String get serverSave => 'Lưu';

  @override
  String get serverDisable => 'Tắt';

  @override
  String get onboardingWelcomeTitle => 'Chào mừng đến với Hook';

  @override
  String get onboardingWelcomeCaption =>
      'Âm nhạc, lời hát và phong cách thị giác của riêng bạn. Chọn ngôn ngữ để bắt đầu — có thể đổi sau trong cài đặt.';

  @override
  String get onboardingSkip => 'Bỏ qua';

  @override
  String get onboardingNext => 'Tiếp tục';

  @override
  String get onboardingStart => 'Bắt đầu nghe';

  @override
  String get onboardingMicrogTitle => 'MicroG và tài khoản Google';

  @override
  String get onboardingMicrogBody =>
      'MicroG tái tạo các dịch vụ Google trên các ROM Android tùy biến không kèm sẵn chúng. Hook chỉ dùng chúng cho một tính năng tùy chọn: kết nối tài khoản YouTube để nhập danh sách phát. Nghe nhạc không bao giờ cần MicroG hay bất kỳ dịch vụ Google nào.';

  @override
  String get onboardingMicrogNote =>
      'Phát nhạc không phụ thuộc MicroG. Kết nối tài khoản là tùy chọn.';

  @override
  String get onboardingMicrogDownload => 'Tải MicroG';

  @override
  String get onboardingMicrogStatusChecking => 'Đang kiểm tra dịch vụ Google…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'Dịch vụ Google đã có trên thiết bị này ($version). Nhập tài khoản sẽ hoạt động ngay.';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'Phát hiện ReVanced GmsCore ($version). SDK đăng nhập chính thức của Google không tương thích với nó, nên kết nối tài khoản có thể không hoạt động. Phát nhạc không bị ảnh hưởng.';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'Không tìm thấy dịch vụ Google. Để nhập danh sách phát từ tài khoản YouTube, hãy cài MicroG trước — hoặc bỏ qua và dùng Hook không cần tài khoản.';

  @override
  String lyricsView(String mode) {
    return 'Chế độ xem lời · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'Nhịp đọc của bạn';

  @override
  String get lyricsModeSubtitle => 'Ba cách đến gần hơn với bài hát.';

  @override
  String get lyricsModeLines => 'Dòng';

  @override
  String get lyricsModeKaraoke => 'Karaoke';

  @override
  String get lyricsModeFocus => 'Tập trung';

  @override
  String get lyricsModeLinesDescription =>
      'Lời hát yên tĩnh với dòng hiện tại được tô sáng';

  @override
  String get lyricsModeKaraokeDescription =>
      'Các từ sáng dần nhẹ nhàng theo giọng hát';

  @override
  String get lyricsModeFocusDescription => 'Một dòng lớn. Không gì khác';

  @override
  String get lyricsModeSaveFailed => 'Không lưu được chế độ xem lời bài hát.';

  @override
  String get lyricsModeFootnote =>
      'Lựa chọn của bạn được lưu cho các bài sau. Độ chính xác của karaoke phụ thuộc dữ liệu nguồn: tô sáng từ chỉ là gần đúng khi không có thời điểm từng từ, và lời đứng yên khi không có dấu thời gian.';

  @override
  String get lyricsNotFound => 'Không tìm thấy lời bài hát';

  @override
  String get karaokeUnavailable => 'Lời karaoke không có cho bản nhạc này';

  @override
  String get unsyncedLyrics => 'Lời chưa đồng bộ';

  @override
  String get wordSyncUpper => 'ĐỒNG BỘ THEO TỪ';

  @override
  String get lineSyncUpper => 'ĐỒNG BỘ THEO DÒNG';

  @override
  String get adjustLyricsSync => 'Chỉnh đồng bộ lời bài hát';

  @override
  String get startsSoon => 'Sắp bắt đầu';

  @override
  String get musicContinues => 'Nhạc vẫn tiếp tục';

  @override
  String get decreaseLyricsOffset => 'Giảm lệch 0,1 giây';

  @override
  String lyricsOffset(String value) {
    return 'Lệch: $value giây';
  }

  @override
  String get increaseLyricsOffset => 'Tăng lệch 0,1 giây';

  @override
  String get hideSetting => 'Ẩn cài đặt';

  @override
  String get lyricsOffsetSaveFailed => 'Không lưu được độ lệch lời bài hát.';

  @override
  String get audioForbidden =>
      'Máy chủ âm thanh từ chối truy cập (HTTP 403). Đã tìm thấy bản nhạc nhưng luồng của nó không khả dụng. VPN không đảm bảo truy cập âm thanh.';

  @override
  String get fullVersionUnavailable =>
      'Không tìm thấy bản đầy đủ trong các nguồn khả dụng. Kiểm tra kết nối hoặc thử lại sau.';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source không phát được bản nhạc này. Kiểm tra kết nối hoặc thử lại sau.';
  }

  @override
  String get recentQueriesUpper => 'TÌM KIẾM GẦN ĐÂY';

  @override
  String get clearHistory => 'Xóa';

  @override
  String get waveFromArtist => 'Làn sóng nghệ sĩ';

  @override
  String get popularTracksUpper => 'BẢN NHẠC PHỔ BIẾN';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bản nhạc',
      zero: 'chưa có bản nhạc',
    );
    return '$_temp0';
  }

  @override
  String get volume => 'Âm lượng';

  @override
  String get systemVolume => 'Hệ thống';

  @override
  String get appVolume => 'Mức Hook';

  @override
  String get mute => 'Tắt tiếng';

  @override
  String get unmute => 'Bật âm thanh';

  @override
  String get volumeMixer => 'Âm thanh và âm lượng';

  @override
  String get systemVolumeCaption =>
      'Mức âm lượng đầu ra của Windows, dùng chung cho mọi ứng dụng';

  @override
  String get appVolumeCaption => 'Chỉ trong Hook, cộng thêm trên mức hệ thống';

  @override
  String get volumeKeysHint => 'Ctrl + ↑ ↓ âm lượng · M tắt tiếng';

  @override
  String get volumeUnavailable => 'Thiết bị này không hỗ trợ âm lượng hệ thống';

  @override
  String get cacheFolder => 'Thư mục lưu trữ';

  @override
  String get copyPath => 'Sao chép đường dẫn';

  @override
  String get pathCopied => 'Đã sao chép đường dẫn vào clipboard';

  @override
  String get previousTrack => 'Bài trước';

  @override
  String get repeatPlayback => 'Lặp lại';

  @override
  String get openPlayer => 'Mở trình phát';

  @override
  String get statsWeek => '7 ngày qua';

  @override
  String get keyboardShortcuts => 'Phím tắt';

  @override
  String get shortcutsCaption => 'Hoạt động mọi nơi trừ ô nhập văn bản.';

  @override
  String get shortcutsSeek => 'Tua 10 giây';

  @override
  String get playPauseShortcut => 'Phát / tạm dừng';

  @override
  String get ageRestrictedTrack =>
      'Bản nhạc này bị giới hạn độ tuổi (18+). Máy chủ cần cookie từ một tài khoản YouTube đã đăng nhập.';

  @override
  String get haptics => 'Phản hồi rung';

  @override
  String get hapticsDescription =>
      'Rung nhẹ khi một cú chạm thay đổi điều gì đó. Chỉ trên Android và iOS.';

  @override
  String get reduceMotion => 'Giảm chuyển động';

  @override
  String get reduceMotionDescription =>
      'Bỏ qua hiệu ứng chuyển cảnh và nền động. Hữu ích trên máy chậm hoặc khi nhạy cảm với chuyển động.';

  @override
  String get backgroundPrefetch => 'Tải trước bản nhạc kế tiếp';

  @override
  String get backgroundPrefetchDescription =>
      'Chuẩn bị sẵn các bản nhạc kế tiếp để chuyển bài tức thì. Dùng thêm một chút dữ liệu.';

  @override
  String get playbackSettings => 'Phát lại';

  @override
  String get cookieStatus => 'Cookie YouTube';

  @override
  String get cookieStatusReady => 'Đã đăng nhập — phát được bản nhạc 18+';

  @override
  String get cookieStatusVisitor => 'Chưa đăng nhập — bản nhạc 18+ bị từ chối';

  @override
  String get cookieStatusUnknown => 'Chưa kiểm tra';

  @override
  String get cookieStatusCheck => 'Kiểm tra';

  @override
  String get cookieStatusChecking => 'Đang kiểm tra…';

  @override
  String get cookieStatusUpload => 'Tải cookie lên';

  @override
  String get cookieStatusUploading => 'Đang tải lên…';

  @override
  String cookieUploadAccepted(int cookies) {
    return 'Đã tải lên $cookies cookie — bản nhạc 18+ đã bật';
  }

  @override
  String cookieUploadRejected(String reason) {
    return 'Máy chủ từ chối tệp: $reason';
  }

  @override
  String get cookieUploadApology =>
      'Tệp này không phải phiên đã đăng nhập, nên bản nhạc 18+ vẫn không phát được. Đăng nhập YouTube bằng tài khoản đã xác minh tuổi rồi xuất lại.';

  @override
  String get cookieStatusUnreachable => 'Máy chủ không phản hồi';

  @override
  String get errorAccountSetup =>
      'Accounts are not enabled on the server. In Supabase, turn off Authentication → Sign In / Providers → Email → «Confirm email», then try again.';

  @override
  String get errorRateLimited =>
      'Too many attempts. Wait a minute and try again.';
}
