// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => '설정';

  @override
  String get settingsCaption => '변경 사항은 이 기기에 저장됩니다.';

  @override
  String get playerSettings => '플레이어';

  @override
  String get lyricsAutoHide => '가사 읽는 동안 컨트롤 숨기기';

  @override
  String get lyricsAutoHideDescription =>
      '10초 동안 아무 조작이 없으면 플레이어 패널이 화면 밖으로 밀려납니다. 복원 버튼으로 다시 불러올 수 있습니다.';

  @override
  String get showPlayerControls => '플레이어 컨트롤 표시';

  @override
  String get equalizer => '이퀄라이저';

  @override
  String get equalizerEnabled => '사운드 처리';

  @override
  String get equalizerPresets => '사운드 프로필';

  @override
  String get equalizerFlat => '오리지널';

  @override
  String get equalizerBass => '깊은 베이스';

  @override
  String get equalizerVocal => '보컬';

  @override
  String get equalizerRock => '록';

  @override
  String get equalizerElectronic => '일렉트로닉';

  @override
  String get equalizerSoft => '부드럽게';

  @override
  String get equalizerCustom => '사용자 지정';

  @override
  String get equalizerBands => '주파수 대역';

  @override
  String get equalizerBassBoost => '베이스 부스트';

  @override
  String get equalizerBassUnsupported =>
      '추가 베이스 부스트는 지원되지 않습니다. 저주파 대역을 사용하세요.';

  @override
  String get equalizerPreamp => '프리앰프';

  @override
  String get equalizerHeadroom => '자동 헤드룸';

  @override
  String get equalizerHeadroomDescription =>
      '주파수를 올릴 때 출력 레벨을 낮춰 피크를 위한 여유를 남깁니다. 리미터는 아닙니다.';

  @override
  String get equalizerWaiting => '이퀄라이저를 오디오 세션에 연결하려면 트랙을 재생하세요.';

  @override
  String get equalizerUnsupported => '사운드 처리는 현재 Android에서만 사용할 수 있습니다.';

  @override
  String get equalizerFailed => '이 기기에서 오디오 효과를 켜지 못했습니다. 음악은 효과 없이도 재생됩니다.';

  @override
  String get equalizerRetry => '효과 다시 연결';

  @override
  String get equalizerLive => '변경 사항이 즉시 적용되고 이 기기에 저장됩니다.';

  @override
  String get youtubeAccount => 'YouTube 및 MicroG';

  @override
  String get youtubeAccountReadOnly =>
      '재생목록에 대한 읽기 전용 접근. 로그인해도 오디오 이용이 보장되지 않습니다.';

  @override
  String get youtubeAccountCompatibility => '호환성과 개인정보';

  @override
  String get youtubeAccountSubtitle => '계정 연결 및 재생목록 가져오기';

  @override
  String get youtubeAccountPrivacy =>
      'Hook은 YouTube에 읽기 전용 접근만 요청합니다. 비밀번호는 Google 시스템 대화상자에만 입력하세요. Hook에는 절대 입력하지 않습니다. 토큰은 Hook 서버로 전송되지 않고 메모리에만 유지됩니다. 앱을 다시 시작한 후 재연결하세요.';

  @override
  String get youtubeAccountPlaybackNotice =>
      '로그인은 계정 데이터 접근 권한을 줄 뿐 오디오 스트림 접근은 아닙니다. HTTP 403 해결을 보장하지 않습니다. 가져오기는 YouTube 녹음을 다른 소스로 대체하지 않고 그대로 유지합니다.';

  @override
  String get youtubeAccountConnect => '계정 연결';

  @override
  String get youtubeAccountDisconnect => 'Hook에서 연결 해제';

  @override
  String get youtubeAccountDisconnected => '연결된 계정 없음';

  @override
  String get youtubeAccountDisconnectNotice =>
      '이 계정을 Hook에서만 연결 해제할까요? 저장된 재생목록은 유지됩니다. 휴대전화의 Google 및 MicroG 계정은 로그아웃되지 않습니다.';

  @override
  String get youtubeAccountSystem => '시스템 Google API';

  @override
  String get youtubeAccountServicesMissing =>
      '호환되는 시스템 Google API가 없습니다. 별도로 설치한 ReVanced GmsCore는 Hook 로그인의 대체가 되지 않습니다.';

  @override
  String get youtubeAccountMicrogNotice =>
      '별도 설치된 ReVanced GmsCore가 감지되었습니다. Hook은 ReVanced 계정이나 토큰을 사용하지 않습니다. 시스템 MicroG가 호환되는 Google API를 제공할 수 있지만, 이 로그인 방식과의 호환은 보장되지 않습니다.';

  @override
  String get youtubeAccountRevancedFound => 'YouTube Music ReVanced가 설치되어 있음';

  @override
  String get youtubeAccountPlaylists => '계정 재생목록';

  @override
  String get youtubeAccountNoPlaylists =>
      '접근 가능한 재생목록이 없습니다. YouTube Music의 일부 자동 모음집은 YouTube Data API로는 이용할 수 없습니다.';

  @override
  String get youtubeAccountMore => '더 불러오기';

  @override
  String get youtubeAccountPreview => '가져오기 준비';

  @override
  String youtubeAccountProgress(int count) {
    return '가져온 트랙: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return '건너뛴 이용 불가 항목: $count개. 다른 트랙으로 대체되지 않습니다.';
  }

  @override
  String get youtubeAccountSetup => '로그인 설정';

  @override
  String get youtubeAccountSetupBody =>
      '개발자는 Google Cloud에서 YouTube Data API v3를 사용 설정하고, com.hook.music 및 설치된 빌드의 서명 SHA-1용 Android OAuth 클라이언트를 등록하며, 동의 화면을 구성해야 합니다. 테스트 모드에서 허용된 사용자를 추가하세요. docs/YOUTUBE_ACCOUNT_SETUP.md 참고. 비밀번호, 클라이언트 시크릿, 다른 앱의 토큰은 절대 추가하지 마세요.';

  @override
  String get youtubeAccountConfigError =>
      '이 빌드에는 로그인이 구성되지 않았습니다. Google Cloud에서 Android OAuth 클라이언트, 패키지 이름, SHA-1, 허용된 테스트 사용자를 확인하세요.';

  @override
  String get youtubeAccountPermissionError => 'YouTube 데이터 읽기 권한이 부여되지 않았습니다.';

  @override
  String get youtubeAccountExpired => '세션이 만료되었습니다. 계정을 다시 연결하세요.';

  @override
  String get youtubeAccountNoChannel => '선택한 계정에 접근 가능한 YouTube 채널이 없습니다.';

  @override
  String get youtubeAccountQuota => 'YouTube API 할당량을 초과했습니다. 나중에 다시 시도하세요.';

  @override
  String get youtubeAccountFailed =>
      'YouTube 데이터를 가져오지 못했습니다. 연결을 확인하고 다시 시도하세요.';

  @override
  String get youtubeAccountUnsupported =>
      '계정 연결에는 호환되는 시스템 Google API를 갖춘 Android가 필요합니다.';

  @override
  String get importedFromYouTube => 'YouTube 계정에서 가져옴';

  @override
  String get translateLyrics => '가사 번역';

  @override
  String get hideTranslation => '번역 숨기기';

  @override
  String get cancelTranslation => '번역 취소';

  @override
  String get translationLoading => '번역을 준비하는 중…';

  @override
  String get translationAttribution => 'Google 번역에 의해 자동 번역됨';

  @override
  String get translationNotice =>
      '번역이 노래의 의미를 정확히 담지 못할 수 있습니다. 단어 하이라이트는 원문에만 적용됩니다.';

  @override
  String get translationModelTitle => '언어 모델을 다운로드할까요?';

  @override
  String get translationModelBody =>
      '번역은 휴대전화에서 실행됩니다. 가사는 서버로 전송되지 않습니다. 첫 번째 번역에는 Google ML Kit 모델이 필요하며 수십 메가바이트를 차지합니다. 다운로드는 현재 연결(모바일 데이터 포함)을 사용합니다. 취소하면 결과가 숨겨지지만 이미 시작된 모델 다운로드는 백그라운드에서 완료될 수 있습니다.';

  @override
  String get translationDownload => '다운로드 후 번역';

  @override
  String get translationUnavailable => '번역에 실패했습니다. 모델 다운로드 접근을 확인하고 다시 시도하세요.';

  @override
  String get translationUnsupported => '기기 내 번역은 현재 Android에서만 사용할 수 있습니다.';

  @override
  String get translationUnknownLanguage => '이 노래의 지원 언어를 식별하지 못했습니다.';

  @override
  String get translationSameLanguage => '가사가 이미 선택한 언어입니다.';

  @override
  String get translationTooLarge => '이 가사는 기기 내 번역으로는 너무 깁니다.';

  @override
  String get translationRussian => '러시아어로';

  @override
  String get translationEnglish => '영어로';

  @override
  String get translationTarget => '번역 언어';

  @override
  String get retry => '다시 시도';

  @override
  String get home => '홈';

  @override
  String get search => '검색';

  @override
  String get library => '라이브러리';

  @override
  String get youtubeUnavailableTitle => 'YouTube를 현재 이용할 수 없음';

  @override
  String get youtubeUnavailableBody =>
      '오디오 스트림을 가져올 수 없습니다. 네트워크와 VPN 경로를 확인하세요. VPN을 사용 중이어도 YouTube가 요청을 거부할 수 있습니다.';

  @override
  String get checkAgain => '다시 확인';

  @override
  String get dismiss => '닫기';

  @override
  String get goodNight => '좋은 밤 되세요';

  @override
  String get goodMorning => '좋은 아침이에요';

  @override
  String get goodAfternoon => '좋은 오후예요';

  @override
  String get goodEvening => '좋은 저녁이에요';

  @override
  String get themeSettings => '모양 설정';

  @override
  String get onYourAir => '당신의 주파수 위에서';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '최근 시그널 $count개',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => '당신의 컬렉션이 기다리고 있어요';

  @override
  String get saved => '저장됨';

  @override
  String get collectionEmptyDetail => '다시 듣고 싶은 음악이 여기 남습니다';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '트랙 $count개',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => '트랙, 아티스트 또는 가사';

  @override
  String get searchUpper => '검색';

  @override
  String get findFirstTrack => '첫 번째 트랙을 찾아보세요';

  @override
  String continuationAfter(String artist) {
    return '$artist 이후의 음악 더 보기';
  }

  @override
  String get chooseTrackWaveDetail => '트랙을 고르면 그 분위기에 맞춰 웨이브를 만들어 드릴게요.';

  @override
  String get continueWaveLabel => '계속 / 01';

  @override
  String get yourWaveLabel => '당신의 웨이브 / 01';

  @override
  String get continueWave => '웨이브 이어서';

  @override
  String get chooseTrack => '트랙 고르기';

  @override
  String get firstTrace => '여기에 첫 번째 흔적을 남겨보세요';

  @override
  String get favoriteWaveHint => '좋아요를 저장하면 웨이브가 더 정확해집니다.';

  @override
  String get openSearch => '검색 열기';

  @override
  String get findYourMusic => '당신의 사운드를 찾아보세요.';

  @override
  String get importMusic => '음악 가져오기';

  @override
  String get rememberedLyricsHint => '기억나는 그 가사…';

  @override
  String get trackArtistHint => '트랙 또는 아티스트 — 어떤 언어든';

  @override
  String get clear => '지우기';

  @override
  String get music => '음악';

  @override
  String get byLyrics => '가사로';

  @override
  String get allSources => '모든 소스';

  @override
  String get lyricsSearchCaption => '제목이 아니라 노래 속 한 구절을 검색하세요.';

  @override
  String get searchingLyrics => '익숙한 가사를 찾는 중…';

  @override
  String get searchingSources => '음악 소스를 검색하는 중…';

  @override
  String get connectionFailed => '연결하지 못했습니다';

  @override
  String get noMatches => '아직 일치 항목이 없습니다';

  @override
  String get lyricsUnavailable => '가사 검색을 현재 이용할 수 없습니다. 나중에 시도하거나 제목으로 검색하세요.';

  @override
  String get searchUnavailable => '검색에 실패했습니다. 연결을 확인하고 다시 시도하세요.';

  @override
  String get lyricsNoMatches => '다른 가사 줄을 시도해 보세요. 모든 가사가 색인된 것은 아닙니다.';

  @override
  String get trackNoMatches =>
      '아티스트를 추가하거나 다른 소스를 선택하세요. 일부 서비스는 사용자 네트워크에서 이용하지 못할 수 있습니다.';

  @override
  String get repeatSearch => '다시 검색';

  @override
  String get lyricMatchesUpper => '가사 일치';

  @override
  String get tracksUpper => '트랙';

  @override
  String playTrack(String title, String artist) {
    return '$title, $artist 재생';
  }

  @override
  String get familiarLinesUpper => '익숙한 가사';

  @override
  String get bestMatchUpper => '최고 일치';

  @override
  String get fullVersionOnPlayback => '재생이 시작되면 완전판을 찾아드릴게요.';

  @override
  String get forgotTitle => '제목은 잊었어도\n음악은 기억나잖아요.';

  @override
  String get startAsYouRemember => '이름, 제목 또는 노래 속 한 구절.\n기억나는 것부터 시작하세요.';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => '이름은 들리는 대로 검색하세요';

  @override
  String get rememberOnlyLine => '가사 한 줄만 기억나요';

  @override
  String get findSongByWords => '가사의 말로 노래 찾기';

  @override
  String get yourArtistsUpper => '당신의 아티스트';

  @override
  String get language => '언어';

  @override
  String get languageCaption => '인터페이스가 선택을 즉시 따릅니다';

  @override
  String get systemLanguage => '시스템';

  @override
  String get russian => '러시아어';

  @override
  String get english => '영어';

  @override
  String get themesAndShaders => '테마와 효과';

  @override
  String get themesSubtitle => '모양, 언어 및 배경 움직임';

  @override
  String get invalidThemeJson => '테마를 읽지 못했습니다. JSON 형식과 필드 값을 확인하세요.';

  @override
  String get exportJson => 'JSON 내보내기';

  @override
  String get importJson => 'JSON 가져오기';

  @override
  String get readyThemes => '테마 프리셋';

  @override
  String get gpuShaders => '배경 효과';

  @override
  String get meshGradient => '트랙 색상 기반 부드러운 GPU 그라디언트';

  @override
  String get vinylNoise => '아날로그 바이닐 입자(노이즈)';

  @override
  String get glassBlur => '유리 블러(Backdrop Blur)';

  @override
  String get cornerRadius => '인터페이스 모서리 반경';

  @override
  String get importThemeTitle => 'JSON에서 테마 가져오기';

  @override
  String get pasteThemeJson => '테마의 JSON 설정을 붙여넣으세요:';

  @override
  String get cancel => '취소';

  @override
  String get apply => '적용';

  @override
  String get themeApplied => '테마가 성공적으로 적용되었습니다!';

  @override
  String get exportThemeTitle => '테마 내보내기(JSON)';

  @override
  String get close => '닫기';

  @override
  String get copyJson => 'JSON 복사';

  @override
  String get jsonCopied => '테마 JSON이 클립보드에 복사되었습니다!';

  @override
  String get libraryUpper => '라이브러리';

  @override
  String get localCollection => '로컬 컬렉션과 재생목록';

  @override
  String get importShort => '가져오기';

  @override
  String get favorites => '좋아요';

  @override
  String get playlists => '재생목록';

  @override
  String get history => '기록';

  @override
  String get offline => '오프라인';

  @override
  String get favoritesEmpty => '좋아요가 비어 있습니다.\n트랙의 하트를 탭하면 여기에 추가됩니다.';

  @override
  String get historyEmpty => '청취 기록이 비어 있습니다.\n검색에서 음악을 재생하면 여기에 나타납니다.';

  @override
  String get noPlaylists => '아직 재생목록이 없습니다';

  @override
  String get importPlaylistHint => 'Spotify 재생목록을 가져오거나 트랙 목록을 붙여넣으세요.';

  @override
  String get importMusicAction => '음악 가져오기';

  @override
  String get playPlaylist => '재생목록 재생';

  @override
  String playlistStarted(String name, int count) {
    return '「$name」 재생 중($count개 트랙)';
  }

  @override
  String get deletePlaylist => '재생목록 삭제';

  @override
  String get playAll => '전체 재생';

  @override
  String get shuffle => '셔플';

  @override
  String get localAudioCache => '로컬 오디오 캐시';

  @override
  String get cacheDescription => '재생한 트랙은 로컬에 저장되어 인터넷 없이 바로 다시 들을 수 있습니다.';

  @override
  String deviceUsage(String size) {
    return '이 기기에서: $size';
  }

  @override
  String get clearCache => '캐시 전체 지우기';

  @override
  String savedTracksUpper(int count) {
    return '저장한 트랙($count개):';
  }

  @override
  String get cacheFeaturesUpper => '캐시 기능:';

  @override
  String get offlineFirst => '완전한 오프라인 우선';

  @override
  String get offlineFirstDescription => '다시 들을 때 오디오가 기기 파일 시스템에서 바로 로드됩니다.';

  @override
  String get maximumBitrate => '최대 비트레이트';

  @override
  String get maximumBitrateDescription =>
      '160–256 kbps의 깨끗한 Opus/M4A 스트림은 트랜스코딩 없이 저장됩니다.';

  @override
  String get trafficAndBattery => '데이터와 배터리 절약';

  @override
  String get trafficAndBatteryDescription =>
      '반복되는 네트워크 요청을 피하면 휴대전화가 더 오래 갑니다.';

  @override
  String get cacheEmpty => '캐시가 비어 있습니다';

  @override
  String get cachedTracksAppear => '다운로드한 트랙이 여기 자동으로 표시됩니다';

  @override
  String get removeFromCache => '캐시에서 제거';

  @override
  String get removeCachedTrackTitle => '트랙을 캐시에서 제거할까요?';

  @override
  String removeCachedTrackBody(String title) {
    return '「$title」이(가) 이 기기에서 제거됩니다.';
  }

  @override
  String get delete => '삭제';

  @override
  String get trackRemovedFromCache => '트랙을 캐시에서 제거했습니다';

  @override
  String get clearCacheTitle => '캐시를 지울까요?';

  @override
  String get clearCacheBody => '저장된 모든 오디오 파일이 이 기기에서 제거됩니다. 좋아요와 기록은 그대로입니다.';

  @override
  String get cacheCleared => '로컬 캐시를 지웠습니다';

  @override
  String get back => '뒤로';

  @override
  String get playlistActions => '재생목록 작업';

  @override
  String get playlistUpper => '재생목록';

  @override
  String get playlistEmpty => '이 재생목록에는 아직 트랙이 없습니다';

  @override
  String get pasteTrackList => '트랙 목록 붙여넣기';

  @override
  String get pasteImportLink => '가져올 링크 붙여넣기';

  @override
  String get tracksNotFound => '해당 링크에서 트랙을 찾지 못했습니다.';

  @override
  String get importError => '가져오기에 실패했습니다. 링크와 인터넷 연결을 확인하세요.';

  @override
  String importedPlaylistStarted(int count) {
    return '가져온 재생목록 재생 중($count개 트랙)';
  }

  @override
  String importedPlaylistName(String platform) {
    return '가져오기($platform)';
  }

  @override
  String playlistSaved(String name) {
    return '재생목록 「$name」이(가) 라이브러리에 저장되었습니다!';
  }

  @override
  String get spotifyImportSubtitle => 'Spotify • 재생목록, 앨범, 트랙';

  @override
  String get artistTrackOrCsv => '아티스트 — 트랙 또는 Exportify CSV';

  @override
  String get pastePlaylistOrTrackLink => '재생목록 또는 트랙 링크 붙여넣기';

  @override
  String get pasteFromClipboard => '클립보드에서 붙여넣기';

  @override
  String get link => '링크';

  @override
  String get trackList => '트랙 목록';

  @override
  String get playlistName => '재생목록 이름';

  @override
  String get startImport => '가져오기 시작';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • 트랙 $count개';
  }

  @override
  String get importedFromSpotify => 'Spotify에서 가져옴';

  @override
  String get importedFromDeezer => 'Deezer에서 가져옴';

  @override
  String get importIntro =>
      '재생목록을 함께 가져오세요. Spotify 링크, 트랙 목록 또는 Exportify 파일을 사용하세요.';

  @override
  String get importTextTab => '텍스트';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => '파일 선택';

  @override
  String get importFileHint =>
      'Exportify에서 내보낸 CSV 또는 TXT 트랙 목록을 선택하세요. UTF-8, 최대 10 MB 및 10,000개 트랙.';

  @override
  String get importFileAndroidOnly =>
      '파일 선택은 Android에서 사용할 수 있습니다. 여기서는 CSV 또는 트랙 목록의 내용을 붙여넣을 수 있습니다.';

  @override
  String get importTextHint => '한 줄에 아티스트 — 트랙 하나. 헤더가 포함된 전체 CSV를 붙여넣어도 됩니다.';

  @override
  String get importPreview => '트랙 미리보기';

  @override
  String get importedFromCsv => 'CSV에서 가져옴';

  @override
  String get importedFromText => '트랙 목록에서 가져옴';

  @override
  String importMoreTracks(int count) {
    return '그리고 $count개 더';
  }

  @override
  String get importMetadataHint =>
      '재생목록은 이 기기에 저장됩니다. 오디오는 트랙을 재생할 때 찾습니다. 가져오기만으로는 노래를 다운로드하지 않습니다.';

  @override
  String get importAnother => '다른 것 가져오기';

  @override
  String get importReading => '재생목록을 읽는 중…';

  @override
  String get importSaving => '라이브러리에 저장하는 중…';

  @override
  String get importNameRequired => '재생목록 이름을 입력하세요.';

  @override
  String get importNameExists =>
      '같은 이름의 재생목록이 이미 있습니다. 둘 다 유지하려면 다른 이름을 선택하세요.';

  @override
  String get importSaveFailed => '재생목록을 저장하지 못했습니다. 미리보기는 그대로 있습니다. 다시 시도하세요.';

  @override
  String get importFileTooLarge => '이 파일은 10 MB를 초과합니다. 재생목록을 더 작은 내보내기로 나누세요.';

  @override
  String get importFileUnsupported => '.csv 또는 .txt 파일을 선택하세요.';

  @override
  String get importFileEncoding =>
      '텍스트 인코딩을 읽지 못했습니다. 파일을 UTF-8로 저장하고 다시 시도하세요.';

  @override
  String get importCsvInvalid =>
      'CSV가 불완전하거나 손상되었습니다. 열이나 따옴표를 바꾸지 말고 다시 내보내세요.';

  @override
  String get importCsvMissingColumns =>
      'CSV에 Track Name과 Artist Name(s) 또는 Title과 Artist 열이 필요합니다. 원본 Exportify 내보내기를 사용하세요.';

  @override
  String get importFileEmpty =>
      '트랙을 찾지 못했습니다. 내용이 있는 내보내기를 선택하거나 아티스트 — 트랙 목록을 붙여넣으세요.';

  @override
  String get importTooManyTracks =>
      '한 번에 최대 10,000개 트랙까지 가져올 수 있습니다. 이 재생목록을 나누세요. 아직 아무것도 저장되지 않았습니다.';

  @override
  String get importFileReadFailed =>
      '이 파일을 열지 못했습니다. 기기에서 이용 가능한지 확인하고 다시 선택하세요.';

  @override
  String get importSpotifyBlocked =>
      'Spotify가 이 재생목록을 사용자 지역에서 공유하지 않았습니다. Exportify로 내보낸 뒤 CSV 파일을 선택하세요.';

  @override
  String get listen => '재생';

  @override
  String get addToPlaylists => '재생목록에 추가';

  @override
  String trackSemantics(String title, String artist) {
    return '트랙 $title, $artist';
  }

  @override
  String get trackActions => '트랙 작업';

  @override
  String get updatesTitle => '업데이트';

  @override
  String get accountTitle => '계정';

  @override
  String get waveLoading => '비슷한 곡을 찾고 있어요…';

  @override
  String get sleepTimer => '수면 타이머';

  @override
  String sleepMinutes(String value) {
    return '$value';
  }

  @override
  String get sleepUntilTrackEnd => '트랙 끝까지';

  @override
  String get sleepCancel => '끄기';

  @override
  String get dislike => '관심 없음';

  @override
  String get dislikeRemove => '숨김에서 제거';

  @override
  String dislikeSaved(String artist) {
    return '숨김: $artist';
  }

  @override
  String get exportPlaylist => 'CSV 내보내기';

  @override
  String get playlistExported => '재생목록 내보냄';

  @override
  String get exportFailed => '내보내기 실패';

  @override
  String get downloadAll => '모두 다운로드';

  @override
  String get statsTitle => '통계';

  @override
  String get statsPlays => '재생 횟수';

  @override
  String get statsFavorites => '즐겨찾기';

  @override
  String get statsPlaylists => '재생목록';

  @override
  String get statsTopArtists => '상위 아티스트';

  @override
  String get statsTopTracks => '상위 트랙';

  @override
  String resumeTitle(String device) {
    return '$device에서 이어 듣기';
  }

  @override
  String get alwaysOnTop => '창 항상 위';

  @override
  String get randomPick => '랜덤 추천';

  @override
  String get accountCaption => '기기 간에 라이브러리 동기화';

  @override
  String get nickname => '닉네임';

  @override
  String get nicknameHint => '3–20자: 영문, 숫자, . _ -';

  @override
  String get password => '비밀번호';

  @override
  String get passwordMinHint => '6자 이상';

  @override
  String get signIn => '로그인';

  @override
  String get signUp => '계정 만들기';

  @override
  String get haveAccountToggle => '이미 계정이 있나요? 로그인';

  @override
  String get noAccountToggle => '아직 계정이 없나요? 만들기';

  @override
  String get signOut => '로그아웃';

  @override
  String get syncNow => '지금 동기화';

  @override
  String get syncing => '동기화 중…';

  @override
  String syncedAt(String time) {
    return '동기화됨: $time';
  }

  @override
  String get neverSynced => '아직 동기화되지 않았습니다';

  @override
  String get errorNicknameTaken => '이 닉네임은 이미 사용 중입니다';

  @override
  String get errorNicknameInvalid => '닉네임: 3–20자, 영문/숫자/._-';

  @override
  String get errorInvalidCredentials => '닉네임 또는 비밀번호가 틀렸습니다';

  @override
  String get errorWeakPassword => '비밀번호가 너무 짧습니다';

  @override
  String get errorNetwork => '연결 없음';

  @override
  String get errorServer => '서버 오류, 나중에 다시 시도하세요';

  @override
  String currentVersion(String version) {
    return '버전 $version';
  }

  @override
  String get checkForUpdates => '업데이트 확인';

  @override
  String get checkingForUpdates => '확인 중…';

  @override
  String get upToDate => '최신 버전을 사용 중입니다';

  @override
  String updateAvailable(String version) {
    return '버전 $version 사용 가능';
  }

  @override
  String get downloadingUpdate => '업데이트 다운로드 중…';

  @override
  String get installUpdate => '설치';

  @override
  String get updateCheckFailed => '업데이트를 확인하지 못했습니다. 인터넷을 확인하세요.';

  @override
  String get installPermissionNeeded => 'Hook이 앱을 설치하도록 허용한 뒤 다시 설치를 누르세요.';

  @override
  String updateSize(String size) {
    return '$size MB';
  }

  @override
  String get download => '다운로드';

  @override
  String get downloading => '다운로드 중…';

  @override
  String get downloaded => '다운로드됨';

  @override
  String get downloadFailed => '다운로드 실패';

  @override
  String get removeDownload => '다운로드 삭제';

  @override
  String get downloadSavedOffline => '오프라인 저장됨';

  @override
  String get startWaveFromTrack => '이 트랙에서 웨이브 시작';

  @override
  String get addToQueue => '대기열에 추가';

  @override
  String addedToQueue(String title) {
    return '대기열에 추가됨: $title';
  }

  @override
  String get removeFavorite => '좋아요에서 제거';

  @override
  String get addFavorite => '좋아요에 추가';

  @override
  String get addToPlaylist => '재생목록에 추가';

  @override
  String get goToArtist => '아티스트로 이동';

  @override
  String get myPlaylist => '내 재생목록';

  @override
  String get newPlaylist => '새 재생목록';

  @override
  String get name => '이름';

  @override
  String get create => '만들기';

  @override
  String get loading => '불러오는 중…';

  @override
  String get pause => '일시정지';

  @override
  String get play => '재생';

  @override
  String get next => '다음';

  @override
  String get speedAndPitch => '속도와 음높이';

  @override
  String speedValue(String value) {
    return '속도: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return '음높이: ${value}x';
  }

  @override
  String get reset => '초기화';

  @override
  String get moreActions => '더 많은 작업';

  @override
  String get playbackQueue => '재생 대기열';

  @override
  String get queueEmpty => '대기열이 비어 있습니다';

  @override
  String get selectingSource => '소스 선택 중';

  @override
  String get collapsePlayer => '플레이어 접기';

  @override
  String get nowPlayingUpper => '지금 재생 중';

  @override
  String get queue => '대기열';

  @override
  String get startWave => '웨이브 시작';

  @override
  String get cover => '아트워크';

  @override
  String get karaokeLyrics => '노래방 가사';

  @override
  String get findMusicStart => '음악을 찾아 재생을 시작하세요';

  @override
  String get playbackNotStarted => '재생이 아직 시작되지 않았습니다';

  @override
  String get openSearchFirstTrack => '검색을 열어 첫 트랙을 찾아보세요';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => '기기 내';

  @override
  String get sourceCatalog => '카탈로그';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => '서버';

  @override
  String get serverResolver => '리졸버 서버';

  @override
  String get serverResolverCaption =>
      '전체 오디오 스트림을 해석하는 선택적 자체 호스팅 서버. 앱이 검색어나 트랙 ID를 보내면 서버가 재생 URL을 돌려줍니다. 계약과 참조 구현은 docs/REMOTE_RESOLVER.md에 있습니다.';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => '구성되지 않음';

  @override
  String get serverSave => '저장';

  @override
  String get serverDisable => '비활성화';

  @override
  String get onboardingWelcomeTitle => 'Hook에 오신 것을 환영합니다';

  @override
  String get onboardingWelcomeCaption =>
      '음악, 가사, 그리고 당신만의 비주얼 스타일. 언어를 선택해 시작하세요. 설정에서 언제든 바꿀 수 있습니다.';

  @override
  String get onboardingSkip => '건너뛰기';

  @override
  String get onboardingNext => '계속';

  @override
  String get onboardingStart => '듣기 시작';

  @override
  String get onboardingMicrogTitle => 'MicroG와 Google 계정';

  @override
  String get onboardingMicrogBody =>
      'MicroG는 Google 서비스 없이 출하되는 커스텀 Android 롬에 그 서비스들을 다시 만들어 줍니다. Hook은 이를 선택 기능 하나에만 사용합니다. 재생목록을 가져오려고 YouTube 계정을 연결하는 것입니다. 음악 재생에는 MicroG나 Google 서비스가 전혀 필요하지 않습니다.';

  @override
  String get onboardingMicrogNote => '재생은 MicroG에 의존하지 않습니다. 계정 연결은 선택 사항입니다.';

  @override
  String get onboardingMicrogDownload => 'MicroG 다운로드';

  @override
  String get onboardingMicrogStatusChecking => 'Google 서비스를 확인하는 중…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return '이 기기에 Google 서비스가 있습니다($version). 계정 가져오기가 바로 작동합니다.';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'ReVanced GmsCore 감지($version). 공식 Google 로그인 SDK와 호환되지 않아 계정 연결이 작동하지 않을 수 있습니다. 재생에는 영향이 없습니다.';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'Google 서비스를 찾지 못했습니다. YouTube 계정에서 재생목록을 가져오려면 먼저 MicroG를 설치하세요. 아니면 이 단계를 건너뛰고 계정 없이 Hook을 사용하세요.';

  @override
  String lyricsView(String mode) {
    return '가사 보기 · $mode';
  }

  @override
  String get lyricsReadingRhythm => '당신의 읽기 리듬';

  @override
  String get lyricsModeSubtitle => '노래에 더 가까이 가는 세 가지 방법.';

  @override
  String get lyricsModeLines => '행';

  @override
  String get lyricsModeKaraoke => '노래방';

  @override
  String get lyricsModeFocus => '포커스';

  @override
  String get lyricsModeLinesDescription => '현재 행이 강조된 차분한 가사';

  @override
  String get lyricsModeKaraokeDescription => '단어가 보컬과 함께 부드럽게 빛납니다';

  @override
  String get lyricsModeFocusDescription => '커다란 한 줄. 그게 전부';

  @override
  String get lyricsModeSaveFailed => '가사 보기를 저장하지 못했습니다.';

  @override
  String get lyricsModeFootnote =>
      '선택한 항목은 이후 곡에도 저장됩니다. 노래방 모드의 정확도는 소스 데이터에 달렸습니다. 단어별 타이밍이 없으면 하이라이트는 근사치이고, 타임스탬프가 없으면 가사는 멈춰 있습니다.';

  @override
  String get lyricsNotFound => '가사를 찾지 못했습니다';

  @override
  String get karaokeUnavailable => '이 트랙에는 노래방 가사가 없습니다';

  @override
  String get unsyncedLyrics => '동기화되지 않은 가사';

  @override
  String get wordSyncUpper => '단어별 싱크';

  @override
  String get lineSyncUpper => '행별 싱크';

  @override
  String get adjustLyricsSync => '가사 동기화 조정';

  @override
  String get startsSoon => '곧 시작됩니다';

  @override
  String get musicContinues => '음악은 계속됩니다';

  @override
  String get decreaseLyricsOffset => '오프셋 0.1초 줄이기';

  @override
  String lyricsOffset(String value) {
    return '오프셋: $value초';
  }

  @override
  String get increaseLyricsOffset => '오프셋 0.1초 늘리기';

  @override
  String get hideSetting => '설정 숨기기';

  @override
  String get lyricsOffsetSaveFailed => '가사 오프셋을 저장하지 못했습니다.';

  @override
  String get audioForbidden =>
      '오디오 서버가 접근을 거부했습니다(HTTP 403). 트랙은 찾았지만 스트림을 이용할 수 없습니다. VPN도 오디오 접근을 보장하지 않습니다.';

  @override
  String get fullVersionUnavailable =>
      '이용 가능한 소스에서 완전판을 찾지 못했습니다. 연결을 확인하거나 나중에 다시 시도하세요.';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source에서 이 트랙을 재생하지 못했습니다. 연결을 확인하거나 나중에 다시 시도하세요.';
  }

  @override
  String get recentQueriesUpper => '최근 검색어';

  @override
  String get clearHistory => '지우기';

  @override
  String get waveFromArtist => '아티스트 웨이브';

  @override
  String get popularTracksUpper => '인기 트랙';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 트랙',
      zero: '아직 트랙이 없습니다',
    );
    return '$_temp0';
  }

  @override
  String get volume => '볼륨';

  @override
  String get systemVolume => '시스템';

  @override
  String get appVolume => 'Hook 음량';

  @override
  String get mute => '음소거';

  @override
  String get unmute => '소리 켜기';

  @override
  String get volumeMixer => '소리 및 음량';

  @override
  String get systemVolumeCaption => '모든 앱과 공유되는 Windows 출력 음량';

  @override
  String get appVolumeCaption => 'Hook 내부에서만, 시스템 음량 위에 적용';

  @override
  String get volumeKeysHint => 'Ctrl + ↑ ↓ 음량 · M 음소거';

  @override
  String get volumeUnavailable => '이 기기에서는 시스템 음량을 사용할 수 없습니다';

  @override
  String get cacheFolder => '저장 폴더';

  @override
  String get copyPath => '경로 복사';

  @override
  String get pathCopied => '경로를 클립보드에 복사했습니다';

  @override
  String get previousTrack => '이전 곡';

  @override
  String get repeatPlayback => '반복';

  @override
  String get openPlayer => '플레이어 열기';

  @override
  String get statsWeek => '최근 7일';

  @override
  String get keyboardShortcuts => '키보드 단축키';

  @override
  String get shortcutsCaption => '텍스트 입력란을 제외한 모든 곳에서 동작합니다.';

  @override
  String get shortcutsSeek => '10초 이동';

  @override
  String get playPauseShortcut => '재생 / 일시정지';

  @override
  String get ageRestrictedTrack =>
      '이 트랙은 연령 제한(18+)이 있습니다. 서버에 YouTube에 로그인한 계정의 쿠키가 필요합니다.';

  @override
  String get haptics => '진동 피드백';

  @override
  String get hapticsDescription => '탭으로 무언가 바뀔 때 짧게 진동합니다. Android와 iOS 전용.';

  @override
  String get reduceMotion => '동작 줄이기';

  @override
  String get reduceMotionDescription =>
      '전환 효과와 애니메이션 배경을 건너뜁니다. 느린 기기나 움직임에 민감한 경우 유용합니다.';

  @override
  String get backgroundPrefetch => '다음 트랙 미리 불러오기';

  @override
  String get backgroundPrefetchDescription =>
      '다음 트랙을 미리 준비해 전환이 즉시 시작됩니다. 데이터를 조금 더 사용합니다.';

  @override
  String get playbackSettings => '재생';

  @override
  String get cookieStatus => 'YouTube 쿠키';

  @override
  String get cookieStatusReady => '로그인됨 — 18+ 트랙을 재생할 수 있습니다';

  @override
  String get cookieStatusVisitor => '로그인 안 됨 — 18+ 트랙이 거부됩니다';

  @override
  String get cookieStatusUnknown => '아직 확인하지 않음';

  @override
  String get cookieStatusCheck => '확인';

  @override
  String get cookieStatusChecking => '확인 중…';
}
