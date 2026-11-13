// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => 'Ajustes';

  @override
  String get settingsCaption => 'As alterações são salvas neste dispositivo.';

  @override
  String get playerSettings => 'Reprodutor';

  @override
  String get lyricsAutoHide => 'Ocultar controles ao ler a letra';

  @override
  String get lyricsAutoHideDescription =>
      'Depois de 10 segundos sem interação, os painéis do reprodutor deslizam para fora da tela. Use o botão de restaurar para trazê-los de volta.';

  @override
  String get showPlayerControls => 'Mostrar controles do reprodutor';

  @override
  String get equalizer => 'Equalizador';

  @override
  String get equalizerEnabled => 'Processamento de som';

  @override
  String get equalizerPresets => 'Perfil de som';

  @override
  String get equalizerFlat => 'Original';

  @override
  String get equalizerBass => 'Graves profundos';

  @override
  String get equalizerVocal => 'Vocais';

  @override
  String get equalizerRock => 'Rock';

  @override
  String get equalizerElectronic => 'Eletrônica';

  @override
  String get equalizerSoft => 'Suave';

  @override
  String get equalizerCustom => 'Personalizado';

  @override
  String get equalizerBands => 'Faixas de frequência';

  @override
  String get equalizerBassBoost => 'Reforço de graves';

  @override
  String get equalizerBassUnsupported =>
      'O reforço de graves adicional não é compatível. Use as faixas de baixa frequência.';

  @override
  String get equalizerPreamp => 'Pré-amplificação';

  @override
  String get equalizerHeadroom => 'Margem automática';

  @override
  String get equalizerHeadroomDescription =>
      'Reduz o nível de saída ao reforçar frequências para deixar espaço aos picos. Não é um limitador.';

  @override
  String get equalizerWaiting =>
      'Reproduza uma faixa para conectar o equalizador à sessão de áudio.';

  @override
  String get equalizerUnsupported =>
      'O processamento de som está disponível apenas no Android por enquanto.';

  @override
  String get equalizerFailed =>
      'Este dispositivo não conseguiu ativar os efeitos de áudio. A música ainda pode tocar sem eles.';

  @override
  String get equalizerRetry => 'Reconectar efeitos';

  @override
  String get equalizerLive =>
      'As alterações são aplicadas na hora e salvas neste dispositivo.';

  @override
  String get youtubeAccount => 'YouTube e MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'Acesso somente leitura às playlists. Entrar não garante a disponibilidade do áudio.';

  @override
  String get youtubeAccountCompatibility => 'Compatibilidade e privacidade';

  @override
  String get youtubeAccountSubtitle =>
      'Conexão de conta e importação de playlists';

  @override
  String get youtubeAccountPrivacy =>
      'O Hook solicita acesso somente leitura ao YouTube. Digite sua senha apenas no diálogo do sistema do Google, nunca no Hook. O token não é enviado a nenhum servidor do Hook e fica só na memória. Reconecte depois de reiniciar o app.';

  @override
  String get youtubeAccountPlaybackNotice =>
      'Entrar dá acesso aos dados da conta, não aos fluxos de áudio. Não garante correção do HTTP 403. As importações preservam as gravações do YouTube sem substituí-las por outra fonte.';

  @override
  String get youtubeAccountConnect => 'Conectar conta';

  @override
  String get youtubeAccountDisconnect => 'Desconectar no Hook';

  @override
  String get youtubeAccountDisconnected => 'Nenhuma conta conectada';

  @override
  String get youtubeAccountDisconnectNotice =>
      'Desconectar esta conta apenas no Hook? As playlists salvas permanecerão. As contas Google e MicroG do telefone não serão desconectadas.';

  @override
  String get youtubeAccountSystem => 'APIs do Google do sistema';

  @override
  String get youtubeAccountServicesMissing =>
      'As APIs do Google do sistema compatíveis não estão disponíveis. Uma instalação separada do ReVanced GmsCore não as substitui para o login do Hook.';

  @override
  String get youtubeAccountMicrogNotice =>
      'Foi detectada uma instalação separada do ReVanced GmsCore. O Hook não usa contas nem tokens do ReVanced. Um MicroG do sistema pode oferecer APIs do Google compatíveis, mas a compatibilidade com este método de login não é garantida.';

  @override
  String get youtubeAccountRevancedFound =>
      'O YouTube Music ReVanced está instalado';

  @override
  String get youtubeAccountPlaylists => 'Playlists da conta';

  @override
  String get youtubeAccountNoPlaylists =>
      'Nenhuma playlist acessível. Algumas coleções automáticas do YouTube Music não estão disponíveis pela YouTube Data API.';

  @override
  String get youtubeAccountMore => 'Carregar mais';

  @override
  String get youtubeAccountPreview => 'Preparar importação';

  @override
  String youtubeAccountProgress(int count) {
    return 'Faixas obtidas: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'Entradas indisponíveis ignoradas: $count. Elas não são substituídas por outras faixas.';
  }

  @override
  String get youtubeAccountSetup => 'Configuração do login';

  @override
  String get youtubeAccountSetupBody =>
      'O desenvolvedor precisa habilitar a YouTube Data API v3 no Google Cloud, registrar um cliente OAuth Android para com.hook.music e o SHA-1 de assinatura da compilação instalada, além de configurar a tela de consentimento. Adicione os usuários permitidos no modo de teste. Consulte docs/YOUTUBE_ACCOUNT_SETUP.md. Nunca adicione senhas, segredos de cliente ou tokens de outros apps.';

  @override
  String get youtubeAccountConfigError =>
      'O login não está configurado para esta compilação. Verifique o cliente OAuth Android, o nome do pacote, o SHA-1 e os usuários de teste permitidos no Google Cloud.';

  @override
  String get youtubeAccountPermissionError =>
      'O acesso de leitura aos dados do YouTube não foi concedido.';

  @override
  String get youtubeAccountExpired => 'Sua sessão expirou. Reconecte a conta.';

  @override
  String get youtubeAccountNoChannel =>
      'A conta selecionada não tem um canal do YouTube acessível.';

  @override
  String get youtubeAccountQuota =>
      'Cota da API do YouTube excedida. Tente novamente mais tarde.';

  @override
  String get youtubeAccountFailed =>
      'Não foi possível obter os dados do YouTube. Verifique sua conexão e tente novamente.';

  @override
  String get youtubeAccountUnsupported =>
      'A conexão de conta requer Android com APIs do Google do sistema compatíveis.';

  @override
  String get importedFromYouTube => 'Importado da conta do YouTube';

  @override
  String get translateLyrics => 'Traduzir letra';

  @override
  String get hideTranslation => 'Ocultar tradução';

  @override
  String get cancelTranslation => 'Cancelar tradução';

  @override
  String get translationLoading => 'Preparando tradução…';

  @override
  String get translationAttribution =>
      'Traduzido automaticamente pelo Google Translate';

  @override
  String get translationNotice =>
      'A tradução pode não capturar com exatidão o significado da música. O destaque de palavras vale apenas para o original.';

  @override
  String get translationModelTitle => 'Baixar modelos de idioma?';

  @override
  String get translationModelBody =>
      'A tradução roda no seu telefone: a letra não é enviada a nenhum servidor. A primeira tradução precisa dos modelos do Google ML Kit, que ocupam dezenas de megabytes. O download usa sua conexão atual, incluindo dados móveis. Cancelar oculta o resultado, mas um download já iniciado pode terminar em segundo plano.';

  @override
  String get translationDownload => 'Baixar e traduzir';

  @override
  String get translationUnavailable =>
      'Falha na tradução. Verifique o acesso aos downloads de modelos e tente novamente.';

  @override
  String get translationUnsupported =>
      'A tradução no dispositivo está disponível apenas no Android por enquanto.';

  @override
  String get translationUnknownLanguage =>
      'Não foi possível identificar um idioma compatível para esta música.';

  @override
  String get translationSameLanguage =>
      'A letra já está no idioma selecionado.';

  @override
  String get translationTooLarge =>
      'Esta letra é longa demais para a tradução no dispositivo.';

  @override
  String get translationRussian => 'Para o russo';

  @override
  String get translationEnglish => 'Para o inglês';

  @override
  String get translationTarget => 'Idioma da tradução';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get home => 'Início';

  @override
  String get search => 'Buscar';

  @override
  String get library => 'Biblioteca';

  @override
  String get youtubeUnavailableTitle =>
      'O YouTube está indisponível no momento';

  @override
  String get youtubeUnavailableBody =>
      'Não foi possível obter um fluxo de áudio. Verifique sua rede e a rota da VPN: o YouTube pode rejeitar solicitações mesmo com VPN.';

  @override
  String get checkAgain => 'Verificar novamente';

  @override
  String get dismiss => 'Dispensar';

  @override
  String get goodNight => 'Boa noite';

  @override
  String get goodMorning => 'Bom dia';

  @override
  String get goodAfternoon => 'Boa tarde';

  @override
  String get goodEvening => 'Boa noite';

  @override
  String get themeSettings => 'Ajustes de aparência';

  @override
  String get onYourAir => 'No seu ar';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sinais recentes',
      one: '1 sinal recente',
      zero: 'Sem sinais recentes',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'Sua coleção está esperando';

  @override
  String get saved => 'Salvo';

  @override
  String get collectionEmptyDetail =>
      'A música que você quer reencontrar vai ficar aqui';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count faixas',
      one: '1 faixa',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => 'Faixa, artista ou letra';

  @override
  String get searchUpper => 'BUSCAR';

  @override
  String get findFirstTrack => 'Encontre sua primeira faixa';

  @override
  String continuationAfter(String artist) {
    return 'Mais música depois de $artist';
  }

  @override
  String get chooseTrackWaveDetail =>
      'Escolha uma faixa e criaremos uma onda a partir do clima dela.';

  @override
  String get continueWaveLabel => 'CONTINUAR / 01';

  @override
  String get yourWaveLabel => 'SUA ONDA / 01';

  @override
  String get continueWave => 'Continuar onda';

  @override
  String get chooseTrack => 'Escolha uma faixa';

  @override
  String get firstTrace => 'Deixe aqui sua primeira marca';

  @override
  String get favoriteWaveHint =>
      'Salve favoritos e sua onda ficará mais precisa.';

  @override
  String get openSearch => 'Abrir busca';

  @override
  String get findYourMusic => 'Encontre seu som.';

  @override
  String get importMusic => 'Importar música';

  @override
  String get rememberedLyricsHint => 'As palavras que você lembra…';

  @override
  String get trackArtistHint => 'Faixa ou artista — qualquer idioma';

  @override
  String get clear => 'Limpar';

  @override
  String get music => 'Música';

  @override
  String get byLyrics => 'Pela letra';

  @override
  String get allSources => 'Todas as fontes';

  @override
  String get lyricsSearchCaption =>
      'Busque uma frase da música, não só o título.';

  @override
  String get searchingLyrics => 'Procurando linhas conhecidas…';

  @override
  String get searchingSources => 'Buscando em fontes de música…';

  @override
  String get connectionFailed => 'Não foi possível conectar';

  @override
  String get noMatches => 'Nenhuma correspondência ainda';

  @override
  String get lyricsUnavailable =>
      'A busca de letras está indisponível agora. Tente mais tarde ou busque pelo título.';

  @override
  String get searchUnavailable =>
      'Falha na busca. Verifique sua conexão e tente novamente.';

  @override
  String get lyricsNoMatches =>
      'Tente outra linha. Nem toda letra está indexada.';

  @override
  String get trackNoMatches =>
      'Adicione o artista ou escolha outra fonte. Alguns serviços podem estar indisponíveis na sua rede.';

  @override
  String get repeatSearch => 'Buscar novamente';

  @override
  String get lyricMatchesUpper => 'CORRESPONDÊNCIAS DE LETRA';

  @override
  String get tracksUpper => 'FAIXAS';

  @override
  String playTrack(String title, String artist) {
    return 'Reproduzir $title, $artist';
  }

  @override
  String get familiarLinesUpper => 'LINHAS FAMILIARES';

  @override
  String get bestMatchUpper => 'MELHOR CORRESPONDÊNCIA';

  @override
  String get fullVersionOnPlayback =>
      'Vamos encontrar a versão completa quando a reprodução começar.';

  @override
  String get forgotTitle => 'Esqueceu o título.\nNão a música.';

  @override
  String get startAsYouRemember =>
      'Um nome, um título ou uma trecho da música.\nComece com o que você lembra.';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => 'Busque nomes como soam';

  @override
  String get rememberOnlyLine => 'Só lembro de um trecho';

  @override
  String get findSongByWords => 'Encontre uma música pelas palavras';

  @override
  String get yourArtistsUpper => 'SEUS ARTISTAS';

  @override
  String get language => 'Idioma';

  @override
  String get languageCaption => 'A interface segue sua escolha imediatamente';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get russian => 'Russo';

  @override
  String get english => 'Inglês';

  @override
  String get themesAndShaders => 'Temas e efeitos';

  @override
  String get themesSubtitle => 'Aparência, idioma e movimento do fundo';

  @override
  String get invalidThemeJson =>
      'Não foi possível ler o tema. Verifique o formato JSON e os valores dos campos.';

  @override
  String get exportJson => 'Exportar JSON';

  @override
  String get importJson => 'Importar JSON';

  @override
  String get readyThemes => 'Temas predefinidos';

  @override
  String get gpuShaders => 'Efeitos de fundo';

  @override
  String get meshGradient => 'Gradiente GPU suave com base nas cores da faixa';

  @override
  String get vinylNoise => 'Granulação de vinil analógico (ruído)';

  @override
  String get glassBlur => 'Desfoque de vidro (Backdrop Blur)';

  @override
  String get cornerRadius => 'Raio dos cantos da interface';

  @override
  String get importThemeTitle => 'Importar tema de um JSON';

  @override
  String get pasteThemeJson => 'Cole a configuração JSON do tema:';

  @override
  String get cancel => 'Cancelar';

  @override
  String get apply => 'Aplicar';

  @override
  String get themeApplied => 'Tema aplicado com sucesso!';

  @override
  String get exportThemeTitle => 'Exportar tema (JSON)';

  @override
  String get close => 'Fechar';

  @override
  String get copyJson => 'Copiar JSON';

  @override
  String get jsonCopied => 'JSON do tema copiado para a área de transferência!';

  @override
  String get libraryUpper => 'BIBLIOTECA';

  @override
  String get localCollection => 'Coleção local e playlists';

  @override
  String get importShort => 'Importar';

  @override
  String get favorites => 'Favoritos';

  @override
  String get playlists => 'Playlists';

  @override
  String get history => 'Histórico';

  @override
  String get offline => 'Off-line';

  @override
  String get favoritesEmpty =>
      'Seus favoritos estão vazios.\nToque no coração de uma faixa para adicioná-la aqui.';

  @override
  String get historyEmpty =>
      'Seu histórico de escuta está vazio.\nToque música pela busca e ela aparecerá aqui.';

  @override
  String get noPlaylists => 'Você ainda não tem playlists';

  @override
  String get importPlaylistHint =>
      'Importe uma playlist do Spotify ou cole uma lista de faixas.';

  @override
  String get importMusicAction => 'Importar música';

  @override
  String get playPlaylist => 'Reproduzir playlist';

  @override
  String playlistStarted(String name, int count) {
    return 'Reproduzindo «$name» ($count faixas)';
  }

  @override
  String get deletePlaylist => 'Excluir playlist';

  @override
  String get playAll => 'Reproduzir tudo';

  @override
  String get shuffle => 'Aleatório';

  @override
  String get localAudioCache => 'Cache de áudio local';

  @override
  String get cacheDescription =>
      'As faixas tocadas são guardadas localmente para reescutar sem internet.';

  @override
  String deviceUsage(String size) {
    return 'Neste dispositivo: $size';
  }

  @override
  String get clearCache => 'Limpar todo o cache';

  @override
  String savedTracksUpper(int count) {
    return 'FAIXAS SALVAS ($count):';
  }

  @override
  String get cacheFeaturesUpper => 'RECURSOS DO CACHE:';

  @override
  String get offlineFirst => 'Prioridade off-line';

  @override
  String get offlineFirstDescription =>
      'Ao reescutar, o áudio carrega direto do sistema de arquivos do dispositivo.';

  @override
  String get maximumBitrate => 'Taxa de bits máxima';

  @override
  String get maximumBitrateDescription =>
      'Fluxos limpos de Opus/M4A a 160–256 kbps são guardados sem transcodificação.';

  @override
  String get trafficAndBattery => 'Economize dados e bateria';

  @override
  String get trafficAndBatteryDescription =>
      'Evitar requisições repetidas de rede ajuda seu telefone a durar mais.';

  @override
  String get cacheEmpty => 'O cache está vazio';

  @override
  String get cachedTracksAppear =>
      'As faixas baixadas aparecerão aqui automaticamente';

  @override
  String get removeFromCache => 'Remover do cache';

  @override
  String get removeCachedTrackTitle => 'Remover a faixa do cache?';

  @override
  String removeCachedTrackBody(String title) {
    return '«$title» será removida deste dispositivo.';
  }

  @override
  String get delete => 'Excluir';

  @override
  String get trackRemovedFromCache => 'Faixa removida do cache';

  @override
  String get clearCacheTitle => 'Limpar o cache?';

  @override
  String get clearCacheBody =>
      'Todos os arquivos de áudio salvos serão removidos deste dispositivo. Favoritos e histórico não mudam.';

  @override
  String get cacheCleared => 'Cache local limpo';

  @override
  String get back => 'Voltar';

  @override
  String get playlistActions => 'Ações da playlist';

  @override
  String get playlistUpper => 'PLAYLIST';

  @override
  String get playlistEmpty => 'Ainda não há faixas nesta playlist';

  @override
  String get pasteTrackList => 'Cole uma lista de faixas';

  @override
  String get pasteImportLink => 'Cole um link para importar';

  @override
  String get tracksNotFound => 'Nenhuma faixa foi encontrada nesse link.';

  @override
  String get importError =>
      'Falha na importação. Verifique o link e sua conexão de internet.';

  @override
  String importedPlaylistStarted(int count) {
    return 'Reproduzindo playlist importada ($count faixas)';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'Importar ($platform)';
  }

  @override
  String playlistSaved(String name) {
    return 'Playlist «$name» salva na sua biblioteca!';
  }

  @override
  String get spotifyImportSubtitle => 'Spotify • Playlists, álbuns e faixas';

  @override
  String get artistTrackOrCsv => 'Artista — Faixa, ou um CSV do Exportify';

  @override
  String get pastePlaylistOrTrackLink => 'Cole um link de playlist ou de faixa';

  @override
  String get pasteFromClipboard => 'Colar da área de transferência';

  @override
  String get link => 'Link';

  @override
  String get trackList => 'Lista de faixas';

  @override
  String get playlistName => 'Nome da playlist';

  @override
  String get startImport => 'Iniciar importação';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count faixas';
  }

  @override
  String get importedFromSpotify => 'Importado do Spotify';

  @override
  String get importedFromDeezer => 'Importado do Deezer';

  @override
  String get importIntro =>
      'Traga suas playlists com você. Use um link do Spotify, uma lista de faixas ou um arquivo do Exportify.';

  @override
  String get importTextTab => 'Texto';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'Escolher arquivo';

  @override
  String get importFileHint =>
      'Escolha o CSV exportado pelo Exportify ou uma lista de faixas em TXT. UTF-8, até 10 MB e 10 000 faixas.';

  @override
  String get importFileAndroidOnly =>
      'A seleção de arquivos está disponível no Android. Aqui você pode colar o conteúdo de um CSV ou de uma lista de faixas.';

  @override
  String get importTextHint =>
      'Um Artista — Faixa por linha. Você também pode colar o CSV completo, incluindo o cabeçalho.';

  @override
  String get importPreview => 'Prévia das faixas';

  @override
  String get importedFromCsv => 'Importado de CSV';

  @override
  String get importedFromText => 'Importado de uma lista de faixas';

  @override
  String importMoreTracks(int count) {
    return 'E mais $count';
  }

  @override
  String get importMetadataHint =>
      'A playlist é salva neste dispositivo. O áudio é buscado ao tocar a faixa; importar não baixa músicas.';

  @override
  String get importAnother => 'Importar outra coisa';

  @override
  String get importReading => 'Lendo sua playlist…';

  @override
  String get importSaving => 'Salvando na sua biblioteca…';

  @override
  String get importNameRequired => 'Digite um nome de playlist.';

  @override
  String get importNameExists =>
      'Já existe uma playlist com esse nome. Escolha outro para manter as duas.';

  @override
  String get importSaveFailed =>
      'Não foi possível salvar a playlist. Sua prévia continua aqui — tente novamente.';

  @override
  String get importFileTooLarge =>
      'Este arquivo passa de 10 MB. Divida a playlist em exportações menores.';

  @override
  String get importFileUnsupported => 'Escolha um arquivo .csv ou .txt.';

  @override
  String get importFileEncoding =>
      'Não foi possível ler a codificação do texto. Salve o arquivo como UTF-8 e tente novamente.';

  @override
  String get importCsvInvalid =>
      'O CSV está incompleto ou malformado. Exporte novamente sem editar colunas ou aspas.';

  @override
  String get importCsvMissingColumns =>
      'O CSV precisa das colunas Track Name e Artist Name(s), ou Title e Artist. Use a exportação original do Exportify.';

  @override
  String get importFileEmpty =>
      'Nenhuma faixa foi encontrada. Escolha uma exportação com conteúdo ou cole uma lista de Artista — Faixa.';

  @override
  String get importTooManyTracks =>
      'Uma única importação pode ter até 10 000 faixas. Divida esta playlist; nada foi salvo ainda.';

  @override
  String get importFileReadFailed =>
      'Não foi possível abrir o arquivo. Verifique se ele está disponível no dispositivo e escolha-o novamente.';

  @override
  String get importSpotifyBlocked =>
      'O Spotify não compartilhou esta playlist na sua região. Exporte-a com o Exportify e escolha o arquivo CSV.';

  @override
  String get listen => 'Tocar';

  @override
  String get addToPlaylists => 'Adicionar a playlists';

  @override
  String trackSemantics(String title, String artist) {
    return 'Faixa $title, $artist';
  }

  @override
  String get trackActions => 'Ações da faixa';

  @override
  String get updatesTitle => 'Atualizações';

  @override
  String get accountTitle => 'Conta';

  @override
  String get waveLoading => 'Encontrando músicas parecidas…';

  @override
  String get sleepTimer => 'Temporizador de sono';

  @override
  String sleepMinutes(String value) {
    return '$value';
  }

  @override
  String get sleepUntilTrackEnd => 'Até o fim da faixa';

  @override
  String get sleepCancel => 'Desligar';

  @override
  String get dislike => 'Não curti';

  @override
  String get dislikeRemove => 'Remover dos ocultos';

  @override
  String dislikeSaved(String artist) {
    return 'Oculto: $artist';
  }

  @override
  String get exportPlaylist => 'Exportar CSV';

  @override
  String get playlistExported => 'Playlist exportada';

  @override
  String get exportFailed => 'Falha na exportação';

  @override
  String get downloadAll => 'Baixar tudo';

  @override
  String get statsTitle => 'Estatísticas';

  @override
  String get statsPlays => 'Reproduções';

  @override
  String get statsFavorites => 'Favoritos';

  @override
  String get statsPlaylists => 'Playlists';

  @override
  String get statsTopArtists => 'Artistas principais';

  @override
  String get statsTopTracks => 'Faixas principais';

  @override
  String resumeTitle(String device) {
    return 'Continuar em $device';
  }

  @override
  String get alwaysOnTop => 'Manter janela no topo';

  @override
  String get randomPick => 'Escolha aleatória para você';

  @override
  String get accountCaption => 'Sincronize sua biblioteca entre dispositivos';

  @override
  String get nickname => 'Apelido';

  @override
  String get nicknameHint => '3–20 caracteres: letras, dígitos, . _ -';

  @override
  String get password => 'Senha';

  @override
  String get passwordMinHint => 'Pelo menos 6 caracteres';

  @override
  String get signIn => 'Entrar';

  @override
  String get signUp => 'Criar conta';

  @override
  String get haveAccountToggle => 'Já tem uma conta? Entrar';

  @override
  String get noAccountToggle => 'Ainda não tem conta? Crie uma';

  @override
  String get signOut => 'Sair';

  @override
  String get syncNow => 'Sincronizar agora';

  @override
  String get syncing => 'Sincronizando…';

  @override
  String syncedAt(String time) {
    return 'Sincronizado: $time';
  }

  @override
  String get neverSynced => 'Ainda não sincronizado';

  @override
  String get errorNicknameTaken => 'Esse apelido já está em uso';

  @override
  String get errorNicknameInvalid =>
      'Apelido: 3–20 caracteres, letras/dígitos/._-';

  @override
  String get errorInvalidCredentials => 'Apelido ou senha incorretos';

  @override
  String get errorWeakPassword => 'A senha é curta demais';

  @override
  String get errorNetwork => 'Sem conexão';

  @override
  String get errorServer => 'Erro do servidor, tente mais tarde';

  @override
  String currentVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get checkForUpdates => 'Verificar atualizações';

  @override
  String get checkingForUpdates => 'Verificando…';

  @override
  String get upToDate => 'Você está na versão mais recente';

  @override
  String updateAvailable(String version) {
    return 'A versão $version está disponível';
  }

  @override
  String get downloadingUpdate => 'Baixando atualização…';

  @override
  String get installUpdate => 'Instalar';

  @override
  String get updateCheckFailed =>
      'Não foi possível verificar atualizações. Verifique a conexão.';

  @override
  String get installPermissionNeeded =>
      'Permita que o Hook instale aplicativos e toque em Instalar novamente.';

  @override
  String updateSize(String size) {
    return '$size MB';
  }

  @override
  String get download => 'Baixar';

  @override
  String get downloading => 'Baixando…';

  @override
  String get downloaded => 'Baixado';

  @override
  String get downloadFailed => 'Falha ao baixar';

  @override
  String get removeDownload => 'Remover download';

  @override
  String get downloadSavedOffline => 'Salvo off-line';

  @override
  String get startWaveFromTrack => 'Iniciar uma onda desta faixa';

  @override
  String get addToQueue => 'Adicionar à fila';

  @override
  String addedToQueue(String title) {
    return 'Adicionado à fila: $title';
  }

  @override
  String get removeFavorite => 'Remover dos favoritos';

  @override
  String get addFavorite => 'Adicionar aos favoritos';

  @override
  String get addToPlaylist => 'Adicionar a playlist';

  @override
  String get goToArtist => 'Ir para o artista';

  @override
  String get myPlaylist => 'Minha playlist';

  @override
  String get newPlaylist => 'Nova playlist';

  @override
  String get name => 'Nome';

  @override
  String get create => 'Criar';

  @override
  String get loading => 'Carregando…';

  @override
  String get pause => 'Pausar';

  @override
  String get play => 'Reproduzir';

  @override
  String get next => 'Próxima';

  @override
  String get speedAndPitch => 'Velocidade e tom';

  @override
  String speedValue(String value) {
    return 'Velocidade: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'Tom: ${value}x';
  }

  @override
  String get reset => 'Redefinir';

  @override
  String get moreActions => 'Mais ações';

  @override
  String get playbackQueue => 'Fila de reprodução';

  @override
  String get queueEmpty => 'A fila está vazia';

  @override
  String get selectingSource => 'Escolhendo fonte';

  @override
  String get collapsePlayer => 'Recolher reprodutor';

  @override
  String get nowPlayingUpper => 'TOCANDO AGORA';

  @override
  String get queue => 'Fila';

  @override
  String get startWave => 'Iniciar onda';

  @override
  String get cover => 'Capa';

  @override
  String get karaokeLyrics => 'Letra karaokê';

  @override
  String get findMusicStart => 'Encontre música e comece a tocar';

  @override
  String get playbackNotStarted => 'A reprodução não começou';

  @override
  String get openSearchFirstTrack =>
      'Abra a busca para encontrar sua primeira faixa';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => 'No dispositivo';

  @override
  String get sourceCatalog => 'Catálogo';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'Servidor';

  @override
  String get serverResolver => 'Servidor resolvedor';

  @override
  String get serverResolverCaption =>
      'Servidor próprio opcional que resolve fluxos de áudio completos. O app envia uma busca ou o ID da faixa; o servidor devolve uma URL de reprodução. O contrato e uma implementação de referência estão em docs/REMOTE_RESOLVER.md.';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => 'Não configurado';

  @override
  String get serverSave => 'Salvar';

  @override
  String get serverDisable => 'Desativar';

  @override
  String get onboardingWelcomeTitle => 'Boas-vindas ao Hook';

  @override
  String get onboardingWelcomeCaption =>
      'Música, letras e seu próprio estilo visual. Escolha um idioma para começar — dá para mudar depois nos ajustes.';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingNext => 'Continuar';

  @override
  String get onboardingStart => 'Começar a ouvir';

  @override
  String get onboardingMicrogTitle => 'MicroG e a conta Google';

  @override
  String get onboardingMicrogBody =>
      'O MicroG recria os serviços do Google em ROMs Android personalizadas que vêm sem eles. O Hook os usa para um único recurso opcional: conectar uma conta do YouTube para importar suas playlists. Tocar música nunca exige MicroG ou qualquer serviço do Google.';

  @override
  String get onboardingMicrogNote =>
      'A reprodução não depende do MicroG. Conectar uma conta é opcional.';

  @override
  String get onboardingMicrogDownload => 'Baixar MicroG';

  @override
  String get onboardingMicrogStatusChecking =>
      'Verificando serviços do Google…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'Os serviços do Google estão presentes neste dispositivo ($version). A importação de conta funcionará de cara.';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'ReVanced GmsCore detectado ($version). O SDK oficial de login do Google não é compatível com ele, então a conexão de conta pode não funcionar. A reprodução não é afetada.';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'Serviços do Google não encontrados. Para importar playlists de uma conta do YouTube, instale o MicroG primeiro — ou pule isto e use o Hook sem conta.';

  @override
  String lyricsView(String mode) {
    return 'Visualização da letra · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'Seu ritmo de leitura';

  @override
  String get lyricsModeSubtitle => 'Três formas de se aproximar da música.';

  @override
  String get lyricsModeLines => 'Linhas';

  @override
  String get lyricsModeKaraoke => 'Karaokê';

  @override
  String get lyricsModeFocus => 'Foco';

  @override
  String get lyricsModeLinesDescription =>
      'Letra calma com a linha atual destacada';

  @override
  String get lyricsModeKaraokeDescription =>
      'As palavras acendem suavemente com os vocais';

  @override
  String get lyricsModeFocusDescription => 'Uma linha grande. Nada mais';

  @override
  String get lyricsModeSaveFailed =>
      'Não foi possível salvar a visualização da letra.';

  @override
  String get lyricsModeFootnote =>
      'Sua escolha fica salva para as próximas músicas. A precisão do karaokê depende dos dados da fonte: o destaque de palavras é aproximado sem tempos por palavra, e a letra fica parada sem marcas de tempo.';

  @override
  String get lyricsNotFound => 'Letra não encontrada';

  @override
  String get karaokeUnavailable =>
      'A letra karaokê não está disponível para esta faixa';

  @override
  String get unsyncedLyrics => 'Letra sem sincronização';

  @override
  String get wordSyncUpper => 'SINCRONIZAÇÃO PALAVRA A PALAVRA';

  @override
  String get lineSyncUpper => 'SINCRONIZAÇÃO LINHA A LINHA';

  @override
  String get adjustLyricsSync => 'Ajustar a sincronização da letra';

  @override
  String get startsSoon => 'Começa em breve';

  @override
  String get musicContinues => 'A música continua';

  @override
  String get decreaseLyricsOffset => 'Diminuir o atraso em 0,1 s';

  @override
  String lyricsOffset(String value) {
    return 'Atraso: $value s';
  }

  @override
  String get increaseLyricsOffset => 'Aumentar o atraso em 0,1 s';

  @override
  String get hideSetting => 'Ocultar ajuste';

  @override
  String get lyricsOffsetSaveFailed =>
      'Não foi possível salvar o atraso da letra.';

  @override
  String get audioForbidden =>
      'O servidor de áudio negou o acesso (HTTP 403). A faixa foi encontrada, mas o fluxo dela está indisponível. Uma VPN não garante acesso ao áudio.';

  @override
  String get fullVersionUnavailable =>
      'Nenhuma versão completa foi encontrada nas fontes disponíveis. Verifique sua conexão ou tente mais tarde.';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source não conseguiu tocar esta faixa. Verifique sua conexão ou tente mais tarde.';
  }

  @override
  String get recentQueriesUpper => 'PESQUISAS RECENTES';

  @override
  String get clearHistory => 'Limpar';

  @override
  String get waveFromArtist => 'Onda do artista';

  @override
  String get popularTracksUpper => 'FAIXAS POPULARES';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count faixas',
      one: '1 faixa',
      zero: 'ainda sem faixas',
    );
    return '$_temp0';
  }

  @override
  String get volume => 'Volume';

  @override
  String get systemVolume => 'Sistema';

  @override
  String get appVolume => 'Nível do Hook';

  @override
  String get mute => 'Silenciar';

  @override
  String get unmute => 'Ativar o som';

  @override
  String get volumeMixer => 'Som e volume';

  @override
  String get systemVolumeCaption =>
      'O nível de saída do Windows, partilhado com todas as aplicações';

  @override
  String get appVolumeCaption =>
      'Apenas dentro do Hook, acima do nível do sistema';

  @override
  String get volumeKeysHint => 'Ctrl + ↑ ↓ volume · M silêncio';

  @override
  String get volumeUnavailable =>
      'O volume do sistema não está disponível neste dispositivo';

  @override
  String get cacheFolder => 'Pasta de armazenamento';

  @override
  String get copyPath => 'Copiar caminho';

  @override
  String get pathCopied => 'Caminho copiado para a área de transferência';

  @override
  String get previousTrack => 'Faixa anterior';

  @override
  String get repeatPlayback => 'Repetir';

  @override
  String get openPlayer => 'Abrir reprodutor';

  @override
  String get statsWeek => 'Últimos 7 dias';

  @override
  String get keyboardShortcuts => 'Atalhos de teclado';

  @override
  String get shortcutsCaption =>
      'Funcionam em qualquer lugar, exceto em campos de texto.';

  @override
  String get shortcutsSeek => 'Avançar 10 segundos';

  @override
  String get playPauseShortcut => 'Reproduzir / pausar';

  @override
  String get ageRestrictedTrack =>
      'Esta faixa tem restrição de idade (18+). O servidor precisa de cookies de uma conta do YouTube com sessão iniciada.';

  @override
  String get haptics => 'Vibração';

  @override
  String get hapticsDescription =>
      'Uma vibração curta quando um toque muda algo. Apenas Android e iOS.';

  @override
  String get reduceMotion => 'Reduzir movimento';

  @override
  String get reduceMotionDescription =>
      'Ignora transições e fundos animados. Útil em aparelhos lentos ou com sensibilidade a movimento.';

  @override
  String get backgroundPrefetch => 'Pré-carregar próximas faixas';

  @override
  String get backgroundPrefetchDescription =>
      'Prepara as próximas faixas em segundo plano para a troca ser instantânea. Usa um pouco mais de dados.';

  @override
  String get playbackSettings => 'Reprodução';

  @override
  String get cookieStatus => 'Cookies do YouTube';

  @override
  String get cookieStatusReady =>
      'Sessão iniciada: as faixas 18+ estão disponíveis';

  @override
  String get cookieStatusVisitor => 'Sem sessão: as faixas 18+ são recusadas';

  @override
  String get cookieStatusUnknown => 'Ainda não verificado';

  @override
  String get cookieStatusCheck => 'Verificar';

  @override
  String get cookieStatusChecking => 'Verificando…';

  @override
  String get cookieStatusUpload => 'Enviar cookies';

  @override
  String get cookieStatusUploading => 'Enviando…';

  @override
  String cookieUploadAccepted(int cookies) {
    return '$cookies cookies enviados: as faixas 18+ estão ativas';
  }

  @override
  String cookieUploadRejected(String reason) {
    return 'O servidor recusou o arquivo: $reason';
  }

  @override
  String get cookieUploadApology =>
      'Esta exportação não é uma sessão iniciada, então as faixas 18+ continuarão sem tocar. Entre no YouTube com uma conta verificada e exporte de novo.';

  @override
  String get cookieStatusUnreachable => 'O servidor não respondeu';

  @override
  String get errorAccountSetup =>
      'Accounts are not enabled on the server. In Supabase, turn off Authentication → Sign In / Providers → Email → «Confirm email», then try again.';

  @override
  String get errorRateLimited =>
      'Too many attempts. Wait a minute and try again.';
}
