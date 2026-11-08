// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'Impostazioni';

  @override
  String get settingsCaption =>
      'Le modifiche vengono salvate su questo dispositivo.';

  @override
  String get playerSettings => 'Riproduzione';

  @override
  String get lyricsAutoHide =>
      'Nascondi i controlli durante la lettura del testo';

  @override
  String get lyricsAutoHideDescription =>
      'Dopo 10 secondi senza interazioni, i pannelli del lettore scorrono fuori schermo. Usa il pulsante di ripristino per farli tornare.';

  @override
  String get showPlayerControls => 'Mostra i controlli del lettore';

  @override
  String get equalizer => 'Equalizzatore';

  @override
  String get equalizerEnabled => 'Elaborazione audio';

  @override
  String get equalizerPresets => 'Profilo sonoro';

  @override
  String get equalizerFlat => 'Originale';

  @override
  String get equalizerBass => 'Bassi profondi';

  @override
  String get equalizerVocal => 'Vocali';

  @override
  String get equalizerRock => 'Rock';

  @override
  String get equalizerElectronic => 'Elettronica';

  @override
  String get equalizerSoft => 'Morbido';

  @override
  String get equalizerCustom => 'Personalizzato';

  @override
  String get equalizerBands => 'Bande di frequenza';

  @override
  String get equalizerBassBoost => 'Potenziamento bassi';

  @override
  String get equalizerBassUnsupported =>
      'Il potenziamento bassi aggiuntivo non è supportato. Usa le bande a bassa frequenza.';

  @override
  String get equalizerPreamp => 'Preamplificazione';

  @override
  String get equalizerHeadroom => 'Margine automatico';

  @override
  String get equalizerHeadroomDescription =>
      'Riduce il livello di uscita quando si potenziano le frequenze per lasciare spazio ai picchi. Non è un limitatore.';

  @override
  String get equalizerWaiting =>
      'Avvia un brano per collegare l\'equalizzatore alla sua sessione audio.';

  @override
  String get equalizerUnsupported =>
      'L\'elaborazione audio è al momento disponibile solo su Android.';

  @override
  String get equalizerFailed =>
      'Questo dispositivo non è riuscito ad attivare gli effetti audio. La musica può comunque suonare senza.';

  @override
  String get equalizerRetry => 'Ricollega gli effetti';

  @override
  String get equalizerLive =>
      'Le modifiche si applicano subito e vengono salvate su questo dispositivo.';

  @override
  String get youtubeAccount => 'YouTube e MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'Accesso in sola lettura alle playlist. L\'accesso non garantisce la disponibilità dell\'audio.';

  @override
  String get youtubeAccountCompatibility => 'Compatibilità e privacy';

  @override
  String get youtubeAccountSubtitle =>
      'Connessione dell\'account e importazione di playlist';

  @override
  String get youtubeAccountPrivacy =>
      'Hook richiede l\'accesso a YouTube in sola lettura. Inserisci la password solo nella finestra di sistema di Google, mai in Hook. Il token non viene inviato a nessun server Hook e resta solo in memoria. Riconnetti dopo aver riavviato l\'app.';

  @override
  String get youtubeAccountPlaybackNotice =>
      'L\'accesso concede i dati dell\'account, non i flussi audio. Non garantisce di risolvere l\'HTTP 403. Le importazioni conservano le registrazioni di YouTube senza sostituirle con un\'altra fonte.';

  @override
  String get youtubeAccountConnect => 'Connetti account';

  @override
  String get youtubeAccountDisconnect => 'Disconnetti in Hook';

  @override
  String get youtubeAccountDisconnected => 'Nessun account connesso';

  @override
  String get youtubeAccountDisconnectNotice =>
      'Disconnettere questo account solo in Hook? Le playlist salvate resteranno. Gli account Google e MicroG del telefono non verranno disconnessi.';

  @override
  String get youtubeAccountSystem => 'API Google di sistema';

  @override
  String get youtubeAccountServicesMissing =>
      'Le API Google di sistema compatibili non sono disponibili. Un\'installazione separata di ReVanced GmsCore non le sostituisce per l\'accesso di Hook.';

  @override
  String get youtubeAccountMicrogNotice =>
      'È stata rilevata un\'installazione separata di ReVanced GmsCore. Hook non usa account o token di ReVanced. Un MicroG di sistema può fornire API Google compatibili, ma la compatibilità con questo metodo di accesso non è garantita.';

  @override
  String get youtubeAccountRevancedFound =>
      'YouTube Music ReVanced è installato';

  @override
  String get youtubeAccountPlaylists => 'Playlist dell\'account';

  @override
  String get youtubeAccountNoPlaylists =>
      'Nessuna playlist accessibile. Alcune raccolte automatiche di YouTube Music non sono disponibili tramite la YouTube Data API.';

  @override
  String get youtubeAccountMore => 'Carica altre';

  @override
  String get youtubeAccountPreview => 'Prepara importazione';

  @override
  String youtubeAccountProgress(int count) {
    return 'Brani recuperati: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'Voci non disponibili ignorate: $count. Non vengono sostituite con altri brani.';
  }

  @override
  String get youtubeAccountSetup => 'Configurazione dell\'accesso';

  @override
  String get youtubeAccountSetupBody =>
      'Lo sviluppatore deve abilitare YouTube Data API v3 in Google Cloud, registrare un client OAuth Android per com.hook.music e l\'SHA-1 di firma della build installata, nonché configurare la schermata di consenso. Aggiungi gli utenti ammessi in modalità test. Vedi docs/YOUTUBE_ACCOUNT_SETUP.md. Non aggiungere mai password, segreti client o token di altre app.';

  @override
  String get youtubeAccountConfigError =>
      'L\'accesso non è configurato per questa build. Controlla il client OAuth Android, il nome del pacchetto, l\'SHA-1 e gli utenti test ammessi in Google Cloud.';

  @override
  String get youtubeAccountPermissionError =>
      'L\'accesso in lettura ai dati di YouTube non è stato concesso.';

  @override
  String get youtubeAccountExpired =>
      'La tua sessione è scaduta. Riconnetti l\'account.';

  @override
  String get youtubeAccountNoChannel =>
      'L\'account selezionato non ha un canale YouTube accessibile.';

  @override
  String get youtubeAccountQuota =>
      'Quota dell\'API YouTube superata. Riprova più tardi.';

  @override
  String get youtubeAccountFailed =>
      'Impossibile recuperare i dati di YouTube. Controlla la connessione e riprova.';

  @override
  String get youtubeAccountUnsupported =>
      'La connessione dell\'account richiede Android con API Google di sistema compatibili.';

  @override
  String get importedFromYouTube => 'Importato dall\'account YouTube';

  @override
  String get translateLyrics => 'Traduci il testo';

  @override
  String get hideTranslation => 'Nascondi traduzione';

  @override
  String get cancelTranslation => 'Annulla traduzione';

  @override
  String get translationLoading => 'Preparazione della traduzione…';

  @override
  String get translationAttribution =>
      'Tradotto automaticamente da Google Traduttore';

  @override
  String get translationNotice =>
      'La traduzione può non cogliere con precisione il significato della canzone. L\'evidenziazione delle parole vale solo per l\'originale.';

  @override
  String get translationModelTitle => 'Scaricare i modelli linguistici?';

  @override
  String get translationModelBody =>
      'La traduzione avviene sul telefono: il testo non viene inviato a nessun server. La prima traduzione richiede i modelli Google ML Kit, che occupano decine di megabyte. Il download usa la connessione attuale, compresi i dati mobili. Annullare nasconde il risultato, ma un download già avviato può concludersi in background.';

  @override
  String get translationDownload => 'Scarica e traduci';

  @override
  String get translationUnavailable =>
      'Traduzione non riuscita. Controlla l\'accesso ai download dei modelli e riprova.';

  @override
  String get translationUnsupported =>
      'La traduzione sul dispositivo è al momento disponibile solo su Android.';

  @override
  String get translationUnknownLanguage =>
      'Impossibile identificare una lingua supportata per questa canzone.';

  @override
  String get translationSameLanguage =>
      'Il testo è già nella lingua selezionata.';

  @override
  String get translationTooLarge =>
      'Questo testo è troppo lungo per la traduzione sul dispositivo.';

  @override
  String get translationRussian => 'In russo';

  @override
  String get translationEnglish => 'In inglese';

  @override
  String get translationTarget => 'Lingua della traduzione';

  @override
  String get retry => 'Riprova';

  @override
  String get home => 'Home';

  @override
  String get search => 'Cerca';

  @override
  String get library => 'Libreria';

  @override
  String get youtubeUnavailableTitle => 'YouTube al momento non è disponibile';

  @override
  String get youtubeUnavailableBody =>
      'Impossibile ottenere un flusso audio. Controlla la rete e la rotta VPN: YouTube può rifiutare le richieste anche con una VPN.';

  @override
  String get checkAgain => 'Ricontrolla';

  @override
  String get dismiss => 'Ignora';

  @override
  String get goodNight => 'Buonanotte';

  @override
  String get goodMorning => 'Buongiorno';

  @override
  String get goodAfternoon => 'Buon pomeriggio';

  @override
  String get goodEvening => 'Buonasera';

  @override
  String get themeSettings => 'Impostazioni aspetto';

  @override
  String get onYourAir => 'Sulla tua antenna';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segnali recenti',
      one: '1 segnale recente',
      zero: 'Nessun segnale recente',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'La tua collezione ti aspetta';

  @override
  String get saved => 'Salvato';

  @override
  String get collectionEmptyDetail =>
      'La musica a cui vuoi tornare resterà qui';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count brani',
      one: '1 brano',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'Brano, artista o testo';

  @override
  String get searchUpper => 'CERCA';

  @override
  String get findFirstTrack => 'Trova il tuo primo brano';

  @override
  String continuationAfter(String artist) {
    return 'Altra musica dopo $artist';
  }

  @override
  String get chooseTrackWaveDetail =>
      'Scegli un brano e costruiremo un\'onda attorno al suo umore.';

  @override
  String get continueWaveLabel => 'CONTINUA / 01';

  @override
  String get yourWaveLabel => 'LA TUA ONDA / 01';

  @override
  String get continueWave => 'Continua l\'onda';

  @override
  String get chooseTrack => 'Scegli un brano';

  @override
  String get firstTrace => 'Lascia qui la tua prima traccia';

  @override
  String get favoriteWaveHint =>
      'Salva i preferiti e la tua onda diventerà più precisa.';

  @override
  String get openSearch => 'Apri la ricerca';

  @override
  String get findYourMusic => 'Trova il tuo suono.';

  @override
  String get importMusic => 'Importa musica';

  @override
  String get rememberedLyricsHint => 'Le parole che ricordi…';

  @override
  String get trackArtistHint => 'Brano o artista — in qualsiasi lingua';

  @override
  String get clear => 'Cancella';

  @override
  String get music => 'Musica';

  @override
  String get byLyrics => 'Per testo';

  @override
  String get allSources => 'Tutte le fonti';

  @override
  String get lyricsSearchCaption =>
      'Cerca una frase della canzone, non solo il titolo.';

  @override
  String get searchingLyrics => 'Cerco righe familiari…';

  @override
  String get searchingSources => 'Ricerca nelle fonti musicali…';

  @override
  String get connectionFailed => 'Impossibile connettersi';

  @override
  String get noMatches => 'Nessuna corrispondenza per ora';

  @override
  String get lyricsUnavailable =>
      'La ricerca dei testi non è disponibile al momento. Riprova più tardi o cerca per titolo.';

  @override
  String get searchUnavailable =>
      'Ricerca non riuscita. Controlla la connessione e riprova.';

  @override
  String get lyricsNoMatches =>
      'Prova un\'altra riga. Non tutti i testi sono indicizzati.';

  @override
  String get trackNoMatches =>
      'Aggiungi l\'artista o scegli un\'altra fonte. Alcuni servizi potrebbero non essere disponibili sulla tua rete.';

  @override
  String get repeatSearch => 'Cerca di nuovo';

  @override
  String get lyricMatchesUpper => 'CORRISPONDENZE DI TESTO';

  @override
  String get tracksUpper => 'BRANI';

  @override
  String playTrack(String title, String artist) {
    return 'Riproduci $title, $artist';
  }

  @override
  String get familiarLinesUpper => 'RIGHE FAMILIARI';

  @override
  String get bestMatchUpper => 'CORRISPONDENZA MIGLIORE';

  @override
  String get fullVersionOnPlayback =>
      'Troveremo la versione completa quando parte la riproduzione.';

  @override
  String get forgotTitle => 'Ti è sfuggito il titolo.\nNon la musica.';

  @override
  String get startAsYouRemember =>
      'Un nome, un titolo o una riga della canzone.\nInizia con ciò che ricordi.';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => 'Cerca i nomi come suonano';

  @override
  String get rememberOnlyLine => 'Ricordo solo una riga';

  @override
  String get findSongByWords => 'Trova una canzone dalle sue parole';

  @override
  String get yourArtistsUpper => 'I TUOI ARTISTI';

  @override
  String get language => 'Lingua';

  @override
  String get languageCaption => 'L\'interfaccia segue subito la tua scelta';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get russian => 'Russo';

  @override
  String get english => 'Inglese';

  @override
  String get themesAndShaders => 'Temi ed effetti';

  @override
  String get themesSubtitle => 'Aspetto, lingua e movimento dello sfondo';

  @override
  String get invalidThemeJson =>
      'Impossibile leggere il tema. Controlla il formato JSON e i valori dei campi.';

  @override
  String get exportJson => 'Esporta JSON';

  @override
  String get importJson => 'Importa JSON';

  @override
  String get readyThemes => 'Temi predefiniti';

  @override
  String get gpuShaders => 'Effetti di sfondo';

  @override
  String get meshGradient => 'Gradiente GPU fluido basato sui colori del brano';

  @override
  String get vinylNoise => 'Grana di vinile analogico (rumore)';

  @override
  String get glassBlur => 'Sfocatura vetro (Backdrop Blur)';

  @override
  String get cornerRadius => 'Raggio degli angoli dell\'interfaccia';

  @override
  String get importThemeTitle => 'Importa tema da JSON';

  @override
  String get pasteThemeJson => 'Incolla la configurazione JSON del tema:';

  @override
  String get cancel => 'Annulla';

  @override
  String get apply => 'Applica';

  @override
  String get themeApplied => 'Tema applicato con successo!';

  @override
  String get exportThemeTitle => 'Esporta tema (JSON)';

  @override
  String get close => 'Chiudi';

  @override
  String get copyJson => 'Copia JSON';

  @override
  String get jsonCopied => 'JSON del tema copiato negli appunti!';

  @override
  String get libraryUpper => 'LIBRERIA';

  @override
  String get localCollection => 'Raccolta locale e playlist';

  @override
  String get importShort => 'Importa';

  @override
  String get favorites => 'Preferiti';

  @override
  String get playlists => 'Playlist';

  @override
  String get history => 'Cronologia';

  @override
  String get offline => 'Offline';

  @override
  String get favoritesEmpty =>
      'I tuoi preferiti sono vuoti.\nTocca il cuore di un brano per aggiungerlo qui.';

  @override
  String get historyEmpty =>
      'La tua cronologia di ascolto è vuota.\nRiproduci musica dalla ricerca e comparirà qui.';

  @override
  String get noPlaylists => 'Non hai ancora playlist';

  @override
  String get importPlaylistHint =>
      'Importa una playlist di Spotify o incolla un elenco di brani.';

  @override
  String get importMusicAction => 'Importa musica';

  @override
  String get playPlaylist => 'Riproduci playlist';

  @override
  String playlistStarted(String name, int count) {
    return 'Riproduzione di «$name» ($count brani)';
  }

  @override
  String get deletePlaylist => 'Elimina playlist';

  @override
  String get playAll => 'Riproduci tutto';

  @override
  String get shuffle => 'Casuale';

  @override
  String get localAudioCache => 'Cache audio locale';

  @override
  String get cacheDescription =>
      'I brani riprodotti vengono conservati localmente per riascoltarli senza connessione.';

  @override
  String deviceUsage(String size) {
    return 'Su questo dispositivo: $size';
  }

  @override
  String get clearCache => 'Svuota tutta la cache';

  @override
  String savedTracksUpper(int count) {
    return 'BRANI SALVATI ($count):';
  }

  @override
  String get cacheFeaturesUpper => 'FUNZIONI DELLA CACHE:';

  @override
  String get offlineFirst => 'Prima di tutto, offline';

  @override
  String get offlineFirstDescription =>
      'Al riascolto, l\'audio viene caricato direttamente dal file system del dispositivo.';

  @override
  String get maximumBitrate => 'Bitrate massimo';

  @override
  String get maximumBitrateDescription =>
      'I flussi puliti Opus/M4A a 160–256 kbps vengono salvati senza transcodifica.';

  @override
  String get trafficAndBattery => 'Risparmia dati e batteria';

  @override
  String get trafficAndBatteryDescription =>
      'Evitare richieste di rete ripetute aiuta il telefono a durare di più.';

  @override
  String get cacheEmpty => 'La cache è vuota';

  @override
  String get cachedTracksAppear =>
      'I brani scaricati compariranno qui automaticamente';

  @override
  String get removeFromCache => 'Rimuovi dalla cache';

  @override
  String get removeCachedTrackTitle => 'Rimuovere il brano dalla cache?';

  @override
  String removeCachedTrackBody(String title) {
    return '«$title» verrà rimosso da questo dispositivo.';
  }

  @override
  String get delete => 'Elimina';

  @override
  String get trackRemovedFromCache => 'Brano rimosso dalla cache';

  @override
  String get clearCacheTitle => 'Svuotare la cache?';

  @override
  String get clearCacheBody =>
      'Tutti i file audio salvati verranno rimossi da questo dispositivo. Preferiti e cronologia non cambiano.';

  @override
  String get cacheCleared => 'Cache locale svuotata';

  @override
  String get back => 'Indietro';

  @override
  String get playlistActions => 'Azioni playlist';

  @override
  String get playlistUpper => 'PLAYLIST';

  @override
  String get playlistEmpty => 'In questa playlist non ci sono ancora brani';

  @override
  String get pasteTrackList => 'Incolla un elenco di brani';

  @override
  String get pasteImportLink => 'Incolla un link da importare';

  @override
  String get tracksNotFound => 'Nessun brano trovato a quel link.';

  @override
  String get importError =>
      'Importazione non riuscita. Controlla il link e la connessione a internet.';

  @override
  String importedPlaylistStarted(int count) {
    return 'Riproduzione della playlist importata ($count brani)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'Importa ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return 'Playlist «$name» salvata nella tua libreria!';
  }

  @override
  String get spotifyImportSubtitle => 'Spotify • Playlist, album e brani';

  @override
  String get artistTrackOrCsv => 'Artista — Brano, oppure un CSV di Exportify';

  @override
  String get pastePlaylistOrTrackLink =>
      'Incolla un link di playlist o di brano';

  @override
  String get pasteFromClipboard => 'Incolla dagli appunti';

  @override
  String get link => 'Link';

  @override
  String get trackList => 'Elenco di brani';

  @override
  String get playlistName => 'Nome della playlist';

  @override
  String get startImport => 'Avvia importazione';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count brani';
  }

  @override
  String get importedFromSpotify => 'Importato da Spotify';

  @override
  String get importedFromDeezer => 'Importato da Deezer';

  @override
  String get importIntro =>
      'Porta con te le tue playlist. Usa un link Spotify, un elenco di brani o un file Exportify.';

  @override
  String get importTextTab => 'Testo';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'Scegli file';

  @override
  String get importFileHint =>
      'Scegli il CSV esportato da Exportify o un elenco di brani TXT. UTF-8, fino a 10 MB e 10.000 brani.';

  @override
  String get importFileAndroidOnly =>
      'La selezione dei file è disponibile su Android. Qui puoi incollare il contenuto di un CSV o di un elenco di brani.';

  @override
  String get importTextHint =>
      'Una riga Artista — Brano per riga. Puoi anche incollare il CSV completo, intestazione inclusa.';

  @override
  String get importPreview => 'Anteprima brani';

  @override
  String get importedFromCsv => 'Importato da CSV';

  @override
  String get importedFromText => 'Importato da un elenco di brani';

  @override
  String importMoreTracks(int count) {
    return 'E altri $count';
  }

  @override
  String get importMetadataHint =>
      'La playlist viene salvata su questo dispositivo. L\'audio viene cercato alla riproduzione del brano; importare non scarica canzoni.';

  @override
  String get importAnother => 'Importa altro';

  @override
  String get importReading => 'Lettura della playlist…';

  @override
  String get importSaving => 'Salvataggio nella libreria…';

  @override
  String get importNameRequired => 'Inserisci un nome per la playlist.';

  @override
  String get importNameExists =>
      'Esiste già una playlist con questo nome. Scegline un altro per tenere entrambe.';

  @override
  String get importSaveFailed =>
      'Impossibile salvare la playlist. L\'anteprima resta qui — riprova.';

  @override
  String get importFileTooLarge =>
      'Il file supera 10 MB. Dividi la playlist in esportazioni più piccole.';

  @override
  String get importFileUnsupported => 'Scegli un file .csv o .txt.';

  @override
  String get importFileEncoding =>
      'Impossibile leggere la codifica del testo. Salva il file in UTF-8 e riprova.';

  @override
  String get importCsvInvalid =>
      'Il CSV è incompleto o malformato. Esportalo di nuovo senza modificarne colonne o virgolette.';

  @override
  String get importCsvMissingColumns =>
      'Il CSV richiede le colonne Track Name e Artist Name(s), oppure Title e Artist. Usa l\'esportazione originale di Exportify.';

  @override
  String get importFileEmpty =>
      'Nessun brano trovato. Scegli un\'esportazione con contenuti o incolla un elenco Artista — Brano.';

  @override
  String get importTooManyTracks =>
      'Una singola importazione può contenere fino a 10.000 brani. Dividi questa playlist; non è ancora stato salvato nulla.';

  @override
  String get importFileReadFailed =>
      'Impossibile aprire il file. Verifica che sia disponibile sul dispositivo e selezionalo di nuovo.';

  @override
  String get importSpotifyBlocked =>
      'Spotify non ha condiviso questa playlist nella tua regione. Esportala con Exportify e scegli il file CSV.';

  @override
  String get listen => 'Riproduci';

  @override
  String get addToPlaylists => 'Aggiungi alle playlist';

  @override
  String trackSemantics(String title, String artist) {
    return 'Brano $title, $artist';
  }

  @override
  String get trackActions => 'Azioni del brano';

  @override
  String get updatesTitle => 'Aggiornamenti';

  @override
  String get accountTitle => 'Account';

  @override
  String get waveLoading => 'Ricerca di brani simili…';

  @override
  String get randomPick => 'Scelta casuale per te';

  @override
  String get accountCaption => 'Sincronizza la libreria tra i dispositivi';

  @override
  String get nickname => 'Nickname';

  @override
  String get nicknameHint => '3–20 caratteri: lettere, cifre, . _ -';

  @override
  String get password => 'Password';

  @override
  String get passwordMinHint => 'Almeno 6 caratteri';

  @override
  String get signIn => 'Accedi';

  @override
  String get signUp => 'Crea account';

  @override
  String get haveAccountToggle => 'Hai già un account? Accedi';

  @override
  String get noAccountToggle => 'Non hai ancora un account? Creane uno';

  @override
  String get signOut => 'Esci';

  @override
  String get syncNow => 'Sincronizza ora';

  @override
  String get syncing => 'Sincronizzazione…';

  @override
  String syncedAt(String time) {
    return 'Sincronizzato: $time';
  }

  @override
  String get neverSynced => 'Mai sincronizzato';

  @override
  String get errorNicknameTaken => 'Questo nickname è già in uso';

  @override
  String get errorNicknameInvalid =>
      'Nickname: 3–20 caratteri, lettere/cifre/._-';

  @override
  String get errorInvalidCredentials => 'Nickname o password errati';

  @override
  String get errorWeakPassword => 'La password è troppo corta';

  @override
  String get errorNetwork => 'Nessuna connessione';

  @override
  String get errorServer => 'Errore del server, riprova più tardi';

  @override
  String currentVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get checkForUpdates => 'Cerca aggiornamenti';

  @override
  String get checkingForUpdates => 'Ricerca in corso…';

  @override
  String get upToDate => 'Hai l\'ultima versione';

  @override
  String updateAvailable(String version) {
    return 'La versione $version è disponibile';
  }

  @override
  String get downloadingUpdate => 'Download dell\'aggiornamento…';

  @override
  String get installUpdate => 'Installa';

  @override
  String get updateCheckFailed =>
      'Impossibile verificare gli aggiornamenti. Controlla la connessione.';

  @override
  String get installPermissionNeeded =>
      'Consenti a Hook di installare app e tocca di nuovo Installa.';

  @override
  String updateSize(String size) {
    return '$size MB';
  }

  @override
  String get download => 'Scarica';

  @override
  String get downloading => 'Download in corso…';

  @override
  String get downloaded => 'Scaricato';

  @override
  String get downloadFailed => 'Download non riuscito';

  @override
  String get removeDownload => 'Rimuovi download';

  @override
  String get downloadSavedOffline => 'Salvato offline';

  @override
  String get startWaveFromTrack => 'Avvia un\'onda da questo brano';

  @override
  String get addToQueue => 'Aggiungi alla coda';

  @override
  String addedToQueue(String title) {
    return 'Aggiunto alla coda: $title';
  }

  @override
  String get removeFavorite => 'Rimuovi dai preferiti';

  @override
  String get addFavorite => 'Aggiungi ai preferiti';

  @override
  String get addToPlaylist => 'Aggiungi alla playlist';

  @override
  String get goToArtist => 'Vai all\'artista';

  @override
  String get myPlaylist => 'La mia playlist';

  @override
  String get newPlaylist => 'Nuova playlist';

  @override
  String get name => 'Nome';

  @override
  String get create => 'Crea';

  @override
  String get loading => 'Caricamento…';

  @override
  String get pause => 'Pausa';

  @override
  String get play => 'Riproduci';

  @override
  String get next => 'Successivo';

  @override
  String get speedAndPitch => 'Velocità e tonalità';

  @override
  String speedValue(String value) {
    return 'Velocità: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'Tonalità: ${value}x';
  }

  @override
  String get reset => 'Ripristina';

  @override
  String get moreActions => 'Altre azioni';

  @override
  String get playbackQueue => 'Coda di riproduzione';

  @override
  String get queueEmpty => 'La coda è vuota';

  @override
  String get selectingSource => 'Selezione della fonte';

  @override
  String get collapsePlayer => 'Comprimi il lettore';

  @override
  String get nowPlayingUpper => 'IN RIPRODUZIONE';

  @override
  String get queue => 'Coda';

  @override
  String get startWave => 'Avvia l\'onda';

  @override
  String get cover => 'Copertina';

  @override
  String get karaokeLyrics => 'Testo karaoke';

  @override
  String get findMusicStart => 'Trova musica e avvia la riproduzione';

  @override
  String get playbackNotStarted => 'La riproduzione non è iniziata';

  @override
  String get openSearchFirstTrack =>
      'Apri la ricerca per trovare il tuo primo brano';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => 'Sul dispositivo';

  @override
  String get sourceCatalog => 'Catalogo';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'Server';

  @override
  String get serverResolver => 'Server risolutore';

  @override
  String get serverResolverCaption =>
      'Server auto-ospitato opzionale che risolve flussi audio completi. L\'app invia una ricerca o un ID brano; il server restituisce un URL di riproduzione. Contratto e implementazione di riferimento sono in docs/REMOTE_RESOLVER.md.';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'Non configurato';

  @override
  String get serverSave => 'Salva';

  @override
  String get serverDisable => 'Disattiva';

  @override
  String get onboardingWelcomeTitle => 'Benvenuto in Hook';

  @override
  String get onboardingWelcomeCaption =>
      'Musica, testi e il tuo stile visivo. Scegli una lingua per iniziare — potrai cambiarla nelle impostazioni.';

  @override
  String get onboardingSkip => 'Salta';

  @override
  String get onboardingNext => 'Continua';

  @override
  String get onboardingStart => 'Inizia ad ascoltare';

  @override
  String get onboardingMicrogTitle => 'MicroG e l\'account Google';

  @override
  String get onboardingMicrogBody =>
      'MicroG ricrea i servizi Google sulle ROM Android personalizzate che ne sono prive. Hook li usa solo per una funzione opzionale: collegare un account YouTube per importare le playlist. Riprodurre musica non richiede mai MicroG né servizi Google.';

  @override
  String get onboardingMicrogNote =>
      'La riproduzione non dipende da MicroG. Collegare un account è facoltativo.';

  @override
  String get onboardingMicrogDownload => 'Scarica MicroG';

  @override
  String get onboardingMicrogStatusChecking => 'Verifica dei servizi Google…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'I servizi Google sono presenti su questo dispositivo ($version). L\'importazione dell\'account funzionerà subito.';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'Rilevato ReVanced GmsCore ($version). L\'SDK ufficiale di accesso Google non è compatibile, quindi la connessione dell\'account potrebbe non funzionare. La riproduzione non è influenzata.';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'Servizi Google non trovati. Per importare playlist da un account YouTube, installa prima MicroG — oppure salta e usa Hook senza account.';

  @override
  String lyricsView(String mode) {
    return 'Vista del testo · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'Il tuo ritmo di lettura';

  @override
  String get lyricsModeSubtitle => 'Tre modi per avvicinarti alla canzone.';

  @override
  String get lyricsModeLines => 'Righe';

  @override
  String get lyricsModeKaraoke => 'Karaoke';

  @override
  String get lyricsModeFocus => 'Focus';

  @override
  String get lyricsModeLinesDescription =>
      'Testo calmo con la riga attuale evidenziata';

  @override
  String get lyricsModeKaraokeDescription =>
      'Le parole si illuminano dolcemente con i vocali';

  @override
  String get lyricsModeFocusDescription => 'Una riga grande. Nient\'altro';

  @override
  String get lyricsModeSaveFailed => 'Impossibile salvare la vista del testo.';

  @override
  String get lyricsModeFootnote =>
      'La scelta resta salvata per le canzoni future. La precisione del karaoke dipende dai dati della fonte: l\'evidenziazione delle parole è approssimativa senza tempi per parola, e il testo resta fermo senza timestamp.';

  @override
  String get lyricsNotFound => 'Testo non trovato';

  @override
  String get karaokeUnavailable =>
      'Il testo karaoke non è disponibile per questo brano';

  @override
  String get unsyncedLyrics => 'Testo non sincronizzato';

  @override
  String get wordSyncUpper => 'SINCRONIZZAZIONE PAROLA PER PAROLA';

  @override
  String get lineSyncUpper => 'SINCRONIZZAZIONE RIGA PER RIGA';

  @override
  String get adjustLyricsSync => 'Regola la sincronizzazione del testo';

  @override
  String get startsSoon => 'Inizia tra poco';

  @override
  String get musicContinues => 'La musica continua';

  @override
  String get decreaseLyricsOffset => 'Riduci lo scarto di 0,1 s';

  @override
  String lyricsOffset(String value) {
    return 'Scarto: $value s';
  }

  @override
  String get increaseLyricsOffset => 'Aumenta lo scarto di 0,1 s';

  @override
  String get hideSetting => 'Nascondi impostazione';

  @override
  String get lyricsOffsetSaveFailed =>
      'Impossibile salvare lo scarto del testo.';

  @override
  String get audioForbidden =>
      'Il server audio ha negato l\'accesso (HTTP 403). Il brano è stato trovato, ma il suo flusso non è disponibile. Una VPN non garantisce l\'accesso all\'audio.';

  @override
  String get fullVersionUnavailable =>
      'Nessuna versione completa trovata nelle fonti disponibili. Controlla la connessione o riprova più tardi.';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source non è riuscito a riprodurre questo brano. Controlla la connessione o riprova più tardi.';
  }

  @override
  String get recentQueriesUpper => 'RICERCHE RECENTI';

  @override
  String get clearHistory => 'Cancella';

  @override
  String get waveFromArtist => 'Onda dell\'artista';

  @override
  String get popularTracksUpper => 'BRANI POPOLARI';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracce',
      one: '1 traccia',
      zero: 'nessuna traccia',
    );
    return '$_temp0';
  }
}
