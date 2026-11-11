// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'Einstellungen';

  @override
  String get settingsCaption =>
      'Änderungen werden auf diesem Gerät gespeichert.';

  @override
  String get playerSettings => 'Player';

  @override
  String get lyricsAutoHide => 'Steuerung beim Lesen des Textes ausblenden';

  @override
  String get lyricsAutoHideDescription =>
      'Nach 10 Sekunden ohne Interaktion gleiten die Player-Panels aus dem Bild. Mit der Wiederherstellen-Taste holst du sie zurück.';

  @override
  String get showPlayerControls => 'Player-Steuerung anzeigen';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get equalizerEnabled => 'Klangverarbeitung';

  @override
  String get equalizerPresets => 'Klangprofil';

  @override
  String get equalizerFlat => 'Original';

  @override
  String get equalizerBass => 'Tiefe Bässe';

  @override
  String get equalizerVocal => 'Gesang';

  @override
  String get equalizerRock => 'Rock';

  @override
  String get equalizerElectronic => 'Electronic';

  @override
  String get equalizerSoft => 'Sanft';

  @override
  String get equalizerCustom => 'Benutzerdefiniert';

  @override
  String get equalizerBands => 'Frequenzbänder';

  @override
  String get equalizerBassBoost => 'Bass-Boost';

  @override
  String get equalizerBassUnsupported =>
      'Zusätzlicher Bass-Boost wird nicht unterstützt. Nutze die Tiefbänder.';

  @override
  String get equalizerPreamp => 'Vorverstärkung';

  @override
  String get equalizerHeadroom => 'Automatischer Headroom';

  @override
  String get equalizerHeadroomDescription =>
      'Reduziert den Ausgangspegel beim Anheben von Frequenzen, um Spitzen Raum zu geben. Kein Limiter.';

  @override
  String get equalizerWaiting =>
      'Starte einen Titel, um den Equalizer mit seiner Audiositzung zu verbinden.';

  @override
  String get equalizerUnsupported =>
      'Klangverarbeitung ist derzeit nur unter Android verfügbar.';

  @override
  String get equalizerFailed =>
      'Dieses Gerät konnte die Audioeffekte nicht aktivieren. Musik läuft auch ohne sie.';

  @override
  String get equalizerRetry => 'Effekte neu verbinden';

  @override
  String get equalizerLive =>
      'Änderungen wirken sofort und werden auf diesem Gerät gespeichert.';

  @override
  String get youtubeAccount => 'YouTube & MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'Lesezugriff auf Playlists. Anmeldung garantiert keine Audioverfügbarkeit.';

  @override
  String get youtubeAccountCompatibility => 'Kompatibilität und Datenschutz';

  @override
  String get youtubeAccountSubtitle => 'Kontoanbindung und Playlist-Import';

  @override
  String get youtubeAccountPrivacy =>
      'Hook fordert nur Lesezugriff auf YouTube an. Gib dein Passwort nur im Systemdialog von Google ein, nie in Hook. Der Token wird an keinen Hook-Server gesendet und bleibt nur im Arbeitsspeicher. Nach dem Neustart der App musst du dich neu verbinden.';

  @override
  String get youtubeAccountPlaybackNotice =>
      'Die Anmeldung gewährt Zugriff auf Kontodaten, nicht auf Audiostreams. Sie behebt kein HTTP 403. Importe behalten die YouTube-Aufnahmen bei, ohne sie durch eine andere Quelle zu ersetzen.';

  @override
  String get youtubeAccountConnect => 'Konto verbinden';

  @override
  String get youtubeAccountDisconnect => 'In Hook abmelden';

  @override
  String get youtubeAccountDisconnected => 'Kein Konto verbunden';

  @override
  String get youtubeAccountDisconnectNotice =>
      'Dieses Konto nur in Hook abmelden? Gespeicherte Playlists bleiben. Google- und MicroG-Konten auf dem Telefon werden nicht abgemeldet.';

  @override
  String get youtubeAccountSystem => 'Google-System-APIs';

  @override
  String get youtubeAccountServicesMissing =>
      'Kompatible Google-System-APIs sind nicht verfügbar. Eine separate ReVanced-GmsCore-Installation ersetzt sie für die Hook-Anmeldung nicht.';

  @override
  String get youtubeAccountMicrogNotice =>
      'Eine separate ReVanced-GmsCore-Installation wurde erkannt. Hook nutzt keine ReVanced-Konten oder -Tokens. Ein System-MicroG kann kompatible Google-APIs bereitstellen, aber die Kompatibilität mit dieser Anmeldemethode ist nicht garantiert.';

  @override
  String get youtubeAccountRevancedFound =>
      'YouTube Music ReVanced ist installiert';

  @override
  String get youtubeAccountPlaylists => 'Konto-Playlists';

  @override
  String get youtubeAccountNoPlaylists =>
      'Keine zugreifbaren Playlists. Einige automatische YouTube-Music-Sammlungen sind über die YouTube Data API nicht verfügbar.';

  @override
  String get youtubeAccountMore => 'Mehr laden';

  @override
  String get youtubeAccountPreview => 'Import vorbereiten';

  @override
  String youtubeAccountProgress(int count) {
    return 'Titel geladen: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'Übersprungene, nicht verfügbare Einträge: $count. Sie werden nicht durch andere Titel ersetzt.';
  }

  @override
  String get youtubeAccountSetup => 'Anmelde-Setup';

  @override
  String get youtubeAccountSetupBody =>
      'Der Entwickler muss die YouTube Data API v3 in Google Cloud aktivieren, einen Android-OAuth-Client für com.hook.music und den Signatur-SHA-1 des installierten Builds registrieren und den Zustimmungsbildschirm konfigurieren. Füge im Testmodus die erlaubten Nutzer hinzu. Siehe docs/YOUTUBE_ACCOUNT_SETUP.md. Füge niemals Passwörter, Client-Secrets oder Tokens anderer Apps hinzu.';

  @override
  String get youtubeAccountConfigError =>
      'Die Anmeldung ist für diesen Build nicht konfiguriert. Prüfe Android-OAuth-Client, Paketnamen, SHA-1 und erlaubte Testnutzer in Google Cloud.';

  @override
  String get youtubeAccountPermissionError =>
      'Der Lesezugriff auf YouTube-Daten wurde nicht gewährt.';

  @override
  String get youtubeAccountExpired =>
      'Deine Sitzung ist abgelaufen. Verbinde das Konto neu.';

  @override
  String get youtubeAccountNoChannel =>
      'Das gewählte Konto hat keinen zugreifbaren YouTube-Kanal.';

  @override
  String get youtubeAccountQuota =>
      'YouTube-API-Kontingent überschritten. Versuche es später erneut.';

  @override
  String get youtubeAccountFailed =>
      'YouTube-Daten konnten nicht abgerufen werden. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get youtubeAccountUnsupported =>
      'Die Kontoanbindung erfordert Android mit kompatiblen Google-System-APIs.';

  @override
  String get importedFromYouTube => 'Aus dem YouTube-Konto importiert';

  @override
  String get translateLyrics => 'Text übersetzen';

  @override
  String get hideTranslation => 'Übersetzung ausblenden';

  @override
  String get cancelTranslation => 'Übersetzung abbrechen';

  @override
  String get translationLoading => 'Übersetzung wird vorbereitet…';

  @override
  String get translationAttribution =>
      'Automatisch übersetzt von Google Translate';

  @override
  String get translationNotice =>
      'Die Übersetzung kann die Bedeutung des Songs ungenau wiedergeben. Die Wort-Hervorhebung gilt nur für das Original.';

  @override
  String get translationModelTitle => 'Sprachmodelle herunterladen?';

  @override
  String get translationModelBody =>
      'Die Übersetzung läuft auf deinem Telefon: Der Text wird an keinen Server gesendet. Die erste Übersetzung benötigt Google-ML-Kit-Modelle mit mehreren zehn Megabytes. Der Download nutzt deine aktuelle Verbindung, auch mobile Daten. Abbrechen blendet das Ergebnis aus, doch ein bereits begonnener Modell-Download kann im Hintergrund fertig werden.';

  @override
  String get translationDownload => 'Herunterladen und übersetzen';

  @override
  String get translationUnavailable =>
      'Übersetzung fehlgeschlagen. Prüfe den Zugriff auf Modell-Downloads und versuche es erneut.';

  @override
  String get translationUnsupported =>
      'Übersetzung auf dem Gerät ist derzeit nur unter Android verfügbar.';

  @override
  String get translationUnknownLanguage =>
      'Es konnte keine unterstützte Sprache für diesen Song erkannt werden.';

  @override
  String get translationSameLanguage =>
      'Der Text ist bereits in der gewählten Sprache.';

  @override
  String get translationTooLarge =>
      'Dieser Text ist zu lang für die Übersetzung auf dem Gerät.';

  @override
  String get translationRussian => 'Auf Russisch';

  @override
  String get translationEnglish => 'Auf Englisch';

  @override
  String get translationTarget => 'Übersetzungssprache';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get home => 'Start';

  @override
  String get search => 'Suchen';

  @override
  String get library => 'Bibliothek';

  @override
  String get youtubeUnavailableTitle => 'YouTube ist gerade nicht verfügbar';

  @override
  String get youtubeUnavailableBody =>
      'Kein Audiostream erhältlich. Prüfe dein Netzwerk und die VPN-Route: YouTube kann Anfragen auch mit VPN ablehnen.';

  @override
  String get checkAgain => 'Erneut prüfen';

  @override
  String get dismiss => 'Ausblenden';

  @override
  String get goodNight => 'Gute Nacht';

  @override
  String get goodMorning => 'Guten Morgen';

  @override
  String get goodAfternoon => 'Guten Tag';

  @override
  String get goodEvening => 'Guten Abend';

  @override
  String get themeSettings => 'Darstellungseinstellungen';

  @override
  String get onYourAir => 'Auf deiner Welle';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neue Signale',
      one: '1 neues Signal',
      zero: 'Keine neuen Signale',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'Deine Sammlung wartet';

  @override
  String get saved => 'Gespeichert';

  @override
  String get collectionEmptyDetail =>
      'Musik, zu der du zurückkehren willst, bleibt hier';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Titel',
      one: '1 Titel',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'Titel, Künstler oder Text';

  @override
  String get searchUpper => 'SUCHEN';

  @override
  String get findFirstTrack => 'Finde deinen ersten Titel';

  @override
  String continuationAfter(String artist) {
    return 'Mehr Musik nach $artist';
  }

  @override
  String get chooseTrackWaveDetail =>
      'Wähle einen Titel und wir bauen eine Welle um seine Stimmung.';

  @override
  String get continueWaveLabel => 'WEITER / 01';

  @override
  String get yourWaveLabel => 'DEINE WELLE / 01';

  @override
  String get continueWave => 'Welle fortsetzen';

  @override
  String get chooseTrack => 'Titel wählen';

  @override
  String get firstTrace => 'Hinterlasse hier deine erste Spur';

  @override
  String get favoriteWaveHint =>
      'Speichere Favoriten, dann wird deine Welle treffsicherer.';

  @override
  String get openSearch => 'Suche öffnen';

  @override
  String get findYourMusic => 'Finde deinen Klang.';

  @override
  String get importMusic => 'Musik importieren';

  @override
  String get rememberedLyricsHint => 'Die Worte, an die du dich erinnerst…';

  @override
  String get trackArtistHint => 'Titel oder Künstler — in jeder Sprache';

  @override
  String get clear => 'Leeren';

  @override
  String get music => 'Musik';

  @override
  String get byLyrics => 'Nach Text';

  @override
  String get allSources => 'Alle Quellen';

  @override
  String get lyricsSearchCaption =>
      'Suche eine Zeile aus dem Song, nicht nur den Titel.';

  @override
  String get searchingLyrics => 'Suche nach bekannten Zeilen…';

  @override
  String get searchingSources => 'Musikquellen werden durchsucht…';

  @override
  String get connectionFailed => 'Verbindung fehlgeschlagen';

  @override
  String get noMatches => 'Noch keine Treffer';

  @override
  String get lyricsUnavailable =>
      'Die Textsuche ist gerade nicht verfügbar. Versuche es später oder suche nach dem Titel.';

  @override
  String get searchUnavailable =>
      'Suche fehlgeschlagen. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get lyricsNoMatches =>
      'Versuche eine andere Zeile. Nicht jeder Text ist indexiert.';

  @override
  String get trackNoMatches =>
      'Ergänze den Künstler oder wähle eine andere Quelle. Manche Dienste sind in deinem Netzwerk evtl. nicht erreichbar.';

  @override
  String get repeatSearch => 'Erneut suchen';

  @override
  String get lyricMatchesUpper => 'TEXT-TREFFER';

  @override
  String get tracksUpper => 'TITEL';

  @override
  String playTrack(String title, String artist) {
    return '„$title“ von $artist spielen';
  }

  @override
  String get familiarLinesUpper => 'BEKANNTE ZEILEN';

  @override
  String get bestMatchUpper => 'BESTER TREFFER';

  @override
  String get fullVersionOnPlayback =>
      'Wir suchen die vollständige Version, sobald die Wiedergabe startet.';

  @override
  String get forgotTitle => 'Der Titel fehlt dir.\nNicht die Musik.';

  @override
  String get startAsYouRemember =>
      'Ein Name, ein Titel oder eine Zeile aus dem Song.\nStarte mit allem, woran du dich erinnerst.';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => 'Suche Namen so, wie sie klingen';

  @override
  String get rememberOnlyLine => 'Ich erinnere mich nur an eine Zeile';

  @override
  String get findSongByWords => 'Song anhand seiner Worte finden';

  @override
  String get yourArtistsUpper => 'DEINE KÜNSTLER';

  @override
  String get language => 'Sprache';

  @override
  String get languageCaption => 'Die Oberfläche folgt sofort deiner Wahl';

  @override
  String get systemLanguage => 'System';

  @override
  String get russian => 'Russisch';

  @override
  String get english => 'Englisch';

  @override
  String get themesAndShaders => 'Themen und Effekte';

  @override
  String get themesSubtitle => 'Aussehen, Sprache und Hintergrundbewegung';

  @override
  String get invalidThemeJson =>
      'Thema konnte nicht gelesen werden. Prüfe das JSON-Format und die Feldwerte.';

  @override
  String get exportJson => 'JSON exportieren';

  @override
  String get importJson => 'JSON importieren';

  @override
  String get readyThemes => 'Design-Voreinstellungen';

  @override
  String get gpuShaders => 'Hintergründe-Effekte';

  @override
  String get meshGradient => 'Weicher GPU-Verlauf aus den Titelfarben';

  @override
  String get vinylNoise => 'Analoges Vinyl-Korn (Noise)';

  @override
  String get glassBlur => 'Glas-Unschärfe (Backdrop Blur)';

  @override
  String get cornerRadius => 'Eckenradius der Oberfläche';

  @override
  String get importThemeTitle => 'Thema aus JSON importieren';

  @override
  String get pasteThemeJson => 'Füge die JSON-Konfiguration des Themas ein:';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get apply => 'Anwenden';

  @override
  String get themeApplied => 'Thema erfolgreich angewendet!';

  @override
  String get exportThemeTitle => 'Thema exportieren (JSON)';

  @override
  String get close => 'Schließen';

  @override
  String get copyJson => 'JSON kopieren';

  @override
  String get jsonCopied => 'Themen-JSON in die Zwischenablage kopiert!';

  @override
  String get libraryUpper => 'BIBLIOTHEK';

  @override
  String get localCollection => 'Lokale Sammlung und Playlists';

  @override
  String get importShort => 'Importieren';

  @override
  String get favorites => 'Favoriten';

  @override
  String get playlists => 'Playlists';

  @override
  String get history => 'Verlauf';

  @override
  String get offline => 'Offline';

  @override
  String get favoritesEmpty =>
      'Deine Favoriten sind leer.\nTippe bei einem Titel auf das Herz, um ihn hier zu sammeln.';

  @override
  String get historyEmpty =>
      'Dein Hörverlauf ist leer.\nSpiele Musik aus der Suche, und er erscheint hier.';

  @override
  String get noPlaylists => 'Du hast noch keine Playlists';

  @override
  String get importPlaylistHint =>
      'Importiere eine Spotify-Playlist oder füge eine Titelliste ein.';

  @override
  String get importMusicAction => 'Musik importieren';

  @override
  String get playPlaylist => 'Playlist abspielen';

  @override
  String playlistStarted(String name, int count) {
    return '„$name“ wird gespielt ($count Titel)';
  }

  @override
  String get deletePlaylist => 'Playlist löschen';

  @override
  String get playAll => 'Alles abspielen';

  @override
  String get shuffle => 'Zufällig';

  @override
  String get localAudioCache => 'Lokaler Audio-Cache';

  @override
  String get cacheDescription =>
      'Gespielte Titel werden lokal gespeichert, um sie ohne Internet sofort erneut zu hören.';

  @override
  String deviceUsage(String size) {
    return 'Auf diesem Gerät: $size';
  }

  @override
  String get clearCache => 'Gesamten Cache leeren';

  @override
  String savedTracksUpper(int count) {
    return 'GESPEICHERTE TITEL ($count):';
  }

  @override
  String get cacheFeaturesUpper => 'CACHE-FUNKTIONEN:';

  @override
  String get offlineFirst => 'Konsequent offline zuerst';

  @override
  String get offlineFirstDescription =>
      'Beim erneuten Hören lädt das Audio direkt aus dem Dateisystem des Geräts.';

  @override
  String get maximumBitrate => 'Maximale Bitrate';

  @override
  String get maximumBitrateDescription =>
      'Saubere Opus-/M4A-Streams mit 160–256 kbps werden ohne Transkodierung gespeichert.';

  @override
  String get trafficAndBattery => 'Daten und Akku sparen';

  @override
  String get trafficAndBatteryDescription =>
      'Wiederholte Netzwerkanfragen vermeiden – dein Telefon hält länger durch.';

  @override
  String get cacheEmpty => 'Der Cache ist leer';

  @override
  String get cachedTracksAppear =>
      'Heruntergeladene Titel erscheinen hier automatisch';

  @override
  String get removeFromCache => 'Aus dem Cache entfernen';

  @override
  String get removeCachedTrackTitle => 'Titel aus dem Cache entfernen?';

  @override
  String removeCachedTrackBody(String title) {
    return '„$title“ wird von diesem Gerät entfernt.';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get trackRemovedFromCache => 'Titel aus dem Cache entfernt';

  @override
  String get clearCacheTitle => 'Cache leeren?';

  @override
  String get clearCacheBody =>
      'Alle gespeicherten Audiodateien werden von diesem Gerät entfernt. Favoriten und Verlauf bleiben unverändert.';

  @override
  String get cacheCleared => 'Lokaler Cache geleert';

  @override
  String get back => 'Zurück';

  @override
  String get playlistActions => 'Playlist-Aktionen';

  @override
  String get playlistUpper => 'PLAYLIST';

  @override
  String get playlistEmpty => 'In dieser Playlist sind noch keine Titel';

  @override
  String get pasteTrackList => 'Titelliste einfügen';

  @override
  String get pasteImportLink => 'Link zum Importieren einfügen';

  @override
  String get tracksNotFound => 'Unter diesem Link wurden keine Titel gefunden.';

  @override
  String get importError =>
      'Import fehlgeschlagen. Prüfe den Link und deine Internetverbindung.';

  @override
  String importedPlaylistStarted(int count) {
    return 'Importierte Playlist wird gespielt ($count Titel)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'Import ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return 'Playlist „$name“ in deiner Bibliothek gespeichert!';
  }

  @override
  String get spotifyImportSubtitle => 'Spotify • Playlists, Alben und Titel';

  @override
  String get artistTrackOrCsv => 'Künstler — Titel oder eine Exportify-CSV';

  @override
  String get pastePlaylistOrTrackLink => 'Playlist- oder Titellink einfügen';

  @override
  String get pasteFromClipboard => 'Aus der Zwischenablage einfügen';

  @override
  String get link => 'Link';

  @override
  String get trackList => 'Titelliste';

  @override
  String get playlistName => 'Playlist-Name';

  @override
  String get startImport => 'Import starten';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count Titel';
  }

  @override
  String get importedFromSpotify => 'Aus Spotify importiert';

  @override
  String get importedFromDeezer => 'Importiert von Deezer';

  @override
  String get importIntro =>
      'Nimm deine Playlists mit. Nutze einen Spotify-Link, eine Titelliste oder eine Exportify-Datei.';

  @override
  String get importTextTab => 'Text';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'Datei wählen';

  @override
  String get importFileHint =>
      'Wähle die von Exportify exportierte CSV oder eine TXT-Titelliste. UTF-8, bis 10 MB und 10.000 Titel.';

  @override
  String get importFileAndroidOnly =>
      'Die Dateiauswahl ist unter Android verfügbar. Hier kannst du den Inhalt einer CSV oder Titelliste einfügen.';

  @override
  String get importTextHint =>
      'Pro Zeile ein Künstler — Titel. Du kannst auch die komplette CSV samt Kopfzeile einfügen.';

  @override
  String get importPreview => 'Titelvorschau';

  @override
  String get importedFromCsv => 'Aus CSV importiert';

  @override
  String get importedFromText => 'Aus einer Titelliste importiert';

  @override
  String importMoreTracks(int count) {
    return 'Und $count weitere';
  }

  @override
  String get importMetadataHint =>
      'Die Playlist wird auf diesem Gerät gespeichert. Das Audio wird beim Abspielen gesucht; der Import lädt keine Songs herunter.';

  @override
  String get importAnother => 'Etwas anderes importieren';

  @override
  String get importReading => 'Deine Playlist wird gelesen…';

  @override
  String get importSaving => 'In deiner Bibliothek wird gespeichert…';

  @override
  String get importNameRequired => 'Gib einen Playlist-Namen ein.';

  @override
  String get importNameExists =>
      'Eine Playlist mit diesem Namen existiert bereits. Wähle einen anderen, um beide zu behalten.';

  @override
  String get importSaveFailed =>
      'Playlist konnte nicht gespeichert werden. Deine Vorschau bleibt bestehen — versuche es erneut.';

  @override
  String get importFileTooLarge =>
      'Diese Datei ist größer als 10 MB. Teile die Playlist in kleinere Exporte auf.';

  @override
  String get importFileUnsupported => 'Wähle eine .csv- oder .txt-Datei.';

  @override
  String get importFileEncoding =>
      'Die Textkodierung konnte nicht gelesen werden. Speichere die Datei als UTF-8 und versuche es erneut.';

  @override
  String get importCsvInvalid =>
      'Die CSV ist unvollständig oder fehlerhaft. Exportiere sie erneut, ohne Spalten oder Anführungszeichen zu verändern.';

  @override
  String get importCsvMissingColumns =>
      'Die CSV braucht die Spalten Track Name und Artist Name(s) oder Title und Artist. Nutze den originalen Exportify-Export.';

  @override
  String get importFileEmpty =>
      'Keine Titel gefunden. Wähle einen gefüllten Export oder füge eine Künstler—Titel-Liste ein.';

  @override
  String get importTooManyTracks =>
      'Ein einzelner Import umfasst höchstens 10.000 Titel. Teile diese Playlist; es wurde noch nichts gespeichert.';

  @override
  String get importFileReadFailed =>
      'Diese Datei konnte nicht geöffnet werden. Prüfe, ob sie auf deinem Gerät verfügbar ist, und wähle sie erneut.';

  @override
  String get importSpotifyBlocked =>
      'Spotify hat diese Playlist in deiner Region nicht geteilt. Exportiere sie mit Exportify und wähle die CSV-Datei.';

  @override
  String get listen => 'Abspielen';

  @override
  String get addToPlaylists => 'Zu Playlists hinzufügen';

  @override
  String trackSemantics(String title, String artist) {
    return 'Titel $title, $artist';
  }

  @override
  String get trackActions => 'Titel-Aktionen';

  @override
  String get updatesTitle => 'Updates';

  @override
  String get accountTitle => 'Konto';

  @override
  String get waveLoading => 'Ähnliche Titel werden gesucht…';

  @override
  String get sleepTimer => 'Einschlaftimer';

  @override
  String sleepMinutes(String value) {
    return '$value';
  }

  @override
  String get sleepUntilTrackEnd => 'Bis zum Titelende';

  @override
  String get sleepCancel => 'Ausschalten';

  @override
  String get dislike => 'Nicht interessiert';

  @override
  String get dislikeRemove => 'Aus Verborgenen entfernen';

  @override
  String dislikeSaved(String artist) {
    return 'Verborgen: $artist';
  }

  @override
  String get exportPlaylist => 'CSV exportieren';

  @override
  String get playlistExported => 'Playlist exportiert';

  @override
  String get exportFailed => 'Export fehlgeschlagen';

  @override
  String get downloadAll => 'Alles herunterladen';

  @override
  String get statsTitle => 'Statistiken';

  @override
  String get statsPlays => 'Wiedergaben';

  @override
  String get statsFavorites => 'Favoriten';

  @override
  String get statsPlaylists => 'Playlists';

  @override
  String get statsTopArtists => 'Top-Künstler';

  @override
  String get statsTopTracks => 'Top-Titel';

  @override
  String resumeTitle(String device) {
    return 'Auf $device fortfahren';
  }

  @override
  String get alwaysOnTop => 'Fenster oben halten';

  @override
  String get randomPick => 'Zufälliger Vorschlag für dich';

  @override
  String get accountCaption =>
      'Synchronisiere deine Bibliothek geräteübergreifend';

  @override
  String get nickname => 'Nickname';

  @override
  String get nicknameHint => '3–20 Zeichen: Buchstaben, Ziffern, . _ -';

  @override
  String get password => 'Passwort';

  @override
  String get passwordMinHint => 'Mindestens 6 Zeichen';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signUp => 'Konto erstellen';

  @override
  String get haveAccountToggle => 'Schon ein Konto? Anmelden';

  @override
  String get noAccountToggle => 'Noch kein Konto? Erstellt eins';

  @override
  String get signOut => 'Abmelden';

  @override
  String get syncNow => 'Jetzt synchronisieren';

  @override
  String get syncing => 'Synchronisiere…';

  @override
  String syncedAt(String time) {
    return 'Synchronisiert: $time';
  }

  @override
  String get neverSynced => 'Noch nie synchronisiert';

  @override
  String get errorNicknameTaken => 'Dieser Nickname ist bereits vergeben';

  @override
  String get errorNicknameInvalid =>
      'Nickname: 3–20 Zeichen, Buchstaben/Ziffern/._-';

  @override
  String get errorInvalidCredentials => 'Falscher Nickname oder Passwort';

  @override
  String get errorWeakPassword => 'Das Passwort ist zu kurz';

  @override
  String get errorNetwork => 'Keine Verbindung';

  @override
  String get errorServer => 'Serverfehler, versuch es später erneut';

  @override
  String currentVersion(String version) {
    return 'Version $version';
  }

  @override
  String get checkForUpdates => 'Nach Updates suchen';

  @override
  String get checkingForUpdates => 'Wird geprüft…';

  @override
  String get upToDate => 'Du bist auf dem neuesten Stand';

  @override
  String updateAvailable(String version) {
    return 'Version $version ist verfügbar';
  }

  @override
  String get downloadingUpdate => 'Update wird geladen…';

  @override
  String get installUpdate => 'Installieren';

  @override
  String get updateCheckFailed =>
      'Update-Prüfung fehlgeschlagen. Prüfe deine Verbindung.';

  @override
  String get installPermissionNeeded =>
      'Erlaube Hook die Installation von Apps und tippe erneut auf Installieren.';

  @override
  String updateSize(String size) {
    return '$size MB';
  }

  @override
  String get download => 'Herunterladen';

  @override
  String get downloading => 'Wird geladen…';

  @override
  String get downloaded => 'Heruntergeladen';

  @override
  String get downloadFailed => 'Download fehlgeschlagen';

  @override
  String get removeDownload => 'Download löschen';

  @override
  String get downloadSavedOffline => 'Offline gespeichert';

  @override
  String get startWaveFromTrack => 'Welle ab diesem Titel starten';

  @override
  String get addToQueue => 'Zur Warteschlange hinzufügen';

  @override
  String addedToQueue(String title) {
    return 'Zur Warteschlange hinzugefügt: $title';
  }

  @override
  String get removeFavorite => 'Aus Favoriten entfernen';

  @override
  String get addFavorite => 'Zu Favoriten hinzufügen';

  @override
  String get addToPlaylist => 'Zur Playlist hinzufügen';

  @override
  String get goToArtist => 'Zum Künstler';

  @override
  String get myPlaylist => 'Meine Playlist';

  @override
  String get newPlaylist => 'Neue Playlist';

  @override
  String get name => 'Name';

  @override
  String get create => 'Erstellen';

  @override
  String get loading => 'Lädt…';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Abspielen';

  @override
  String get next => 'Weiter';

  @override
  String get speedAndPitch => 'Geschwindigkeit und Tonhöhe';

  @override
  String speedValue(String value) {
    return 'Geschwindigkeit: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'Tonhöhe: ${value}x';
  }

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get moreActions => 'Weitere Aktionen';

  @override
  String get playbackQueue => 'Warteschlange';

  @override
  String get queueEmpty => 'Die Warteschlange ist leer';

  @override
  String get selectingSource => 'Quelle wird gewählt';

  @override
  String get collapsePlayer => 'Player einklappen';

  @override
  String get nowPlayingUpper => 'LÄUFT GERADE';

  @override
  String get queue => 'Warteschlange';

  @override
  String get startWave => 'Welle starten';

  @override
  String get cover => 'Cover';

  @override
  String get karaokeLyrics => 'Karaoke-Text';

  @override
  String get findMusicStart => 'Finde Musik und starte die Wiedergabe';

  @override
  String get playbackNotStarted => 'Die Wiedergabe hat noch nicht begonnen';

  @override
  String get openSearchFirstTrack =>
      'Öffne die Suche, um deinen ersten Titel zu finden';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => 'Auf dem Gerät';

  @override
  String get sourceCatalog => 'Katalog';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'Server';

  @override
  String get serverResolver => 'Resolver-Server';

  @override
  String get serverResolverCaption =>
      'Optionaler, selbst gehosteter Server, der vollständige Audiostreams auflöst. Die App sendet eine Suchanfrage oder Titel-ID; der Server antwortet mit einer Wiedergabe-URL. Vertrag und Referenzimplementierung liegen in docs/REMOTE_RESOLVER.md.';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'Nicht konfiguriert';

  @override
  String get serverSave => 'Speichern';

  @override
  String get serverDisable => 'Deaktivieren';

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei Hook';

  @override
  String get onboardingWelcomeCaption =>
      'Musik, Texte und dein eigener visueller Stil. Wähle eine Sprache, um zu starten — du kannst sie später in den Einstellungen wechseln.';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingStart => 'Loslegen';

  @override
  String get onboardingMicrogTitle => 'MicroG und das Google-Konto';

  @override
  String get onboardingMicrogBody =>
      'MicroG stellt Google-Dienste auf benutzerdefinierten Android-ROMs nach, die ohne sie ausgeliefert werden. Hook nutzt sie nur für eine optionale Funktion: ein YouTube-Konto zu verbinden, um Playlists zu importieren. Zum Musikhören braucht es weder MicroG noch irgendeinen Google-Dienst.';

  @override
  String get onboardingMicrogNote =>
      'Die Wiedergabe hängt nicht von MicroG ab. Die Kontoverbindung ist optional.';

  @override
  String get onboardingMicrogDownload => 'MicroG herunterladen';

  @override
  String get onboardingMicrogStatusChecking => 'Google-Dienste werden geprüft…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'Google-Dienste sind auf diesem Gerät vorhanden ($version). Der Kontoimport funktioniert sofort.';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'ReVanced GmsCore erkannt ($version). Das offizielle Google-SDK ist damit nicht kompatibel, die Kontoverbindung kann also scheitern. Die Wiedergabe ist nicht betroffen.';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'Google-Dienste wurden nicht gefunden. Um Playlists aus einem YouTube-Konto zu importieren, installiere zuerst MicroG — oder überspringe dies und nutze Hook ohne Konto.';

  @override
  String lyricsView(String mode) {
    return 'Textansicht · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'Dein Leserythmus';

  @override
  String get lyricsModeSubtitle => 'Drei Wege, dem Song näherzukommen.';

  @override
  String get lyricsModeLines => 'Zeilen';

  @override
  String get lyricsModeKaraoke => 'Karaoke';

  @override
  String get lyricsModeFocus => 'Fokus';

  @override
  String get lyricsModeLinesDescription =>
      'Ruhiger Text mit hervorgehobener aktueller Zeile';

  @override
  String get lyricsModeKaraokeDescription =>
      'Die Wörter leuchten sanft mit dem Gesang auf';

  @override
  String get lyricsModeFocusDescription => 'Eine große Zeile. Nichts weiter';

  @override
  String get lyricsModeSaveFailed =>
      'Textansicht konnte nicht gespeichert werden.';

  @override
  String get lyricsModeFootnote =>
      'Deine Wahl wird für künftige Songs gespeichert. Die Karaoke-Genauigkeit hängt von den Daten der Quelle ab: ohne Wort-Timing ist die Hervorhebung nur ungefähr, ohne Zeitstempel bleibt der Text stehen.';

  @override
  String get lyricsNotFound => 'Text nicht gefunden';

  @override
  String get karaokeUnavailable =>
      'Karaoke-Text ist für diesen Titel nicht verfügbar';

  @override
  String get unsyncedLyrics => 'Unsynchronisierter Text';

  @override
  String get wordSyncUpper => 'SYNCHRONISATION WORT FÜR WORT';

  @override
  String get lineSyncUpper => 'SYNCHRONISATION ZEILE FÜR ZEILE';

  @override
  String get adjustLyricsSync => 'Text-Synchronisation anpassen';

  @override
  String get startsSoon => 'Es geht bald los';

  @override
  String get musicContinues => 'Die Musik läuft weiter';

  @override
  String get decreaseLyricsOffset => 'Versatz um 0,1 s verringern';

  @override
  String lyricsOffset(String value) {
    return 'Versatz: $value s';
  }

  @override
  String get increaseLyricsOffset => 'Versatz um 0,1 s erhöhen';

  @override
  String get hideSetting => 'Einstellung ausblenden';

  @override
  String get lyricsOffsetSaveFailed =>
      'Text-Versatz konnte nicht gespeichert werden.';

  @override
  String get audioForbidden =>
      'Der Audioserver hat den Zugriff verweigert (HTTP 403). Der Titel wurde gefunden, aber sein Stream ist nicht verfügbar. Ein VPN garantiert keinen Audiozugriff.';

  @override
  String get fullVersionUnavailable =>
      'In den verfügbaren Quellen wurde keine vollständige Version gefunden. Prüfe deine Verbindung oder versuche es später.';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source konnte diesen Titel nicht wiedergeben. Prüfe deine Verbindung oder versuche es später.';
  }

  @override
  String get recentQueriesUpper => 'LETZTE SUCHANFRAGEN';

  @override
  String get clearHistory => 'Löschen';

  @override
  String get waveFromArtist => 'Künstlerwelle';

  @override
  String get popularTracksUpper => 'BELIEBTE TITEL';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Titel',
      one: '1 Titel',
      zero: 'noch keine Titel',
    );
    return '$_temp0';
  }

  @override
  String get volume => 'Lautstärke';

  @override
  String get systemVolume => 'System';

  @override
  String get appVolume => 'Hook-Pegel';

  @override
  String get mute => 'Stummschalten';

  @override
  String get unmute => 'Ton einschalten';

  @override
  String get volumeMixer => 'Ton und Lautstärke';

  @override
  String get systemVolumeCaption =>
      'Die Windows-Ausgangslautstärke, geteilt mit allen Apps';

  @override
  String get appVolumeCaption =>
      'Nur innerhalb von Hook, oberhalb des Systempegels';

  @override
  String get volumeKeysHint => 'Ctrl + ↑ ↓ Lautstärke · M stumm';

  @override
  String get volumeUnavailable =>
      'Systemlautstärke ist auf diesem Gerät nicht verfügbar';

  @override
  String get cacheFolder => 'Speicherordner';

  @override
  String get copyPath => 'Pfad kopieren';

  @override
  String get pathCopied => 'Pfad in die Zwischenablage kopiert';

  @override
  String get previousTrack => 'Vorheriger Titel';

  @override
  String get repeatPlayback => 'Wiederholen';

  @override
  String get openPlayer => 'Player öffnen';

  @override
  String get statsWeek => 'Letzte 7 Tage';

  @override
  String get keyboardShortcuts => 'Tastenkürzel';

  @override
  String get shortcutsCaption => 'Funktionieren überall außer in Textfeldern.';

  @override
  String get shortcutsSeek => '10 Sekunden springen';

  @override
  String get playPauseShortcut => 'Wiedergabe / Pause';
}
