import 'package:ming_cute_icons/ming_cute_icons.dart';

/// Single icon family for the whole app.
///
/// The UI used to mix Material's filled/rounded glyphs with MingCute line
/// icons, so two icons sitting next to each other had different stroke weights
/// and optical sizes. Everything now comes from MingCute's line set, exposed
/// through semantic names so a screen never picks a glyph directly.
abstract final class HookIcons {
  // Navigation
  static const home = MingCuteIcons.mgc_home_4_line;
  static const search = MingCuteIcons.mgc_search_2_line;
  static const library = MingCuteIcons.mgc_album_line;
  static const libraryShelf = MingCuteIcons.mgc_playlist_line;
  static const settings = MingCuteIcons.mgc_settings_3_line;
  static const palette = MingCuteIcons.mgc_palette_line;
  static const stats = MingCuteIcons.mgc_chart_bar_line;

  // Transport
  static const play = MingCuteIcons.mgc_play_fill;
  static const pause = MingCuteIcons.mgc_pause_fill;
  static const previous = MingCuteIcons.mgc_skip_previous_fill;
  static const next = MingCuteIcons.mgc_skip_forward_fill;
  static const shuffle = MingCuteIcons.mgc_shuffle_line;
  static const shuffleOn = MingCuteIcons.mgc_shuffle_2_fill;
  static const repeat = MingCuteIcons.mgc_repeat_line;
  static const repeatOne = MingCuteIcons.mgc_repeat_one_fill;

  // Audio
  static const volume = MingCuteIcons.mgc_volume_line;
  static const volumeMute = MingCuteIcons.mgc_volume_mute_line;
  static const volumeOff = MingCuteIcons.mgc_volume_off_line;
  static const mixer = MingCuteIcons.mgc_settings_5_line;
  static const queue = MingCuteIcons.mgc_playlist_2_line;
  static const lyrics = MingCuteIcons.mgc_subtitle_line;
  static const lyricsFocus = MingCuteIcons.mgc_scan_line;
  static const lyricsTranslate = MingCuteIcons.mgc_translate_line;
  static const output = MingCuteIcons.mgc_airplay_line;
  static const headphones = MingCuteIcons.mgc_headphone_line;

  // Collection
  static const heart = MingCuteIcons.mgc_heart_line;
  static const heartFilled = MingCuteIcons.mgc_heart_fill;
  static const thumbDown = MingCuteIcons.mgc_thumb_down_line;
  static const download = MingCuteIcons.mgc_download_2_line;
  static const downloadDone = MingCuteIcons.mgc_download_2_fill;
  static const downloadFile = MingCuteIcons.mgc_file_download_line;
  static const importFile = MingCuteIcons.mgc_file_upload_line;
  static const history = MingCuteIcons.mgc_history_line;
  static const add = MingCuteIcons.mgc_add_line;
  static const remove = MingCuteIcons.mgc_minus_circle_line;
  static const playlist = MingCuteIcons.mgc_playlist_line;
  static const playlistAdd = MingCuteIcons.mgc_playlist_line;
  static const playlistCheck = MingCuteIcons.mgc_list_check_line;
  static const dice = MingCuteIcons.mgc_game_1_line;
  static const shufflePick = MingCuteIcons.mgc_shuffle_line;
  static const deleteForever = MingCuteIcons.mgc_delete_2_line;

  // Chrome
  static const close = MingCuteIcons.mgc_close_line;
  static const back = MingCuteIcons.mgc_arrow_left_line;
  static const forward = MingCuteIcons.mgc_arrow_right_line;
  static const chevron = MingCuteIcons.mgc_arrow_right_line;
  static const chevronDown = MingCuteIcons.mgc_down_line;
  static const expand = MingCuteIcons.mgc_arrow_up_line;
  static const collapse = MingCuteIcons.mgc_arrow_down_line;
  static const more = MingCuteIcons.mgc_more_2_line;
  static const moreVertical = MingCuteIcons.mgc_more_1_line;
  static const check = MingCuteIcons.mgc_check_line;
  static const checkCircle = MingCuteIcons.mgc_check_circle_line;
  static const circle = MingCuteIcons.mgc_round_line;
  static const refresh = MingCuteIcons.mgc_refresh_1_line;
  static const sync = MingCuteIcons.mgc_refresh_2_line;
  static const external = MingCuteIcons.mgc_arrow_right_up_line;
  static const paste = MingCuteIcons.mgc_paste_line;
  static const folderOpen = MingCuteIcons.mgc_folder_open_line;
  static const block = MingCuteIcons.mgc_forbid_circle_line;

  // Status / empty states
  static const offline = MingCuteIcons.mgc_wifi_off_line;
  static const noResults = MingCuteIcons.mgc_search_2_none_line;
  static const info = MingCuteIcons.mgc_information_line;
  static const warning = MingCuteIcons.mgc_alert_line;
  static const time = MingCuteIcons.mgc_time_line;
  static const timer = MingCuteIcons.mgc_alarm_1_line;

  // Account / system
  static const account = MingCuteIcons.mgc_user_1_line;
  static const accountCircle = MingCuteIcons.mgc_user_1_line;
  static const social = MingCuteIcons.mgc_user_3_line;
  static const server = MingCuteIcons.mgc_server_line;
  static const shield = MingCuteIcons.mgc_shield_line;
  static const syncCloud = MingCuteIcons.mgc_cloud_line;
  static const window = MingCuteIcons.mgc_monitor_line;
  static const pip = MingCuteIcons.mgc_monitor_line;
  static const language = MingCuteIcons.mgc_translate_line;
  static const visibility = MingCuteIcons.mgc_eye_line;
  static const visibilityOff = MingCuteIcons.mgc_eye_close_line;
  static const filter = MingCuteIcons.mgc_filter_line;
  static const sort = MingCuteIcons.mgc_sort_descending_line;
  static const keyboard = MingCuteIcons.mgc_keyboard_line;
  static const fullscreen = MingCuteIcons.mgc_fullscreen_line;
  static const fullscreenExit = MingCuteIcons.mgc_fullscreen_2_line;
  static const stop = MingCuteIcons.mgc_stop_fill;
  static const closeCircle = MingCuteIcons.mgc_close_circle_line;
  static const file = MingCuteIcons.mgc_file_line;
  static const folder = MingCuteIcons.mgc_folder_line;
  static const share = MingCuteIcons.mgc_share_2_line;
  static const edit = MingCuteIcons.mgc_edit_2_line;
  static const delete = MingCuteIcons.mgc_delete_line;
  static const copy = MingCuteIcons.mgc_copy_line;
  static const link = MingCuteIcons.mgc_link_line;
  static const music = MingCuteIcons.mgc_music_2_line;
  static const note = MingCuteIcons.mgc_music_line;
  static const waveform = MingCuteIcons.mgc_sound_line_fill;
  static const disc = MingCuteIcons.mgc_disc_line;
  static const sparkle = MingCuteIcons.mgc_lightning_line;
  static const mic = MingCuteIcons.mgc_mic_line;
  static const youtube = MingCuteIcons.mgc_youtube_line;
  static const apps = MingCuteIcons.mgc_appstore_line;
  static const battery = MingCuteIcons.mgc_battery_charging_line;
  static const premium = MingCuteIcons.mgc_diamond_line;
}
