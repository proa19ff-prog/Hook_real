// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'Налаштування';

  @override
  String get settingsCaption => 'Зміни зберігаються на цьому пристрої.';

  @override
  String get playerSettings => 'Програвач';

  @override
  String get lyricsAutoHide => 'Ховати керування під час читання тексту';

  @override
  String get lyricsAutoHideDescription =>
      'Через 10 секунд без взаємодії панелі програвача з\'їдуть з екрана. Скористайтеся кнопкою відновлення, щоб повернути їх.';

  @override
  String get showPlayerControls => 'Показувати керування програвачем';

  @override
  String get equalizer => 'Еквалайзер';

  @override
  String get equalizerEnabled => 'Обробка звуку';

  @override
  String get equalizerPresets => 'Звуковий профіль';

  @override
  String get equalizerFlat => 'Оригінал';

  @override
  String get equalizerBass => 'Глибокий бас';

  @override
  String get equalizerVocal => 'Вокал';

  @override
  String get equalizerRock => 'Рок';

  @override
  String get equalizerElectronic => 'Електронна';

  @override
  String get equalizerSoft => 'М\'який';

  @override
  String get equalizerCustom => 'Власний';

  @override
  String get equalizerBands => 'Смуги частот';

  @override
  String get equalizerBassBoost => 'Підсилення басів';

  @override
  String get equalizerBassUnsupported =>
      'Додаткове підсилення басів не підтримується. Використовуйте низькочастотні смуги.';

  @override
  String get equalizerPreamp => 'Попереднє підсилення';

  @override
  String get equalizerHeadroom => 'Автоматичний запас';

  @override
  String get equalizerHeadroomDescription =>
      'Знижує рівень виходу при підсиленні частот, щоб залишити місце для піків. Це не лімітер.';

  @override
  String get equalizerWaiting =>
      'Запустіть трек, щоб з\'єднати еквалайзер із його аудіосесією.';

  @override
  String get equalizerUnsupported =>
      'Обробка звуку наразі доступна лише на Android.';

  @override
  String get equalizerFailed =>
      'Цей пристрій не зміг увімкнути звукові ефекти. Музика гратиме й без них.';

  @override
  String get equalizerRetry => 'Перепідключити ефекти';

  @override
  String get equalizerLive =>
      'Зміни застосовуються миттєво та зберігаються на цьому пристрої.';

  @override
  String get youtubeAccount => 'YouTube і MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'Доступ лише для читання до плейлистів. Вхід не гарантує доступності аудіо.';

  @override
  String get youtubeAccountCompatibility => 'Сумісність і приватність';

  @override
  String get youtubeAccountSubtitle =>
      'Підключення облікового запису та імпорт плейлистів';

  @override
  String get youtubeAccountPrivacy =>
      'Hook просить доступ до YouTube лише для читання. Пароль уводьте лише в системному вікні Google, ніколи в самому Hook. Токен не надсилається на жоден сервер Hook і зберігається лише в пам\'яті. Після перезапуску програми підключіться знову.';

  @override
  String get youtubeAccountPlaybackNotice =>
      'Вхід дає доступ до даних облікового запису, а не до аудіопотоків. Це не гарантує виправлення HTTP 403. Імпорт зберігає записи YouTube, не підмінюючи їх іншим джерелом.';

  @override
  String get youtubeAccountConnect => 'Підключити обліковий запис';

  @override
  String get youtubeAccountDisconnect => 'Відключити в Hook';

  @override
  String get youtubeAccountDisconnected =>
      'Немає підключеного облікового запису';

  @override
  String get youtubeAccountDisconnectNotice =>
      'Відключити цей запис лише в Hook? Збережені плейлисти залишаться. Облікові записи Google та MicroG на телефоні не вийдуть.';

  @override
  String get youtubeAccountSystem => 'Системні API Google';

  @override
  String get youtubeAccountServicesMissing =>
      'Сумісні системні API Google недоступні. Окрема інсталяція ReVanced GmsCore не замінює їх для входу Hook.';

  @override
  String get youtubeAccountMicrogNotice =>
      'Виявлено окрему інсталяцію ReVanced GmsCore. Hook не використовує облікові записи чи токени ReVanced. Системний MicroG може надавати сумісні API Google, але сумісність із цим методом входу не гарантована.';

  @override
  String get youtubeAccountRevancedFound =>
      'YouTube Music ReVanced установлено';

  @override
  String get youtubeAccountPlaylists => 'Плейлисти облікового запису';

  @override
  String get youtubeAccountNoPlaylists =>
      'Немає доступних плейлистів. Деякі автоматичні збірки YouTube Music недоступні через YouTube Data API.';

  @override
  String get youtubeAccountMore => 'Завантажити ще';

  @override
  String get youtubeAccountPreview => 'Підготувати імпорт';

  @override
  String youtubeAccountProgress(int count) {
    return 'Отримано треків: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'Пропущено недоступних записів: $count. Вони не замінюються іншими треками.';
  }

  @override
  String get youtubeAccountSetup => 'Налаштування входу';

  @override
  String get youtubeAccountSetupBody =>
      'Розробник має увімкнути YouTube Data API v3 у Google Cloud, зареєструвати OAuth-клієнт Android для com.hook.music та SHA-1 підпису встановленої збірки й налаштувати екран згоди. У тестовому режимі додайте дозволених користувачів. Дивіться docs/YOUTUBE_ACCOUNT_SETUP.md. Ніколи не додавайте паролі, секрети клієнтів чи токени інших програм.';

  @override
  String get youtubeAccountConfigError =>
      'Вхід не налаштовано для цієї збірки. Перевірте в Google Cloud OAuth-клієнт Android, назву пакета, SHA-1 і дозволених тестових користувачів.';

  @override
  String get youtubeAccountPermissionError =>
      'Доступ на читання даних YouTube не надано.';

  @override
  String get youtubeAccountExpired =>
      'Ваша сесія минула. Підключіть обліковий запис знову.';

  @override
  String get youtubeAccountNoChannel =>
      'У вибраного облікового запису немає доступного каналу YouTube.';

  @override
  String get youtubeAccountQuota =>
      'Квоту API YouTube вичерпано. Спробуйте пізніше.';

  @override
  String get youtubeAccountFailed =>
      'Не вдалося отримати дані YouTube. Перевірте з\'єднання та спробуйте ще раз.';

  @override
  String get youtubeAccountUnsupported =>
      'Підключення облікового запису потребує Android із сумісними системними API Google.';

  @override
  String get importedFromYouTube => 'Імпортовано з облікового запису YouTube';

  @override
  String get translateLyrics => 'Перекласти текст';

  @override
  String get hideTranslation => 'Сховати переклад';

  @override
  String get cancelTranslation => 'Скасувати переклад';

  @override
  String get translationLoading => 'Підготовка перекладу…';

  @override
  String get translationAttribution =>
      'Автоматично перекладено через Google Перекладач';

  @override
  String get translationNotice =>
      'Переклад може не точно передавати зміст пісні. Підсвічування слів стосується лише оригіналу.';

  @override
  String get translationModelTitle => 'Завантажити мовні моделі?';

  @override
  String get translationModelBody =>
      'Переклад працює на вашому телефоні: текст не надсилається на жоден сервер. Для першого перекладу потрібні моделі Google ML Kit — десятки мегабайт. Завантаження використовує поточне з\'єднання, зокрема мобільний інтернет. Скасування ховає результат, але вже розпочате завантаження моделі може завершитися у фоні.';

  @override
  String get translationDownload => 'Завантажити та перекласти';

  @override
  String get translationUnavailable =>
      'Переклад не вдався. Перевірте доступ до завантаження моделей і спробуйте ще раз.';

  @override
  String get translationUnsupported =>
      'Переклад на пристрої наразі доступний лише на Android.';

  @override
  String get translationUnknownLanguage =>
      'Не вдалося визначити підтримувану мову цієї пісні.';

  @override
  String get translationSameLanguage => 'Текст уже мовою вибору.';

  @override
  String get translationTooLarge =>
      'Цей текст завеликий для перекладу на пристрої.';

  @override
  String get translationRussian => 'Російською';

  @override
  String get translationEnglish => 'Англійською';

  @override
  String get translationTarget => 'Мова перекладу';

  @override
  String get retry => 'Повторити';

  @override
  String get home => 'Головна';

  @override
  String get search => 'Пошук';

  @override
  String get library => 'Бібліотека';

  @override
  String get youtubeUnavailableTitle => 'YouTube зараз недоступний';

  @override
  String get youtubeUnavailableBody =>
      'Не вдалося отримати аудіопотік. Перевірте мережу та маршрут VPN: YouTube може відхиляти запити навіть із VPN.';

  @override
  String get checkAgain => 'Перевірити ще раз';

  @override
  String get dismiss => 'Закрити';

  @override
  String get goodNight => 'Доброї ночі';

  @override
  String get goodMorning => 'Доброго ранку';

  @override
  String get goodAfternoon => 'Доброго дня';

  @override
  String get goodEvening => 'Доброго вечора';

  @override
  String get themeSettings => 'Налаштування вигляду';

  @override
  String get onYourAir => 'На вашій хвилі';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count нещодавнього сигналу',
      many: '$count нещодавніх сигналів',
      few: '$count нещодавні сигнали',
      one: '1 нещодавній сигнал',
      zero: 'Немає нещодавніх сигналів',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'Ваша колекція чекає';

  @override
  String get saved => 'Збережено';

  @override
  String get collectionEmptyDetail =>
      'Музика, до якої ви захочете повернутися, залишеться тут';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count трека',
      many: '$count треків',
      few: '$count треки',
      one: '1 трек',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'Трек, виконавець або текст';

  @override
  String get searchUpper => 'ПОШУК';

  @override
  String get findFirstTrack => 'Знайдіть свій перший трек';

  @override
  String continuationAfter(String artist) {
    return 'Більше музики після $artist';
  }

  @override
  String get chooseTrackWaveDetail =>
      'Оберіть трек, і ми збудуємо навколо його настрою хвилю.';

  @override
  String get continueWaveLabel => 'ПРОДОВЖИТИ / 01';

  @override
  String get yourWaveLabel => 'ВАША ХВИЛЯ / 01';

  @override
  String get continueWave => 'Продовжити хвилю';

  @override
  String get chooseTrack => 'Оберіть трек';

  @override
  String get firstTrace => 'Залишіть тут свій перший слід';

  @override
  String get favoriteWaveHint =>
      'Зберігайте улюблене, і ваша хвиля стане точнішою.';

  @override
  String get openSearch => 'Відкрити пошук';

  @override
  String get findYourMusic => 'Знайдіть свій звук.';

  @override
  String get importMusic => 'Імпортувати музику';

  @override
  String get rememberedLyricsHint => 'Слова, які ви пам\'ятаєте…';

  @override
  String get trackArtistHint => 'Трек або виконавець — будь-якою мовою';

  @override
  String get clear => 'Очистити';

  @override
  String get music => 'Музика';

  @override
  String get byLyrics => 'За текстом';

  @override
  String get allSources => 'Усі джерела';

  @override
  String get lyricsSearchCaption => 'Шукайте фразу з пісні, а не лише назву.';

  @override
  String get searchingLyrics => 'Шукаю знайомі рядки…';

  @override
  String get searchingSources => 'Пошук у музичних джерелах…';

  @override
  String get connectionFailed => 'Не вдалося з\'єднатися';

  @override
  String get noMatches => 'Ще немає збігів';

  @override
  String get lyricsUnavailable =>
      'Пошук текстів зараз недоступний. Спробуйте пізніше або шукайте за назвою.';

  @override
  String get searchUnavailable =>
      'Пошук не вдався. Перевірте з\'єднання та спробуйте ще раз.';

  @override
  String get lyricsNoMatches =>
      'Спробуйте інший рядок. Не всі тексти проіндексовано.';

  @override
  String get trackNoMatches =>
      'Додайте виконавця або оберіть інше джерело. Деякі сервіси можуть бути недоступні у вашій мережі.';

  @override
  String get repeatSearch => 'Шукати ще раз';

  @override
  String get lyricMatchesUpper => 'ЗБІГИ ТЕКСТУ';

  @override
  String get tracksUpper => 'ТРЕКИ';

  @override
  String playTrack(String title, String artist) {
    return 'Прослухати $title, $artist';
  }

  @override
  String get familiarLinesUpper => 'ЗНАЙОМІ РЯДКИ';

  @override
  String get bestMatchUpper => 'НАЙКРАЩИЙ ЗБІГ';

  @override
  String get fullVersionOnPlayback =>
      'Повну версію знайдемо, коли розпочнеться відтворення.';

  @override
  String get forgotTitle => 'Ви забули назву.\nАле не музику.';

  @override
  String get startAsYouRemember =>
      'Назва, заголовок або рядок із пісні.\nПочніть із того, що пам\'ятаєте.';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => 'Шукайте назви так, як вони звучать';

  @override
  String get rememberOnlyLine => 'Пам\'ятаю лише один рядок';

  @override
  String get findSongByWords => 'Знайдіть пісню за її словами';

  @override
  String get yourArtistsUpper => 'ВАШІ ВИКОНАВЦІ';

  @override
  String get language => 'Мова';

  @override
  String get languageCaption => 'Інтерфейс одразу застосовує ваш вибір';

  @override
  String get systemLanguage => 'Система';

  @override
  String get russian => 'Російська';

  @override
  String get english => 'Англійська';

  @override
  String get themesAndShaders => 'Теми та ефекти';

  @override
  String get themesSubtitle => 'Вигляд, мова та рух тла';

  @override
  String get invalidThemeJson =>
      'Не вдалося прочитати тему. Перевірте формат JSON і значення полів.';

  @override
  String get exportJson => 'Експортувати JSON';

  @override
  String get importJson => 'Імпортувати JSON';

  @override
  String get readyThemes => 'Готові теми';

  @override
  String get gpuShaders => 'Ефекти тла';

  @override
  String get meshGradient => 'Гладкий градієнт GPU з барв треку';

  @override
  String get vinylNoise => 'Зерно вінілової платівки (шум)';

  @override
  String get glassBlur => 'Скляне розмиття (Backdrop Blur)';

  @override
  String get cornerRadius => 'Радіус заокруглення інтерфейсу';

  @override
  String get importThemeTitle => 'Імпортувати тему з JSON';

  @override
  String get pasteThemeJson => 'Вставте JSON-конфігурацію теми:';

  @override
  String get cancel => 'Скасувати';

  @override
  String get apply => 'Застосувати';

  @override
  String get themeApplied => 'Тему застосовано успішно!';

  @override
  String get exportThemeTitle => 'Експортувати тему (JSON)';

  @override
  String get close => 'Закрити';

  @override
  String get copyJson => 'Копіювати JSON';

  @override
  String get jsonCopied => 'JSON теми скопійовано в буфер обміну!';

  @override
  String get libraryUpper => 'БІБЛІОТЕКА';

  @override
  String get localCollection => 'Локальна колекція та плейлисти';

  @override
  String get importShort => 'Імпорт';

  @override
  String get favorites => 'Улюблене';

  @override
  String get playlists => 'Плейлисти';

  @override
  String get history => 'Історія';

  @override
  String get offline => 'Офлайн';

  @override
  String get favoritesEmpty =>
      'Ваше улюблене порожнє.\nТоркніться серця біля трека, щоб додати його сюди.';

  @override
  String get historyEmpty =>
      'Ваша історія прослуховування порожня.\nУвімкніть музику з пошуку — вона з\'явиться тут.';

  @override
  String get noPlaylists => 'У вас ще немає плейлистів';

  @override
  String get importPlaylistHint =>
      'Імпортуйте плейлист зі Spotify або вставте список треків.';

  @override
  String get importMusicAction => 'Імпортувати музику';

  @override
  String get playPlaylist => 'Прослухати плейлист';

  @override
  String playlistStarted(String name, int count) {
    return 'Відтворення «$name» ($count треків)';
  }

  @override
  String get deletePlaylist => 'Видалити плейлист';

  @override
  String get playAll => 'Відтворити все';

  @override
  String get shuffle => 'Перемішати';

  @override
  String get localAudioCache => 'Локальний аудіокеш';

  @override
  String get cacheDescription =>
      'Програшані треки зберігаються локально, щоб слухати їх знову без інтернету.';

  @override
  String deviceUsage(String size) {
    return 'На цьому пристрої: $size';
  }

  @override
  String get clearCache => 'Очистити весь кеш';

  @override
  String savedTracksUpper(int count) {
    return 'ЗБЕРЕЖЕНІ ТРЕКИ ($count):';
  }

  @override
  String get cacheFeaturesUpper => 'МОЖЛИВОСТІ КЕШУ:';

  @override
  String get offlineFirst => 'Спершу офлайн';

  @override
  String get offlineFirstDescription =>
      'При повторному прослуховуванні аудіо завантажується прямо з файлової системи пристрою.';

  @override
  String get maximumBitrate => 'Максимальний бітрейт';

  @override
  String get maximumBitrateDescription =>
      'Чисті потоки Opus/M4A 160–256 кбіт/с зберігаються без перекодування.';

  @override
  String get trafficAndBattery => 'Економте трафік і батарею';

  @override
  String get trafficAndBatteryDescription =>
      'Уникання повторних мережевих запитів допомагає телефону працювати довше.';

  @override
  String get cacheEmpty => 'Кеш порожній';

  @override
  String get cachedTracksAppear =>
      'Завантажені треки з\'являться тут автоматично';

  @override
  String get removeFromCache => 'Видалити з кешу';

  @override
  String get removeCachedTrackTitle => 'Видалити трек із кешу?';

  @override
  String removeCachedTrackBody(String title) {
    return '«$title» буде видалено з цього пристрою.';
  }

  @override
  String get delete => 'Видалити';

  @override
  String get trackRemovedFromCache => 'Трек видалено з кешу';

  @override
  String get clearCacheTitle => 'Очистити кеш?';

  @override
  String get clearCacheBody =>
      'Усі збережені аудіофайли буде видалено з цього пристрою. Улюблене та історія не зміняться.';

  @override
  String get cacheCleared => 'Локальний кеш очищено';

  @override
  String get back => 'Назад';

  @override
  String get playlistActions => 'Дії з плейлистом';

  @override
  String get playlistUpper => 'ПЛЕЙЛИСТ';

  @override
  String get playlistEmpty => 'У цьому плейлисті ще немає треків';

  @override
  String get pasteTrackList => 'Вставте список треків';

  @override
  String get pasteImportLink => 'Вставте посилання для імпорту';

  @override
  String get tracksNotFound => 'За цим посиланням не знайдено треків.';

  @override
  String get importError =>
      'Імпорт не вдався. Перевірте посилання та інтернет-з\'єднання.';

  @override
  String importedPlaylistStarted(int count) {
    return 'Відтворення імпортованого плейлиста ($count треків)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'Імпорт ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return 'Плейлист «$name» збережено у вашій бібліотеці!';
  }

  @override
  String get spotifyImportSubtitle => 'Spotify • Плейлисти, альбоми та треки';

  @override
  String get artistTrackOrCsv => 'Виконавець — Трек або CSV з Exportify';

  @override
  String get pastePlaylistOrTrackLink =>
      'Вставте посилання на плейлист або трек';

  @override
  String get pasteFromClipboard => 'Вставити з буфера обміну';

  @override
  String get link => 'Посилання';

  @override
  String get trackList => 'Список треків';

  @override
  String get playlistName => 'Назва плейлиста';

  @override
  String get startImport => 'Розпочати імпорт';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count треків';
  }

  @override
  String get importedFromSpotify => 'Імпортовано зі Spotify';

  @override
  String get importIntro =>
      'Заберіть свої плейлисти з собою. Скористайтеся посиланням Spotify, списком треків або файлом Exportify.';

  @override
  String get importTextTab => 'Текст';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'Обрати файл';

  @override
  String get importFileHint =>
      'Оберіть CSV, експортований з Exportify, або список треків TXT. UTF-8, до 10 МБ і 10 000 треків.';

  @override
  String get importFileAndroidOnly =>
      'Вибір файлів доступний на Android. Тут можна вставити вміст CSV або списку треків.';

  @override
  String get importTextHint =>
      'Рядок на рядок: Виконавець — Трек. Також можна вставити весь CSV, разом із заголовком.';

  @override
  String get importPreview => 'Перегляд треків';

  @override
  String get importedFromCsv => 'Імпортовано з CSV';

  @override
  String get importedFromText => 'Імпортовано зі списку треків';

  @override
  String importMoreTracks(int count) {
    return 'І ще $count';
  }

  @override
  String get importMetadataHint =>
      'Плейлист зберігається на цьому пристрої. Аудіо шукається під час відтворення трека; імпорт не завантажує пісні.';

  @override
  String get importAnother => 'Імпортувати щось інше';

  @override
  String get importReading => 'Читаємо ваш плейлист…';

  @override
  String get importSaving => 'Зберігаємо до бібліотеки…';

  @override
  String get importNameRequired => 'Уведіть назву плейлиста.';

  @override
  String get importNameExists =>
      'Плейлист із такою назвою вже існує. Оберіть іншу назву, щоб зберегти обидва.';

  @override
  String get importSaveFailed =>
      'Не вдалося зберегти плейлист. Ваш попередній перегляд залишився — спробуйте ще раз.';

  @override
  String get importFileTooLarge =>
      'Файл перевищує 10 МБ. Розділіть плейлист на менші експорти.';

  @override
  String get importFileUnsupported => 'Оберіть файл .csv або .txt.';

  @override
  String get importFileEncoding =>
      'Не вдалося прочитати кодування тексту. Збережіть файл у UTF-8 і спробуйте ще раз.';

  @override
  String get importCsvInvalid =>
      'CSV неповний або пошкоджений. Експортуйте його знову, не змінюючи стовпців та лапок.';

  @override
  String get importCsvMissingColumns =>
      'CSV потребує стовпців Track Name і Artist Name(s) або Title і Artist. Оберіть оригінальний експорт Exportify.';

  @override
  String get importFileEmpty =>
      'Не знайдено жодного трека. Оберіть заповнений експорт або вставте список Виконавець — Трек.';

  @override
  String get importTooManyTracks =>
      'Один імпорт може містити до 10 000 треків. Розділіть цей плейлист; ще нічого не збережено.';

  @override
  String get importFileReadFailed =>
      'Не вдалося відкрити цей файл. Перевірте, чи він доступний на пристрої, та оберіть його знову.';

  @override
  String get importSpotifyBlocked =>
      'Spotify не поділився цим плейлистом у вашому регіоні. Експортуйте його через Exportify й оберіть файл CSV.';

  @override
  String get listen => 'Прослухати';

  @override
  String get addToPlaylists => 'Додати до плейлистів';

  @override
  String trackSemantics(String title, String artist) {
    return 'Трек $title, $artist';
  }

  @override
  String get trackActions => 'Дії з треком';

  @override
  String get download => 'Завантажити';

  @override
  String get downloading => 'Завантаження…';

  @override
  String get downloaded => 'Завантажено';

  @override
  String get downloadFailed => 'Не вдалося завантажити';

  @override
  String get removeDownload => 'Видалити завантаження';

  @override
  String get downloadSavedOffline => 'Збережено офлайн';

  @override
  String get startWaveFromTrack => 'Почати хвилю з цього трека';

  @override
  String get addToQueue => 'Додати до черги';

  @override
  String addedToQueue(String title) {
    return 'Додано до черги: $title';
  }

  @override
  String get removeFavorite => 'Прибрати з улюблених';

  @override
  String get addFavorite => 'Додати до улюблених';

  @override
  String get addToPlaylist => 'Додати до плейлиста';

  @override
  String get goToArtist => 'До виконавця';

  @override
  String get myPlaylist => 'Мій плейлист';

  @override
  String get newPlaylist => 'Новий плейлист';

  @override
  String get name => 'Назва';

  @override
  String get create => 'Створити';

  @override
  String get loading => 'Завантаження…';

  @override
  String get pause => 'Пауза';

  @override
  String get play => 'Пуск';

  @override
  String get next => 'Далі';

  @override
  String get speedAndPitch => 'Швидкість і висота тону';

  @override
  String speedValue(String value) {
    return 'Швидкість: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'Висота: ${value}x';
  }

  @override
  String get reset => 'Скинути';

  @override
  String get moreActions => 'Більше дій';

  @override
  String get playbackQueue => 'Черга відтворення';

  @override
  String get queueEmpty => 'Черга порожня';

  @override
  String get selectingSource => 'Вибір джерела';

  @override
  String get collapsePlayer => 'Згорнути програвач';

  @override
  String get nowPlayingUpper => 'ЗАРАЗ ГРАЄ';

  @override
  String get queue => 'Черга';

  @override
  String get startWave => 'Почати хвилю';

  @override
  String get cover => 'Обкладинка';

  @override
  String get karaokeLyrics => 'Текст караоке';

  @override
  String get findMusicStart => 'Знайдіть музику та почніть відтворення';

  @override
  String get playbackNotStarted => 'Відтворення ще не почалося';

  @override
  String get openSearchFirstTrack =>
      'Відкрийте пошук, щоб знайти свій перший трек';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => 'На пристрої';

  @override
  String get sourceCatalog => 'Каталог';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'Сервер';

  @override
  String get serverResolver => 'Сервер-резолвер';

  @override
  String get serverResolverCaption =>
      'Необов\'язковий власний сервер, який знаходить повні аудіопотоки. Програма надсилає пошуковий запит або ID трека; сервер повертає адресу відтворення. Контракт і зразок реалізації — у docs/REMOTE_RESOLVER.md.';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'Не налаштовано';

  @override
  String get serverSave => 'Зберегти';

  @override
  String get serverDisable => 'Вимкнути';

  @override
  String get onboardingWelcomeTitle => 'Вітаємо в Hook';

  @override
  String get onboardingWelcomeCaption =>
      'Музика, тексти та ваш власний візуальний стиль. Оберіть мову, щоб почати — її можна змінити в налаштуваннях.';

  @override
  String get onboardingSkip => 'Пропустити';

  @override
  String get onboardingNext => 'Далі';

  @override
  String get onboardingStart => 'Почати слухати';

  @override
  String get onboardingMicrogTitle => 'MicroG і обліковий запис Google';

  @override
  String get onboardingMicrogBody =>
      'MicroG відтворює сервіси Google на кастомних прошивках Android, які постачаються без них. Hook використовує ці сервіси лише для однієї необов\'язкової функції: підключення облікового запису YouTube для імпорту плейлистів. Для відтворення музики MicroG і будь-які сервіси Google не потрібні.';

  @override
  String get onboardingMicrogNote =>
      'Відтворення не залежить від MicroG. Підключення облікового запису — необов\'язкове.';

  @override
  String get onboardingMicrogDownload => 'Завантажити MicroG';

  @override
  String get onboardingMicrogStatusChecking => 'Перевіряємо сервіси Google…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'Сервіси Google є на цьому пристрої ($version). Імпорт облікового запису запрацює одразу.';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'Виявлено ReVanced GmsCore ($version). Офіційний SDK входу Google з ним несумісний, тому підключення облікового запису може не запрацювати. Відтворення не постраждає.';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'Сервіси Google не знайдено. Щоб імпортувати плейлисти з облікового запису YouTube, спершу встановіть MicroG — або пропустіть і користуйтеся Hook без облікового запису.';

  @override
  String lyricsView(String mode) {
    return 'Вигляд тексту · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'Ваш ритм читання';

  @override
  String get lyricsModeSubtitle => 'Три способи наблизитися до пісні.';

  @override
  String get lyricsModeLines => 'Рядки';

  @override
  String get lyricsModeKaraoke => 'Караоке';

  @override
  String get lyricsModeFocus => 'Фокус';

  @override
  String get lyricsModeLinesDescription =>
      'Спокійний текст із підсвіченим поточним рядком';

  @override
  String get lyricsModeKaraokeDescription =>
      'Слова плавно засвічуються разом із вокалом';

  @override
  String get lyricsModeFocusDescription => 'Один великий рядок. Більше нічого';

  @override
  String get lyricsModeSaveFailed => 'Не вдалося зберегти вигляд тексту.';

  @override
  String get lyricsModeFootnote =>
      'Ваш вибір зберігається для наступних пісень. Точність караоке залежить від даних джерела: без часу на слово підсвічування приблизне, а без часових міток текст стоїть на місці.';

  @override
  String get lyricsNotFound => 'Текст не знайдено';

  @override
  String get karaokeUnavailable => 'Текст караоке недоступний для цього трека';

  @override
  String get unsyncedLyrics => 'Несинхронізований текст';

  @override
  String get wordSyncUpper => 'СИНХРОНІЗАЦІЯ СЛОВО ЗА СЛОВОМ';

  @override
  String get lineSyncUpper => 'СИНХРОНІЗАЦІЯ РЯДОК ЗА РЯДКОМ';

  @override
  String get adjustLyricsSync => 'Налаштувати синхронізацію тексту';

  @override
  String get startsSoon => 'Скоро почнеться';

  @override
  String get musicContinues => 'Музика триває';

  @override
  String get decreaseLyricsOffset => 'Зменшити зміщення на 0,1 с';

  @override
  String lyricsOffset(String value) {
    return 'Зміщення: $value с';
  }

  @override
  String get increaseLyricsOffset => 'Збільшити зміщення на 0,1 с';

  @override
  String get hideSetting => 'Сховати налаштування';

  @override
  String get lyricsOffsetSaveFailed => 'Не вдалося зберегти зміщення тексту.';

  @override
  String get audioForbidden =>
      'Аудіосервер відмовив у доступі (HTTP 403). Трек знайдено, але його потік недоступний. VPN не гарантує доступу до аудіо.';

  @override
  String get fullVersionUnavailable =>
      'У доступних джерелах не знайдено повної версії. Перевірте з\'єднання або спробуйте пізніше.';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source не зміг відтворити цей трек. Перевірте з\'єднання або спробуйте пізніше.';
  }

  @override
  String get recentQueriesUpper => 'НЕДАВНІ ЗАПИТИ';

  @override
  String get clearHistory => 'Очистити';

  @override
  String get waveFromArtist => 'Хвиля від виконавця';

  @override
  String get popularTracksUpper => 'ПОПУЛЯРНІ ТРЕКИ';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count треків',
      many: '$count треків',
      few: '$count треки',
      one: '$count трек',
      zero: 'поки немає треків',
    );
    return '$_temp0';
  }
}
