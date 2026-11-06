# Equalizer and original-file playback fallback

## Equalizer

Open the fullscreen player's three-dot menu, then **Equalizer**. Start a track first so Android can provide its audio session. Enable sound processing to use:

- device-native frequency bands, labelled with their actual centre frequencies and gain in dB;
- Original, Deep bass, Vocals, Rock, Electronic and Soft profiles, plus custom adjustments;
- optional native BassBoost on devices that implement it;
- preamp attenuation from -12 to 0 dB;
- automatic output headroom when boosting bands/bass (enabled by default).

Controls are saved on the device and reapplied when the player audio session changes, including when switching to a downloaded file. The effect plugin lives with the Flutter audio engine, not the Activity, so backgrounding the player does not release its effects. They affect only Hook's audio session, not all phone audio. Android's actual Equalizer uses 100 millibels per dB. BassBoost's 0–100% control represents native strength, not a measured dB gain.

Automatic headroom reduces player output; it is **not** a hard limiter or a guarantee against distortion. Avoid extreme boosts and excessive listening volume. Other platforms show an unsupported message instead of pretending to process sound. Devices that reject audio effect control can continue playback without effects and offer a reconnect action.

## Download fallback

When streaming fails, Hook refreshes the same recording's stream URL, then tries one complete-file download before abandoning it. Errors that happen after playback has started also trigger a local recovery attempt. A failed Range/native probe does not prevent the download resolver from trying a whole-file GET.

For a direct YouTube recording, the download resolver selects the highest-bitrate available default audio-only stream for the **same video ID**. Bytes are saved without transcoding. “Original” here means the original offered audio stream for that recording, **not** a studio master, FLAC conversion, or an invented lossless version. Existing catalog matching rules still apply to Spotify/other metadata-only entries, which do not themselves provide audio.

The cache:

- saves the real container extension, including M4A, WebM, MP3 and other recognised audio formats;
- rejects HTTP errors, partial responses, HTML, JSON and HLS playlists;
- validates transfer length when supplied and publishes only completed files;
- limits each file to 250 MiB and each transfer to two minutes;
- retains original track metadata and reuses downloaded audio on later playback.

HLS-only sources are not downloaded as bogus `.m4a` files. No HLS segment merger or re-encoder is included. Downloads use the current connection, including mobile data, and consume app-private storage. Saved audio remains in Hook's existing offline/cache library until cleared; it is not exported to the public Music folder.

Recovery keeps the original track ID/source, queue and media metadata. Runtime recovery resumes at the previous position; track changes and stopping cancel the fallback. Pausing and seeking during the transfer update recovery intent rather than auto-playing an old track afterwards.

**A download still needs access to the source.** It can help if whole-file downloads work but native streaming/Range requests do not. It cannot fix a network block, authentication requirement or persistent HTTP 403 on its own. There is no private backend configured by these changes.

## Lyrics

Lyrics are cached separately using the original source-qualified track identity. Their available word timings, line timings, backing vocals and singer information are persisted unchanged. Local playback therefore retains the same lyrics association and existing per-track timing offset.

A successful audio download does not guarantee lyrics exist: providers must supply them at least once. Cache misses/offline errors do not overwrite good saved lyrics. Switching to a local file does not manufacture syllable timings or translations.

## Server requirements for the next stage

A reasonable test VPS is Ubuntu 24.04 with 2 vCPU, 3 GiB RAM, approximately 45 GiB NVMe and a public IPv4 address in a region where YouTube is reachable. An HTTPS hostname, SSH-key access and a sufficient bandwidth allowance are also needed. CPU/RAM sizing is for a small initial deployment without transcoding, ML training or a large local music archive.

Verify search, resolution and actual audio bytes from the assigned IP before renting long-term: datacentre IPs can be rejected. A server that merely redirects the phone to `googlevideo.com` does not remove the phone's dependence on Google connectivity. A usable relay must send audio bytes and preserve Range/seek behaviour. At 128–256 kbit/s, one listening hour transfers roughly 60–120 MB of audio to the client, with provider-specific ingress/egress billing and overhead to consider.

No deployment, credentials, commit or push are included here.
