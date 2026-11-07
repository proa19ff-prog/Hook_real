// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Hook';

  @override
  String get settings => '設定';

  @override
  String get settingsCaption => '変更はこの端末に保存されます。';

  @override
  String get playerSettings => 'プレーヤー';

  @override
  String get lyricsAutoHide => '歌詞を読む間コントロールを隠す';

  @override
  String get lyricsAutoHideDescription =>
      '10秒間操作がないと、プレーヤーのパネルが画面からスライドして消えます。復元ボタンで呼び戻せます。';

  @override
  String get showPlayerControls => 'プレーヤーのコントロールを表示';

  @override
  String get equalizer => 'イコライザー';

  @override
  String get equalizerEnabled => 'サウンド処理';

  @override
  String get equalizerPresets => 'サウンドプロファイル';

  @override
  String get equalizerFlat => 'オリジナル';

  @override
  String get equalizerBass => '深いベース';

  @override
  String get equalizerVocal => 'ボーカル';

  @override
  String get equalizerRock => 'ロック';

  @override
  String get equalizerElectronic => 'エレクトロニカ';

  @override
  String get equalizerSoft => 'ソフト';

  @override
  String get equalizerCustom => 'カスタム';

  @override
  String get equalizerBands => '周波数帯域';

  @override
  String get equalizerBassBoost => 'ベースブースト';

  @override
  String get equalizerBassUnsupported => '追加のベースブーストには対応していません。低域の帯域をお使いください。';

  @override
  String get equalizerPreamp => 'プリアンプ';

  @override
  String get equalizerHeadroom => '自動ヘッドルーム';

  @override
  String get equalizerHeadroomDescription =>
      '周波数を持ち上げる際に出力レベルを下げ、ピークのための余裕を確保します。リミッターではありません。';

  @override
  String get equalizerWaiting => '曲を再生すると、イコライザーがそのオーディオセッションに接続されます。';

  @override
  String get equalizerUnsupported => 'サウンド処理は現在Androidでのみ利用できます。';

  @override
  String get equalizerFailed => 'この端末ではオーディオ効果を有効にできませんでした。音楽は効果なしでも再生できます。';

  @override
  String get equalizerRetry => '効果を再接続';

  @override
  String get equalizerLive => '変更は即座に適用され、この端末に保存されます。';

  @override
  String get youtubeAccount => 'YouTube と MicroG';

  @override
  String get youtubeAccountReadOnly =>
      'プレイリストへの読み取り専用アクセス。サインインしても音声が再生できるとは限りません。';

  @override
  String get youtubeAccountCompatibility => '互換性とプライバシー';

  @override
  String get youtubeAccountSubtitle => 'アカウント接続とプレイリストのインポート';

  @override
  String get youtubeAccountPrivacy =>
      'Hook は YouTube への読み取り専用アクセスを要求します。パスワードは Google のシステムダイアログにのみ入力し、Hook には絶対に入力しないでください。トークンは Hook のサーバーには送られず、メモリ上にのみ保持されます。アプリ再起動後は再接続が必要です。';

  @override
  String get youtubeAccountPlaybackNotice =>
      'サインインで得られるのはアカウントデータへのアクセスであり、オーディオストリームではありません。HTTP 403 の解決を保証するものでもありません。インポートは YouTube の録音を別のソースに置き換えずに保持します。';

  @override
  String get youtubeAccountConnect => 'アカウントを接続';

  @override
  String get youtubeAccountDisconnect => 'Hook で接続解除';

  @override
  String get youtubeAccountDisconnected => 'アカウント未接続';

  @override
  String get youtubeAccountDisconnectNotice =>
      'このアカウントを Hook だけから解除しますか？保存したプレイリストは残ります。携帯電話上の Google・MicroG アカウントからはサインアウトしません。';

  @override
  String get youtubeAccountSystem => 'システムの Google API';

  @override
  String get youtubeAccountServicesMissing =>
      '互換性のあるシステム Google API が利用できません。別途インストールした ReVanced GmsCore は Hook のサインインには代わりになりません。';

  @override
  String get youtubeAccountMicrogNotice =>
      '別途インストールされた ReVanced GmsCore が検出されました。Hook は ReVanced のアカウントやトークンを使用しません。システムの MicroG が互換性のある Google API を提供する場合もありますが、このサインイン方式との互換性は保証されません。';

  @override
  String get youtubeAccountRevancedFound =>
      'YouTube Music ReVanced がインストールされています';

  @override
  String get youtubeAccountPlaylists => 'アカウントのプレイリスト';

  @override
  String get youtubeAccountNoPlaylists =>
      'アクセス可能なプレイリストがありません。YouTube Music の一部の自動コレクションは YouTube Data API からは取得できません。';

  @override
  String get youtubeAccountMore => 'さらに読み込む';

  @override
  String get youtubeAccountPreview => 'インポートを準備';

  @override
  String youtubeAccountProgress(int count) {
    return '取得したトラック: $count';
  }

  @override
  String youtubeAccountUnavailableTracks(int count) {
    return 'スキップした利用不可の項目: $count。別のトラックには置き換えません。';
  }

  @override
  String get youtubeAccountSetup => 'サインインの設定';

  @override
  String get youtubeAccountSetupBody =>
      '開発者は Google Cloud で YouTube Data API v3 を有効にし、com.hook.music とインストール済みビルドの署名 SHA-1 に対して Android OAuth クライアントを登録し、同意画面を構成する必要があります。テストモードでは許可するユーザーを追加してください。詳細は docs/YOUTUBE_ACCOUNT_SETUP.md。パスワード、クライアントシークレット、他アプリのトークンを絶対に追加しないでください。';

  @override
  String get youtubeAccountConfigError =>
      'このビルドではサインインが設定されていません。Google Cloud で Android OAuth クライアント、パッケージ名、SHA-1、許可されたテストユーザーを確認してください。';

  @override
  String get youtubeAccountPermissionError =>
      'YouTube データへの読み取りアクセスが許可されませんでした。';

  @override
  String get youtubeAccountExpired => 'セッションの有効期限が切れました。アカウントに再接続してください。';

  @override
  String get youtubeAccountNoChannel =>
      '選択したアカウントにはアクセス可能な YouTube チャンネルがありません。';

  @override
  String get youtubeAccountQuota => 'YouTube API の割り当てを超えました。後でもう一度お試しください。';

  @override
  String get youtubeAccountFailed =>
      'YouTube のデータを取得できませんでした。接続を確認してもう一度お試しください。';

  @override
  String get youtubeAccountUnsupported =>
      'アカウント接続には、互換性のあるシステム Google API を備えた Android が必要です。';

  @override
  String get importedFromYouTube => 'YouTube アカウントからインポート';

  @override
  String get translateLyrics => '歌詞を翻訳';

  @override
  String get hideTranslation => '翻訳を隠す';

  @override
  String get cancelTranslation => '翻訳をキャンセル';

  @override
  String get translationLoading => '翻訳を準備中…';

  @override
  String get translationAttribution => 'Google 翻訳による自動翻訳';

  @override
  String get translationNotice =>
      '翻訳が曲の意味を正確に捉えられない場合があります。単語のハイライトは原文にのみ適用されます。';

  @override
  String get translationModelTitle => '言語モデルをダウンロードしますか？';

  @override
  String get translationModelBody =>
      '翻訳はあなたの携帯電話上で実行されます。歌詞がサーバーに送信されることはありません。初回の翻訳には Google ML Kit のモデルが必要で、数十メガバイトを要します。ダウンロードは現在の接続（モバイルデータを含む）を使用します。キャンセルすると結果は非表示になりますが、開始済みのモデルダウンロードはバックグラウンドで完了する場合があります。';

  @override
  String get translationDownload => 'ダウンロードして翻訳';

  @override
  String get translationUnavailable =>
      '翻訳に失敗しました。モデルのダウンロードへのアクセスを確認してもう一度お試しください。';

  @override
  String get translationUnsupported => '端末上での翻訳は現在 Android でのみ利用できます。';

  @override
  String get translationUnknownLanguage => 'この曲の対応言語を特定できませんでした。';

  @override
  String get translationSameLanguage => '歌詞はすでに選択した言語です。';

  @override
  String get translationTooLarge => 'この歌詞は端末上での翻訳には長すぎます。';

  @override
  String get translationRussian => 'ロシア語へ';

  @override
  String get translationEnglish => '英語へ';

  @override
  String get translationTarget => '翻訳言語';

  @override
  String get retry => '再試行';

  @override
  String get home => 'ホーム';

  @override
  String get search => '検索';

  @override
  String get library => 'ライブラリ';

  @override
  String get youtubeUnavailableTitle => 'YouTube は現在利用できません';

  @override
  String get youtubeUnavailableBody =>
      'オーディオストリームを取得できませんでした。ネットワークと VPN 経路を確認してください。VPN を使っていても YouTube はリクエストを拒否することがあります。';

  @override
  String get checkAgain => '再確認';

  @override
  String get dismiss => '閉じる';

  @override
  String get goodNight => 'おやすみなさい';

  @override
  String get goodMorning => 'おはようございます';

  @override
  String get goodAfternoon => 'こんにちは';

  @override
  String get goodEvening => 'こんばんは';

  @override
  String get themeSettings => '外観の設定';

  @override
  String get onYourAir => 'あなたの電波に乗せて';

  @override
  String recentSignals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '最近のシグナル $count 件',
    );
    return '$_temp0';
  }

  @override
  String get collectionWaiting => 'あなたのコレクションが待っています';

  @override
  String get saved => '保存済み';

  @override
  String get collectionEmptyDetail => 'また聴きたい音楽はここに残ります';

  @override
  String tracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 曲',
    );
    return '$_temp0';
  }

  @override
  String get homeSearchHint => '曲名、アーティスト、または歌詞';

  @override
  String get searchUpper => '検索';

  @override
  String get findFirstTrack => '最初の1曲を見つけましょう';

  @override
  String continuationAfter(String artist) {
    return '$artist のあとの音楽をもっと';
  }

  @override
  String get chooseTrackWaveDetail => '曲を選べば、その雰囲気に合わせたウェーブを作ります。';

  @override
  String get continueWaveLabel => 'つづき / 01';

  @override
  String get yourWaveLabel => 'あなたのウェーブ / 01';

  @override
  String get continueWave => 'ウェーブを続ける';

  @override
  String get chooseTrack => '曲を選ぶ';

  @override
  String get firstTrace => '最初の足跡をここに残しましょう';

  @override
  String get favoriteWaveHint => 'お気に入りを保存すると、ウェーブがさらに的確になります。';

  @override
  String get openSearch => '検索を開く';

  @override
  String get findYourMusic => 'あなたのサウンドを見つけて。';

  @override
  String get importMusic => '音楽をインポート';

  @override
  String get rememberedLyricsHint => '覚えているあの言葉…';

  @override
  String get trackArtistHint => '曲名かアーティスト — どの言語でも';

  @override
  String get clear => 'クリア';

  @override
  String get music => '音楽';

  @override
  String get byLyrics => '歌詞で';

  @override
  String get allSources => 'すべてのソース';

  @override
  String get lyricsSearchCaption => 'タイトルではなく、歌の中のフレーズを検索します。';

  @override
  String get searchingLyrics => '聞き覚えのあるフレーズを探しています…';

  @override
  String get searchingSources => '音楽ソースを検索中…';

  @override
  String get connectionFailed => '接続できませんでした';

  @override
  String get noMatches => 'まだ一致はありません';

  @override
  String get lyricsUnavailable => '歌詞検索は現在利用できません。後でもう一度試すか、タイトルで検索してください。';

  @override
  String get searchUnavailable => '検索に失敗しました。接続を確認してもう一度お試しください。';

  @override
  String get lyricsNoMatches => '別のフレーズを試してください。すべての歌詞が索引化されているわけではありません。';

  @override
  String get trackNoMatches =>
      'アーティスト名を加えるか、別のソースを選んでください。一部のサービスはあなたのネットワークで利用できない場合があります。';

  @override
  String get repeatSearch => 'もう一度検索';

  @override
  String get lyricMatchesUpper => '歌詞の一致';

  @override
  String get tracksUpper => 'トラック';

  @override
  String playTrack(String title, String artist) {
    return '$title（$artist）を再生';
  }

  @override
  String get familiarLinesUpper => '聞き覚えのあるフレーズ';

  @override
  String get bestMatchUpper => '最適な一致';

  @override
  String get fullVersionOnPlayback => '再生開始時にフルバージョンを探します。';

  @override
  String get forgotTitle => 'タイトルは思い出せない。\nでも音楽は覚えている。';

  @override
  String get startAsYouRemember => '名前、タイトル、曲のフレーズ。\n思い出せるところから始めましょう。';

  @override
  String get foreignNameExample => 'Martin Rose';

  @override
  String get foreignNamesCaption => '名前は響きのままに検索';

  @override
  String get rememberOnlyLine => 'フレーズしか覚えていない';

  @override
  String get findSongByWords => '歌詞の言葉から曲を探す';

  @override
  String get yourArtistsUpper => 'あなたのアーティスト';

  @override
  String get language => '言語';

  @override
  String get languageCaption => 'インターフェースは選択にすぐ従います';

  @override
  String get systemLanguage => 'システム';

  @override
  String get russian => 'ロシア語';

  @override
  String get english => '英語';

  @override
  String get themesAndShaders => 'テーマとエフェクト';

  @override
  String get themesSubtitle => '外観、言語、背景の動き';

  @override
  String get invalidThemeJson => 'テーマを読み取れませんでした。JSON 形式とフィールド値を確認してください。';

  @override
  String get exportJson => 'JSON をエクスポート';

  @override
  String get importJson => 'JSON をインポート';

  @override
  String get readyThemes => 'テーマのプリセット';

  @override
  String get gpuShaders => '背景エフェクト';

  @override
  String get meshGradient => '曲の色に基づくなめらかな GPU グラデーション';

  @override
  String get vinylNoise => 'アナログレコードの粒子（ノイズ）';

  @override
  String get glassBlur => 'ガラスのぼかし（Backdrop Blur）';

  @override
  String get cornerRadius => 'インターフェースの角丸';

  @override
  String get importThemeTitle => 'JSON からテーマをインポート';

  @override
  String get pasteThemeJson => 'テーマの JSON 設定を貼り付けてください：';

  @override
  String get cancel => 'キャンセル';

  @override
  String get apply => '適用';

  @override
  String get themeApplied => 'テーマを適用しました！';

  @override
  String get exportThemeTitle => 'テーマをエクスポート（JSON）';

  @override
  String get close => '閉じる';

  @override
  String get copyJson => 'JSON をコピー';

  @override
  String get jsonCopied => 'テーマの JSON をクリップボードにコピーしました！';

  @override
  String get libraryUpper => 'ライブラリ';

  @override
  String get localCollection => 'ローカルコレクションとプレイリスト';

  @override
  String get importShort => 'インポート';

  @override
  String get favorites => 'お気に入り';

  @override
  String get playlists => 'プレイリスト';

  @override
  String get history => '履歴';

  @override
  String get offline => 'オフライン';

  @override
  String get favoritesEmpty => 'お気に入りはまだ空です。\n曲のハートをタップするとここに追加されます。';

  @override
  String get historyEmpty => '再生履歴はまだ空です。\n検索から音楽を再生すると、ここに表示されます。';

  @override
  String get noPlaylists => 'プレイリストはまだありません';

  @override
  String get importPlaylistHint => 'Spotify のプレイリストをインポートするか、曲リストを貼り付けてください。';

  @override
  String get importMusicAction => '音楽をインポート';

  @override
  String get playPlaylist => 'プレイリストを再生';

  @override
  String playlistStarted(String name, int count) {
    return '「$name」を再生中（$count 曲）';
  }

  @override
  String get deletePlaylist => 'プレイリストを削除';

  @override
  String get playAll => 'すべて再生';

  @override
  String get shuffle => 'シャッフル';

  @override
  String get localAudioCache => 'ローカルオーディオキャッシュ';

  @override
  String get cacheDescription => '再生した曲はローカルに保存され、インターネットなしですぐに再再生できます。';

  @override
  String deviceUsage(String size) {
    return 'この端末上: $size';
  }

  @override
  String get clearCache => 'キャッシュをすべて消去';

  @override
  String savedTracksUpper(int count) {
    return '保存したトラック（$count）:';
  }

  @override
  String get cacheFeaturesUpper => 'キャッシュの特徴:';

  @override
  String get offlineFirst => '完全なオフラインファースト';

  @override
  String get offlineFirstDescription => '再再生の際、オーディオは端末のファイルシステムから直接読み込まれます。';

  @override
  String get maximumBitrate => '最大ビットレート';

  @override
  String get maximumBitrateDescription =>
      '160〜256 kbps のクリーンな Opus/M4A ストリームはトランスコードせずに保存されます。';

  @override
  String get trafficAndBattery => 'データと電池を節約';

  @override
  String get trafficAndBatteryDescription =>
      '繰り返しのネットワーク要求を避けることで、携帯電話が長くもちます。';

  @override
  String get cacheEmpty => 'キャッシュは空です';

  @override
  String get cachedTracksAppear => 'ダウンロードした曲はここに自動的に表示されます';

  @override
  String get removeFromCache => 'キャッシュから削除';

  @override
  String get removeCachedTrackTitle => 'この曲をキャッシュから削除しますか？';

  @override
  String removeCachedTrackBody(String title) {
    return '「$title」はこの端末から削除されます。';
  }

  @override
  String get delete => '削除';

  @override
  String get trackRemovedFromCache => '曲をキャッシュから削除しました';

  @override
  String get clearCacheTitle => 'キャッシュを消去しますか？';

  @override
  String get clearCacheBody =>
      '保存済みのオーディオファイルはすべてこの端末から削除されます。お気に入りと履歴は変わりません。';

  @override
  String get cacheCleared => 'ローカルキャッシュを消去しました';

  @override
  String get back => '戻る';

  @override
  String get playlistActions => 'プレイリストの操作';

  @override
  String get playlistUpper => 'プレイリスト';

  @override
  String get playlistEmpty => 'このプレイリストにはまだ曲がありません';

  @override
  String get pasteTrackList => '曲リストを貼り付け';

  @override
  String get pasteImportLink => 'インポートするリンクを貼り付け';

  @override
  String get tracksNotFound => 'そのリンクからは曲が見つかりませんでした。';

  @override
  String get importError => 'インポートに失敗しました。リンクとインターネット接続を確認してください。';

  @override
  String importedPlaylistStarted(int count) {
    return 'インポートしたプレイリストを再生中（$count 曲）';
  }

  @override
  String importedPlaylistName(String platform) {
    return 'インポート（$platform）';
  }

  @override
  String playlistSaved(String name) {
    return 'プレイリスト「$name」をライブラリに保存しました！';
  }

  @override
  String get spotifyImportSubtitle => 'Spotify • プレイリスト、アルバム、トラック';

  @override
  String get artistTrackOrCsv => 'アーティスト — 曲名、または Exportify の CSV';

  @override
  String get pastePlaylistOrTrackLink => 'プレイリストまたは曲のリンクを貼り付け';

  @override
  String get pasteFromClipboard => 'クリップボードから貼り付け';

  @override
  String get link => 'リンク';

  @override
  String get trackList => '曲リスト';

  @override
  String get playlistName => 'プレイリスト名';

  @override
  String get startImport => 'インポートを開始';

  @override
  String importedCollectionMeta(String author, int count) {
    return '$author • $count 曲';
  }

  @override
  String get importedFromSpotify => 'Spotify からインポート';

  @override
  String get importIntro =>
      'あなたのプレイリストを持ち込みましょう。Spotify リンク、曲リスト、Exportify ファイルが使えます。';

  @override
  String get importTextTab => 'テキスト';

  @override
  String get importFileTab => 'CSV / TXT';

  @override
  String get importChooseFile => 'ファイルを選択';

  @override
  String get importFileHint =>
      'Exportify でエクスポートした CSV か、TXT の曲リストを選択してください。UTF-8、最大 10 MB・10,000 曲。';

  @override
  String get importFileAndroidOnly =>
      'ファイル選択は Android で利用できます。ここでは CSV や曲リストの内容を貼り付けることができます。';

  @override
  String get importTextHint =>
      '1行に「アーティスト — 曲名」を1件。ヘッダー付きの CSV 全体を貼り付けても構いません。';

  @override
  String get importPreview => '曲のプレビュー';

  @override
  String get importedFromCsv => 'CSV からインポート';

  @override
  String get importedFromText => '曲リストからインポート';

  @override
  String importMoreTracks(int count) {
    return 'ほか $count 曲';
  }

  @override
  String get importMetadataHint =>
      'プレイリストはこの端末に保存されます。オーディオは再生時に探されます。インポートしても曲はダウンロードされません。';

  @override
  String get importAnother => 'ほかのものをインポート';

  @override
  String get importReading => 'プレイリストを読み込み中…';

  @override
  String get importSaving => 'ライブラリに保存中…';

  @override
  String get importNameRequired => 'プレイリスト名を入力してください。';

  @override
  String get importNameExists => '同じ名前のプレイリストが既にあります。両方残すには別の名前を選んでください。';

  @override
  String get importSaveFailed =>
      'プレイリストを保存できませんでした。プレビューは残っています — もう一度お試しください。';

  @override
  String get importFileTooLarge =>
      'このファイルは 10 MB を超えています。プレイリストを小さなエクスポートに分けてください。';

  @override
  String get importFileUnsupported => '.csv または .txt ファイルを選択してください。';

  @override
  String get importFileEncoding =>
      'テキストのエンコーディングを読み取れませんでした。ファイルを UTF-8 で保存してもう一度お試しください。';

  @override
  String get importCsvInvalid => 'CSV が不完全か破損しています。列や引用符を変更せずに再エクスポートしてください。';

  @override
  String get importCsvMissingColumns =>
      'CSV には Track Name と Artist Name(s)、または Title と Artist の列が必要です。元の Exportify エクスポートを使用してください。';

  @override
  String get importFileEmpty =>
      '曲が見つかりませんでした。中身のあるエクスポートを選ぶか、アーティスト — 曲名のリストを貼り付けてください。';

  @override
  String get importTooManyTracks =>
      '1回のインポートは最大 10,000 曲です。このプレイリストを分けてください。まだ何も保存されていません。';

  @override
  String get importFileReadFailed =>
      'このファイルを開けませんでした。端末で利用可能か確認して、もう一度選択してください。';

  @override
  String get importSpotifyBlocked =>
      'Spotify はこのプレイリストをあなたの地域で共有していません。Exportify でエクスポートし、CSV ファイルを選択してください。';

  @override
  String get listen => '再生';

  @override
  String get addToPlaylists => 'プレイリストに追加';

  @override
  String trackSemantics(String title, String artist) {
    return 'トラック $title、$artist';
  }

  @override
  String get trackActions => 'トラックの操作';

  @override
  String get startWaveFromTrack => 'この曲からウェーブを開始';

  @override
  String get addToQueue => 'キューに追加';

  @override
  String addedToQueue(String title) {
    return 'キューに追加しました: $title';
  }

  @override
  String get removeFavorite => 'お気に入りから削除';

  @override
  String get addFavorite => 'お気に入りに追加';

  @override
  String get addToPlaylist => 'プレイリストに追加';

  @override
  String get goToArtist => 'アーティストへ';

  @override
  String get myPlaylist => 'マイプレイリスト';

  @override
  String get newPlaylist => '新しいプレイリスト';

  @override
  String get name => '名前';

  @override
  String get create => '作成';

  @override
  String get loading => '読み込み中…';

  @override
  String get pause => '一時停止';

  @override
  String get play => '再生';

  @override
  String get next => '次へ';

  @override
  String get speedAndPitch => '速度とピッチ';

  @override
  String speedValue(String value) {
    return '速度: ${value}x';
  }

  @override
  String pitchValue(String value) {
    return 'ピッチ: ${value}x';
  }

  @override
  String get reset => 'リセット';

  @override
  String get moreActions => 'その他の操作';

  @override
  String get playbackQueue => '再生キュー';

  @override
  String get queueEmpty => 'キューは空です';

  @override
  String get selectingSource => 'ソースを選択中';

  @override
  String get collapsePlayer => 'プレーヤーを折りたたむ';

  @override
  String get nowPlayingUpper => '再生中';

  @override
  String get queue => 'キュー';

  @override
  String get startWave => 'ウェーブを開始';

  @override
  String get cover => 'アートワーク';

  @override
  String get karaokeLyrics => 'カラオケ歌詞';

  @override
  String get findMusicStart => '音楽を見つけて再生を始めよう';

  @override
  String get playbackNotStarted => '再生はまだ始まっていません';

  @override
  String get openSearchFirstTrack => '検索を開いて最初の1曲を見つけましょう';

  @override
  String get sourceSoundCloud => 'SoundCloud';

  @override
  String get sourceDevice => '端末内';

  @override
  String get sourceCatalog => 'カタログ';

  @override
  String get sourceYouTube => 'YouTube';

  @override
  String get sourceAudius => 'Audius';

  @override
  String get sourceServer => 'サーバー';

  @override
  String get serverResolver => 'リゾルバサーバー';

  @override
  String get serverResolverCaption =>
      '完全なオーディオストリームを解決する任意の自前サーバー。アプリは検索語またはトラック ID を送り、サーバーは再生 URL を返します。契約とリファレンス実装は docs/REMOTE_RESOLVER.md にあります。';

  @override
  String get serverResolverHint => 'https://hook-resolver.example.com';

  @override
  String get serverResolverDisabled => '未設定';

  @override
  String get serverSave => '保存';

  @override
  String get serverDisable => '無効にする';

  @override
  String get onboardingWelcomeTitle => 'Hook へようこそ';

  @override
  String get onboardingWelcomeCaption =>
      '音楽、歌詞、そしてあなただけのビジュアルスタイル。言語を選んで始めましょう — 設定から後で変えられます。';

  @override
  String get onboardingSkip => 'スキップ';

  @override
  String get onboardingNext => '続ける';

  @override
  String get onboardingStart => '聴き始める';

  @override
  String get onboardingMicrogTitle => 'MicroG と Google アカウント';

  @override
  String get onboardingMicrogBody =>
      'MicroG は、Google サービスなしで提供されるカスタム Android ROM の上に、それらのサービスを再現します。Hook はそれを1つのオプション機能だけに使います。プレイリストをインポートするために YouTube アカウントを接続することです。音楽の再生に MicroG や Google サービスは一切必要ありません。';

  @override
  String get onboardingMicrogNote => '再生は MicroG に依存しません。アカウント接続は任意です。';

  @override
  String get onboardingMicrogDownload => 'MicroG をダウンロード';

  @override
  String get onboardingMicrogStatusChecking => 'Google サービスを確認中…';

  @override
  String onboardingMicrogStatusOk(String version) {
    return 'この端末には Google サービスがあります（$version）。アカウントのインポートはすぐに使えます。';
  }

  @override
  String onboardingMicrogStatusReVanced(String version) {
    return 'ReVanced GmsCore を検出（$version）。公式の Google サインイン SDK とは互換性がないため、アカウント接続は動作しない可能性があります。再生には影響しません。';
  }

  @override
  String get onboardingMicrogStatusMissing =>
      'Google サービスが見つかりません。YouTube アカウントからプレイリストをインポートするには、先に MicroG をインストールするか、これをスキップしてアカウントなしで Hook をお使いください。';

  @override
  String lyricsView(String mode) {
    return '歌詞ビュー · $mode';
  }

  @override
  String get lyricsReadingRhythm => 'あなたの読むリズム';

  @override
  String get lyricsModeSubtitle => '曲に寄り添う3つの方法。';

  @override
  String get lyricsModeLines => '行';

  @override
  String get lyricsModeKaraoke => 'カラオケ';

  @override
  String get lyricsModeFocus => 'フォーカス';

  @override
  String get lyricsModeLinesDescription => '現在の行をハイライトした落ち着いた歌詞';

  @override
  String get lyricsModeKaraokeDescription => '言葉がボーカルに合わせてやさしく光ります';

  @override
  String get lyricsModeFocusDescription => '大きな1行だけ。他には何も';

  @override
  String get lyricsModeSaveFailed => '歌詞ビューを保存できませんでした。';

  @override
  String get lyricsModeFootnote =>
      '選択は今後の曲にも保存されます。カラオケの精度はソースデータ次第です。単語ごとのタイミングがない場合ハイライトは概算で、タイムスタンプがなければ歌詞は動きません。';

  @override
  String get lyricsNotFound => '歌詞が見つかりません';

  @override
  String get karaokeUnavailable => 'この曲のカラオケ歌詞は利用できません';

  @override
  String get unsyncedLyrics => '同期されていない歌詞';

  @override
  String get wordSyncUpper => '単語ごとのシンク';

  @override
  String get lineSyncUpper => '行ごとのシンク';

  @override
  String get adjustLyricsSync => '歌詞の同期を調整';

  @override
  String get startsSoon => 'もうすぐ始まります';

  @override
  String get musicContinues => '音楽は続きます';

  @override
  String get decreaseLyricsOffset => 'オフセットを 0.1 秒減らす';

  @override
  String lyricsOffset(String value) {
    return 'オフセット: $value 秒';
  }

  @override
  String get increaseLyricsOffset => 'オフセットを 0.1 秒増やす';

  @override
  String get hideSetting => '設定を隠す';

  @override
  String get lyricsOffsetSaveFailed => '歌詞のオフセットを保存できませんでした。';

  @override
  String get audioForbidden =>
      'オーディオサーバーがアクセスを拒否しました（HTTP 403）。曲は見つかりましたが、そのストリームは利用できません。VPN でもオーディオへのアクセスは保証されません。';

  @override
  String get fullVersionUnavailable =>
      '利用可能なソースにフルバージョンが見つかりませんでした。接続を確認するか、後でもう一度お試しください。';

  @override
  String sourcePlaybackFailed(String source) {
    return '$source はこの曲を再生できませんでした。接続を確認するか、後でもう一度お試しください。';
  }

  @override
  String get recentQueriesUpper => '最近の検索';

  @override
  String get clearHistory => '消去';

  @override
  String get waveFromArtist => 'アーティストのウェーブ';

  @override
  String get popularTracksUpper => '人気曲';

  @override
  String artistTracksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 曲',
      zero: 'まだ曲がありません',
    );
    return '$_temp0';
  }
}
