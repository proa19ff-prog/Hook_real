// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'Réglages';

  @override
  String get settingsCaption =>
      'Les modifications sont enregistrées sur cet appareil.';

  @override
  String get playerSettings => 'Lecteur';

  @override
  String get lyricsAutoHide =>
      'Masquer les commandes pendant la lecture des paroles';

  @override
  String get lyricsAutoHideDescription =>
      'Après 10 secondes sans interaction, les panneaux du lecteur glissent hors de l\'écran. Utilisez le bouton de restauration pour les faire revenir.';

  @override
  String get showPlayerControls => 'Afficher les commandes du lecteur';

  @override
  String get equalizer => 'Égaliseur';

  @override
  String get equalizerEnabled => 'Traitement du son';

  @override
  String get equalizerPresets => 'Profil sonore';

  @override
  String get equalizerFlat => 'Original';

  @override
  String get equalizerBass => 'Basses profonds';

  @override
  String get equalizerVocal => 'Voix';

  @override
  String get equalizerRock => 'Rock';

  @override
  String get equalizerElectronic => 'Électronique';

  @override
  String get equalizerSoft => 'Doux';

  @override
  String get equalizerCustom => 'Personnalisé';

  @override
  String get equalizerBands => 'Bandes de fréquences';

  @override
  String get equalizerBassBoost => 'Renforcement des basses';

  @override
  String get equalizerBassUnsupported =>
      'Le renforcement supplémentaire des basses n\'est pas pris en charge. Utilisez les bandes basses fréquences.';

  @override
  String get equalizerPreamp => 'Préamplification';

  @override
  String get equalizerHeadroom => 'Marge automatique';

  @override
  String get equalizerHeadroomDescription =>
      'Réduit le niveau de sortie lors du renforcement des fréquences pour laisser de la place aux pics. Ce n\'est pas un limiteur.';

  @override
  String get equalizerWaiting =>
      'Lancez un morceau pour connecter l\'égaliseur à sa session audio.';

  @override
  String get equalizerUnsupported =>
      'Le traitement du son n\'est disponible que sur Android pour le moment.';

  @override
  String get equalizerFailed =>
      'Cet appareil n\'a pas pu activer les effets audio. La musique peut toujours être lue sans eux.';

  @override
  String get equalizerRetry => 'Reconnecter les effets';

  @override
  String get equalizerLive =>
      'Les modifications s\'appliquent immédiatement et sont enregistrées sur cet appareil.';

  @override
  String get youtubeAccount => 'YouTube et MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'Accès aux playlists en lecture seule. Se connecter ne garantit pas la disponibilité de l\'audio.';

  @override
  String get youtubeAccountCompatibility => 'Compatibilité et confidentialité';

  @override
  String get youtubeAccountSubtitle =>
      'Connexion de compte et import de playlists';

  @override
  String get youtubeAccountPrivacy =>
      'Hook demande un accès YouTube en lecture seule. Saisissez votre mot de passe uniquement dans la fenêtre système de Google, jamais dans Hook. Le jeton n\'est envoyé à aucun serveur Hook et reste en mémoire. Reconnectez-vous après avoir redémarré l\'app.';

  @override
  String get youtubeAccountPlaybackNotice =>
      'Se connecter donne accès aux données du compte, pas aux flux audio. Cela ne garantit pas de corriger l\'erreur HTTP 403. Les imports conservent les enregistrements YouTube sans les remplacer par une autre source.';

  @override
  String get youtubeAccountConnect => 'Connecter le compte';

  @override
  String get youtubeAccountDisconnect => 'Déconnecter dans Hook';

  @override
  String get youtubeAccountDisconnected => 'Aucun compte connecté';

  @override
  String get youtubeAccountDisconnectNotice =>
      'Déconnecter ce compte uniquement dans Hook ? Les playlists enregistrées resteront. Les comptes Google et MicroG du téléphone ne seront pas déconnectés.';

  @override
  String get youtubeAccountSystem => 'API Google du système';

  @override
  String get youtubeAccountServicesMissing =>
      'Les API Google du système compatibles sont indisponibles. Une installation distincte de ReVanced GmsCore ne les remplace pas pour la connexion Hook.';

  @override
  String get youtubeAccountMicrogNotice =>
      'Une installation distincte de ReVanced GmsCore a été détectée. Hook n\'utilise ni les comptes ni les jetons ReVanced. Un MicroG système peut fournir des API Google compatibles, mais la compatibilité avec cette méthode de connexion n\'est pas garantie.';

  @override
  String get youtubeAccountRevancedFound =>
      'YouTube Music ReVanced est installé';

  @override
  String get youtubeAccountPlaylists => 'Playlists du compte';

  @override
  String get youtubeAccountNoPlaylists =>
      'Aucune playlist accessible. Certaines collections automatiques de YouTube Music ne sont pas disponibles via la YouTube Data API.';

  @override
  String get youtubeAccountMore => 'Charger plus';

  @override
  String get youtubeAccountPreview => 'Préparer l\'import';

  @override
  String youtubeAccountProgress(int count) {
    return 'Pistes récupérées : $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'Entrées indisponibles ignorées : $count. Elles ne sont pas remplacées par d\'autres pistes.';
  }

  @override
  String get youtubeAccountSetup => 'Configuration de la connexion';

  @override
  String get youtubeAccountSetupBody =>
      'Le développeur doit activer YouTube Data API v3 dans Google Cloud, enregistrer un client OAuth Android pour com.hook.music et le SHA-1 de signature de la version installée, puis configurer l\'écran de consentement. Ajoutez les utilisateurs autorisés en mode test. Voir docs/YOUTUBE_ACCOUNT_SETUP.md. N\'ajoutez jamais de mots de passe, de secrets client ni de jetons d\'autres apps.';

  @override
  String get youtubeAccountConfigError =>
      'La connexion n\'est pas configurée pour cette version. Vérifiez le client OAuth Android, le nom du paquet, le SHA-1 et les utilisateurs test autorisés dans Google Cloud.';

  @override
  String get youtubeAccountPermissionError =>
      'L\'accès en lecture aux données YouTube n\'a pas été accordé.';

  @override
  String get youtubeAccountExpired =>
      'Votre session a expiré. Reconnectez le compte.';

  @override
  String get youtubeAccountNoChannel =>
      'Le compte sélectionné n\'a pas de chaîne YouTube accessible.';

  @override
  String get youtubeAccountQuota =>
      'Quota de l\'API YouTube dépassé. Réessayez plus tard.';

  @override
  String get youtubeAccountFailed =>
      'Impossible de récupérer les données YouTube. Vérifiez votre connexion et réessayez.';

  @override
  String get youtubeAccountUnsupported =>
      'La connexion de compte requiert Android avec des API Google du système compatibles.';

  @override
  String get importedFromYouTube => 'Importé depuis le compte YouTube';

  @override
  String get translateLyrics => 'Traduire les paroles';

  @override
  String get hideTranslation => 'Masquer la traduction';

  @override
  String get cancelTranslation => 'Annuler la traduction';

  @override
  String get translationLoading => 'Préparation de la traduction…';

  @override
  String get translationAttribution =>
      'Traduit automatiquement par Google Traduction';

  @override
  String get translationNotice =>
      'La traduction peut ne pas refléter fidèlement le sens de la chanson. Le surlignage des mots ne s\'applique qu\'à l\'original.';

  @override
  String get translationModelTitle => 'Télécharger les modèles de langue ?';

  @override
  String get translationModelBody =>
      'La traduction s\'exécute sur votre téléphone : les paroles ne sont envoyées à aucun serveur. La première traduction nécessite les modèles Google ML Kit, qui pèsent des dizaines de mégaoctets. Le téléchargement utilise votre connexion actuelle, y compris les données mobiles. Annuler masque le résultat, mais un téléchargement déjà lancé peut se terminer en arrière-plan.';

  @override
  String get translationDownload => 'Télécharger et traduire';

  @override
  String get translationUnavailable =>
      'Échec de la traduction. Vérifiez l\'accès aux téléchargements de modèles et réessayez.';

  @override
  String get translationUnsupported =>
      'La traduction sur l\'appareil n\'est disponible que sur Android pour le moment.';

  @override
  String get translationUnknownLanguage =>
      'Impossible d\'identifier une langue prise en charge pour cette chanson.';

  @override
  String get translationSameLanguage =>
      'Les paroles sont déjà dans la langue sélectionnée.';

  @override
  String get translationTooLarge =>
      'Ces paroles sont trop longues pour la traduction sur l\'appareil.';

  @override
  String get translationRussian => 'Vers le russe';

  @override
  String get translationEnglish => 'Vers l\'anglais';

  @override
  String get translationTarget => 'Langue de traduction';

  @override
  String get retry => 'Réessayer';

  @override
  String get home => 'Accueil';

  @override
  String get search => 'Rechercher';

  @override
  String get library => 'Bibliothèque';

  @override
  String get youtubeUnavailableTitle => 'YouTube est actuellement indisponible';

  @override
  String get youtubeUnavailableBody =>
      'Impossible d\'obtenir un flux audio. Vérifiez votre réseau et votre itinéraire VPN : YouTube peut rejeter les requêtes même avec un VPN.';

  @override
  String get checkAgain => 'Vérifier à nouveau';

  @override
  String get dismiss => 'Fermer';

  @override
  String get goodNight => 'Bonne nuit';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get themeSettings => 'Réglages d\'apparence';

  @override
  String get onYourAir => 'Sur votre antenne';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count signaux récents',
      one: '1 signal récent',
      zero: 'Aucun signal récent',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'Votre collection vous attend';

  @override
  String get saved => 'Enregistré';

  @override
  String get collectionEmptyDetail =>
      'La musique à laquelle vous voulez revenir restera ici';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistes',
      one: '1 piste',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'Piste, artiste ou paroles';

  @override
  String get searchUpper => 'RECHERCHER';

  @override
  String get findFirstTrack => 'Trouvez votre première piste';

  @override
  String continuationAfter(String artist) {
    return 'Plus de musique après $artist';
  }

  @override
  String get chooseTrackWaveDetail =>
      'Choisissez une piste et nous construirons une vague autour de son ambiance.';

  @override
  String get continueWaveLabel => 'CONTINUER / 01';

  @override
  String get yourWaveLabel => 'VOTRE VAGUE / 01';

  @override
  String get continueWave => 'Continuer la vague';

  @override
  String get chooseTrack => 'Choisir une piste';

  @override
  String get firstTrace => 'Laissez ici votre première trace';

  @override
  String get favoriteWaveHint =>
      'Enregistrez des favoris et votre vague deviendra plus précise.';

  @override
  String get openSearch => 'Ouvrir la recherche';

  @override
  String get findYourMusic => 'Trouvez votre son.';

  @override
  String get importMusic => 'Importer de la musique';

  @override
  String get rememberedLyricsHint => 'Les mots dont vous vous souvenez…';

  @override
  String get trackArtistHint =>
      'Piste ou artiste — dans n\'importe quelle langue';

  @override
  String get clear => 'Effacer';

  @override
  String get music => 'Musique';

  @override
  String get byLyrics => 'Par les paroles';

  @override
  String get allSources => 'Toutes les sources';

  @override
  String get lyricsSearchCaption =>
      'Cherchez une phrase de la chanson, pas seulement son titre.';

  @override
  String get searchingLyrics => 'Recherche de lignes familières…';

  @override
  String get searchingSources => 'Recherche dans les sources musicales…';

  @override
  String get connectionFailed => 'Impossible de se connecter';

  @override
  String get noMatches => 'Aucune correspondance pour l\'instant';

  @override
  String get lyricsUnavailable =>
      'La recherche de paroles est indisponible pour le moment. Réessayez plus tard ou cherchez par titre.';

  @override
  String get searchUnavailable =>
      'Échec de la recherche. Vérifiez votre connexion et réessayez.';

  @override
  String get lyricsNoMatches =>
      'Essayez une autre ligne. Toutes les paroles ne sont pas indexées.';

  @override
  String get trackNoMatches =>
      'Ajoutez l\'artiste ou choisissez une autre source. Certains services peuvent être indisponibles sur votre réseau.';

  @override
  String get repeatSearch => 'Rechercher à nouveau';

  @override
  String get lyricMatchesUpper => 'CORRESPONDANCES DE PAROLES';

  @override
  String get tracksUpper => 'PISTES';

  @override
  String playTrack(String title, String artist) {
    return 'Lire $title, $artist';
  }

  @override
  String get familiarLinesUpper => 'LIGNES FAMILIÈRES';

  @override
  String get bestMatchUpper => 'MEILLEURE CORRESPONDANCE';

  @override
  String get fullVersionOnPlayback =>
      'Nous chercherons la version complète au début de la lecture.';

  @override
  String get forgotTitle => 'Vous avez oublié le titre.\nPas la musique.';

  @override
  String get startAsYouRemember =>
      'Un nom, un titre ou une ligne de la chanson.\nCommencez par ce dont vous vous souvenez.';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => 'Cherchez les noms comme ils sonnent';

  @override
  String get rememberOnlyLine => 'Je me souviens seulement d\'une ligne';

  @override
  String get findSongByWords => 'Trouver une chanson par ses mots';

  @override
  String get yourArtistsUpper => 'VOS ARTISTES';

  @override
  String get language => 'Langue';

  @override
  String get languageCaption => 'L\'interface suit votre choix immédiatement';

  @override
  String get systemLanguage => 'Système';

  @override
  String get russian => 'Russe';

  @override
  String get english => 'Anglais';

  @override
  String get themesAndShaders => 'Thèmes et effets';

  @override
  String get themesSubtitle => 'Apparence, langue et mouvement du fond';

  @override
  String get invalidThemeJson =>
      'Impossible de lire le thème. Vérifiez le format JSON et les valeurs des champs.';

  @override
  String get exportJson => 'Exporter en JSON';

  @override
  String get importJson => 'Importer un JSON';

  @override
  String get readyThemes => 'Thèmes prédéfinis';

  @override
  String get gpuShaders => 'Effets d\'arrière-plan';

  @override
  String get meshGradient =>
      'Dégradé GPU lisse basé sur les couleurs du morceau';

  @override
  String get vinylNoise => 'Grain de vinyle analogique (bruit)';

  @override
  String get glassBlur => 'Flou de verre (Backdrop Blur)';

  @override
  String get cornerRadius => 'Rayon des angles de l\'interface';

  @override
  String get importThemeTitle => 'Importer un thème depuis un JSON';

  @override
  String get pasteThemeJson => 'Collez la configuration JSON du thème :';

  @override
  String get cancel => 'Annuler';

  @override
  String get apply => 'Appliquer';

  @override
  String get themeApplied => 'Thème appliqué avec succès !';

  @override
  String get exportThemeTitle => 'Exporter le thème (JSON)';

  @override
  String get close => 'Fermer';

  @override
  String get copyJson => 'Copier le JSON';

  @override
  String get jsonCopied => 'JSON du thème copié dans le presse-papiers !';

  @override
  String get libraryUpper => 'BIBLIOTHÈQUE';

  @override
  String get localCollection => 'Collection locale et playlists';

  @override
  String get importShort => 'Importer';

  @override
  String get favorites => 'Favoris';

  @override
  String get playlists => 'Playlists';

  @override
  String get history => 'Historique';

  @override
  String get offline => 'Hors ligne';

  @override
  String get favoritesEmpty =>
      'Vos favoris sont vides.\nTouchez le cœur d\'une piste pour l\'ajouter ici.';

  @override
  String get historyEmpty =>
      'Votre historique d\'écoute est vide.\nÉcoutez de la musique via la recherche et elle apparaîtra ici.';

  @override
  String get noPlaylists => 'Vous n\'avez pas encore de playlist';

  @override
  String get importPlaylistHint =>
      'Importez une playlist Spotify ou collez une liste de pistes.';

  @override
  String get importMusicAction => 'Importer de la musique';

  @override
  String get playPlaylist => 'Lire la playlist';

  @override
  String playlistStarted(String name, int count) {
    return 'Lecture de « $name » ($count pistes)';
  }

  @override
  String get deletePlaylist => 'Supprimer la playlist';

  @override
  String get playAll => 'Tout lire';

  @override
  String get shuffle => 'Aléatoire';

  @override
  String get localAudioCache => 'Cache audio local';

  @override
  String get cacheDescription =>
      'Les pistes écoutées sont stockées localement pour une réécoute instantanée sans connexion.';

  @override
  String deviceUsage(String size) {
    return 'Sur cet appareil : $size';
  }

  @override
  String get clearCache => 'Vider tout le cache';

  @override
  String savedTracksUpper(int count) {
    return 'PISTES ENREGISTRÉES ($count) :';
  }

  @override
  String get cacheFeaturesUpper => 'FONCTIONS DU CACHE :';

  @override
  String get offlineFirst => 'Priorité au hors-ligne';

  @override
  String get offlineFirstDescription =>
      'À la réécoute, l\'audio se charge directement depuis le système de fichiers de l\'appareil.';

  @override
  String get maximumBitrate => 'Débit maximal';

  @override
  String get maximumBitrateDescription =>
      'Les flux propres Opus/M4A à 160–256 kbps sont mis en cache sans transcodage.';

  @override
  String get trafficAndBattery => 'Économisez données et batterie';

  @override
  String get trafficAndBatteryDescription =>
      'Éviter les requêtes réseau répétées aide votre téléphone à durer plus longtemps.';

  @override
  String get cacheEmpty => 'Le cache est vide';

  @override
  String get cachedTracksAppear =>
      'Les pistes téléchargées apparaîtront ici automatiquement';

  @override
  String get removeFromCache => 'Retirer du cache';

  @override
  String get removeCachedTrackTitle => 'Retirer la piste du cache ?';

  @override
  String removeCachedTrackBody(String title) {
    return '« $title » sera retirée de cet appareil.';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get trackRemovedFromCache => 'Piste retirée du cache';

  @override
  String get clearCacheTitle => 'Vider le cache ?';

  @override
  String get clearCacheBody =>
      'Tous les fichiers audio enregistrés seront supprimés de cet appareil. Les favoris et l\'historique ne changent pas.';

  @override
  String get cacheCleared => 'Cache local vidé';

  @override
  String get back => 'Retour';

  @override
  String get playlistActions => 'Actions de playlist';

  @override
  String get playlistUpper => 'PLAYLIST';

  @override
  String get playlistEmpty => 'Cette playlist ne contient pas encore de pistes';

  @override
  String get pasteTrackList => 'Collez une liste de pistes';

  @override
  String get pasteImportLink => 'Collez un lien à importer';

  @override
  String get tracksNotFound => 'Aucune piste trouvée pour ce lien.';

  @override
  String get importError =>
      'Échec de l\'import. Vérifiez le lien et votre connexion internet.';

  @override
  String importedPlaylistStarted(int count) {
    return 'Lecture de la playlist importée ($count pistes)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'Import ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return 'Playlist « $name » enregistrée dans votre bibliothèque !';
  }

  @override
  String get spotifyImportSubtitle => 'Spotify • Playlists, albums et pistes';

  @override
  String get artistTrackOrCsv => 'Artiste — Titre, ou un CSV Exportify';

  @override
  String get pastePlaylistOrTrackLink =>
      'Collez un lien de playlist ou de piste';

  @override
  String get pasteFromClipboard => 'Coller depuis le presse-papiers';

  @override
  String get link => 'Lien';

  @override
  String get trackList => 'Liste de pistes';

  @override
  String get playlistName => 'Nom de la playlist';

  @override
  String get startImport => 'Lancer l\'import';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count pistes';
  }

  @override
  String get importedFromSpotify => 'Importé depuis Spotify';

  @override
  String get importedFromDeezer => 'Importé depuis Deezer';

  @override
  String get importIntro =>
      'Emportez vos playlists. Utilisez un lien Spotify, une liste de pistes ou un fichier Exportify.';

  @override
  String get importTextTab => 'Texte';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'Choisir un fichier';

  @override
  String get importFileHint =>
      'Choisissez le CSV exporté par Exportify ou une liste de pistes TXT. UTF-8, jusqu\'à 10 Mo et 10 000 pistes.';

  @override
  String get importFileAndroidOnly =>
      'La sélection de fichiers est disponible sur Android. Ici, vous pouvez coller le contenu d\'un CSV ou d\'une liste de pistes.';

  @override
  String get importTextHint =>
      'Une ligne Artiste — Titre par ligne. Vous pouvez aussi coller le CSV complet, en-tête comprise.';

  @override
  String get importPreview => 'Aperçu des pistes';

  @override
  String get importedFromCsv => 'Importé depuis un CSV';

  @override
  String get importedFromText => 'Importé depuis une liste de pistes';

  @override
  String importMoreTracks(int count) {
    return 'Et $count de plus';
  }

  @override
  String get importMetadataHint =>
      'La playlist est enregistrée sur cet appareil. L\'audio est recherché au moment de la lecture ; importer ne télécharge pas de chansons.';

  @override
  String get importAnother => 'Importer autre chose';

  @override
  String get importReading => 'Lecture de votre playlist…';

  @override
  String get importSaving => 'Enregistrement dans votre bibliothèque…';

  @override
  String get importNameRequired => 'Saisissez un nom de playlist.';

  @override
  String get importNameExists =>
      'Une playlist porte déjà ce nom. Choisissez-en un autre pour garder les deux.';

  @override
  String get importSaveFailed =>
      'Impossible d\'enregistrer la playlist. Votre aperçu est toujours là — réessayez.';

  @override
  String get importFileTooLarge =>
      'Ce fichier dépasse 10 Mo. Divisez la playlist en exports plus petits.';

  @override
  String get importFileUnsupported => 'Choisissez un fichier .csv ou .txt.';

  @override
  String get importFileEncoding =>
      'Impossible de lire l\'encodage du texte. Enregistrez le fichier en UTF-8 et réessayez.';

  @override
  String get importCsvInvalid =>
      'Le CSV est incomplet ou mal formé. Exportez-le à nouveau sans modifier ses colonnes ni ses guillemets.';

  @override
  String get importCsvMissingColumns =>
      'Le CSV doit contenir les colonnes Track Name et Artist Name(s), ou Title et Artist. Utilisez l\'export Exportify d\'origine.';

  @override
  String get importFileEmpty =>
      'Aucune piste trouvée. Choisissez un export rempli ou collez une liste Artiste — Titre.';

  @override
  String get importTooManyTracks =>
      'Un seul import peut contenir jusqu\'à 10 000 pistes. Divisez cette playlist ; rien n\'a encore été enregistré.';

  @override
  String get importFileReadFailed =>
      'Impossible d\'ouvrir ce fichier. Vérifiez qu\'il est disponible sur votre appareil et choisissez-le à nouveau.';

  @override
  String get importSpotifyBlocked =>
      'Spotify n\'a pas partagé cette playlist dans votre région. Exportez-la avec Exportify et choisissez le fichier CSV.';

  @override
  String get listen => 'Écouter';

  @override
  String get addToPlaylists => 'Ajouter à des playlists';

  @override
  String trackSemantics(String title, String artist) {
    return 'Piste $title, $artist';
  }

  @override
  String get trackActions => 'Actions de piste';

  @override
  String get updatesTitle => 'Mises à jour';

  @override
  String currentVersion(String version) {
    return 'Version $version';
  }

  @override
  String get checkForUpdates => 'Rechercher des mises à jour';

  @override
  String get checkingForUpdates => 'Recherche…';

  @override
  String get upToDate => 'Vous avez la dernière version';

  @override
  String updateAvailable(String version) {
    return 'La version $version est disponible';
  }

  @override
  String get downloadingUpdate => 'Téléchargement de la mise à jour…';

  @override
  String get installUpdate => 'Installer';

  @override
  String get updateCheckFailed =>
      'Impossible de vérifier les mises à jour. Vérifiez votre connexion.';

  @override
  String get installPermissionNeeded =>
      'Autorisez Hook à installer des applications, puis appuyez à nouveau sur Installer.';

  @override
  String updateSize(String size) {
    return '$size Mo';
  }

  @override
  String get download => 'Télécharger';

  @override
  String get downloading => 'Téléchargement…';

  @override
  String get downloaded => 'Téléchargé';

  @override
  String get downloadFailed => 'Téléchargement impossible';

  @override
  String get removeDownload => 'Supprimer le téléchargement';

  @override
  String get downloadSavedOffline => 'Enregistré hors ligne';

  @override
  String get startWaveFromTrack => 'Démarrer une vague depuis cette piste';

  @override
  String get addToQueue => 'Ajouter à la file';

  @override
  String addedToQueue(String title) {
    return 'Ajouté à la file : $title';
  }

  @override
  String get removeFavorite => 'Retirer des favoris';

  @override
  String get addFavorite => 'Ajouter aux favoris';

  @override
  String get addToPlaylist => 'Ajouter à une playlist';

  @override
  String get goToArtist => 'Aller à l\'artiste';

  @override
  String get myPlaylist => 'Ma playlist';

  @override
  String get newPlaylist => 'Nouvelle playlist';

  @override
  String get name => 'Nom';

  @override
  String get create => 'Créer';

  @override
  String get loading => 'Chargement…';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Lire';

  @override
  String get next => 'Suivant';

  @override
  String get speedAndPitch => 'Vitesse et tonalité';

  @override
  String speedValue(String value) {
    return 'Vitesse : ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'Tonalité : ${value}x';
  }

  @override
  String get reset => 'Réinitialiser';

  @override
  String get moreActions => 'Plus d\'actions';

  @override
  String get playbackQueue => 'File de lecture';

  @override
  String get queueEmpty => 'La file est vide';

  @override
  String get selectingSource => 'Sélection de la source';

  @override
  String get collapsePlayer => 'Réduire le lecteur';

  @override
  String get nowPlayingUpper => 'EN COURS DE LECTURE';

  @override
  String get queue => 'File';

  @override
  String get startWave => 'Démarrer la vague';

  @override
  String get cover => 'Pochette';

  @override
  String get karaokeLyrics => 'Paroles karaoké';

  @override
  String get findMusicStart => 'Trouvez de la musique et lancez la lecture';

  @override
  String get playbackNotStarted => 'La lecture n\'a pas commencé';

  @override
  String get openSearchFirstTrack =>
      'Ouvrez la recherche pour trouver votre première piste';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => 'Sur l\'appareil';

  @override
  String get sourceCatalog => 'Catalogue';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'Serveur';

  @override
  String get serverResolver => 'Serveur résolveur';

  @override
  String get serverResolverCaption =>
      'Serveur auto-hébergé optionnel qui résout des flux audio complets. L\'app envoie une recherche ou un identifiant de piste ; le serveur renvoie une URL de lecture. Le contrat et une implémentation de référence sont dans docs/REMOTE_RESOLVER.md.';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'Non configuré';

  @override
  String get serverSave => 'Enregistrer';

  @override
  String get serverDisable => 'Désactiver';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue dans Hook';

  @override
  String get onboardingWelcomeCaption =>
      'Musique, paroles et votre propre style visuel. Choisissez une langue pour commencer — vous pourrez la changer plus tard dans les réglages.';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Continuer';

  @override
  String get onboardingStart => 'Commencer à écouter';

  @override
  String get onboardingMicrogTitle => 'MicroG et le compte Google';

  @override
  String get onboardingMicrogBody =>
      'MicroG recrée les services Google sur les ROM Android personnalisées qui en sont dépourvues. Hook ne les utilise que pour une fonction optionnelle : connecter un compte YouTube pour importer vos playlists. Écouter de la musique ne nécessite jamais MicroG ni aucun service Google.';

  @override
  String get onboardingMicrogNote =>
      'La lecture ne dépend pas de MicroG. Connecter un compte est facultatif.';

  @override
  String get onboardingMicrogDownload => 'Télécharger MicroG';

  @override
  String get onboardingMicrogStatusChecking =>
      'Vérification des services Google…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'Les services Google sont présents sur cet appareil ($version). L\'import de compte fonctionnera directement.';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'ReVanced GmsCore détecté ($version). Le SDK de connexion Google officiel n\'est pas compatible avec lui, la connexion de compte peut donc ne pas fonctionner. La lecture n\'est pas affectée.';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'Services Google introuvables. Pour importer des playlists depuis un compte YouTube, installez d\'abord MicroG — ou passez ceci et utilisez Hook sans compte.';

  @override
  String lyricsView(String mode) {
    return 'Vue des paroles · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'Votre rythme de lecture';

  @override
  String get lyricsModeSubtitle =>
      'Trois façons de se rapprocher de la chanson.';

  @override
  String get lyricsModeLines => 'Lignes';

  @override
  String get lyricsModeKaraoke => 'Karaoké';

  @override
  String get lyricsModeFocus => 'Focus';

  @override
  String get lyricsModeLinesDescription =>
      'Paroles calmes avec la ligne actuelle surlignée';

  @override
  String get lyricsModeKaraokeDescription =>
      'Les mots s\'illuminent en douceur avec les voix';

  @override
  String get lyricsModeFocusDescription => 'Une grande ligne. Rien d\'autre';

  @override
  String get lyricsModeSaveFailed =>
      'Impossible d\'enregistrer la vue des paroles.';

  @override
  String get lyricsModeFootnote =>
      'Votre choix est conservé pour les chansons suivantes. La précision du karaoké dépend des données de la source : le surlignage des mots est approximatif sans minutage par mot, et les paroles restent fixes sans horodatage.';

  @override
  String get lyricsNotFound => 'Paroles introuvables';

  @override
  String get karaokeUnavailable =>
      'Les paroles karaoké ne sont pas disponibles pour ce morceau';

  @override
  String get unsyncedLyrics => 'Paroles non synchronisées';

  @override
  String get wordSyncUpper => 'SYNCHRONISATION MOT À MOT';

  @override
  String get lineSyncUpper => 'SYNCHRONISATION LIGNE PAR LIGNE';

  @override
  String get adjustLyricsSync => 'Ajuster la synchronisation des paroles';

  @override
  String get startsSoon => 'Ça commence bientôt';

  @override
  String get musicContinues => 'La musique continue';

  @override
  String get decreaseLyricsOffset => 'Réduire le décalage de 0,1 s';

  @override
  String lyricsOffset(String value) {
    return 'Décalage : $value s';
  }

  @override
  String get increaseLyricsOffset => 'Augmenter le décalage de 0,1 s';

  @override
  String get hideSetting => 'Masquer le réglage';

  @override
  String get lyricsOffsetSaveFailed =>
      'Impossible d\'enregistrer le décalage des paroles.';

  @override
  String get audioForbidden =>
      'Le serveur audio a refusé l\'accès (HTTP 403). La piste a été trouvée, mais son flux est indisponible. Un VPN ne garantit pas l\'accès à l\'audio.';

  @override
  String get fullVersionUnavailable =>
      'Aucune version complète trouvée dans les sources disponibles. Vérifiez votre connexion ou réessayez plus tard.';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source n\'a pas pu lire ce morceau. Vérifiez votre connexion ou réessayez plus tard.';
  }

  @override
  String get recentQueriesUpper => 'RECHERCHES RÉCENTES';

  @override
  String get clearHistory => 'Effacer';

  @override
  String get waveFromArtist => 'Vague de l\'artiste';

  @override
  String get popularTracksUpper => 'TITRES POPULAIRES';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titres',
      one: '1 titre',
      zero: 'aucun titre pour l\'instant',
    );
    return '$_temp0';
  }
}
