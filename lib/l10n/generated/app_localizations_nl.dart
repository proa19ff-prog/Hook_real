// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'Instellingen';

  @override
  String get settingsCaption =>
      'Wijzigingen worden op dit apparaat opgeslagen.';

  @override
  String get playerSettings => 'Speler';

  @override
  String get lyricsAutoHide =>
      'Bediening verbergen tijdens het lezen van songteksten';

  @override
  String get lyricsAutoHideDescription =>
      'Na 10 seconden zonder interactie schuiven de spelerpanelen uit beeld. Gebruik de herstelknop om ze terug te halen.';

  @override
  String get showPlayerControls => 'Spelerbediening tonen';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get equalizerEnabled => 'Geluidsverwerking';

  @override
  String get equalizerPresets => 'Geluidsprofiel';

  @override
  String get equalizerFlat => 'Origineel';

  @override
  String get equalizerBass => 'Diepe bas';

  @override
  String get equalizerVocal => 'Zang';

  @override
  String get equalizerRock => 'Rock';

  @override
  String get equalizerElectronic => 'Elektronisch';

  @override
  String get equalizerSoft => 'Zacht';

  @override
  String get equalizerCustom => 'Aangepast';

  @override
  String get equalizerBands => 'Frequentiebanden';

  @override
  String get equalizerBassBoost => 'Bass-boost';

  @override
  String get equalizerBassUnsupported =>
      'Extra bass-boost wordt niet ondersteund. Gebruik de lage frequentiebanden.';

  @override
  String get equalizerPreamp => 'Voorversterking';

  @override
  String get equalizerHeadroom => 'Automatische speling';

  @override
  String get equalizerHeadroomDescription =>
      'Verlaagt het uitgangsniveau bij het versterken van frequenties om ruimte voor pieken te laten. Dit is geen limiter.';

  @override
  String get equalizerWaiting =>
      'Speel een nummer af om de equalizer aan zijn audiosessie te koppelen.';

  @override
  String get equalizerUnsupported =>
      'Geluidsverwerking is momenteel alleen op Android beschikbaar.';

  @override
  String get equalizerFailed =>
      'Dit apparaat kon de audio-effecten niet inschakelen. Muziek kan ook zonder hen spelen.';

  @override
  String get equalizerRetry => 'Effecten opnieuw verbinden';

  @override
  String get equalizerLive =>
      'Wijzigingen werken direct en worden op dit apparaat opgeslagen.';

  @override
  String get youtubeAccount => 'YouTube en MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'Alleen-lezen toegang tot afspeellijsten. Inloggen garandeert geen beschikbare audio.';

  @override
  String get youtubeAccountCompatibility => 'Compatibiliteit en privacy';

  @override
  String get youtubeAccountSubtitle =>
      'Accountkoppeling en afspeellijst-import';

  @override
  String get youtubeAccountPrivacy =>
      'Hook vraagt alleen-lezen toegang tot YouTube. Voer je wachtwoord alleen in het systeemvenster van Google in, nooit in Hook. Het token wordt niet naar een Hook-server gestuurd en blijft alleen in het geheugen. Verbind opnieuw na het herstarten van de app.';

  @override
  String get youtubeAccountPlaybackNotice =>
      'Inloggen geeft toegang tot accountgegevens, niet tot audiostreams. Het garandeert geen oplossing voor HTTP 403. Imports behouden YouTube-opnames zonder ze te vervangen door een andere bron.';

  @override
  String get youtubeAccountConnect => 'Account verbinden';

  @override
  String get youtubeAccountDisconnect => 'Verbreken in Hook';

  @override
  String get youtubeAccountDisconnected => 'Geen account verbonden';

  @override
  String get youtubeAccountDisconnectNotice =>
      'Dit account alleen in Hook verbreken? Opgeslagen afspeellijsten blijven bestaan. Je wordt niet uitgelogd bij Google- en MicroG-accounts op je telefoon.';

  @override
  String get youtubeAccountSystem => 'Systeem-Google-API\'s';

  @override
  String get youtubeAccountServicesMissing =>
      'Compatibele systeem-Google-API\'s zijn niet beschikbaar. Een losse installatie van ReVanced GmsCore vervangt ze niet voor Hook-aanmelding.';

  @override
  String get youtubeAccountMicrogNotice =>
      'Er is een losse installatie van ReVanced GmsCore gedetecteerd. Hook gebruikt geen ReVanced-accounts of -tokens. Systeem-MicroG kan compatibele Google-API\'s bieden, maar compatibiliteit met deze aanmeldmethode is niet gegarandeerd.';

  @override
  String get youtubeAccountRevancedFound =>
      'YouTube Music ReVanced is geïnstalleerd';

  @override
  String get youtubeAccountPlaylists => 'Accountafspeellijsten';

  @override
  String get youtubeAccountNoPlaylists =>
      'Geen toegankelijke afspeellijsten. Sommige automatische YouTube Music-collecties zijn niet beschikbaar via de YouTube Data API.';

  @override
  String get youtubeAccountMore => 'Meer laden';

  @override
  String get youtubeAccountPreview => 'Import voorbereiden';

  @override
  String youtubeAccountProgress(int count) {
    return 'Opgehaalde nummers: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'Overgeslagen onbereikbare items: $count. Ze worden niet vervangen door andere nummers.';
  }

  @override
  String get youtubeAccountSetup => 'Aanmeldconfiguratie';

  @override
  String get youtubeAccountSetupBody =>
      'De ontwikkelaar moet YouTube Data API v3 in Google Cloud inschakelen, een Android-OAuth-client registreren voor com.hook.music en de SHA-1 van de ondertekening van de geïnstalleerde build, en het toestemmingsscherm configureren. Voeg in de testmodus toegestane gebruikers toe. Zie docs/YOUTUBE_ACCOUNT_SETUP.md. Voeg nooit wachtwoorden, clients secrets of tokens van andere apps toe.';

  @override
  String get youtubeAccountConfigError =>
      'Aanmelden is niet geconfigureerd voor deze build. Controleer de Android-OAuth-client, de pakketnaam, de SHA-1 en de toegestane testgebruikers in Google Cloud.';

  @override
  String get youtubeAccountPermissionError =>
      'Leestoegang tot YouTube-gegevens is niet verleend.';

  @override
  String get youtubeAccountExpired =>
      'Je sessie is verlopen. Verbind het account opnieuw.';

  @override
  String get youtubeAccountNoChannel =>
      'Het gekozen account heeft geen toegankelijk YouTube-kanaal.';

  @override
  String get youtubeAccountQuota =>
      'YouTube-API-quota overschreden. Probeer het later opnieuw.';

  @override
  String get youtubeAccountFailed =>
      'Kon YouTube-gegevens niet ophalen. Controleer je verbinding en probeer het opnieuw.';

  @override
  String get youtubeAccountUnsupported =>
      'Accountkoppeling vereist Android met compatibele systeem-Google-API\'s.';

  @override
  String get importedFromYouTube => 'Geïmporteerd uit YouTube-account';

  @override
  String get translateLyrics => 'Songtekst vertalen';

  @override
  String get hideTranslation => 'Vertaling verbergen';

  @override
  String get cancelTranslation => 'Vertaling annuleren';

  @override
  String get translationLoading => 'Vertaling wordt voorbereid…';

  @override
  String get translationAttribution =>
      'Automatisch vertaald door Google Translate';

  @override
  String get translationNotice =>
      'De vertaling vangt de betekenis van het lied mogelijk niet exact. Woordmarkering geldt alleen voor het origineel.';

  @override
  String get translationModelTitle => 'Taalmodellen downloaden?';

  @override
  String get translationModelBody =>
      'De vertaling draait op je telefoon: songteksten worden niet naar een server gestuurd. De eerste vertaling heeft Google ML Kit-modellen nodig, die tientallen megabytes beslaan. De download gebruikt je huidige verbinding, inclusief mobiele data. Annuleren verbergt het resultaat, maar een al gestarte modeldownload kan op de achtergrond afronden.';

  @override
  String get translationDownload => 'Downloaden en vertalen';

  @override
  String get translationUnavailable =>
      'Vertaling mislukt. Controleer de toegang tot modeldownloads en probeer het opnieuw.';

  @override
  String get translationUnsupported =>
      'Vertaling op het apparaat is momenteel alleen op Android beschikbaar.';

  @override
  String get translationUnknownLanguage =>
      'Kon geen ondersteunde taal voor dit nummer vaststellen.';

  @override
  String get translationSameLanguage =>
      'De songtekst is al in de gekozen taal.';

  @override
  String get translationTooLarge =>
      'Deze songtekst is te lang voor vertaling op het apparaat.';

  @override
  String get translationRussian => 'Naar het Russisch';

  @override
  String get translationEnglish => 'Naar het Engels';

  @override
  String get translationTarget => 'Vertaaltaal';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get home => 'Start';

  @override
  String get search => 'Zoeken';

  @override
  String get library => 'Bibliotheek';

  @override
  String get youtubeUnavailableTitle => 'YouTube is nu niet beschikbaar';

  @override
  String get youtubeUnavailableBody =>
      'Kon geen audiostream verkrijgen. Controleer je netwerk en VPN-route: YouTube kan verzoeken afwijzen, zelfs met een VPN.';

  @override
  String get checkAgain => 'Opnieuw controleren';

  @override
  String get dismiss => 'Sluiten';

  @override
  String get goodNight => 'Goedenacht';

  @override
  String get goodMorning => 'Goedemorgen';

  @override
  String get goodAfternoon => 'Goedemiddag';

  @override
  String get goodEvening => 'Goedenavond';

  @override
  String get themeSettings => 'Uiterlijk-instellingen';

  @override
  String get onYourAir => 'Op jouw golflengte';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recente signalen',
      one: '1 recent signaal',
      zero: 'Geen recente signalen',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'Je collectie wacht op je';

  @override
  String get saved => 'Opgeslagen';

  @override
  String get collectionEmptyDetail =>
      'Muziek waarnaar je wilt terugkeren blijft hier';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nummers',
      one: '1 nummer',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'Nummer, artiest of songtekst';

  @override
  String get searchUpper => 'ZOEKEN';

  @override
  String get findFirstTrack => 'Vind je eerste nummer';

  @override
  String continuationAfter(String artist) {
    return 'Meer muziek na $artist';
  }

  @override
  String get chooseTrackWaveDetail =>
      'Kies een nummer en we bouwen een golf rond zijn sfeer.';

  @override
  String get continueWaveLabel => 'DOORGAAN / 01';

  @override
  String get yourWaveLabel => 'JOE GOLF / 01';

  @override
  String get continueWave => 'Golf voortzetten';

  @override
  String get chooseTrack => 'Kies een nummer';

  @override
  String get firstTrace => 'Laat hier je eerste spoor na';

  @override
  String get favoriteWaveHint =>
      'Bewaar favorieten, dan wordt je golf nauwkeuriger.';

  @override
  String get openSearch => 'Zoeken openen';

  @override
  String get findYourMusic => 'Vind je geluid.';

  @override
  String get importMusic => 'Muziek importeren';

  @override
  String get rememberedLyricsHint => 'De woorden die je kent…';

  @override
  String get trackArtistHint => 'Nummer of artiest — in welke taal dan ook';

  @override
  String get clear => 'Wissen';

  @override
  String get music => 'Muziek';

  @override
  String get byLyrics => 'Op songtekst';

  @override
  String get allSources => 'Alle bronnen';

  @override
  String get lyricsSearchCaption =>
      'Zoek op een zin uit het lied, niet alleen op de titel.';

  @override
  String get searchingLyrics => 'Bekende regels worden gezocht…';

  @override
  String get searchingSources => 'Muziekbronnen worden doorzocht…';

  @override
  String get connectionFailed => 'Kon geen verbinding maken';

  @override
  String get noMatches => 'Nog geen overeenkomsten';

  @override
  String get lyricsUnavailable =>
      'Songtekst-zoeken is nu niet beschikbaar. Probeer het later of zoek op titel.';

  @override
  String get searchUnavailable =>
      'Zoeken mislukt. Controleer je verbinding en probeer het opnieuw.';

  @override
  String get lyricsNoMatches =>
      'Probeer een andere regel. Lang niet elke songtekst is geïndexeerd.';

  @override
  String get trackNoMatches =>
      'Voeg de artiest toe of kies een andere bron. Sommige diensten zijn mogelijk niet bereikbaar op je netwerk.';

  @override
  String get repeatSearch => 'Opnieuw zoeken';

  @override
  String get lyricMatchesUpper => 'TEKSTOVEREENKOMSTEN';

  @override
  String get tracksUpper => 'NUMMERS';

  @override
  String playTrack(String title, String artist) {
    return 'Speel $title, $artist af';
  }

  @override
  String get familiarLinesUpper => 'BEKENDE REGELS';

  @override
  String get bestMatchUpper => 'BESTE OVEREENKOMST';

  @override
  String get fullVersionOnPlayback =>
      'We zoeken de volledige versie zodra het afspelen begint.';

  @override
  String get forgotTitle => 'De titel was weg.\nDe muziek niet.';

  @override
  String get startAsYouRemember =>
      'Een naam, titel of regel uit het lied.\nBegin met wat je nog weet.';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => 'Zoek namen zoals ze klinken';

  @override
  String get rememberOnlyLine => 'Ik weet alleen nog een regel';

  @override
  String get findSongByWords => 'Vind een lied op zijn woorden';

  @override
  String get yourArtistsUpper => 'JOE ARTIESTEN';

  @override
  String get language => 'Taal';

  @override
  String get languageCaption => 'De interface volgt je keuze direct';

  @override
  String get systemLanguage => 'Systeem';

  @override
  String get russian => 'Russisch';

  @override
  String get english => 'Engels';

  @override
  String get themesAndShaders => 'Thema\'s en effecten';

  @override
  String get themesSubtitle => 'Uiterlijk, taal en achtergrondbeweging';

  @override
  String get invalidThemeJson =>
      'Kon het thema niet lezen. Controleer het JSON-formaat en de veldwaarden.';

  @override
  String get exportJson => 'JSON exporteren';

  @override
  String get importJson => 'JSON importeren';

  @override
  String get readyThemes => 'Thema-presets';

  @override
  String get gpuShaders => 'Achtergrondeffecten';

  @override
  String get meshGradient =>
      'Gladde GPU-verloop op basis van de kleuren van het nummer';

  @override
  String get vinylNoise => 'Analoge vinylkorrels (ruis)';

  @override
  String get glassBlur => 'Glasvervaging (Backdrop Blur)';

  @override
  String get cornerRadius => 'Hoekstraal van de interface';

  @override
  String get importThemeTitle => 'Thema importeren uit JSON';

  @override
  String get pasteThemeJson => 'Plak de JSON-configuratie van het thema:';

  @override
  String get cancel => 'Annuleren';

  @override
  String get apply => 'Toepassen';

  @override
  String get themeApplied => 'Thema succesvol toegepast!';

  @override
  String get exportThemeTitle => 'Thema exporteren (JSON)';

  @override
  String get close => 'Sluiten';

  @override
  String get copyJson => 'JSON kopiëren';

  @override
  String get jsonCopied => 'Thema-JSON naar het klembord gekopieerd!';

  @override
  String get libraryUpper => 'BIBLIOTHEEK';

  @override
  String get localCollection => 'Lokale collectie en afspeellijsten';

  @override
  String get importShort => 'Importeren';

  @override
  String get favorites => 'Favorieten';

  @override
  String get playlists => 'Afspeellijsten';

  @override
  String get history => 'Geschiedenis';

  @override
  String get offline => 'Offline';

  @override
  String get favoritesEmpty =>
      'Je favorieten zijn leeg.\nTik op het hartje bij een nummer om het hier toe te voegen.';

  @override
  String get historyEmpty =>
      'Je luistergeschiedenis is leeg.\nSpeel muziek af via zoeken en het verschijnt hier.';

  @override
  String get noPlaylists => 'Je hebt nog geen afspeellijsten';

  @override
  String get importPlaylistHint =>
      'Importeer een Spotify-afspeellijst of plak een nummerlijst.';

  @override
  String get importMusicAction => 'Muziek importeren';

  @override
  String get playPlaylist => 'Afspeellijst afspelen';

  @override
  String playlistStarted(String name, int count) {
    return '«$name» wordt afgespeeld ($count nummers)';
  }

  @override
  String get deletePlaylist => 'Afspeellijst verwijderen';

  @override
  String get playAll => 'Alles afspelen';

  @override
  String get shuffle => 'Willekeurig';

  @override
  String get localAudioCache => 'Lokale audiocache';

  @override
  String get cacheDescription =>
      'Afgespeelde nummers worden lokaal bewaard om ze zonder internet direct opnieuw te horen.';

  @override
  String deviceUsage(String size) {
    return 'Op dit apparaat: $size';
  }

  @override
  String get clearCache => 'Alle cache wissen';

  @override
  String savedTracksUpper(int count) {
    return 'OPGESLAGEN NUMMERS ($count):';
  }

  @override
  String get cacheFeaturesUpper => 'CACHE-FUNCTIES:';

  @override
  String get offlineFirst => 'Volledig offline-eerst';

  @override
  String get offlineFirstDescription =>
      'Bij herbeluisteren wordt de audio rechtstreeks uit het bestandssysteem van het apparaat geladen.';

  @override
  String get maximumBitrate => 'Maximale bitrate';

  @override
  String get maximumBitrateDescription =>
      'Schone Opus/M4A-streams van 160–256 kbps worden zonder transcodering bewaard.';

  @override
  String get trafficAndBattery => 'Bespaar data en accu';

  @override
  String get trafficAndBatteryDescription =>
      'Herhaalde netwerkverzoeken vermijden helpt je telefoon langer mee te gaan.';

  @override
  String get cacheEmpty => 'De cache is leeg';

  @override
  String get cachedTracksAppear =>
      'Gedownloade nummers verschijnen hier automatisch';

  @override
  String get removeFromCache => 'Uit cache verwijderen';

  @override
  String get removeCachedTrackTitle => 'Nummer uit de cache verwijderen?';

  @override
  String removeCachedTrackBody(String title) {
    return '«$title» wordt van dit apparaat verwijderd.';
  }

  @override
  String get delete => 'Verwijderen';

  @override
  String get trackRemovedFromCache => 'Nummer uit de cache verwijderd';

  @override
  String get clearCacheTitle => 'Cache wissen?';

  @override
  String get clearCacheBody =>
      'Alle opgeslagen audiobestanden worden van dit apparaat verwijderd. Favorieten en geschiedenis blijven ongewijzigd.';

  @override
  String get cacheCleared => 'Lokale cache gewist';

  @override
  String get back => 'Terug';

  @override
  String get playlistActions => 'Afspeellijstacties';

  @override
  String get playlistUpper => 'AFSPEELLIJST';

  @override
  String get playlistEmpty => 'In deze afspeellijst staan nog geen nummers';

  @override
  String get pasteTrackList => 'Plak een nummerlijst';

  @override
  String get pasteImportLink => 'Plak een link om te importeren';

  @override
  String get tracksNotFound => 'Er zijn geen nummers gevonden op die link.';

  @override
  String get importError =>
      'Import mislukt. Controleer de link en je internetverbinding.';

  @override
  String importedPlaylistStarted(int count) {
    return 'Geïmporteerde afspeellijst wordt afgespeeld ($count nummers)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'Import ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return 'Afspeellijst «$name» opgeslagen in je bibliotheek!';
  }

  @override
  String get spotifyImportSubtitle =>
      'Spotify • Afspeellijsten, albums en nummers';

  @override
  String get artistTrackOrCsv => 'Artiest — Nummer, of een Exportify-CSV';

  @override
  String get pastePlaylistOrTrackLink => 'Plak een afspeellijst- of nummerlink';

  @override
  String get pasteFromClipboard => 'Plakken uit klembord';

  @override
  String get link => 'Link';

  @override
  String get trackList => 'Nummerlijst';

  @override
  String get playlistName => 'Naam van de afspeellijst';

  @override
  String get startImport => 'Import starten';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count nummers';
  }

  @override
  String get importedFromSpotify => 'Geïmporteerd uit Spotify';

  @override
  String get importIntro =>
      'Neem je afspeellijsten mee. Gebruik een Spotify-link, een nummerlijst of een Exportify-bestand.';

  @override
  String get importTextTab => 'Tekst';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'Bestand kiezen';

  @override
  String get importFileHint =>
      'Kies de door Exportify geëxporteerde CSV of een TXT-nummerlijst. UTF-8, tot 10 MB en 10.000 nummers.';

  @override
  String get importFileAndroidOnly =>
      'Bestandskeuze is beschikbaar op Android. Hier kun je de inhoud van een CSV of nummerlijst plakken.';

  @override
  String get importTextHint =>
      'Eén regel per Artiest — Nummer. Je kunt ook de volledige CSV, inclusief de kopregel, plakken.';

  @override
  String get importPreview => 'Voorbeeld van nummers';

  @override
  String get importedFromCsv => 'Geïmporteerd uit CSV';

  @override
  String get importedFromText => 'Geïmporteerd uit een nummerlijst';

  @override
  String importMoreTracks(int count) {
    return 'En $count meer';
  }

  @override
  String get importMetadataHint =>
      'De afspeellijst wordt op dit apparaat opgeslagen. Audio wordt gezocht wanneer je een nummer afspeelt; importeren downloadt geen nummers.';

  @override
  String get importAnother => 'Iets anders importeren';

  @override
  String get importReading => 'Je afspeellijst wordt gelezen…';

  @override
  String get importSaving => 'Opslaan in je bibliotheek…';

  @override
  String get importNameRequired => 'Voer een naam voor de afspeellijst in.';

  @override
  String get importNameExists =>
      'Er bestaat al een afspeellijst met deze naam. Kies een andere naam om beide te bewaren.';

  @override
  String get importSaveFailed =>
      'Kon de afspeellijst niet opslaan. Je voorbeeld is er nog — probeer het opnieuw.';

  @override
  String get importFileTooLarge =>
      'Dit bestand is groter dan 10 MB. Splits de afspeellijst in kleinere exports.';

  @override
  String get importFileUnsupported => 'Kies een .csv- of .txt-bestand.';

  @override
  String get importFileEncoding =>
      'Kon de tekstcodering niet lezen. Sla het bestand op als UTF-8 en probeer het opnieuw.';

  @override
  String get importCsvInvalid =>
      'De CSV is onvolledig of ongeldig. Exporteer hem opnieuw zonder kolommen of aanhalingstekens te wijzigen.';

  @override
  String get importCsvMissingColumns =>
      'De CSV heeft de kolommen Track Name en Artist Name(s), of Title en Artist nodig. Gebruik de oorspronkelijke Exportify-export.';

  @override
  String get importFileEmpty =>
      'Geen nummers gevonden. Kies een gevulde export of plak een Artiest — Nummer-lijst.';

  @override
  String get importTooManyTracks =>
      'Eén import kan maximaal 10.000 nummers bevatten. Splits deze afspeellijst; er is nog niets opgeslagen.';

  @override
  String get importFileReadFailed =>
      'Kon dit bestand niet openen. Controleer of het beschikbaar is op je apparaat en kies het opnieuw.';

  @override
  String get importSpotifyBlocked =>
      'Spotify heeft deze afspeellijst niet gedeeld in jouw regio. Exporteer met Exportify en kies het CSV-bestand.';

  @override
  String get listen => 'Afspelen';

  @override
  String get addToPlaylists => 'Toevoegen aan afspeellijsten';

  @override
  String trackSemantics(String title, String artist) {
    return 'Nummer $title, $artist';
  }

  @override
  String get trackActions => 'Nummeracties';

  @override
  String get startWaveFromTrack => 'Een golf starten vanaf dit nummer';

  @override
  String get addToQueue => 'Aan wachtrij toevoegen';

  @override
  String addedToQueue(String title) {
    return 'Aan wachtrij toegevoegd: $title';
  }

  @override
  String get removeFavorite => 'Uit favorieten verwijderen';

  @override
  String get addFavorite => 'Aan favorieten toevoegen';

  @override
  String get addToPlaylist => 'Aan afspeellijst toevoegen';

  @override
  String get goToArtist => 'Naar de artiest';

  @override
  String get myPlaylist => 'Mijn afspeellijst';

  @override
  String get newPlaylist => 'Nieuwe afspeellijst';

  @override
  String get name => 'Naam';

  @override
  String get create => 'Maken';

  @override
  String get loading => 'Laden…';

  @override
  String get pause => 'Pauze';

  @override
  String get play => 'Afspelen';

  @override
  String get next => 'Volgende';

  @override
  String get speedAndPitch => 'Snelheid en toonhoogte';

  @override
  String speedValue(String value) {
    return 'Snelheid: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'Toonhoogte: ${value}x';
  }

  @override
  String get reset => 'Herstellen';

  @override
  String get moreActions => 'Meer acties';

  @override
  String get playbackQueue => 'Afspeelwachtrij';

  @override
  String get queueEmpty => 'De wachtrij is leeg';

  @override
  String get selectingSource => 'Bron wordt gekozen';

  @override
  String get collapsePlayer => 'Speler samenvouwen';

  @override
  String get nowPlayingUpper => 'NU AAN HET SPELEN';

  @override
  String get queue => 'Wachtrij';

  @override
  String get startWave => 'Golf starten';

  @override
  String get cover => 'Hoes';

  @override
  String get karaokeLyrics => 'Karaoke-songtekst';

  @override
  String get findMusicStart => 'Vind muziek en begin met afspelen';

  @override
  String get playbackNotStarted => 'Het afspelen is nog niet gestart';

  @override
  String get openSearchFirstTrack =>
      'Open zoeken om je eerste nummer te vinden';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => 'Op apparaat';

  @override
  String get sourceCatalog => 'Catalogus';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'Server';

  @override
  String get serverResolver => 'Resolver-server';

  @override
  String get serverResolverCaption =>
      'Optionele zelfgehoste server die volledige audiostreams oplost. De app stuurt een zoekopdracht of nummer-ID; de server geeft een afspeel-URL terug. Het contract en een referentie-implementatie staan in docs/REMOTE_RESOLVER.md.';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'Niet geconfigureerd';

  @override
  String get serverSave => 'Opslaan';

  @override
  String get serverDisable => 'Uitschakelen';

  @override
  String get onboardingWelcomeTitle => 'Welkom bij Hook';

  @override
  String get onboardingWelcomeCaption =>
      'Muziek, songteksten en je eigen visuele stijl. Kies een taal om te beginnen — je kunt hem later in de instellingen wijzigen.';

  @override
  String get onboardingSkip => 'Overslaan';

  @override
  String get onboardingNext => 'Doorgaan';

  @override
  String get onboardingStart => 'Beginnen met luisteren';

  @override
  String get onboardingMicrogTitle => 'MicroG en het Google-account';

  @override
  String get onboardingMicrogBody =>
      'MicroG bouwt Google-diensten opnieuw op aangepaste Android-ROM\'s die er zonder worden geleverd. Hook gebruikt ze slechts voor één optionele functie: een YouTube-account koppelen om je afspeellijsten te importeren. Muziek afspelen heeft nooit MicroG of een Google-dienst nodig.';

  @override
  String get onboardingMicrogNote =>
      'Afspelen hangt niet af van MicroG. Een account koppelen is optioneel.';

  @override
  String get onboardingMicrogDownload => 'MicroG downloaden';

  @override
  String get onboardingMicrogStatusChecking =>
      'Google-diensten worden gecontroleerd…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'Google-diensten zijn aanwezig op dit apparaat ($version). Account-import werkt meteen.';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'ReVanced GmsCore gedetecteerd ($version). De officiële Google-aanmeld-SDK is er niet mee compatibel, dus accountkoppeling werkt mogelijk niet. Afspelen is niet beïnvloed.';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'Google-diensten zijn niet gevonden. Om afspeellijsten uit een YouTube-account te importeren, installeer eerst MicroG — of sla dit over en gebruik Hook zonder account.';

  @override
  String lyricsView(String mode) {
    return 'Songtekstweergave · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'Je leesritme';

  @override
  String get lyricsModeSubtitle =>
      'Drie manieren om dichter bij het lied te komen.';

  @override
  String get lyricsModeLines => 'Regels';

  @override
  String get lyricsModeKaraoke => 'Karaoke';

  @override
  String get lyricsModeFocus => 'Focus';

  @override
  String get lyricsModeLinesDescription =>
      'Rustige songtekst met de huidige regel gemarkeerd';

  @override
  String get lyricsModeKaraokeDescription =>
      'Woorden lichten zachtjes op met de zang';

  @override
  String get lyricsModeFocusDescription => 'Eén grote regel. Niets anders';

  @override
  String get lyricsModeSaveFailed => 'Kon de songtekstweergave niet opslaan.';

  @override
  String get lyricsModeFootnote =>
      'Je keuze wordt bewaard voor toekomstige nummers. De nauwkeurigheid van karaoke hangt af van de brongegevens: woordmarkering is bij benadering zonder woordtiming, en de tekst blijft stil zonder tijdstempels.';

  @override
  String get lyricsNotFound => 'Songtekst niet gevonden';

  @override
  String get karaokeUnavailable =>
      'Karaoke-songtekst is niet beschikbaar voor dit nummer';

  @override
  String get unsyncedLyrics => 'Niet-gesynchroniseerde songtekst';

  @override
  String get wordSyncUpper => 'WOORD-VOOR-WOORD SYNC';

  @override
  String get lineSyncUpper => 'REGEL-VOOR-REGEL SYNC';

  @override
  String get adjustLyricsSync => 'Songtekst-synchronisatie aanpassen';

  @override
  String get startsSoon => 'Begint zo';

  @override
  String get musicContinues => 'De muziek gaat door';

  @override
  String get decreaseLyricsOffset => 'Verschiving 0,1 s verminderen';

  @override
  String lyricsOffset(String value) {
    return 'Verschiving: $value s';
  }

  @override
  String get increaseLyricsOffset => 'Verschiving 0,1 s vergroten';

  @override
  String get hideSetting => 'Instelling verbergen';

  @override
  String get lyricsOffsetSaveFailed =>
      'Kon de songtekst-verschiving niet opslaan.';

  @override
  String get audioForbidden =>
      'De audioserver weigerde toegang (HTTP 403). Het nummer is gevonden, maar zijn stream is niet beschikbaar. Een VPN garandeert geen toegang tot audio.';

  @override
  String get fullVersionUnavailable =>
      'Er is geen volledige versie gevonden in de beschikbare bronnen. Controleer je verbinding of probeer het later.';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source kon dit nummer niet afspelen. Controleer je verbinding of probeer het later.';
  }

  @override
  String get recentQueriesUpper => 'RECENTE ZOEKOPDRACHTEN';

  @override
  String get clearHistory => 'Wissen';

  @override
  String get waveFromArtist => 'Golf van artiest';

  @override
  String get popularTracksUpper => 'POPULAIRE NUMMERS';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nummers',
      one: '1 nummer',
      zero: 'nog geen nummers',
    );
    return '$_temp0';
  }
}
