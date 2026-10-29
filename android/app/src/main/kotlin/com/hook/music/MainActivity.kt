package com.hook.music

import com.ryanheise.audioservice.AudioServiceActivity

// just_audio_background runs playback inside audio_service, which needs its
// own activity subclass to bind the Flutter engine to the media service.
class MainActivity: AudioServiceActivity() {
}
