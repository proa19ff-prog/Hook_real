// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => '设置';

  @override
  String get settingsCaption => '更改会保存在此设备上。';

  @override
  String get playerSettings => '播放器';

  @override
  String get lyricsAutoHide => '阅读歌词时隐藏控件';

  @override
  String get lyricsAutoHideDescription => '10 秒无操作后，播放器面板会滑出屏幕。使用还原按钮可将其找回。';

  @override
  String get showPlayerControls => '显示播放器控件';

  @override
  String get equalizer => '均衡器';

  @override
  String get equalizerEnabled => '声音处理';

  @override
  String get equalizerPresets => '声音配置';

  @override
  String get equalizerFlat => '原声';

  @override
  String get equalizerBass => '深沉低音';

  @override
  String get equalizerVocal => '人声';

  @override
  String get equalizerRock => '摇滚';

  @override
  String get equalizerElectronic => '电子';

  @override
  String get equalizerSoft => '柔和';

  @override
  String get equalizerCustom => '自定义';

  @override
  String get equalizerBands => '频段';

  @override
  String get equalizerBassBoost => '低音增强';

  @override
  String get equalizerBassUnsupported => '不支持额外的低音增强。请使用低频段。';

  @override
  String get equalizerPreamp => '前置增益';

  @override
  String get equalizerHeadroom => '自动余量';

  @override
  String get equalizerHeadroomDescription => '在提升频率时降低输出电平，为峰值留出空间。这不是限幅器。';

  @override
  String get equalizerWaiting => '播放一首曲目，将均衡器连接到其音频会话。';

  @override
  String get equalizerUnsupported => '声音处理目前仅在 Android 上可用。';

  @override
  String get equalizerFailed => '此设备无法启用音频效果。音乐仍可在没有它们的情况下播放。';

  @override
  String get equalizerRetry => '重新连接效果';

  @override
  String get equalizerLive => '更改立即生效并保存在此设备上。';

  @override
  String get youtubeAccount => 'YouTube 与 MicroG';

  @override
  String get youtubeAccountReadOnly => '对播放列表的只读访问。登录并不保证音频可用。';

  @override
  String get youtubeAccountCompatibility => '兼容性与隐私';

  @override
  String get youtubeAccountSubtitle => '账号连接与播放列表导入';

  @override
  String get youtubeAccountPrivacy =>
      'Hook 请求 YouTube 的只读访问。请仅在 Google 的系统对话框中输入密码，绝不要在 Hook 中输入。令牌不会发送到任何 Hook 服务器，只保留在内存中。重启应用后需要重新连接。';

  @override
  String get youtubeAccountPlaybackNotice =>
      '登录提供的是账号数据访问权，而非音频流。它不能保证修复 HTTP 403。导入会保留 YouTube 录音，不会替换为其他来源。';

  @override
  String get youtubeAccountConnect => '连接账号';

  @override
  String get youtubeAccountDisconnect => '在 Hook 中断开';

  @override
  String get youtubeAccountDisconnected => '未连接账号';

  @override
  String get youtubeAccountDisconnectNotice =>
      '仅在 Hook 中断开此账号？已保存的播放列表会保留。手机上的 Google 和 MicroG 账号不会退出登录。';

  @override
  String get youtubeAccountSystem => '系统 Google API';

  @override
  String get youtubeAccountServicesMissing =>
      '缺少兼容的系统 Google API。单独安装的 ReVanced GmsCore 无法在 Hook 登录中替代它们。';

  @override
  String get youtubeAccountMicrogNotice =>
      '检测到单独安装的 ReVanced GmsCore。Hook 不使用 ReVanced 的账号或令牌。系统 MicroG 可能提供兼容的 Google API，但不保证与此登录方式兼容。';

  @override
  String get youtubeAccountRevancedFound => '已安装 YouTube Music ReVanced';

  @override
  String get youtubeAccountPlaylists => '账号播放列表';

  @override
  String get youtubeAccountNoPlaylists =>
      '没有可访问的播放列表。部分 YouTube Music 自动合集无法通过 YouTube Data API 获取。';

  @override
  String get youtubeAccountMore => '加载更多';

  @override
  String get youtubeAccountPreview => '准备导入';

  @override
  String youtubeAccountProgress(int count) {
    return '已获取曲目：$count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return '已跳过不可用条目：$count。它们不会被其他曲目替代。';
  }

  @override
  String get youtubeAccountSetup => '登录设置';

  @override
  String get youtubeAccountSetupBody =>
      '开发者需要在 Google Cloud 启用 YouTube Data API v3，为 com.hook.music 及所安装版本的签名 SHA-1 注册 Android OAuth 客户端，并配置同意界面。在测试模式下添加允许的用户。参见 docs/YOUTUBE_ACCOUNT_SETUP.md。切勿添加密码、客户端密钥或其他应用的令牌。';

  @override
  String get youtubeAccountConfigError =>
      '此版本未配置登录。请在 Google Cloud 中检查 Android OAuth 客户端、包名、SHA-1 和允许的测试用户。';

  @override
  String get youtubeAccountPermissionError => '未授予 YouTube 数据的读取权限。';

  @override
  String get youtubeAccountExpired => '会话已过期。请重新连接账号。';

  @override
  String get youtubeAccountNoChannel => '所选账号没有可访问的 YouTube 频道。';

  @override
  String get youtubeAccountQuota => 'YouTube API 配额已超。请稍后再试。';

  @override
  String get youtubeAccountFailed => '无法获取 YouTube 数据。请检查网络连接后重试。';

  @override
  String get youtubeAccountUnsupported => '账号连接需要带有兼容系统 Google API 的 Android。';

  @override
  String get importedFromYouTube => '从 YouTube 账号导入';

  @override
  String get translateLyrics => '翻译歌词';

  @override
  String get hideTranslation => '隐藏翻译';

  @override
  String get cancelTranslation => '取消翻译';

  @override
  String get translationLoading => '正在准备翻译…';

  @override
  String get translationAttribution => '由 Google 翻译自动翻译';

  @override
  String get translationNotice => '翻译可能无法准确捕捉歌曲含义。逐词高亮仅适用于原文。';

  @override
  String get translationModelTitle => '下载语言模型？';

  @override
  String get translationModelBody =>
      '翻译在您的手机上运行：歌词不会发送到任何服务器。首次翻译需要 Google ML Kit 模型，占用数十兆字节。下载会使用您当前的网络连接，包括移动数据。取消会隐藏结果，但已开始的模型下载可能在后台完成。';

  @override
  String get translationDownload => '下载并翻译';

  @override
  String get translationUnavailable => '翻译失败。请检查模型下载权限后重试。';

  @override
  String get translationUnsupported => '设备端翻译目前仅在 Android 上可用。';

  @override
  String get translationUnknownLanguage => '无法识别这首歌曲的支持语言。';

  @override
  String get translationSameLanguage => '歌词已经是所选语言。';

  @override
  String get translationTooLarge => '这些歌词太长，无法进行设备端翻译。';

  @override
  String get translationRussian => '译为俄语';

  @override
  String get translationEnglish => '译为英语';

  @override
  String get translationTarget => '翻译语言';

  @override
  String get retry => '重试';

  @override
  String get home => '主页';

  @override
  String get search => '搜索';

  @override
  String get library => '资料库';

  @override
  String get youtubeUnavailableTitle => 'YouTube 当前不可用';

  @override
  String get youtubeUnavailableBody =>
      '无法获取音频流。请检查网络和 VPN 路由：即使使用 VPN，YouTube 也可能拒绝请求。';

  @override
  String get checkAgain => '再次检查';

  @override
  String get dismiss => '关闭';

  @override
  String get goodNight => '晚安';

  @override
  String get goodMorning => '早上好';

  @override
  String get goodAfternoon => '下午好';

  @override
  String get goodEvening => '晚上好';

  @override
  String get themeSettings => '外观设置';

  @override
  String get onYourAir => '在你的电台';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条近期信号',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => '你的收藏在等你';

  @override
  String get saved => '已保存';

  @override
  String get collectionEmptyDetail => '你想回味的音乐会留在这里';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 首曲目',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => '曲目、歌手或歌词';

  @override
  String get searchUpper => '搜索';

  @override
  String get findFirstTrack => '找到你的第一首曲目';

  @override
  String continuationAfter(String artist) {
    return '$artist 之后的更多音乐';
  }

  @override
  String get chooseTrackWaveDetail => '选择一首曲目，我们会围绕它的情绪生成声波。';

  @override
  String get continueWaveLabel => '继续 / 01';

  @override
  String get yourWaveLabel => '你的声波 / 01';

  @override
  String get continueWave => '继续声波';

  @override
  String get chooseTrack => '选择曲目';

  @override
  String get firstTrace => '在这里留下你的第一道痕迹';

  @override
  String get favoriteWaveHint => '收藏喜欢的歌，你的声波会更准。';

  @override
  String get openSearch => '打开搜索';

  @override
  String get findYourMusic => '找到你的声音。';

  @override
  String get importMusic => '导入音乐';

  @override
  String get rememberedLyricsHint => '你记得的那些歌词…';

  @override
  String get trackArtistHint => '曲目或歌手——任何语言';

  @override
  String get clear => '清除';

  @override
  String get music => '音乐';

  @override
  String get byLyrics => '按歌词';

  @override
  String get allSources => '全部来源';

  @override
  String get lyricsSearchCaption => '搜索歌中的一句话，而不仅是标题。';

  @override
  String get searchingLyrics => '寻找熟悉的句子…';

  @override
  String get searchingSources => '正在搜索音乐来源…';

  @override
  String get connectionFailed => '无法连接';

  @override
  String get noMatches => '暂无匹配';

  @override
  String get lyricsUnavailable => '歌词搜索当前不可用。请稍后再试，或按标题搜索。';

  @override
  String get searchUnavailable => '搜索失败。请检查网络连接后重试。';

  @override
  String get lyricsNoMatches => '换一句试试。并非所有歌词都已收录。';

  @override
  String get trackNoMatches => '加上歌手或换一个来源。某些服务在你的网络中可能不可用。';

  @override
  String get repeatSearch => '重新搜索';

  @override
  String get lyricMatchesUpper => '歌词匹配';

  @override
  String get tracksUpper => '曲目';

  @override
  String playTrack(String title, String artist) {
    return '播放 $title，$artist';
  }

  @override
  String get familiarLinesUpper => '熟悉的句子';

  @override
  String get bestMatchUpper => '最佳匹配';

  @override
  String get fullVersionOnPlayback => '播放开始时我们会寻找完整版本。';

  @override
  String get forgotTitle => '忘了标题。\n没忘音乐。';

  @override
  String get startAsYouRemember => '歌名、标题或歌中的一句话。\n从任何记得的地方开始。';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => '按发音搜索名字';

  @override
  String get rememberOnlyLine => '我只记得一句';

  @override
  String get findSongByWords => '按歌词找歌';

  @override
  String get yourArtistsUpper => '你的歌手';

  @override
  String get language => '语言';

  @override
  String get languageCaption => '界面立即跟随你的选择';

  @override
  String get systemLanguage => '跟随系统';

  @override
  String get russian => '俄语';

  @override
  String get english => '英语';

  @override
  String get themesAndShaders => '主题与特效';

  @override
  String get themesSubtitle => '外观、语言与背景动态';

  @override
  String get invalidThemeJson => '无法读取主题。请检查 JSON 格式与字段值。';

  @override
  String get exportJson => '导出 JSON';

  @override
  String get importJson => '导入 JSON';

  @override
  String get readyThemes => '主题预设';

  @override
  String get gpuShaders => '背景特效';

  @override
  String get meshGradient => '基于曲目色彩的柔和 GPU 渐变';

  @override
  String get vinylNoise => '模拟黑胶颗粒（噪点）';

  @override
  String get glassBlur => '玻璃模糊（Backdrop Blur）';

  @override
  String get cornerRadius => '界面圆角半径';

  @override
  String get importThemeTitle => '从 JSON 导入主题';

  @override
  String get pasteThemeJson => '粘贴主题的 JSON 配置：';

  @override
  String get cancel => '取消';

  @override
  String get apply => '应用';

  @override
  String get themeApplied => '主题应用成功！';

  @override
  String get exportThemeTitle => '导出主题（JSON）';

  @override
  String get close => '关闭';

  @override
  String get copyJson => '复制 JSON';

  @override
  String get jsonCopied => '主题 JSON 已复制到剪贴板！';

  @override
  String get libraryUpper => '资料库';

  @override
  String get localCollection => '本地收藏与播放列表';

  @override
  String get importShort => '导入';

  @override
  String get favorites => '收藏';

  @override
  String get playlists => '播放列表';

  @override
  String get history => '历史';

  @override
  String get offline => '离线';

  @override
  String get favoritesEmpty => '你的收藏还是空的。\n点击曲目上的红心即可添加到这里。';

  @override
  String get historyEmpty => '你的收听历史还是空的。\n从搜索播放音乐，它就会出现在这里。';

  @override
  String get noPlaylists => '你还没有播放列表';

  @override
  String get importPlaylistHint => '导入 Spotify 播放列表或粘贴曲目清单。';

  @override
  String get importMusicAction => '导入音乐';

  @override
  String get playPlaylist => '播放列表';

  @override
  String playlistStarted(String name, int count) {
    return '正在播放「$name」（$count 首曲目）';
  }

  @override
  String get deletePlaylist => '删除播放列表';

  @override
  String get playAll => '全部播放';

  @override
  String get shuffle => '随机播放';

  @override
  String get localAudioCache => '本地音频缓存';

  @override
  String get cacheDescription => '播放过的曲目会本地保存，以便离线秒回。';

  @override
  String deviceUsage(String size) {
    return '此设备上：$size';
  }

  @override
  String get clearCache => '清除全部缓存';

  @override
  String savedTracksUpper(int count) {
    return '已保存曲目（$count）：';
  }

  @override
  String get cacheFeaturesUpper => '缓存特性：';

  @override
  String get offlineFirst => '完全离线优先';

  @override
  String get offlineFirstDescription => '重播时，音频直接从设备文件系统加载。';

  @override
  String get maximumBitrate => '最高码率';

  @override
  String get maximumBitrateDescription =>
      '160–256 kbps 的干净 Opus/M4A 流不经转码直接缓存。';

  @override
  String get trafficAndBattery => '省流量省电';

  @override
  String get trafficAndBatteryDescription => '避免重复的网络请求，让你的手机续航更久。';

  @override
  String get cacheEmpty => '缓存为空';

  @override
  String get cachedTracksAppear => '下载的曲目会自动出现在这里';

  @override
  String get removeFromCache => '从缓存移除';

  @override
  String get removeCachedTrackTitle => '从缓存移除该曲目？';

  @override
  String removeCachedTrackBody(String title) {
    return '「$title」将从此设备移除。';
  }

  @override
  String get delete => '删除';

  @override
  String get trackRemovedFromCache => '曲目已从缓存移除';

  @override
  String get clearCacheTitle => '清除缓存？';

  @override
  String get clearCacheBody => '所有保存的音频文件都将从此设备移除。收藏和历史不会改变。';

  @override
  String get cacheCleared => '本地缓存已清除';

  @override
  String get back => '返回';

  @override
  String get playlistActions => '播放列表操作';

  @override
  String get playlistUpper => '播放列表';

  @override
  String get playlistEmpty => '这个播放列表还没有曲目';

  @override
  String get pasteTrackList => '粘贴曲目清单';

  @override
  String get pasteImportLink => '粘贴要导入的链接';

  @override
  String get tracksNotFound => '该链接未找到曲目。';

  @override
  String get importError => '导入失败。请检查链接和网络连接。';

  @override
  String importedPlaylistStarted(int count) {
    return '正在播放导入的播放列表（$count 首曲目）';
  }

  @override
  String importedPlaylistName(String platform) {
    return '导入（$platform）';
  }

  @override
  String playlistSaved(String name) {
    return '播放列表「$name」已保存到你的资料库！';
  }

  @override
  String get spotifyImportSubtitle => 'Spotify • 播放列表、专辑与曲目';

  @override
  String get artistTrackOrCsv => '歌手 — 曲目，或 Exportify 的 CSV';

  @override
  String get pastePlaylistOrTrackLink => '粘贴播放列表或曲目链接';

  @override
  String get pasteFromClipboard => '从剪贴板粘贴';

  @override
  String get link => '链接';

  @override
  String get trackList => '曲目清单';

  @override
  String get playlistName => '播放列表名称';

  @override
  String get startImport => '开始导入';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count 首曲目';
  }

  @override
  String get importedFromSpotify => '从 Spotify 导入';

  @override
  String get importIntro => '把你的播放列表带过来。使用 Spotify 链接、曲目清单或 Exportify 文件。';

  @override
  String get importTextTab => '文本';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => '选择文件';

  @override
  String get importFileHint =>
      '选择 Exportify 导出的 CSV 或 TXT 曲目清单。UTF-8，最大 10 MB、10,000 首。';

  @override
  String get importFileAndroidOnly => '文件选择在 Android 上可用。在此你可以粘贴 CSV 或曲目清单的内容。';

  @override
  String get importTextHint => '每行一条「歌手 — 曲目」。也可以粘贴含表头的完整 CSV。';

  @override
  String get importPreview => '曲目预览';

  @override
  String get importedFromCsv => '从 CSV 导入';

  @override
  String get importedFromText => '从曲目清单导入';

  @override
  String importMoreTracks(int count) {
    return '还有 $count 首';
  }

  @override
  String get importMetadataHint => '播放列表保存在此设备上。音频在播放曲目时查找；导入不会下载歌曲。';

  @override
  String get importAnother => '导入其他内容';

  @override
  String get importReading => '正在读取你的播放列表…';

  @override
  String get importSaving => '正在保存到资料库…';

  @override
  String get importNameRequired => '请输入播放列表名称。';

  @override
  String get importNameExists => '同名播放列表已存在。换一个名称可同时保留两者。';

  @override
  String get importSaveFailed => '无法保存播放列表。你的预览还在这里——再试一次。';

  @override
  String get importFileTooLarge => '文件超过 10 MB。请把播放列表拆分为更小的导出。';

  @override
  String get importFileUnsupported => '请选择 .csv 或 .txt 文件。';

  @override
  String get importFileEncoding => '无法读取文本编码。请以 UTF-8 保存文件后重试。';

  @override
  String get importCsvInvalid => 'CSV 不完整或格式错误。请重新导出，不要改动列或引号。';

  @override
  String get importCsvMissingColumns =>
      'CSV 需要包含 Track Name 和 Artist Name(s) 列，或 Title 和 Artist 列。请使用原始的 Exportify 导出。';

  @override
  String get importFileEmpty => '未找到曲目。请选择有内容的导出文件，或粘贴「歌手 — 曲目」清单。';

  @override
  String get importTooManyTracks => '单次导入最多 10,000 首。请拆分此播放列表；目前尚未保存任何内容。';

  @override
  String get importFileReadFailed => '无法打开此文件。请确认它在设备上可用后重新选择。';

  @override
  String get importSpotifyBlocked =>
      'Spotify 未在你的地区分享此播放列表。请用 Exportify 导出后选择 CSV 文件。';

  @override
  String get listen => '播放';

  @override
  String get addToPlaylists => '添加到播放列表';

  @override
  String trackSemantics(String title, String artist) {
    return '曲目 $title，$artist';
  }

  @override
  String get trackActions => '曲目操作';

  @override
  String get startWaveFromTrack => '从这首曲目开始声波';

  @override
  String get addToQueue => '添加到队列';

  @override
  String addedToQueue(String title) {
    return '已加入队列：$title';
  }

  @override
  String get removeFavorite => '从收藏移除';

  @override
  String get addFavorite => '添加到收藏';

  @override
  String get addToPlaylist => '添加到播放列表';

  @override
  String get goToArtist => '前往歌手';

  @override
  String get myPlaylist => '我的播放列表';

  @override
  String get newPlaylist => '新建播放列表';

  @override
  String get name => '名称';

  @override
  String get create => '创建';

  @override
  String get loading => '加载中…';

  @override
  String get pause => '暂停';

  @override
  String get play => '播放';

  @override
  String get next => '下一首';

  @override
  String get speedAndPitch => '速度与音调';

  @override
  String speedValue(String value) {
    return '速度：${value}x';
  }

  @override
  String pitchValue(String value) {
    return '音调：${value}x';
  }

  @override
  String get reset => '重置';

  @override
  String get moreActions => '更多操作';

  @override
  String get playbackQueue => '播放队列';

  @override
  String get queueEmpty => '队列为空';

  @override
  String get selectingSource => '正在选择来源';

  @override
  String get collapsePlayer => '收起播放器';

  @override
  String get nowPlayingUpper => '正在播放';

  @override
  String get queue => '队列';

  @override
  String get startWave => '开始声波';

  @override
  String get cover => '封面';

  @override
  String get karaokeLyrics => '卡拉OK歌词';

  @override
  String get findMusicStart => '找到音乐，开始播放';

  @override
  String get playbackNotStarted => '播放尚未开始';

  @override
  String get openSearchFirstTrack => '打开搜索，找到你的第一首曲目';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => '设备上';

  @override
  String get sourceCatalog => '曲库';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => '服务器';

  @override
  String get serverResolver => '解析服务器';

  @override
  String get serverResolverCaption =>
      '可选的自托管服务器，用于解析完整音频流。应用发送搜索词或曲目 ID；服务器返回播放地址。契约与参考实现在 docs/REMOTE_RESOLVER.md。';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => '未配置';

  @override
  String get serverSave => '保存';

  @override
  String get serverDisable => '停用';

  @override
  String get onboardingWelcomeTitle => '欢迎来到 Hook';

  @override
  String get onboardingWelcomeCaption => '音乐、歌词与属于你的视觉风格。选择语言开始——之后可以在设置中更改。';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingNext => '继续';

  @override
  String get onboardingStart => '开始聆听';

  @override
  String get onboardingMicrogTitle => 'MicroG 与 Google 账号';

  @override
  String get onboardingMicrogBody =>
      'MicroG 在没有预装 Google 服务的自定义 Android 系统上重建这些服务。Hook 只将它们用于一项可选功能：连接 YouTube 账号以导入播放列表。播放音乐从不需要 MicroG 或任何 Google 服务。';

  @override
  String get onboardingMicrogNote => '播放不依赖 MicroG。连接账号是可选的。';

  @override
  String get onboardingMicrogDownload => '下载 MicroG';

  @override
  String get onboardingMicrogStatusChecking => '正在检查 Google 服务…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return '此设备上已有 Google 服务（$version）。账号导入开箱即用。';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return '检测到 ReVanced GmsCore（$version）。官方 Google 登录 SDK 与其不兼容，账号连接可能无法使用。播放不受影响。';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      '未找到 Google 服务。要从 YouTube 账号导入播放列表，请先安装 MicroG——或者跳过，直接无账号使用 Hook。';

  @override
  String lyricsView(String mode) {
    return '歌词视图 · $mode';
  }

  @override
  String get lyricsReadingRhythm => '你的阅读节奏';

  @override
  String get lyricsModeSubtitle => '三种方式贴近这首歌。';

  @override
  String get lyricsModeLines => '逐行';

  @override
  String get lyricsModeKaraoke => '卡拉OK';

  @override
  String get lyricsModeFocus => '聚焦';

  @override
  String get lyricsModeLinesDescription => '安静展示歌词并高亮当前行';

  @override
  String get lyricsModeKaraokeDescription => '字词随人声缓缓亮起';

  @override
  String get lyricsModeFocusDescription => '一行大字。别无他物';

  @override
  String get lyricsModeSaveFailed => '无法保存歌词视图。';

  @override
  String get lyricsModeFootnote =>
      '你的选择会为之后的歌曲保留。卡拉OK的精度取决于来源数据：没有逐词时间戳时高亮是近似的，没有时间标记时歌词保持静止。';

  @override
  String get lyricsNotFound => '未找到歌词';

  @override
  String get karaokeUnavailable => '这首曲目没有卡拉OK歌词';

  @override
  String get unsyncedLyrics => '未同步歌词';

  @override
  String get wordSyncUpper => '逐词同步';

  @override
  String get lineSyncUpper => '逐行同步';

  @override
  String get adjustLyricsSync => '调整歌词同步';

  @override
  String get startsSoon => '即将开始';

  @override
  String get musicContinues => '音乐继续';

  @override
  String get decreaseLyricsOffset => '偏移减少 0.1 秒';

  @override
  String lyricsOffset(String value) {
    return '偏移：$value 秒';
  }

  @override
  String get increaseLyricsOffset => '偏移增加 0.1 秒';

  @override
  String get hideSetting => '隐藏设置';

  @override
  String get lyricsOffsetSaveFailed => '无法保存歌词偏移。';

  @override
  String get audioForbidden =>
      '音频服务器拒绝访问（HTTP 403）。曲目已找到，但其音频流不可用。VPN 不保证能访问音频。';

  @override
  String get fullVersionUnavailable => '在可用来源中未找到完整版本。请检查连接或稍后再试。';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source 无法播放此曲目。请检查连接或稍后再试。';
  }
}
