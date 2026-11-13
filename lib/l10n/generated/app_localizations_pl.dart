// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'Ustawienia';

  @override
  String get settingsCaption => 'Zmiany są zapisywane na tym urządzeniu.';

  @override
  String get playerSettings => 'Odtwarzacz';

  @override
  String get lyricsAutoHide => 'Ukryj sterowanie podczas czytania tekstu';

  @override
  String get lyricsAutoHideDescription =>
      'Po 10 sekundach bez interakcji panele odtwarzacza zjadą z ekranu. Użyj przycisku przywróć, aby je sprowadzić.';

  @override
  String get showPlayerControls => 'Pokaż sterowanie odtwarzacza';

  @override
  String get equalizer => 'Korektor';

  @override
  String get equalizerEnabled => 'Przetwarzanie dźwięku';

  @override
  String get equalizerPresets => 'Profil dźwięku';

  @override
  String get equalizerFlat => 'Oryginalny';

  @override
  String get equalizerBass => 'Głęboki bas';

  @override
  String get equalizerVocal => 'Wokal';

  @override
  String get equalizerRock => 'Rock';

  @override
  String get equalizerElectronic => 'Elektroniczna';

  @override
  String get equalizerSoft => 'Miękki';

  @override
  String get equalizerCustom => 'Własny';

  @override
  String get equalizerBands => 'Pasma częstotliwości';

  @override
  String get equalizerBassBoost => 'Wzmocnienie basu';

  @override
  String get equalizerBassUnsupported =>
      'Dodatkowe wzmocnienie basu nie jest obsługiwane. Użyj pasm niskich częstotliwości.';

  @override
  String get equalizerPreamp => 'Prewzmacnianie';

  @override
  String get equalizerHeadroom => 'Automatyczny zapas';

  @override
  String get equalizerHeadroomDescription =>
      'Zmniejsza poziom wyjściowy przy podbijaniu częstotliwości, by zostawić miejsce na piky. To nie jest limiter.';

  @override
  String get equalizerWaiting =>
      'Uruchom utwór, aby połączyć korektor z jego sesją audio.';

  @override
  String get equalizerUnsupported =>
      'Przetwarzanie dźwięku jest obecnie dostępne tylko na Androidzie.';

  @override
  String get equalizerFailed =>
      'To urządzenie nie mogło włączyć efektów dźwiękowych. Muzyka zagra i bez nich.';

  @override
  String get equalizerRetry => 'Połącz efekty ponownie';

  @override
  String get equalizerLive =>
      'Zmiany działają natychmiast i są zapisywane na tym urządzeniu.';

  @override
  String get youtubeAccount => 'YouTube i MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'Dostęp do playlist tylko do odczytu. Zalogowanie nie gwarantuje dostępności audio.';

  @override
  String get youtubeAccountCompatibility => 'Zgodność i prywatność';

  @override
  String get youtubeAccountSubtitle => 'Łączenie konta i import playlist';

  @override
  String get youtubeAccountPrivacy =>
      'Hook prosi o dostęp do YouTube tylko do odczytu. Hasło wpisuj wyłącznie w systemowym oknie Google, nigdy w Hooku. Token nie jest wysyłany na żaden serwer Hooka i pozostaje tylko w pamięci. Po restarcie aplikacji połącz się ponownie.';

  @override
  String get youtubeAccountPlaybackNotice =>
      'Zalogowanie daje dostęp do danych konta, nie do strumieni audio. Nie gwarantuje naprawy HTTP 403. Importy zachowują nagrania z YouTube bez podmieniania ich na inne źródło.';

  @override
  String get youtubeAccountConnect => 'Połącz konto';

  @override
  String get youtubeAccountDisconnect => 'Odłącz w Hooku';

  @override
  String get youtubeAccountDisconnected => 'Brak połączonego konta';

  @override
  String get youtubeAccountDisconnectNotice =>
      'Odłączyć to konto tylko w Hooku? Zapisane playlisty zostaną. Konta Google i MicroG w telefonie nie zostaną wylogowane.';

  @override
  String get youtubeAccountSystem => 'Systemowe API Google';

  @override
  String get youtubeAccountServicesMissing =>
      'Kompatybilne systemowe API Google są niedostępne. Osobna instalacja ReVanced GmsCore nie zastępuje ich przy logowaniu Hooka.';

  @override
  String get youtubeAccountMicrogNotice =>
      'Wykryto osobną instalację ReVanced GmsCore. Hook nie używa kont ani tokenów ReVanced. Systemowy MicroG może dostarczać zgodnych API Google, ale zgodność z tą metodą logowania nie jest gwarantowana.';

  @override
  String get youtubeAccountRevancedFound =>
      'YouTube Music ReVanced jest zainstalowany';

  @override
  String get youtubeAccountPlaylists => 'Playlisty konta';

  @override
  String get youtubeAccountNoPlaylists =>
      'Brak dostępnych playlist. Niektóre automatyczne kolekcje YouTube Music nie są dostępne przez YouTube Data API.';

  @override
  String get youtubeAccountMore => 'Wczytaj więcej';

  @override
  String get youtubeAccountPreview => 'Przygotuj import';

  @override
  String youtubeAccountProgress(int count) {
    return 'Pobrane utwory: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'Pominięte niedostępne pozycje: $count. Nie są zastępowane innymi utworami.';
  }

  @override
  String get youtubeAccountSetup => 'Konfiguracja logowania';

  @override
  String get youtubeAccountSetupBody =>
      'Deweloper musi włączyć YouTube Data API v3 w Google Cloud, zarejestrować klienta OAuth Android dla com.hook.music i SHA-1 podpisu zainstalowanej wersji oraz skonfigurować ekran zgody. W trybie testowym dodaj dozwolonych użytkowników. Zobacz docs/YOUTUBE_ACCOUNT_SETUP.md. Nigdy nie dodawaj haseł, sekretów klienta ani tokenów innych aplikacji.';

  @override
  String get youtubeAccountConfigError =>
      'Logowanie nie jest skonfigurowane dla tej wersji. Sprawdź w Google Cloud klienta OAuth Android, nazwę pakietu, SHA-1 i dozwolonych użytkowników testowych.';

  @override
  String get youtubeAccountPermissionError =>
      'Nie przyznano dostępu do odczytu danych YouTube.';

  @override
  String get youtubeAccountExpired =>
      'Twoja sesja wygasła. Połącz konto ponownie.';

  @override
  String get youtubeAccountNoChannel =>
      'Wybrane konto nie ma dostępnego kanału YouTube.';

  @override
  String get youtubeAccountQuota =>
      'Limit API YouTube przekroczony. Spróbuj później.';

  @override
  String get youtubeAccountFailed =>
      'Nie udało się pobrać danych YouTube. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get youtubeAccountUnsupported =>
      'Łączenie konta wymaga Androida ze zgodnymi systemowymi API Google.';

  @override
  String get importedFromYouTube => 'Zaimportowano z konta YouTube';

  @override
  String get translateLyrics => 'Przetłumacz tekst';

  @override
  String get hideTranslation => 'Ukryj tłumaczenie';

  @override
  String get cancelTranslation => 'Anuluj tłumaczenie';

  @override
  String get translationLoading => 'Przygotowywanie tłumaczenia…';

  @override
  String get translationAttribution =>
      'Automatycznie przetłumaczone przez Google Translate';

  @override
  String get translationNotice =>
      'Tłumaczenie może nie oddawać dokładnie znaczenia piosenki. Podświetlanie słów dotyczy tylko oryginału.';

  @override
  String get translationModelTitle => 'Pobrać modele językowe?';

  @override
  String get translationModelBody =>
      'Tłumaczenie działa na twoim telefonie: tekst nie jest wysyłany na żaden serwer. Pierwsze tłumaczenie wymaga modeli Google ML Kit, które zajmują dziesiątki megabajtów. Pobieranie korzysta z bieżącego połączenia, także z danych komórkowych. Anulowanie ukrywa wynik, ale rozpoczęte pobieranie modelu może ukończyć się w tle.';

  @override
  String get translationDownload => 'Pobierz i przetłumacz';

  @override
  String get translationUnavailable =>
      'Tłumaczenie nie powiodło się. Sprawdź dostęp do pobierania modeli i spróbuj ponownie.';

  @override
  String get translationUnsupported =>
      'Tłumaczenie na urządzeniu jest obecnie dostępne tylko na Androidzie.';

  @override
  String get translationUnknownLanguage =>
      'Nie udało się rozpoznać obsługiwanej języka tej piosenki.';

  @override
  String get translationSameLanguage => 'Tekst jest już w wybranym języku.';

  @override
  String get translationTooLarge =>
      'Ten tekst jest za długi do tłumaczenia na urządzeniu.';

  @override
  String get translationRussian => 'Na rosyjski';

  @override
  String get translationEnglish => 'Na angielski';

  @override
  String get translationTarget => 'Język tłumaczenia';

  @override
  String get retry => 'Ponów';

  @override
  String get home => 'Start';

  @override
  String get search => 'Szukaj';

  @override
  String get library => 'Biblioteka';

  @override
  String get youtubeUnavailableTitle => 'YouTube jest teraz niedostępny';

  @override
  String get youtubeUnavailableBody =>
      'Nie udało się uzyskać strumienia audio. Sprawdź sieć i trasę VPN: YouTube może odrzucać żądania nawet przez VPN.';

  @override
  String get checkAgain => 'Sprawdź ponownie';

  @override
  String get dismiss => 'Zamknij';

  @override
  String get goodNight => 'Dobranoc';

  @override
  String get goodMorning => 'Dzień dobry';

  @override
  String get goodAfternoon => 'Dobre popołudnie';

  @override
  String get goodEvening => 'Dobry wieczór';

  @override
  String get themeSettings => 'Ustawienia wyglądu';

  @override
  String get onYourAir => 'Na Twojej antenie';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count niedawnych sygnałów',
      many: '$count niedawnych sygnałów',
      few: '$count niedawne sygnały',
      one: '1 niedawny sygnał',
      zero: 'Brak niedawnych sygnałów',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'Twoja kolekcja czeka';

  @override
  String get saved => 'Zapisano';

  @override
  String get collectionEmptyDetail =>
      'Muzyka, do której chcesz wracać, zostanie tutaj';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utworu',
      many: '$count utworów',
      few: '$count utwory',
      one: '1 utwór',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'Utwór, wykonawca lub tekst';

  @override
  String get searchUpper => 'SZUKAJ';

  @override
  String get findFirstTrack => 'Znajdź swój pierwszy utwór';

  @override
  String continuationAfter(String artist) {
    return 'Więcej muzyki po $artist';
  }

  @override
  String get chooseTrackWaveDetail =>
      'Wybierz utwór, a zbudujemy wokół jego nastroju falę.';

  @override
  String get continueWaveLabel => 'KONTYNUUJ / 01';

  @override
  String get yourWaveLabel => 'TWOJA FALA / 01';

  @override
  String get continueWave => 'Kontynuuj falę';

  @override
  String get chooseTrack => 'Wybierz utwór';

  @override
  String get firstTrace => 'Zostaw tu swój pierwszy ślad';

  @override
  String get favoriteWaveHint =>
      'Zapisuj ulubione, a Twoja fala będzie trafniejsza.';

  @override
  String get openSearch => 'Otwórz wyszukiwanie';

  @override
  String get findYourMusic => 'Znajdź swój dźwięk.';

  @override
  String get importMusic => 'Importuj muzykę';

  @override
  String get rememberedLyricsHint => 'Słowa, które pamiętasz…';

  @override
  String get trackArtistHint => 'Utwór lub wykonawca — w dowolnym języku';

  @override
  String get clear => 'Wyczyść';

  @override
  String get music => 'Muzyka';

  @override
  String get byLyrics => 'Po tekście';

  @override
  String get allSources => 'Wszystkie źródła';

  @override
  String get lyricsSearchCaption =>
      'Szukaj frazy z piosenki, a nie tylko tytułu.';

  @override
  String get searchingLyrics => 'Szukam znajomych linijek…';

  @override
  String get searchingSources => 'Przeszukiwanie źródeł muzyki…';

  @override
  String get connectionFailed => 'Nie udało się połączyć';

  @override
  String get noMatches => 'Nie ma jeszcze dopasowań';

  @override
  String get lyricsUnavailable =>
      'Wyszukiwanie tekstów jest teraz niedostępne. Spróbuj później albo szukaj po tytule.';

  @override
  String get searchUnavailable =>
      'Wyszukiwanie nie powiodło się. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get lyricsNoMatches =>
      'Spróbuj innej linijki. Nie każdy tekst jest indeksowany.';

  @override
  String get trackNoMatches =>
      'Dodaj wykonawcę albo wybierz inne źródło. Niektóre usługi mogą być niedostępne w Twojej sieci.';

  @override
  String get repeatSearch => 'Szukaj ponownie';

  @override
  String get lyricMatchesUpper => 'DOPASOWANIA TEKSTU';

  @override
  String get tracksUpper => 'UTWORY';

  @override
  String playTrack(String title, String artist) {
    return 'Odtwórz $title, $artist';
  }

  @override
  String get familiarLinesUpper => 'ZNAJOME LINIJKI';

  @override
  String get bestMatchUpper => 'NAJLEPSZE DOPASOWANIE';

  @override
  String get fullVersionOnPlayback =>
      'Pełną wersję znajdziemy, gdy zacznie się odtwarzanie.';

  @override
  String get forgotTitle => 'Pamiętasz muzykę.\nNie tytuł.';

  @override
  String get startAsYouRemember =>
      'Nazwa, tytuł albo linijka z piosenki.\nZacznij od tego, co pamiętasz.';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => 'Szukaj nazw tak, jak brzmią';

  @override
  String get rememberOnlyLine => 'Pamiętam tylko jedną linijkę';

  @override
  String get findSongByWords => 'Znajdź piosenkę po jej słowach';

  @override
  String get yourArtistsUpper => 'TWOI WYKONAWCY';

  @override
  String get language => 'Język';

  @override
  String get languageCaption => 'Interfejs od razu stosuje Twój wybór';

  @override
  String get systemLanguage => 'System';

  @override
  String get russian => 'Rosyjski';

  @override
  String get english => 'Angielski';

  @override
  String get themesAndShaders => 'Motywy i efekty';

  @override
  String get themesSubtitle => 'Wygląd, język i ruch tła';

  @override
  String get invalidThemeJson =>
      'Nie udało się odczytać motywu. Sprawdź format JSON i wartości pól.';

  @override
  String get exportJson => 'Eksportuj JSON';

  @override
  String get importJson => 'Importuj JSON';

  @override
  String get readyThemes => 'Gotowe motywy';

  @override
  String get gpuShaders => 'Efekty tła';

  @override
  String get meshGradient => 'Gładki gradient GPU z barw utworu';

  @override
  String get vinylNoise => 'Ziarno analogowej płyty (szum)';

  @override
  String get glassBlur => 'Rozmycie szkła (Backdrop Blur)';

  @override
  String get cornerRadius => 'Promień zaokrąglenia interfejsu';

  @override
  String get importThemeTitle => 'Importuj motyw z JSON';

  @override
  String get pasteThemeJson => 'Wklej konfigurację JSON motywu:';

  @override
  String get cancel => 'Anuluj';

  @override
  String get apply => 'Zastosuj';

  @override
  String get themeApplied => 'Motyw zastosowany pomyślnie!';

  @override
  String get exportThemeTitle => 'Eksportuj motyw (JSON)';

  @override
  String get close => 'Zamknij';

  @override
  String get copyJson => 'Kopiuj JSON';

  @override
  String get jsonCopied => 'JSON motywu skopiowany do schowka!';

  @override
  String get libraryUpper => 'BIBLIOTEKA';

  @override
  String get localCollection => 'Lokalna kolekcja i playlisty';

  @override
  String get importShort => 'Importuj';

  @override
  String get favorites => 'Ulubione';

  @override
  String get playlists => 'Playlisty';

  @override
  String get history => 'Historia';

  @override
  String get offline => 'Offline';

  @override
  String get favoritesEmpty =>
      'Twoje ulubione są puste.\nDotknij serca przy utworze, aby dodać go tutaj.';

  @override
  String get historyEmpty =>
      'Twoja historia odsłuchu jest pusta.\nOdtwórz muzykę z wyszukiwania, a pojawi się tutaj.';

  @override
  String get noPlaylists => 'Nie masz jeszcze żadnych playlist';

  @override
  String get importPlaylistHint =>
      'Zaimportuj playlistę ze Spotify lub wklej listę utworów.';

  @override
  String get importMusicAction => 'Importuj muzykę';

  @override
  String get playPlaylist => 'Odtwórz playlistę';

  @override
  String playlistStarted(String name, int count) {
    return 'Odtwarzanie „$name” ($count utworów)';
  }

  @override
  String get deletePlaylist => 'Usuń playlistę';

  @override
  String get playAll => 'Odtwórz wszystko';

  @override
  String get shuffle => 'Losowo';

  @override
  String get localAudioCache => 'Lokalna pamięć audio';

  @override
  String get cacheDescription =>
      'Odtwarzane utwory są zapisywane lokalnie, by móc je wznawiać bez internetu.';

  @override
  String deviceUsage(String size) {
    return 'Na tym urządzeniu: $size';
  }

  @override
  String get clearCache => 'Wyczyść całą pamięć podręczną';

  @override
  String savedTracksUpper(int count) {
    return 'ZAPISANE UTWORY ($count):';
  }

  @override
  String get cacheFeaturesUpper => 'FUNKCJE PAMIĘCI PODRĘCZNEJ:';

  @override
  String get offlineFirst => 'Najpierw offline';

  @override
  String get offlineFirstDescription =>
      'Przy wznowieniu audio ładuje się wprost z systemu plików urządzenia.';

  @override
  String get maximumBitrate => 'Maksymalny bitrate';

  @override
  String get maximumBitrateDescription =>
      'Czyste strumienie Opus/M4A 160–256 kbps są zapisywane bez transkodowania.';

  @override
  String get trafficAndBattery => 'Oszczędzaj dane i baterię';

  @override
  String get trafficAndBatteryDescription =>
      'Unikanie powtarzanych żądań sieciowych pomaga telefonowi wytrzymać dłużej.';

  @override
  String get cacheEmpty => 'Pamięć podręczna jest pusta';

  @override
  String get cachedTracksAppear =>
      'Pobrane utwory pojawią się tu automatycznie';

  @override
  String get removeFromCache => 'Usuń z pamięci podręcznej';

  @override
  String get removeCachedTrackTitle => 'Usunąć utwór z pamięci podręcznej?';

  @override
  String removeCachedTrackBody(String title) {
    return '„$title” zostanie usunięty z tego urządzenia.';
  }

  @override
  String get delete => 'Usuń';

  @override
  String get trackRemovedFromCache => 'Utwór usunięty z pamięci podręcznej';

  @override
  String get clearCacheTitle => 'Wyczyścić pamięć podręczną?';

  @override
  String get clearCacheBody =>
      'Wszystkie zapisane pliki audio zostaną usunięte z tego urządzenia. Ulubione i historia się nie zmienią.';

  @override
  String get cacheCleared => 'Lokalna pamięć podręczna wyczyszczona';

  @override
  String get back => 'Wstecz';

  @override
  String get playlistActions => 'Akcje playlisty';

  @override
  String get playlistUpper => 'PLAYLISTA';

  @override
  String get playlistEmpty => 'Ta playlista nie ma jeszcze utworów';

  @override
  String get pasteTrackList => 'Wklej listę utworów';

  @override
  String get pasteImportLink => 'Wklej link do zaimportowania';

  @override
  String get tracksNotFound => 'Pod tym linkiem nie znaleziono utworów.';

  @override
  String get importError =>
      'Import nie powiódł się. Sprawdź link i połączenie z internetem.';

  @override
  String importedPlaylistStarted(int count) {
    return 'Odtwarzanie zaimportowanej playlisty ($count utworów)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'Import ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return 'Playlista „$name” zapisana w Twojej bibliotece!';
  }

  @override
  String get spotifyImportSubtitle => 'Spotify • Playlisty, albumy i utwory';

  @override
  String get artistTrackOrCsv => 'Wykonawca — Utwór albo CSV z Exportify';

  @override
  String get pastePlaylistOrTrackLink => 'Wklej link do playlisty lub utworu';

  @override
  String get pasteFromClipboard => 'Wklej ze schowka';

  @override
  String get link => 'Link';

  @override
  String get trackList => 'Lista utworów';

  @override
  String get playlistName => 'Nazwa playlisty';

  @override
  String get startImport => 'Rozpocznij import';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count utworów';
  }

  @override
  String get importedFromSpotify => 'Zaimportowano ze Spotify';

  @override
  String get importedFromDeezer => 'Zaimportowano z Deezer';

  @override
  String get importIntro =>
      'Zabierz playlisty ze sobą. Użyj linku Spotify, listy utworów lub pliku Exportify.';

  @override
  String get importTextTab => 'Tekst';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'Wybierz plik';

  @override
  String get importFileHint =>
      'Wybierz CSV wyeksportowany z Exportify albo listę utworów TXT. UTF-8, do 10 MB i 10 000 utworów.';

  @override
  String get importFileAndroidOnly =>
      'Wybór plików jest dostępny na Androidzie. Tutaj możesz wkleić zawartość CSV lub listy utworów.';

  @override
  String get importTextHint =>
      'Jedna linijka: Wykonawca — Utwór. Możesz też wkleić cały CSV wraz z nagłówkiem.';

  @override
  String get importPreview => 'Podgląd utworów';

  @override
  String get importedFromCsv => 'Zaimportowano z CSV';

  @override
  String get importedFromText => 'Zaimportowano z listy utworów';

  @override
  String importMoreTracks(int count) {
    return 'I jeszcze $count';
  }

  @override
  String get importMetadataHint =>
      'Playlista jest zapisywana na tym urządzeniu. Audio jest wyszukiwane przy odtwarzaniu utworu; import nie pobiera piosenek.';

  @override
  String get importAnother => 'Zaimportuj coś innego';

  @override
  String get importReading => 'Odczytywanie playlisty…';

  @override
  String get importSaving => 'Zapisywanie w bibliotece…';

  @override
  String get importNameRequired => 'Podaj nazwę playlisty.';

  @override
  String get importNameExists =>
      'Playlista o tej nazwie już istnieje. Wybierz inną nazwę, by zachować obie.';

  @override
  String get importSaveFailed =>
      'Nie udało się zapisać playlisty. Podgląd nadal tu jest — spróbuj ponownie.';

  @override
  String get importFileTooLarge =>
      'Ten plik przekracza 10 MB. Podziel playlistę na mniejsze eksporty.';

  @override
  String get importFileUnsupported => 'Wybierz plik .csv lub .txt.';

  @override
  String get importFileEncoding =>
      'Nie udało się odczytać kodowania tekstu. Zapisz plik w UTF-8 i spróbuj ponownie.';

  @override
  String get importCsvInvalid =>
      'CSV jest niekompletny lub uszkodzony. Wyeksportuj go ponownie, nie zmieniając kolumn ani cudzysłowów.';

  @override
  String get importCsvMissingColumns =>
      'CSV wymaga kolumn Track Name i Artist Name(s) albo Title i Artist. Wybierz oryginalny eksport z Exportify.';

  @override
  String get importFileEmpty =>
      'Nie znaleziono utworów. Wybierz wypełniony eksport albo wklej listę Wykonawca — Utwór.';

  @override
  String get importTooManyTracks =>
      'Pojedynczy import może zawierać do 10 000 utworów. Podziel tę playlistę; nic jeszcze nie zapisano.';

  @override
  String get importFileReadFailed =>
      'Nie udało się otworzyć tego pliku. Sprawdź, czy jest dostępny na urządzeniu, i wybierz go ponownie.';

  @override
  String get importSpotifyBlocked =>
      'Spotify nie udostępnił tej playlisty w Twoim regionie. Wyeksportuj ją przez Exportify i wybierz plik CSV.';

  @override
  String get listen => 'Odtwórz';

  @override
  String get addToPlaylists => 'Dodaj do playlist';

  @override
  String trackSemantics(String title, String artist) {
    return 'Utwór $title, $artist';
  }

  @override
  String get trackActions => 'Akcje utworu';

  @override
  String get updatesTitle => 'Aktualizacje';

  @override
  String get accountTitle => 'Konto';

  @override
  String get waveLoading => 'Szukamy podobnych utworów…';

  @override
  String get sleepTimer => 'Minutnik snu';

  @override
  String sleepMinutes(String value) {
    return '$value';
  }

  @override
  String get sleepUntilTrackEnd => 'Do końca utworu';

  @override
  String get sleepCancel => 'Wyłącz';

  @override
  String get dislike => 'Nie lubię';

  @override
  String get dislikeRemove => 'Usuń z ukrytych';

  @override
  String dislikeSaved(String artist) {
    return 'Ukryto: $artist';
  }

  @override
  String get exportPlaylist => 'Eksport CSV';

  @override
  String get playlistExported => 'Playlista wyeksportowana';

  @override
  String get exportFailed => 'Eksport nieudany';

  @override
  String get downloadAll => 'Pobierz wszystko';

  @override
  String get statsTitle => 'Statystyki';

  @override
  String get statsPlays => 'Odtworzenia';

  @override
  String get statsFavorites => 'Ulubione';

  @override
  String get statsPlaylists => 'Playlisty';

  @override
  String get statsTopArtists => 'Top artyści';

  @override
  String get statsTopTracks => 'Top utwory';

  @override
  String resumeTitle(String device) {
    return 'Kontynuuj na $device';
  }

  @override
  String get alwaysOnTop => 'Trzymaj okno na wierzchu';

  @override
  String get randomPick => 'Losowy wybór dla ciebie';

  @override
  String get accountCaption => 'Synchronizuj bibliotekę między urządzeniami';

  @override
  String get nickname => 'Nick';

  @override
  String get nicknameHint => '3–20 znaków: litery, cyfry, . _ -';

  @override
  String get password => 'Hasło';

  @override
  String get passwordMinHint => 'Co najmniej 6 znaków';

  @override
  String get signIn => 'Zaloguj się';

  @override
  String get signUp => 'Utwórz konto';

  @override
  String get haveAccountToggle => 'Masz już konto? Zaloguj się';

  @override
  String get noAccountToggle => 'Nie masz konta? Utwórz je';

  @override
  String get signOut => 'Wyloguj się';

  @override
  String get syncNow => 'Synchronizuj teraz';

  @override
  String get syncing => 'Synchronizacja…';

  @override
  String syncedAt(String time) {
    return 'Zsynchronizowano: $time';
  }

  @override
  String get neverSynced => 'Jeszcze nigdy nie zsynchronizowano';

  @override
  String get errorNicknameTaken => 'Ten nick jest już zajęty';

  @override
  String get errorNicknameInvalid => 'Nick: 3–20 znaków, litery/cyfry/._-';

  @override
  String get errorInvalidCredentials => 'Nieprawidłowy nick lub hasło';

  @override
  String get errorWeakPassword => 'Hasło jest za krótkie';

  @override
  String get errorNetwork => 'Brak połączenia';

  @override
  String get errorServer => 'Błąd serwera, spróbuj później';

  @override
  String currentVersion(String version) {
    return 'Wersja $version';
  }

  @override
  String get checkForUpdates => 'Sprawdź aktualizacje';

  @override
  String get checkingForUpdates => 'Sprawdzanie…';

  @override
  String get upToDate => 'Masz najnowszą wersję';

  @override
  String updateAvailable(String version) {
    return 'Dostępna wersja $version';
  }

  @override
  String get downloadingUpdate => 'Pobieranie aktualizacji…';

  @override
  String get installUpdate => 'Zainstaluj';

  @override
  String get updateCheckFailed =>
      'Nie udało się sprawdzić aktualizacji. Sprawdź internet.';

  @override
  String get installPermissionNeeded =>
      'Zezwól Hook na instalację aplikacji i dotknij Zainstaluj ponownie.';

  @override
  String updateSize(String size) {
    return '$size MB';
  }

  @override
  String get download => 'Pobierz';

  @override
  String get downloading => 'Pobieranie…';

  @override
  String get downloaded => 'Pobrano';

  @override
  String get downloadFailed => 'Nie udało się pobrać';

  @override
  String get removeDownload => 'Usuń pobrany';

  @override
  String get downloadSavedOffline => 'Zapisano offline';

  @override
  String get startWaveFromTrack => 'Rozpocznij falę od tego utworu';

  @override
  String get addToQueue => 'Dodaj do kolejki';

  @override
  String addedToQueue(String title) {
    return 'Dodano do kolejki: $title';
  }

  @override
  String get removeFavorite => 'Usuń z ulubionych';

  @override
  String get addFavorite => 'Dodaj do ulubionych';

  @override
  String get addToPlaylist => 'Dodaj do playlisty';

  @override
  String get goToArtist => 'Przejdź do wykonawcy';

  @override
  String get myPlaylist => 'Moja playlista';

  @override
  String get newPlaylist => 'Nowa playlista';

  @override
  String get name => 'Nazwa';

  @override
  String get create => 'Utwórz';

  @override
  String get loading => 'Wczytywanie…';

  @override
  String get pause => 'Pauza';

  @override
  String get play => 'Odtwórz';

  @override
  String get next => 'Dalej';

  @override
  String get speedAndPitch => 'Prędkość i wysokość dźwięku';

  @override
  String speedValue(String value) {
    return 'Prędkość: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'Wysokość: ${value}x';
  }

  @override
  String get reset => 'Resetuj';

  @override
  String get moreActions => 'Więcej akcji';

  @override
  String get playbackQueue => 'Kolejka odtwarzania';

  @override
  String get queueEmpty => 'Kolejka jest pusta';

  @override
  String get selectingSource => 'Wybieranie źródła';

  @override
  String get collapsePlayer => 'Zwiń odtwarzacz';

  @override
  String get nowPlayingUpper => 'TERAZ ODTWARZANE';

  @override
  String get queue => 'Kolejka';

  @override
  String get startWave => 'Rozpocznij falę';

  @override
  String get cover => 'Okładka';

  @override
  String get karaokeLyrics => 'Tekst karaoke';

  @override
  String get findMusicStart => 'Znajdź muzykę i zacznij odtwarzanie';

  @override
  String get playbackNotStarted => 'Odtwarzanie jeszcze się nie zaczęło';

  @override
  String get openSearchFirstTrack =>
      'Otwórz wyszukiwanie, by znaleźć swój pierwszy utwór';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => 'Na urządzeniu';

  @override
  String get sourceCatalog => 'Katalog';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'Serwer';

  @override
  String get serverResolver => 'Serwer rozwiązywania';

  @override
  String get serverResolverCaption =>
      'Opcjonalny własny serwer, który znajduje pełne strumienie audio. Aplikacja wysyła zapytanie lub identyfikator utworu; serwer zwraca adres odtwarzania. Kontrakt i implementacja wzorcowa są w docs/REMOTE_RESOLVER.md.';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'Nieskonfigurowany';

  @override
  String get serverSave => 'Zapisz';

  @override
  String get serverDisable => 'Wyłącz';

  @override
  String get onboardingWelcomeTitle => 'Witaj w Hooku';

  @override
  String get onboardingWelcomeCaption =>
      'Muzyka, teksty i Twój własny styl wizualny. Wybierz język, żeby zacząć — zmienisz go później w ustawieniach.';

  @override
  String get onboardingSkip => 'Pomiń';

  @override
  String get onboardingNext => 'Dalej';

  @override
  String get onboardingStart => 'Zacznij słuchać';

  @override
  String get onboardingMicrogTitle => 'MicroG i konto Google';

  @override
  String get onboardingMicrogBody =>
      'MicroG odtwarza usługi Google na niestandardowych ROM-ach Android, które są ich pozbawione. Hook używa ich tylko do jednej opcjonalnej funkcji: połączenia konta YouTube w celu importu playlist. Odtwarzanie muzyki nigdy nie wymaga MicroG ani żadnych usług Google.';

  @override
  String get onboardingMicrogNote =>
      'Odtwarzanie nie zależy od MicroG. Łączenie konta jest opcjonalne.';

  @override
  String get onboardingMicrogDownload => 'Pobierz MicroG';

  @override
  String get onboardingMicrogStatusChecking => 'Sprawdzanie usług Google…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'Usługi Google są obecne na tym urządzeniu ($version). Import konta zadziała od razu.';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'Wykryto ReVanced GmsCore ($version). Oficjalny SDK logowania Google nie jest z nim zgodny, więc łączenie konta może nie zadziałać. Odtwarzanie nie jest dotknięte.';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'Nie znaleziono usług Google. Aby importować playlisty z konta YouTube, najpierw zainstaluj MicroG — albo pomiń i używaj Hooka bez konta.';

  @override
  String lyricsView(String mode) {
    return 'Widok tekstu · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'Twój rytm czytania';

  @override
  String get lyricsModeSubtitle => 'Trzy sposoby, by zbliżyć się do piosenki.';

  @override
  String get lyricsModeLines => 'Linijki';

  @override
  String get lyricsModeKaraoke => 'Karaoke';

  @override
  String get lyricsModeFocus => 'Fokus';

  @override
  String get lyricsModeLinesDescription =>
      'Spokojny tekst z podświetloną bieżącą linijką';

  @override
  String get lyricsModeKaraokeDescription =>
      'Słowa rozświetlają się płynnie razem z wokalem';

  @override
  String get lyricsModeFocusDescription => 'Jedna duża linijka. Nic więcej';

  @override
  String get lyricsModeSaveFailed => 'Nie udało się zapisać widoku tekstu.';

  @override
  String get lyricsModeFootnote =>
      'Twój wybór jest zapisywany na kolejne piosenki. Celność karaoke zależy od danych źródłowych: bez czasu na słowo podświetlanie jest przybliżone, a bez znaczników czasu tekst stoi w miejscu.';

  @override
  String get lyricsNotFound => 'Nie znaleziono tekstu';

  @override
  String get karaokeUnavailable =>
      'Tekst karaoke jest niedostępny dla tego utworu';

  @override
  String get unsyncedLyrics => 'Tekst bez synchronizacji';

  @override
  String get wordSyncUpper => 'SYNCHRONIZACJA SŁOWO PO SŁOWIE';

  @override
  String get lineSyncUpper => 'SYNCHRONIZACJA LINIJKA PO LINIJCE';

  @override
  String get adjustLyricsSync => 'Dostosuj synchronizację tekstu';

  @override
  String get startsSoon => 'Zaraz się zacznie';

  @override
  String get musicContinues => 'Muzyka gra dalej';

  @override
  String get decreaseLyricsOffset => 'Zmniejsz przesunięcie o 0,1 s';

  @override
  String lyricsOffset(String value) {
    return 'Przesunięcie: $value s';
  }

  @override
  String get increaseLyricsOffset => 'Zwiększ przesunięcie o 0,1 s';

  @override
  String get hideSetting => 'Ukryj ustawienie';

  @override
  String get lyricsOffsetSaveFailed =>
      'Nie udało się zapisać przesunięcia tekstu.';

  @override
  String get audioForbidden =>
      'Serwer audio odmówił dostępu (HTTP 403). Utwór znaleziono, ale jego strumień jest niedostępny. VPN nie gwarantuje dostępu do audio.';

  @override
  String get fullVersionUnavailable =>
      'W dostępnych źródłach nie znaleziono pełnej wersji. Sprawdź połączenie albo spróbuj później.';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source nie mógł odtworzyć tego utworu. Sprawdź połączenie albo spróbuj później.';
  }

  @override
  String get recentQueriesUpper => 'OSTATNIE ZAPYTANIA';

  @override
  String get clearHistory => 'Wyczyść';

  @override
  String get waveFromArtist => 'Fala artysty';

  @override
  String get popularTracksUpper => 'POPULARNE UTWORY';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utworu',
      many: '$count utworów',
      few: '$count utwory',
      one: '$count utwór',
      zero: 'brak utworów',
    );
    return '$_temp0';
  }

  @override
  String get volume => 'Głośność';

  @override
  String get systemVolume => 'System';

  @override
  String get appVolume => 'Poziom Hook';

  @override
  String get mute => 'Wycisz';

  @override
  String get unmute => 'Włącz dźwięk';

  @override
  String get volumeMixer => 'Dźwięk i głośność';

  @override
  String get systemVolumeCaption =>
      'Poziom wyjścia Windows, wspólny dla wszystkich aplikacji';

  @override
  String get appVolumeCaption => 'Tylko w Hook, powyżej poziomu systemowego';

  @override
  String get volumeKeysHint => 'Ctrl + ↑ ↓ głośność · M wyciszenie';

  @override
  String get volumeUnavailable =>
      'Głośność systemowa jest niedostępna na tym urządzeniu';

  @override
  String get cacheFolder => 'Folder przechowywania';

  @override
  String get copyPath => 'Kopiuj ścieżkę';

  @override
  String get pathCopied => 'Skopiowano ścieżkę do schowka';

  @override
  String get previousTrack => 'Poprzedni utwór';

  @override
  String get repeatPlayback => 'Powtarzaj';

  @override
  String get openPlayer => 'Otwórz odtwarzacz';

  @override
  String get statsWeek => 'Ostatnie 7 dni';

  @override
  String get keyboardShortcuts => 'Skróty klawiszowe';

  @override
  String get shortcutsCaption => 'Działają wszędzie poza polami tekstowymi.';

  @override
  String get shortcutsSeek => 'Przeskok o 10 sekund';

  @override
  String get playPauseShortcut => 'Odtwórz / pauza';

  @override
  String get ageRestrictedTrack =>
      'Ten utwór ma ograniczenie wiekowe (18+). Serwer potrzebuje ciasteczek z zalogowanego konta YouTube.';

  @override
  String get haptics => 'Wibracje';

  @override
  String get hapticsDescription =>
      'Krótka wibracja, gdy dotknięcie coś zmienia. Tylko Android i iOS.';

  @override
  String get reduceMotion => 'Ogranicz animacje';

  @override
  String get reduceMotionDescription =>
      'Pomija przejścia i animowane tła. Przydatne na słabych urządzeniach lub przy wrażliwości na ruch.';

  @override
  String get backgroundPrefetch => 'Wczytuj kolejne utwory';

  @override
  String get backgroundPrefetchDescription =>
      'Przygotowuje kolejne utwory w tle, aby przełączanie było natychmiastowe. Zużywa nieco więcej danych.';

  @override
  String get playbackSettings => 'Odtwarzanie';

  @override
  String get cookieStatus => 'Ciasteczka YouTube';

  @override
  String get cookieStatusReady => 'Zalogowano — utwory 18+ są dostępne';

  @override
  String get cookieStatusVisitor => 'Nie zalogowano — utwory 18+ są odrzucane';

  @override
  String get cookieStatusUnknown => 'Jeszcze nie sprawdzono';

  @override
  String get cookieStatusCheck => 'Sprawdź';

  @override
  String get cookieStatusChecking => 'Sprawdzanie…';

  @override
  String get cookieStatusUpload => 'Wgraj ciasteczka';

  @override
  String get cookieStatusUploading => 'Wgrywanie…';

  @override
  String cookieUploadAccepted(int cookies) {
    return 'Wgrano $cookies ciasteczek — utwory 18+ są dostępne';
  }

  @override
  String cookieUploadRejected(String reason) {
    return 'Serwer odrzucił plik: $reason';
  }

  @override
  String get cookieUploadApology =>
      'Ten eksport nie jest zalogowaną sesją, więc utwory 18+ nadal nie zagrają. Zaloguj się do YouTube na zweryfikowanym koncie i wyeksportuj ponownie.';

  @override
  String get cookieStatusUnreachable => 'Serwer nie odpowiedział';

  @override
  String get errorAccountSetup =>
      'Accounts are not enabled on the server. In Supabase, turn off Authentication → Sign In / Providers → Email → «Confirm email», then try again.';

  @override
  String get errorRateLimited =>
      'Too many attempts. Wait a minute and try again.';
}
