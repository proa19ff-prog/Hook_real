// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'Ajustes';

  @override
  String get settingsCaption => 'Los cambios se guardan en este dispositivo.';

  @override
  String get playerSettings => 'Reproductor';

  @override
  String get lyricsAutoHide => 'Ocultar controles al leer la letra';

  @override
  String get lyricsAutoHideDescription =>
      'Tras 10 segundos sin interacción, los paneles del reproductor se deslizan fuera de la vista. Usa el botón de restaurar para traerlos de vuelta.';

  @override
  String get showPlayerControls => 'Mostrar controles del reproductor';

  @override
  String get equalizer => 'Ecualizador';

  @override
  String get equalizerEnabled => 'Procesamiento de sonido';

  @override
  String get equalizerPresets => 'Perfil de sonido';

  @override
  String get equalizerFlat => 'Original';

  @override
  String get equalizerBass => 'Graves profundos';

  @override
  String get equalizerVocal => 'Voces';

  @override
  String get equalizerRock => 'Rock';

  @override
  String get equalizerElectronic => 'Electrónica';

  @override
  String get equalizerSoft => 'Suave';

  @override
  String get equalizerCustom => 'Personalizado';

  @override
  String get equalizerBands => 'Bandas de frecuencia';

  @override
  String get equalizerBassBoost => 'Realce de graves';

  @override
  String get equalizerBassUnsupported =>
      'El realce de graves adicional no es compatible. Usa las bandas de baja frecuencia.';

  @override
  String get equalizerPreamp => 'Preamplificación';

  @override
  String get equalizerHeadroom => 'Margen automático';

  @override
  String get equalizerHeadroomDescription =>
      'Reduce el nivel de salida al realzar frecuencias para dejar espacio a los picos. No es un limitador.';

  @override
  String get equalizerWaiting =>
      'Reproduce una pista para conectar el ecualizador a su sesión de audio.';

  @override
  String get equalizerUnsupported =>
      'El procesamiento de sonido solo está disponible en Android por ahora.';

  @override
  String get equalizerFailed =>
      'Este dispositivo no pudo activar los efectos de audio. La música puede sonar sin ellos.';

  @override
  String get equalizerRetry => 'Reconectar efectos';

  @override
  String get equalizerLive =>
      'Los cambios se aplican al instante y se guardan en este dispositivo.';

  @override
  String get youtubeAccount => 'YouTube y MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'Acceso de solo lectura a listas. Iniciar sesión no garantiza la disponibilidad del audio.';

  @override
  String get youtubeAccountCompatibility => 'Compatibilidad y privacidad';

  @override
  String get youtubeAccountSubtitle =>
      'Conexión de cuenta e importación de listas';

  @override
  String get youtubeAccountPrivacy =>
      'Hook solicita acceso de solo lectura a YouTube. Introduce tu contraseña solo en el diálogo del sistema de Google, nunca en Hook. El token no se envía a ningún servidor de Hook y se conserva solo en memoria. Vuelve a conectar tras reiniciar la app.';

  @override
  String get youtubeAccountPlaybackNotice =>
      'Iniciar sesión da acceso a los datos de la cuenta, no a los flujos de audio. No garantiza una solución al HTTP 403. Las importaciones conservan las grabaciones de YouTube sin sustituirlas por otra fuente.';

  @override
  String get youtubeAccountConnect => 'Conectar cuenta';

  @override
  String get youtubeAccountDisconnect => 'Desconectar en Hook';

  @override
  String get youtubeAccountDisconnected => 'Sin cuenta conectada';

  @override
  String get youtubeAccountDisconnectNotice =>
      '¿Desconectar esta cuenta solo en Hook? Las listas guardadas permanecerán. Las cuentas de Google y MicroG del teléfono no se cerrarán.';

  @override
  String get youtubeAccountSystem => 'APIs de Google del sistema';

  @override
  String get youtubeAccountServicesMissing =>
      'No hay APIs de Google del sistema compatibles. Una instalación aparte de ReVanced GmsCore no las sustituye para el inicio de sesión de Hook.';

  @override
  String get youtubeAccountMicrogNotice =>
      'Se detectó una instalación aparte de ReVanced GmsCore. Hook no usa cuentas ni tokens de ReVanced. Un MicroG del sistema puede ofrecer APIs de Google compatibles, pero la compatibilidad con este método de inicio de sesión no está garantizada.';

  @override
  String get youtubeAccountRevancedFound =>
      'YouTube Music ReVanced está instalado';

  @override
  String get youtubeAccountPlaylists => 'Listas de la cuenta';

  @override
  String get youtubeAccountNoPlaylists =>
      'No hay listas accesibles. Algunas colecciones automáticas de YouTube Music no están disponibles a través de la YouTube Data API.';

  @override
  String get youtubeAccountMore => 'Cargar más';

  @override
  String get youtubeAccountPreview => 'Preparar importación';

  @override
  String youtubeAccountProgress(int count) {
    return 'Pistas obtenidas: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'Entradas no disponibles omitidas: $count. No se sustituyen por otras pistas.';
  }

  @override
  String get youtubeAccountSetup => 'Configuración del inicio de sesión';

  @override
  String get youtubeAccountSetupBody =>
      'El desarrollador debe habilitar YouTube Data API v3 en Google Cloud, registrar un cliente OAuth de Android para com.hook.music y el SHA-1 de firma de la compilación instalada, y configurar la pantalla de consentimiento. Añade los usuarios permitidos en modo de pruebas. Consulta docs/YOUTUBE_ACCOUNT_SETUP.md. Nunca añadas contraseñas, secretos de cliente ni tokens de otras apps.';

  @override
  String get youtubeAccountConfigError =>
      'El inicio de sesión no está configurado para esta compilación. Revisa el cliente OAuth de Android, el nombre del paquete, el SHA-1 y los usuarios de prueba permitidos en Google Cloud.';

  @override
  String get youtubeAccountPermissionError =>
      'No se concedió el acceso de lectura a los datos de YouTube.';

  @override
  String get youtubeAccountExpired =>
      'Tu sesión ha caducado. Vuelve a conectar la cuenta.';

  @override
  String get youtubeAccountNoChannel =>
      'La cuenta seleccionada no tiene un canal de YouTube accesible.';

  @override
  String get youtubeAccountQuota =>
      'Cuota de la API de YouTube superada. Inténtalo más tarde.';

  @override
  String get youtubeAccountFailed =>
      'No se pudieron obtener los datos de YouTube. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get youtubeAccountUnsupported =>
      'La conexión de cuenta requiere Android con APIs de Google del sistema compatibles.';

  @override
  String get importedFromYouTube => 'Importado de la cuenta de YouTube';

  @override
  String get translateLyrics => 'Traducir letra';

  @override
  String get hideTranslation => 'Ocultar traducción';

  @override
  String get cancelTranslation => 'Cancelar traducción';

  @override
  String get translationLoading => 'Preparando traducción…';

  @override
  String get translationAttribution =>
      'Traducido automáticamente por Google Translate';

  @override
  String get translationNotice =>
      'La traducción puede no captar con exactitud el significado de la canción. El resaltado de palabras se aplica solo al original.';

  @override
  String get translationModelTitle => '¿Descargar modelos de idioma?';

  @override
  String get translationModelBody =>
      'La traducción se ejecuta en tu teléfono: la letra no se envía a ningún servidor. La primera traducción necesita los modelos de Google ML Kit, que ocupan decenas de megabytes. La descarga usa tu conexión actual, incluidos los datos móviles. Cancelar oculta el resultado, pero una descarga ya iniciada puede terminar en segundo plano.';

  @override
  String get translationDownload => 'Descargar y traducir';

  @override
  String get translationUnavailable =>
      'Falló la traducción. Comprueba el acceso a las descargas de modelos e inténtalo de nuevo.';

  @override
  String get translationUnsupported =>
      'La traducción en el dispositivo solo está disponible en Android por ahora.';

  @override
  String get translationUnknownLanguage =>
      'No se pudo identificar un idioma compatible para esta canción.';

  @override
  String get translationSameLanguage =>
      'La letra ya está en el idioma seleccionado.';

  @override
  String get translationTooLarge =>
      'Esta letra es demasiado larga para la traducción en el dispositivo.';

  @override
  String get translationRussian => 'Al ruso';

  @override
  String get translationEnglish => 'Al inglés';

  @override
  String get translationTarget => 'Idioma de traducción';

  @override
  String get retry => 'Reintentar';

  @override
  String get home => 'Inicio';

  @override
  String get search => 'Buscar';

  @override
  String get library => 'Biblioteca';

  @override
  String get youtubeUnavailableTitle =>
      'YouTube no está disponible ahora mismo';

  @override
  String get youtubeUnavailableBody =>
      'No se pudo obtener un flujo de audio. Comprueba tu red y la ruta de la VPN: YouTube puede rechazar solicitudes incluso con VPN.';

  @override
  String get checkAgain => 'Comprobar de nuevo';

  @override
  String get dismiss => 'Descartar';

  @override
  String get goodNight => 'Buenas noches';

  @override
  String get goodMorning => 'Buenos días';

  @override
  String get goodAfternoon => 'Buenas tardes';

  @override
  String get goodEvening => 'Buenas noches';

  @override
  String get themeSettings => 'Ajustes de apariencia';

  @override
  String get onYourAir => 'En tu antena';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count señales recientes',
      one: '1 señal reciente',
      zero: 'Sin señales recientes',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'Tu colección te espera';

  @override
  String get saved => 'Guardado';

  @override
  String get collectionEmptyDetail =>
      'La música a la que quieres volver se quedará aquí';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistas',
      one: '1 pista',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'Pista, artista o letra';

  @override
  String get searchUpper => 'BUSCAR';

  @override
  String get findFirstTrack => 'Encuentra tu primera pista';

  @override
  String continuationAfter(String artist) {
    return 'Más música después de $artist';
  }

  @override
  String get chooseTrackWaveDetail =>
      'Elige una pista y crearemos una onda a partir de su ánimo.';

  @override
  String get continueWaveLabel => 'CONTINUAR / 01';

  @override
  String get yourWaveLabel => 'TU ONDA / 01';

  @override
  String get continueWave => 'Continuar onda';

  @override
  String get chooseTrack => 'Elige una pista';

  @override
  String get firstTrace => 'Deja aquí tu primera huella';

  @override
  String get favoriteWaveHint => 'Guarda favoritos y tu onda será más precisa.';

  @override
  String get openSearch => 'Abrir búsqueda';

  @override
  String get findYourMusic => 'Encuentra tu sonido.';

  @override
  String get importMusic => 'Importar música';

  @override
  String get rememberedLyricsHint => 'Las palabras que recuerdas…';

  @override
  String get trackArtistHint => 'Pista o artista — en cualquier idioma';

  @override
  String get clear => 'Limpiar';

  @override
  String get music => 'Música';

  @override
  String get byLyrics => 'Por letra';

  @override
  String get allSources => 'Todas las fuentes';

  @override
  String get lyricsSearchCaption =>
      'Busca una frase de la canción, no solo su título.';

  @override
  String get searchingLyrics => 'Buscando líneas conocidas…';

  @override
  String get searchingSources => 'Buscando en fuentes de música…';

  @override
  String get connectionFailed => 'No se pudo conectar';

  @override
  String get noMatches => 'Aún no hay coincidencias';

  @override
  String get lyricsUnavailable =>
      'La búsqueda de letras no está disponible ahora. Prueba más tarde o busca por título.';

  @override
  String get searchUnavailable =>
      'Falló la búsqueda. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get lyricsNoMatches =>
      'Prueba con otra línea. No todas las letras están indexadas.';

  @override
  String get trackNoMatches =>
      'Añade el artista o elige otra fuente. Algunos servicios pueden no estar disponibles en tu red.';

  @override
  String get repeatSearch => 'Buscar de nuevo';

  @override
  String get lyricMatchesUpper => 'COINCIDENCIAS DE LETRA';

  @override
  String get tracksUpper => 'PISTAS';

  @override
  String playTrack(String title, String artist) {
    return 'Reproducir $title, $artist';
  }

  @override
  String get familiarLinesUpper => 'LÍNEAS FAMILIARES';

  @override
  String get bestMatchUpper => 'MEJOR COINCIDENCIA';

  @override
  String get fullVersionOnPlayback =>
      'Buscaremos la versión completa cuando empiece la reproducción.';

  @override
  String get forgotTitle => 'Olvidaste el título.\nNo la música.';

  @override
  String get startAsYouRemember =>
      'Un nombre, un título o una línea de la canción.\nEmpieza con lo que recuerdes.';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => 'Busca los nombres como suenan';

  @override
  String get rememberOnlyLine => 'Solo recuerdo una línea';

  @override
  String get findSongByWords => 'Encuentra una canción por sus palabras';

  @override
  String get yourArtistsUpper => 'TUS ARTISTAS';

  @override
  String get language => 'Idioma';

  @override
  String get languageCaption => 'La interfaz sigue tu elección al instante';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get russian => 'Ruso';

  @override
  String get english => 'Inglés';

  @override
  String get themesAndShaders => 'Temas y efectos';

  @override
  String get themesSubtitle => 'Apariencia, idioma y movimiento del fondo';

  @override
  String get invalidThemeJson =>
      'No se pudo leer el tema. Revisa el formato JSON y los valores de los campos.';

  @override
  String get exportJson => 'Exportar JSON';

  @override
  String get importJson => 'Importar JSON';

  @override
  String get readyThemes => 'Temas predefinidos';

  @override
  String get gpuShaders => 'Efectos de fondo';

  @override
  String get meshGradient =>
      'Degradado GPU suave basado en los colores de la pista';

  @override
  String get vinylNoise => 'Grano de vinilo analógico (ruido)';

  @override
  String get glassBlur => 'Desenfoque de cristal (Backdrop Blur)';

  @override
  String get cornerRadius => 'Radio de esquinas de la interfaz';

  @override
  String get importThemeTitle => 'Importar tema desde JSON';

  @override
  String get pasteThemeJson => 'Pega la configuración JSON del tema:';

  @override
  String get cancel => 'Cancelar';

  @override
  String get apply => 'Aplicar';

  @override
  String get themeApplied => '¡Tema aplicado con éxito!';

  @override
  String get exportThemeTitle => 'Exportar tema (JSON)';

  @override
  String get close => 'Cerrar';

  @override
  String get copyJson => 'Copiar JSON';

  @override
  String get jsonCopied => '¡JSON del tema copiado al portapapeles!';

  @override
  String get libraryUpper => 'BIBLIOTECA';

  @override
  String get localCollection => 'Colección local y listas';

  @override
  String get importShort => 'Importar';

  @override
  String get favorites => 'Favoritos';

  @override
  String get playlists => 'Listas';

  @override
  String get history => 'Historial';

  @override
  String get offline => 'Sin conexión';

  @override
  String get favoritesEmpty =>
      'Tus favoritos están vacíos.\nToca el corazón de una pista para añadirla aquí.';

  @override
  String get historyEmpty =>
      'Tu historial de escucha está vacío.\nReproduce música desde la búsqueda y aparecerá aquí.';

  @override
  String get noPlaylists => 'Aún no tienes listas';

  @override
  String get importPlaylistHint =>
      'Importa una lista de Spotify o pega una lista de pistas.';

  @override
  String get importMusicAction => 'Importar música';

  @override
  String get playPlaylist => 'Reproducir lista';

  @override
  String playlistStarted(String name, int count) {
    return 'Reproduciendo «$name» ($count pistas)';
  }

  @override
  String get deletePlaylist => 'Eliminar lista';

  @override
  String get playAll => 'Reproducir todo';

  @override
  String get shuffle => 'Aleatorio';

  @override
  String get localAudioCache => 'Caché de audio local';

  @override
  String get cacheDescription =>
      'Las pistas reproducidas se guardan localmente para volver a escucharlas sin conexión.';

  @override
  String deviceUsage(String size) {
    return 'En este dispositivo: $size';
  }

  @override
  String get clearCache => 'Borrar toda la caché';

  @override
  String savedTracksUpper(int count) {
    return 'PISTAS GUARDADAS ($count):';
  }

  @override
  String get cacheFeaturesUpper => 'FUNCIONES DE LA CACHÉ:';

  @override
  String get offlineFirst => 'Prioridad a sin conexión';

  @override
  String get offlineFirstDescription =>
      'Al volver a escuchar, el audio se carga directamente del sistema de archivos del dispositivo.';

  @override
  String get maximumBitrate => 'Bitrate máximo';

  @override
  String get maximumBitrateDescription =>
      'Los flujos limpios de Opus/M4A a 160–256 kbps se guardan sin transcodificar.';

  @override
  String get trafficAndBattery => 'Ahorra datos y batería';

  @override
  String get trafficAndBatteryDescription =>
      'Evitar solicitudes de red repetidas ayuda a que tu teléfono dure más.';

  @override
  String get cacheEmpty => 'La caché está vacía';

  @override
  String get cachedTracksAppear =>
      'Las pistas descargadas aparecerán aquí automáticamente';

  @override
  String get removeFromCache => 'Quitar de la caché';

  @override
  String get removeCachedTrackTitle => '¿Quitar la pista de la caché?';

  @override
  String removeCachedTrackBody(String title) {
    return '«$title» se quitará de este dispositivo.';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get trackRemovedFromCache => 'Pista quitada de la caché';

  @override
  String get clearCacheTitle => '¿Borrar la caché?';

  @override
  String get clearCacheBody =>
      'Todos los archivos de audio guardados se eliminarán de este dispositivo. Los favoritos y el historial no cambiarán.';

  @override
  String get cacheCleared => 'Caché local borrada';

  @override
  String get back => 'Atrás';

  @override
  String get playlistActions => 'Acciones de lista';

  @override
  String get playlistUpper => 'LISTA';

  @override
  String get playlistEmpty => 'Aún no hay pistas en esta lista';

  @override
  String get pasteTrackList => 'Pega una lista de pistas';

  @override
  String get pasteImportLink => 'Pega un enlace para importar';

  @override
  String get tracksNotFound => 'No se encontraron pistas en ese enlace.';

  @override
  String get importError =>
      'Falló la importación. Comprueba el enlace y tu conexión a internet.';

  @override
  String importedPlaylistStarted(int count) {
    return 'Reproduciendo lista importada ($count pistas)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'Importar ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return '¡Lista «$name» guardada en tu biblioteca!';
  }

  @override
  String get spotifyImportSubtitle => 'Spotify • Listas, álbumes y pistas';

  @override
  String get artistTrackOrCsv => 'Artista — Pista, o un CSV de Exportify';

  @override
  String get pastePlaylistOrTrackLink => 'Pega un enlace de lista o de pista';

  @override
  String get pasteFromClipboard => 'Pegar del portapapeles';

  @override
  String get link => 'Enlace';

  @override
  String get trackList => 'Lista de pistas';

  @override
  String get playlistName => 'Nombre de la lista';

  @override
  String get startImport => 'Iniciar importación';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count pistas';
  }

  @override
  String get importedFromSpotify => 'Importado de Spotify';

  @override
  String get importedFromDeezer => 'Importado de Deezer';

  @override
  String get importIntro =>
      'Trae tus listas contigo. Usa un enlace de Spotify, una lista de pistas o un archivo de Exportify.';

  @override
  String get importTextTab => 'Texto';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'Elegir archivo';

  @override
  String get importFileHint =>
      'Elige el CSV exportado por Exportify o una lista de pistas en TXT. UTF-8, hasta 10 MB y 10 000 pistas.';

  @override
  String get importFileAndroidOnly =>
      'La selección de archivos está disponible en Android. Aquí puedes pegar el contenido de un CSV o de una lista de pistas.';

  @override
  String get importTextHint =>
      'Un Artista — Pista por línea. También puedes pegar el CSV completo, incluida su cabecera.';

  @override
  String get importPreview => 'Vista previa de pistas';

  @override
  String get importedFromCsv => 'Importado de CSV';

  @override
  String get importedFromText => 'Importado de una lista de pistas';

  @override
  String importMoreTracks(int count) {
    return 'Y $count más';
  }

  @override
  String get importMetadataHint =>
      'La lista se guarda en este dispositivo. El audio se busca al reproducir la pista; importar no descarga canciones.';

  @override
  String get importAnother => 'Importar otra cosa';

  @override
  String get importReading => 'Leyendo tu lista…';

  @override
  String get importSaving => 'Guardando en tu biblioteca…';

  @override
  String get importNameRequired => 'Introduce un nombre de lista.';

  @override
  String get importNameExists =>
      'Ya existe una lista con este nombre. Elige otro para conservar ambas.';

  @override
  String get importSaveFailed =>
      'No se pudo guardar la lista. Tu vista previa sigue aquí — inténtalo de nuevo.';

  @override
  String get importFileTooLarge =>
      'Este archivo supera los 10 MB. Divide la lista en exportaciones más pequeñas.';

  @override
  String get importFileUnsupported => 'Elige un archivo .csv o .txt.';

  @override
  String get importFileEncoding =>
      'No se pudo leer la codificación del texto. Guarda el archivo como UTF-8 e inténtalo de nuevo.';

  @override
  String get importCsvInvalid =>
      'El CSV está incompleto o mal formado. Vuelve a exportarlo sin editar sus columnas ni comillas.';

  @override
  String get importCsvMissingColumns =>
      'El CSV necesita las columnas Track Name y Artist Name(s), o Title y Artist. Usa la exportación original de Exportify.';

  @override
  String get importFileEmpty =>
      'No se encontraron pistas. Elige una exportación con contenido o pega una lista de Artista — Pista.';

  @override
  String get importTooManyTracks =>
      'Una sola importación puede contener hasta 10 000 pistas. Divide esta lista; aún no se ha guardado nada.';

  @override
  String get importFileReadFailed =>
      'No se pudo abrir el archivo. Comprueba que esté disponible en tu dispositivo y elígelo de nuevo.';

  @override
  String get importSpotifyBlocked =>
      'Spotify no compartió esta lista en tu región. Expórtala con Exportify y elige el archivo CSV.';

  @override
  String get listen => 'Reproducir';

  @override
  String get addToPlaylists => 'Añadir a listas';

  @override
  String trackSemantics(String title, String artist) {
    return 'Pista $title, $artist';
  }

  @override
  String get trackActions => 'Acciones de pista';

  @override
  String get updatesTitle => 'Actualizaciones';

  @override
  String currentVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get checkForUpdates => 'Buscar actualizaciones';

  @override
  String get checkingForUpdates => 'Buscando…';

  @override
  String get upToDate => 'Tienes la última versión';

  @override
  String updateAvailable(String version) {
    return 'La versión $version está disponible';
  }

  @override
  String get downloadingUpdate => 'Descargando actualización…';

  @override
  String get installUpdate => 'Instalar';

  @override
  String get updateCheckFailed =>
      'No se pudo buscar actualizaciones. Comprueba tu conexión.';

  @override
  String get installPermissionNeeded =>
      'Permite que Hook instale aplicaciones y pulsa Instalar de nuevo.';

  @override
  String updateSize(String size) {
    return '$size MB';
  }

  @override
  String get download => 'Descargar';

  @override
  String get downloading => 'Descargando…';

  @override
  String get downloaded => 'Descargado';

  @override
  String get downloadFailed => 'No se pudo descargar';

  @override
  String get removeDownload => 'Eliminar descarga';

  @override
  String get downloadSavedOffline => 'Guardado sin conexión';

  @override
  String get startWaveFromTrack => 'Iniciar una onda desde esta pista';

  @override
  String get addToQueue => 'Añadir a la cola';

  @override
  String addedToQueue(String title) {
    return 'Añadido a la cola: $title';
  }

  @override
  String get removeFavorite => 'Quitar de favoritos';

  @override
  String get addFavorite => 'Añadir a favoritos';

  @override
  String get addToPlaylist => 'Añadir a lista';

  @override
  String get goToArtist => 'Ir al artista';

  @override
  String get myPlaylist => 'Mi lista';

  @override
  String get newPlaylist => 'Nueva lista';

  @override
  String get name => 'Nombre';

  @override
  String get create => 'Crear';

  @override
  String get loading => 'Cargando…';

  @override
  String get pause => 'Pausa';

  @override
  String get play => 'Reproducir';

  @override
  String get next => 'Siguiente';

  @override
  String get speedAndPitch => 'Velocidad y tono';

  @override
  String speedValue(String value) {
    return 'Velocidad: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'Tono: ${value}x';
  }

  @override
  String get reset => 'Restablecer';

  @override
  String get moreActions => 'Más acciones';

  @override
  String get playbackQueue => 'Cola de reproducción';

  @override
  String get queueEmpty => 'La cola está vacía';

  @override
  String get selectingSource => 'Eligiendo fuente';

  @override
  String get collapsePlayer => 'Plegar reproductor';

  @override
  String get nowPlayingUpper => 'SONANDO AHORA';

  @override
  String get queue => 'Cola';

  @override
  String get startWave => 'Iniciar onda';

  @override
  String get cover => 'Portada';

  @override
  String get karaokeLyrics => 'Letra karaoki';

  @override
  String get findMusicStart => 'Encuentra música y empieza a reproducir';

  @override
  String get playbackNotStarted => 'La reproducción no ha empezado';

  @override
  String get openSearchFirstTrack =>
      'Abre la búsqueda para encontrar tu primera pista';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => 'En el dispositivo';

  @override
  String get sourceCatalog => 'Catálogo';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'Servidor';

  @override
  String get serverResolver => 'Servidor resolutor';

  @override
  String get serverResolverCaption =>
      'Servidor propio opcional que resuelve flujos de audio completos. La app envía una búsqueda o un ID de pista; el servidor devuelve una URL de reproducción. El contrato y una implementación de referencia están en docs/REMOTE_RESOLVER.md.';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'Sin configurar';

  @override
  String get serverSave => 'Guardar';

  @override
  String get serverDisable => 'Desactivar';

  @override
  String get onboardingWelcomeTitle => 'Te damos la bienvenida a Hook';

  @override
  String get onboardingWelcomeCaption =>
      'Música, letras y tu propio estilo visual. Elige un idioma para empezar — podrás cambiarlo después en los ajustes.';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingNext => 'Continuar';

  @override
  String get onboardingStart => 'Empezar a escuchar';

  @override
  String get onboardingMicrogTitle => 'MicroG y la cuenta de Google';

  @override
  String get onboardingMicrogBody =>
      'MicroG recrea los servicios de Google en ROMs de Android personalizadas que no los incluyen. Hook los usa solo para una función opcional: conectar una cuenta de YouTube para importar tus listas. La reproducción de música nunca requiere MicroG ni ningún servicio de Google.';

  @override
  String get onboardingMicrogNote =>
      'La reproducción no depende de MicroG. Conectar una cuenta es opcional.';

  @override
  String get onboardingMicrogDownload => 'Descargar MicroG';

  @override
  String get onboardingMicrogStatusChecking =>
      'Comprobando servicios de Google…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'Los servicios de Google están presentes en este dispositivo ($version). La importación de cuenta funcionará desde el principio.';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'ReVanced GmsCore detectado ($version). El SDK oficial de inicio de sesión de Google no es compatible con él, así que la conexión de cuenta puede no funcionar. La reproducción no se ve afectada.';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'No se encontraron servicios de Google. Para importar listas desde una cuenta de YouTube, instala MicroG primero — o omite esto y usa Hook sin cuenta.';

  @override
  String lyricsView(String mode) {
    return 'Vista de letra · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'Tu ritmo de lectura';

  @override
  String get lyricsModeSubtitle => 'Tres formas de acercarte a la canción.';

  @override
  String get lyricsModeLines => 'Líneas';

  @override
  String get lyricsModeKaraoke => 'Karaoki';

  @override
  String get lyricsModeFocus => 'Foco';

  @override
  String get lyricsModeLinesDescription =>
      'Letra serena con la línea actual resaltada';

  @override
  String get lyricsModeKaraokeDescription =>
      'Las palabras se iluminan suavemente con las voces';

  @override
  String get lyricsModeFocusDescription => 'Una línea grande. Nada más';

  @override
  String get lyricsModeSaveFailed => 'No se pudo guardar la vista de letra.';

  @override
  String get lyricsModeFootnote =>
      'Tu elección se guarda para las próximas canciones. La precisión del karaoki depende de los datos de origen: el resaltado de palabras es aproximado sin tiempos por palabra, y la letra se queda quieta sin marcas de tiempo.';

  @override
  String get lyricsNotFound => 'Letra no encontrada';

  @override
  String get karaokeUnavailable =>
      'La letra karaoki no está disponible para esta pista';

  @override
  String get unsyncedLyrics => 'Letra sin sincronizar';

  @override
  String get wordSyncUpper => 'SINCRONIZACIÓN PALABRA A PALABRA';

  @override
  String get lineSyncUpper => 'SINCRONIZACIÓN LÍNEA A LÍNEA';

  @override
  String get adjustLyricsSync => 'Ajustar la sincronización de la letra';

  @override
  String get startsSoon => 'Empieza pronto';

  @override
  String get musicContinues => 'La música sigue';

  @override
  String get decreaseLyricsOffset => 'Reducir desfase en 0,1 s';

  @override
  String lyricsOffset(String value) {
    return 'Desfase: $value s';
  }

  @override
  String get increaseLyricsOffset => 'Aumentar desfase en 0,1 s';

  @override
  String get hideSetting => 'Ocultar ajuste';

  @override
  String get lyricsOffsetSaveFailed =>
      'No se pudo guardar el desfase de la letra.';

  @override
  String get audioForbidden =>
      'El servidor de audio denegó el acceso (HTTP 403). La pista se encontró, pero su flujo no está disponible. Una VPN no garantiza el acceso al audio.';

  @override
  String get fullVersionUnavailable =>
      'No se encontró una versión completa en las fuentes disponibles. Comprueba tu conexión o inténtalo más tarde.';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source no pudo reproducir esta pista. Comprueba tu conexión o inténtalo más tarde.';
  }

  @override
  String get recentQueriesUpper => 'BÚSQUEDAS RECIENTES';

  @override
  String get clearHistory => 'Borrar';

  @override
  String get waveFromArtist => 'Onda del artista';

  @override
  String get popularTracksUpper => 'CANCIONES POPULARES';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones',
      one: '1 canción',
      zero: 'todavía sin canciones',
    );
    return '$_temp0';
  }
}
