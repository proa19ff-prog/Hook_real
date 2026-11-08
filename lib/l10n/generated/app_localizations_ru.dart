// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'Настройки';

  @override
  String get settingsCaption => 'Изменения сохраняются на этом устройстве.';

  @override
  String get playerSettings => 'Плеер';

  @override
  String get lyricsAutoHide => 'Скрывать панели при просмотре текста';

  @override
  String get lyricsAutoHideDescription =>
      'После 10 секунд без касаний панели плеера плавно уезжают. Кнопка возврата снова показывает управление.';

  @override
  String get showPlayerControls => 'Вернуть управление';

  @override
  String get equalizer => 'Эквалайзер';

  @override
  String get equalizerEnabled => 'Обработка звука';

  @override
  String get equalizerPresets => 'Характер звучания';

  @override
  String get equalizerFlat => 'Оригинал';

  @override
  String get equalizerBass => 'Глубокий бас';

  @override
  String get equalizerVocal => 'Вокал';

  @override
  String get equalizerRock => 'Рок';

  @override
  String get equalizerElectronic => 'Электроника';

  @override
  String get equalizerSoft => 'Мягкий';

  @override
  String get equalizerCustom => 'Свой';

  @override
  String get equalizerBands => 'Частотные полосы';

  @override
  String get equalizerBassBoost => 'Усиление баса';

  @override
  String get equalizerBassUnsupported =>
      'Дополнительное усиление баса не поддерживается. Используй низкочастотные полосы.';

  @override
  String get equalizerPreamp => 'Предусиление';

  @override
  String get equalizerHeadroom => 'Автоматический запас';

  @override
  String get equalizerHeadroomDescription =>
      'Снижает громкость при усилении частот, оставляя запас для пиков. Это не лимитер.';

  @override
  String get equalizerWaiting =>
      'Запусти трек, чтобы подключить эквалайзер к его аудиосессии.';

  @override
  String get equalizerUnsupported =>
      'Обработка звука пока доступна только на Android.';

  @override
  String get equalizerFailed =>
      'Устройство не смогло включить аудиоэффекты. Музыка может играть без них.';

  @override
  String get equalizerRetry => 'Подключить эффекты снова';

  @override
  String get equalizerLive =>
      'Изменения слышны сразу и сохраняются на этом устройстве.';

  @override
  String get youtubeAccount => 'YouTube и MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'Доступ только для чтения плейлистов. Вход не гарантирует доступность аудио.';

  @override
  String get youtubeAccountCompatibility =>
      'Совместимость и конфиденциальность';

  @override
  String get youtubeAccountSubtitle =>
      'Подключение аккаунта и импорт плейлистов';

  @override
  String get youtubeAccountPrivacy =>
      'Hook запрашивает доступ только для чтения YouTube. Пароль вводится только в системном окне Google, не в Hook. Токен не передаётся серверу Hook и хранится только в памяти. После перезапуска приложения потребуется подключиться снова.';

  @override
  String get youtubeAccountPlaybackNotice =>
      'Вход даёт доступ к данным аккаунта, а не к аудиопотокам. Он не гарантирует устранение ошибки 403. Импорт сохраняет записи YouTube, не подменяя их другим источником.';

  @override
  String get youtubeAccountConnect => 'Подключить аккаунт';

  @override
  String get youtubeAccountDisconnect => 'Отключить в Hook';

  @override
  String get youtubeAccountDisconnected => 'Аккаунт не подключён';

  @override
  String get youtubeAccountDisconnectNotice =>
      'Отключить аккаунт только в Hook? Сохранённые плейлисты останутся. Выход из Google и MicroG на телефоне не выполняется.';

  @override
  String get youtubeAccountSystem => 'Системные Google API';

  @override
  String get youtubeAccountServicesMissing =>
      'Совместимые системные Google API недоступны. Отдельный ReVanced GmsCore не заменяет их для входа в Hook.';

  @override
  String get youtubeAccountMicrogNotice =>
      'ReVanced GmsCore обнаружен отдельно. Hook не использует аккаунты и токены ReVanced. Системный MicroG может обслуживать совместимые Google API, но его совместимость с этим способом входа не гарантируется.';

  @override
  String get youtubeAccountRevancedFound => 'YouTube Music ReVanced установлен';

  @override
  String get youtubeAccountPlaylists => 'Плейлисты аккаунта';

  @override
  String get youtubeAccountNoPlaylists =>
      'Доступных плейлистов нет. Некоторые автоматические подборки YouTube Music не доступны через YouTube Data API.';

  @override
  String get youtubeAccountMore => 'Загрузить ещё';

  @override
  String get youtubeAccountPreview => 'Подготовить импорт';

  @override
  String youtubeAccountProgress(int count) {
    return 'Получено треков: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'Недоступных записей пропущено: $count. Они не заменяются другими треками.';
  }

  @override
  String get youtubeAccountSetup => 'Настройка входа';

  @override
  String get youtubeAccountSetupBody =>
      'Разработчику необходимо включить YouTube Data API v3 в Google Cloud, создать OAuth-клиент Android для com.hook.music с SHA-1 ключа установленной сборки и настроить экран согласия. Для режима тестирования добавить разрешённых пользователей. Инструкция: docs/YOUTUBE_ACCOUNT_SETUP.md. Пароль, client_secret и чужие токены в приложение не добавляются.';

  @override
  String get youtubeAccountConfigError =>
      'Вход не настроен для этой сборки. Проверьте OAuth-клиент Android, package name, SHA-1 и разрешённых тестовых пользователей в Google Cloud.';

  @override
  String get youtubeAccountPermissionError =>
      'Не получено разрешение на чтение данных YouTube.';

  @override
  String get youtubeAccountExpired =>
      'Сессия истекла. Подключите аккаунт снова.';

  @override
  String get youtubeAccountNoChannel =>
      'У выбранного аккаунта нет доступного канала YouTube.';

  @override
  String get youtubeAccountQuota =>
      'Лимит YouTube API исчерпан. Попробуйте позже.';

  @override
  String get youtubeAccountFailed =>
      'Не удалось получить данные YouTube. Проверьте подключение и повторите попытку.';

  @override
  String get youtubeAccountUnsupported =>
      'Подключение аккаунта поддерживается только на Android с совместимыми системными Google API.';

  @override
  String get importedFromYouTube => 'Импорт из аккаунта YouTube';

  @override
  String get translateLyrics => 'Перевести текст';

  @override
  String get hideTranslation => 'Скрыть перевод';

  @override
  String get cancelTranslation => 'Отменить перевод';

  @override
  String get translationLoading => 'Подготовка перевода…';

  @override
  String get translationAttribution =>
      'Автоматический перевод: Google Translate';

  @override
  String get translationNotice =>
      'Перевод может неточно передавать смысл песни. Подсветка слов относится только к оригиналу.';

  @override
  String get translationModelTitle => 'Скачать языковую модель?';

  @override
  String get translationModelBody =>
      'Перевод выполняется на телефоне: текст песни не отправляется на сервер. Для первого перевода нужны модели Google ML Kit — десятки мегабайт. Загрузка использует текущее подключение, в том числе мобильный интернет. Отмена скроет результат, но начатая загрузка модели может завершиться в фоне.';

  @override
  String get translationDownload => 'Скачать и перевести';

  @override
  String get translationUnavailable =>
      'Перевод не выполнен. Проверьте доступ к загрузке моделей и попробуйте ещё раз.';

  @override
  String get translationUnsupported =>
      'Перевод на устройстве пока доступен только на Android.';

  @override
  String get translationUnknownLanguage =>
      'Не удалось определить поддерживаемый язык песни.';

  @override
  String get translationSameLanguage => 'Текст уже на выбранном языке.';

  @override
  String get translationTooLarge =>
      'Текст слишком длинный для перевода на устройстве.';

  @override
  String get translationRussian => 'На русский';

  @override
  String get translationEnglish => 'На английский';

  @override
  String get translationTarget => 'Язык перевода';

  @override
  String get retry => 'Повторить';

  @override
  String get home => 'Главная';

  @override
  String get search => 'Поиск';

  @override
  String get library => 'Медиатека';

  @override
  String get youtubeUnavailableTitle => 'YouTube сейчас недоступен';

  @override
  String get youtubeUnavailableBody =>
      'Не удалось получить аудиопоток. Проверьте сеть и маршрут VPN: YouTube может отклонять запросы даже с VPN.';

  @override
  String get checkAgain => 'Проверить снова';

  @override
  String get dismiss => 'Закрыть';

  @override
  String get goodNight => 'Доброй ночи';

  @override
  String get goodMorning => 'Доброе утро';

  @override
  String get goodAfternoon => 'Добрый день';

  @override
  String get goodEvening => 'Добрый вечер';

  @override
  String get themeSettings => 'Настройки оформления';

  @override
  String get onYourAir => 'В вашем эфире';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count последних сигнала',
      many: '$count последних сигналов',
      few: '$count последних сигнала',
      one: '$count последний сигнал',
      zero: 'Нет последних сигналов',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'Коллекция ждёт';

  @override
  String get saved => 'Сохранённые';

  @override
  String get collectionEmptyDetail =>
      'Здесь останется то, к чему хочется вернуться';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count трека',
      many: '$count треков',
      few: '$count трека',
      one: '$count трек',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'Трек, артист или слова песни';

  @override
  String get searchUpper => 'ПОИСК';

  @override
  String get findFirstTrack => 'Найдите первый трек';

  @override
  String continuationAfter(String artist) {
    return 'Продолжение после $artist';
  }

  @override
  String get chooseTrackWaveDetail =>
      'Выберите трек — и соберём волну в его настроении.';

  @override
  String get continueWaveLabel => 'ПРОДОЛЖИМ / 01';

  @override
  String get yourWaveLabel => 'ВАША ВОЛНА / 01';

  @override
  String get continueWave => 'Продолжить волну';

  @override
  String get chooseTrack => 'Выбрать трек';

  @override
  String get firstTrace => 'Оставьте здесь первый след';

  @override
  String get favoriteWaveHint =>
      'Добавляйте любимые треки — и ваша волна станет точнее.';

  @override
  String get openSearch => 'Открыть поиск';

  @override
  String get findYourMusic => 'Найти своё.';

  @override
  String get importMusic => 'Импорт музыки';

  @override
  String get rememberedLyricsHint => 'Слова, которые запомнились…';

  @override
  String get trackArtistHint => 'Трек, артист — можно по-русски';

  @override
  String get clear => 'Очистить';

  @override
  String get music => 'Музыка';

  @override
  String get byLyrics => 'По тексту';

  @override
  String get allSources => 'Все источники';

  @override
  String get lyricsSearchCaption =>
      'Ищем фразу в песне, а не только в названии.';

  @override
  String get searchingLyrics => 'Ищем знакомые строки…';

  @override
  String get searchingSources => 'Собираем музыку из источников…';

  @override
  String get connectionFailed => 'Не удалось связаться';

  @override
  String get noMatches => 'Пока без совпадений';

  @override
  String get lyricsUnavailable =>
      'Сервис поиска по тексту сейчас недоступен. Попробуйте позже или ищите по названию.';

  @override
  String get searchUnavailable =>
      'Не удалось выполнить поиск. Проверьте соединение и попробуйте ещё раз.';

  @override
  String get lyricsNoMatches =>
      'Попробуйте другую строчку. Не все тексты есть в индексе.';

  @override
  String get trackNoMatches =>
      'Уточните исполнителя или выберите другой источник. Часть сервисов может быть недоступна в вашей сети.';

  @override
  String get repeatSearch => 'Повторить поиск';

  @override
  String get lyricMatchesUpper => 'СОВПАДЕНИЯ ПО ТЕКСТУ';

  @override
  String get tracksUpper => 'ТРЕКИ';

  @override
  String playTrack(String title, String artist) {
    return 'Воспроизвести $title, $artist';
  }

  @override
  String get familiarLinesUpper => 'ЗНАКОМЫЕ СТРОКИ';

  @override
  String get bestMatchUpper => 'ЛУЧШЕЕ СОВПАДЕНИЕ';

  @override
  String get fullVersionOnPlayback =>
      'Полную версию подберём при воспроизведении.';

  @override
  String get forgotTitle => 'Название забыли.\nМузыку — нет.';

  @override
  String get startAsYouRemember =>
      'Имя на слух, название или строчка из песни.\nНачните так, как помните.';

  @override
  String get foreignNameExample => 'Мартин роз';

  @override
  String get foreignNamesCaption => 'Иностранные имена — русскими буквами';

  @override
  String get rememberOnlyLine => 'Помню только строчку';

  @override
  String get findSongByWords => 'Найти песню по словам';

  @override
  String get yourArtistsUpper => 'ВАШИ АРТИСТЫ';

  @override
  String get language => 'Язык';

  @override
  String get languageCaption => 'Интерфейс меняется сразу после выбора';

  @override
  String get systemLanguage => 'Системный';

  @override
  String get russian => 'Русский';

  @override
  String get english => 'English';

  @override
  String get themesAndShaders => 'Темы и эффекты';

  @override
  String get themesSubtitle => 'Оформление, язык и движение фона';

  @override
  String get invalidThemeJson =>
      'Не удалось прочитать тему. Проверьте формат JSON и значения полей.';

  @override
  String get exportJson => 'Экспорт JSON';

  @override
  String get importJson => 'Импорт JSON';

  @override
  String get readyThemes => 'Готовые темы';

  @override
  String get gpuShaders => 'Эффекты фона';

  @override
  String get meshGradient => 'Плавный GPU-градиент по цветам трека';

  @override
  String get vinylNoise => 'Аналоговое виниловое зерно (Noise)';

  @override
  String get glassBlur => 'Размытие стекла (Backdrop Blur)';

  @override
  String get cornerRadius => 'Скругление элементов интерфейса';

  @override
  String get importThemeTitle => 'Импорт темы из JSON';

  @override
  String get pasteThemeJson => 'Вставьте конфигурационный JSON темы:';

  @override
  String get cancel => 'Отмена';

  @override
  String get apply => 'Применить';

  @override
  String get themeApplied => 'Тема успешно применена!';

  @override
  String get exportThemeTitle => 'Экспорт темы (JSON)';

  @override
  String get close => 'Закрыть';

  @override
  String get copyJson => 'Скопировать JSON';

  @override
  String get jsonCopied => 'JSON темы скопирован в буфер!';

  @override
  String get libraryUpper => 'МЕДИАТЕКА';

  @override
  String get localCollection => 'Локальная коллекция и плейлисты';

  @override
  String get importShort => 'Импорт';

  @override
  String get favorites => 'Избранное';

  @override
  String get playlists => 'Плейлисты';

  @override
  String get history => 'История';

  @override
  String get offline => 'Офлайн';

  @override
  String get favoritesEmpty =>
      'В избранном пока пусто.\nНажмите ❤️ на треке, чтобы добавить его сюда.';

  @override
  String get historyEmpty =>
      'История прослушиваний пуста.\nВключайте треки в поиске, чтобы они появились здесь!';

  @override
  String get noPlaylists => 'У вас пока нет плейлистов';

  @override
  String get importPlaylistHint =>
      'Импортируйте плейлист из Spotify или список треков!';

  @override
  String get importMusicAction => 'Импортировать музыку';

  @override
  String get playPlaylist => 'Слушать плейлист';

  @override
  String playlistStarted(String name, int count) {
    return 'Включен плейлист «$name» ($count треков)';
  }

  @override
  String get deletePlaylist => 'Удалить плейлист';

  @override
  String get playAll => 'Слушать всё';

  @override
  String get shuffle => 'Перемешать';

  @override
  String get localAudioCache => 'Локальный аудио-кэш';

  @override
  String get cacheDescription =>
      'Прослушанные треки автоматически сохраняются в локальное хранилище для мгновенного повторного воспроизведения без интернета.';

  @override
  String deviceUsage(String size) {
    return 'Занято на устройстве: $size';
  }

  @override
  String get clearCache => 'Очистить весь кэш';

  @override
  String savedTracksUpper(int count) {
    return 'СОХРАНЁННЫЕ ТРЕКИ ($count):';
  }

  @override
  String get cacheFeaturesUpper => 'СВОЙСТВА КЭША:';

  @override
  String get offlineFirst => 'Полный Offline-First';

  @override
  String get offlineFirstDescription =>
      'При повторном запуске аудио проигрывается напрямую из файловой системы устройства.';

  @override
  String get maximumBitrate => 'Максимальный битрейт';

  @override
  String get maximumBitrateDescription =>
      'Кэшируются чистые аудиопотоки Opus/M4A 160–256 kbps без перекодирования.';

  @override
  String get trafficAndBattery => 'Экономия трафика и батареи';

  @override
  String get trafficAndBatteryDescription =>
      'Отсутствие повторных сетевых запросов продлевает время работы смартфона.';

  @override
  String get cacheEmpty => 'Кэш пока пуст';

  @override
  String get cachedTracksAppear =>
      'Скачанные треки появятся здесь автоматически';

  @override
  String get removeFromCache => 'Удалить из кэша';

  @override
  String get removeCachedTrackTitle => 'Удалить трек из кэша?';

  @override
  String removeCachedTrackBody(String title) {
    return '«$title» будет удалён с устройства.';
  }

  @override
  String get delete => 'Удалить';

  @override
  String get trackRemovedFromCache => 'Трек удалён из кэша';

  @override
  String get clearCacheTitle => 'Очистить кэш?';

  @override
  String get clearCacheBody =>
      'Все сохранённые аудиофайлы будут удалены с устройства. Избранное и история останутся без изменений.';

  @override
  String get cacheCleared => 'Локальный кэш очищен';

  @override
  String get back => 'Назад';

  @override
  String get playlistActions => 'Действия с плейлистом';

  @override
  String get playlistUpper => 'ПЛЕЙЛИСТ';

  @override
  String get playlistEmpty => 'В этом плейлисте пока нет треков';

  @override
  String get pasteTrackList => 'Вставьте список треков';

  @override
  String get pasteImportLink => 'Вставьте ссылку для импорта';

  @override
  String get tracksNotFound => 'Не удалось найти треки по указанной ссылке.';

  @override
  String get importError =>
      'Ошибка импорта: проверьте ссылку и интернет-соединение.';

  @override
  String importedPlaylistStarted(int count) {
    return 'Включен импортированный плейлист ($count треков)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'Импорт ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return 'Плейлист «$name» сохранен в медиатеку!';
  }

  @override
  String get spotifyImportSubtitle => 'Spotify • Плейлисты, альбомы и треки';

  @override
  String get artistTrackOrCsv => 'Артист — Трек или CSV из Exportify';

  @override
  String get pastePlaylistOrTrackLink => 'Вставьте ссылку на плейлист или трек';

  @override
  String get pasteFromClipboard => 'Вставить из буфера';

  @override
  String get link => 'Ссылка';

  @override
  String get trackList => 'Список треков';

  @override
  String get playlistName => 'Название плейлиста';

  @override
  String get startImport => 'Начать импорт';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count треков';
  }

  @override
  String get importedFromSpotify => 'Импортировано из Spotify';

  @override
  String get importedFromDeezer => 'Импортировано с Deezer';

  @override
  String get importIntro =>
      'Заберите плейлисты с собой. По ссылке Spotify, списком треков или файлом из Exportify.';

  @override
  String get importTextTab => 'Текст';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'Выбрать файл';

  @override
  String get importFileHint =>
      'Выберите CSV из Exportify или TXT со списком треков. Кодировка UTF-8, до 10 МБ и 10 000 треков.';

  @override
  String get importFileAndroidOnly =>
      'Выбор файла доступен на Android. Здесь можно вставить содержимое CSV или список треков.';

  @override
  String get importTextHint =>
      'По одному «Артист — Трек» на строку. Можно вставить CSV целиком, вместе с заголовками.';

  @override
  String get importPreview => 'Посмотреть треки';

  @override
  String get importedFromCsv => 'Импортировано из CSV';

  @override
  String get importedFromText => 'Импортировано из списка треков';

  @override
  String importMoreTracks(int count) {
    return 'И ещё $count';
  }

  @override
  String get importMetadataHint =>
      'Плейлист сохранится на устройстве. Аудио подберём при воспроизведении — импорт не скачивает песни.';

  @override
  String get importAnother => 'Импортировать другое';

  @override
  String get importReading => 'Читаем плейлист…';

  @override
  String get importSaving => 'Сохраняем в медиатеку…';

  @override
  String get importNameRequired => 'Введите название плейлиста.';

  @override
  String get importNameExists =>
      'Плейлист с таким именем уже есть. Выберите другое имя, чтобы сохранить оба.';

  @override
  String get importSaveFailed =>
      'Не удалось сохранить плейлист. Предпросмотр остался — попробуйте ещё раз.';

  @override
  String get importFileTooLarge =>
      'Файл больше 10 МБ. Разделите плейлист на несколько файлов.';

  @override
  String get importFileUnsupported => 'Выберите файл .csv или .txt.';

  @override
  String get importFileEncoding =>
      'Не удалось прочитать кодировку. Сохраните файл в UTF-8 и попробуйте ещё раз.';

  @override
  String get importCsvInvalid =>
      'CSV повреждён или обрезан. Экспортируйте его заново, не меняя столбцы и кавычки.';

  @override
  String get importCsvMissingColumns =>
      'В CSV нужны столбцы Track Name и Artist Name(s) либо Title и Artist. Выберите исходный файл Exportify.';

  @override
  String get importFileEmpty =>
      'Треки не найдены. Выберите непустой экспорт или вставьте список «Артист — Трек».';

  @override
  String get importTooManyTracks =>
      'За один раз можно импортировать до 10 000 треков. Разделите плейлист — пока ничего не сохранено.';

  @override
  String get importFileReadFailed =>
      'Не удалось открыть файл. Проверьте, что он доступен на устройстве, и выберите его ещё раз.';

  @override
  String get importSpotifyBlocked =>
      'Spotify не отдал плейлист в вашем регионе. Экспортируйте его через Exportify и выберите CSV-файл.';

  @override
  String get listen => 'Слушать';

  @override
  String get addToPlaylists => 'В плейлисты';

  @override
  String trackSemantics(String title, String artist) {
    return 'Трек $title, $artist';
  }

  @override
  String get trackActions => 'Действия с треком';

  @override
  String get updatesTitle => 'Обновления';

  @override
  String get accountTitle => 'Аккаунт';

  @override
  String get waveLoading => 'Подбираем похожие треки…';

  @override
  String get accountCaption => 'Синхронизация библиотеки между устройствами';

  @override
  String get nickname => 'Ник';

  @override
  String get nicknameHint => '3–20 символов: буквы, цифры, . _ -';

  @override
  String get password => 'Пароль';

  @override
  String get passwordMinHint => 'Минимум 6 символов';

  @override
  String get signIn => 'Войти';

  @override
  String get signUp => 'Создать аккаунт';

  @override
  String get haveAccountToggle => 'Уже есть аккаунт? Войти';

  @override
  String get noAccountToggle => 'Нет аккаунта? Создать';

  @override
  String get signOut => 'Выйти';

  @override
  String get syncNow => 'Синхронизировать';

  @override
  String get syncing => 'Синхронизация…';

  @override
  String syncedAt(String time) {
    return 'Синхронизировано: $time';
  }

  @override
  String get neverSynced => 'Ещё не синхронизировалось';

  @override
  String get errorNicknameTaken => 'Такой ник уже занят';

  @override
  String get errorNicknameInvalid => 'Ник: 3–20 символов, буквы/цифры/._-';

  @override
  String get errorInvalidCredentials => 'Неверный ник или пароль';

  @override
  String get errorWeakPassword => 'Пароль слишком короткий';

  @override
  String get errorNetwork => 'Нет соединения';

  @override
  String get errorServer => 'Ошибка сервера, попробуйте позже';

  @override
  String currentVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get checkForUpdates => 'Проверить обновления';

  @override
  String get checkingForUpdates => 'Проверяем…';

  @override
  String get upToDate => 'Установлена последняя версия';

  @override
  String updateAvailable(String version) {
    return 'Доступна версия $version';
  }

  @override
  String get downloadingUpdate => 'Скачивание обновления…';

  @override
  String get installUpdate => 'Установить';

  @override
  String get updateCheckFailed =>
      'Не удалось проверить обновления. Проверьте интернет.';

  @override
  String get installPermissionNeeded =>
      'Разрешите Hook установку приложений и нажмите «Установить» снова.';

  @override
  String updateSize(String size) {
    return '$size МБ';
  }

  @override
  String get download => 'Скачать';

  @override
  String get downloading => 'Скачивание…';

  @override
  String get downloaded => 'Скачано';

  @override
  String get downloadFailed => 'Не удалось скачать';

  @override
  String get removeDownload => 'Удалить загрузку';

  @override
  String get downloadSavedOffline => 'Сохранено офлайн';

  @override
  String get startWaveFromTrack => 'Запустить волну по треку';

  @override
  String get addToQueue => 'Добавить в очередь';

  @override
  String addedToQueue(String title) {
    return 'Добавлено в очередь: $title';
  }

  @override
  String get removeFavorite => 'Убрать из избранного';

  @override
  String get addFavorite => 'Добавить в избранное';

  @override
  String get addToPlaylist => 'Добавить в плейлист';

  @override
  String get goToArtist => 'Перейти к исполнителю';

  @override
  String get myPlaylist => 'Мой плейлист';

  @override
  String get newPlaylist => 'Новый плейлист';

  @override
  String get name => 'Название';

  @override
  String get create => 'Создать';

  @override
  String get loading => 'Загрузка…';

  @override
  String get pause => 'Пауза';

  @override
  String get play => 'Играть';

  @override
  String get next => 'Следующий';

  @override
  String get speedAndPitch => 'Скорость и тональность';

  @override
  String speedValue(String value) {
    return 'Скорость: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'Высота тона: ${value}x';
  }

  @override
  String get reset => 'Сброс';

  @override
  String get moreActions => 'Дополнительные действия';

  @override
  String get playbackQueue => 'Очередь воспроизведения';

  @override
  String get queueEmpty => 'Очередь пуста';

  @override
  String get selectingSource => 'Подбор источника';

  @override
  String get collapsePlayer => 'Свернуть плеер';

  @override
  String get nowPlayingUpper => 'СЕЙЧАС ИГРАЕТ';

  @override
  String get queue => 'Очередь';

  @override
  String get startWave => 'Запустить волну';

  @override
  String get cover => 'Обложка';

  @override
  String get karaokeLyrics => 'Текст караоке';

  @override
  String get findMusicStart => 'Найдите музыку и начните воспроизведение';

  @override
  String get playbackNotStarted => 'Воспроизведение ещё не началось';

  @override
  String get openSearchFirstTrack => 'Откройте поиск, чтобы найти первый трек';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => 'На устройстве';

  @override
  String get sourceCatalog => 'Каталог';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'Сервер';

  @override
  String get serverResolver => 'Резолвер-сервер';

  @override
  String get serverResolverCaption =>
      'Необязательный собственный сервер, который находит полные аудиопотоки. Приложение отправляет поисковый запрос или ID трека, сервер возвращает ссылку на воспроизведение. Контракт и пример реализации — в docs/REMOTE_RESOLVER.md.';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'Не настроен';

  @override
  String get serverSave => 'Сохранить';

  @override
  String get serverDisable => 'Отключить';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать в Hook';

  @override
  String get onboardingWelcomeCaption =>
      'Музыка, тексты и свой визуальный стиль. Выберите язык, чтобы начать — его можно поменять в настройках.';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get onboardingMicrogTitle => 'MicroG и аккаунт Google';

  @override
  String get onboardingMicrogBody =>
      'MicroG воссоздаёт сервисы Google на кастомных прошивках Android, где их нет. Hook использует эти сервисы только для одной необязательной функции — подключения аккаунта YouTube ради импорта плейлистов. Воспроизведению музыки MicroG и любые сервисы Google не нужны.';

  @override
  String get onboardingMicrogNote =>
      'Воспроизведение не зависит от MicroG. Подключение аккаунта — необязательный шаг.';

  @override
  String get onboardingMicrogDownload => 'Скачать MicroG';

  @override
  String get onboardingMicrogStatusChecking => 'Проверяем сервисы Google…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'Сервисы Google есть на устройстве ($version). Импорт аккаунта заработает сразу.';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'Обнаружен ReVanced GmsCore ($version). Официальный SDK входа Google с ним несовместим, поэтому подключение аккаунта может не заработать. На воспроизведение это не влияет.';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'Сервисы Google не найдены. Чтобы импортировать плейлисты из аккаунта YouTube, сначала установите MicroG — либо пропустите и пользуйтесь Hook без аккаунта.';

  @override
  String lyricsView(String mode) {
    return 'Вид текста · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'Ваш ритм чтения';

  @override
  String get lyricsModeSubtitle => 'Три способа быть ближе к песне.';

  @override
  String get lyricsModeLines => 'Строки';

  @override
  String get lyricsModeKaraoke => 'Караоке';

  @override
  String get lyricsModeFocus => 'Фокус';

  @override
  String get lyricsModeLinesDescription =>
      'Спокойный текст, подсветка текущей строки';

  @override
  String get lyricsModeKaraokeDescription =>
      'Плавная подсветка слов в ритме вокала';

  @override
  String get lyricsModeFocusDescription =>
      'Одна крупная строка. Ничего лишнего';

  @override
  String get lyricsModeSaveFailed => 'Не удалось сохранить вид текста.';

  @override
  String get lyricsModeFootnote =>
      'Выбор сохранится для следующих песен. Точность караоке зависит от данных: без пословных меток подсветка слов приблизительная, без временных меток текст остаётся неподвижным.';

  @override
  String get lyricsNotFound => 'Текст песни не найден';

  @override
  String get karaokeUnavailable => 'Текст караоке отсутствует для этого трека';

  @override
  String get unsyncedLyrics => 'Текст без синхронизации';

  @override
  String get wordSyncUpper => 'ПОСЛОВНАЯ СИНХРОНИЗАЦИЯ';

  @override
  String get lineSyncUpper => 'ПОСТРОЧНАЯ СИНХРОНИЗАЦИЯ';

  @override
  String get adjustLyricsSync => 'Настроить синхронизацию текста';

  @override
  String get startsSoon => 'Скоро начнётся';

  @override
  String get musicContinues => 'Музыка продолжается';

  @override
  String get decreaseLyricsOffset => 'Уменьшить сдвиг на 0.1 с';

  @override
  String lyricsOffset(String value) {
    return 'Сдвиг: $value с';
  }

  @override
  String get increaseLyricsOffset => 'Увеличить сдвиг на 0.1 с';

  @override
  String get hideSetting => 'Скрыть настройку';

  @override
  String get lyricsOffsetSaveFailed => 'Не удалось сохранить сдвиг текста.';

  @override
  String get audioForbidden =>
      'Сервер аудио отклонил доступ (HTTP 403). Трек найден, но поток недоступен. VPN не гарантирует доступ к аудио.';

  @override
  String get fullVersionUnavailable =>
      'Полная версия не найдена в доступных источниках. Проверьте сеть или попробуйте позже.';

  @override
  String sourcePlaybackFailed(String source) {
    return 'Источник $source не смог воспроизвести трек. Проверьте сеть или попробуйте позже.';
  }

  @override
  String get recentQueriesUpper => 'НЕДАВНИЕ ЗАПРОСЫ';

  @override
  String get clearHistory => 'Очистить';

  @override
  String get waveFromArtist => 'Волна от артиста';

  @override
  String get popularTracksUpper => 'ПОПУЛЯРНЫЕ ТРЕКИ';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count трека',
      many: '$count треков',
      few: '$count трека',
      one: '$count трек',
      zero: 'пока нет треков',
    );
    return '$_temp0';
  }
}
