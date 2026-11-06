# Android YouTube account setup

Hook uses Google's official Android Identity `AuthorizationClient` from `com.google.android.gms:play-services-auth:22.0.0` and the `https://www.googleapis.com/auth/youtube.readonly` scope. This reads the connected account's channel, playlists, and video metadata through YouTube Data API v3. It does **not** grant audio/video streaming rights, extract playable streams, bypass YouTube restrictions, or read a login/token from YouTube, YouTube Music, ReVanced, or another app.

## Google Cloud configuration

The project owner must perform these steps. Hook does not register a project or approve consent on the user's behalf.

1. Create or select a Google Cloud project and enable **YouTube Data API v3** in APIs & Services.
2. Configure Google Auth Platform's branding, audience/consent screen, and data access. Add the YouTube read-only scope above. If the external app is in testing, add each intended Google account as a **test user**. Publishing to a wider audience may require Google's sensitive-scope verification.
3. Create an OAuth client of type **Android**, with package name **`com.hook.music`** and the **SHA-1 signing-certificate fingerprint of the APK actually installed**. Register separate clients for different debug, release, or Play App Signing certificates as appropriate. The Android Gradle `signingReport` task or `keytool` can show the local signing fingerprint; use the Play Console's app-signing certificate for Play-distributed APKs.
4. Check the current signing configuration before registering the certificate. This repository's `release` build currently uses `signingConfigs.debug`; a production signing change requires the corresponding OAuth client too.
5. On the device, choose **Connect** in Hook, select an account in the official account picker, and accept the requested read-only access. The selected account must have an accessible YouTube channel.

There is no `client_secret`, web-server credential, API key, or refresh token to embed in the APK. This implementation requests neither offline access nor a server authorization code. The Android client is identified by package and signing certificate. A missing/mismatched registration (including SDK developer error 10) or disabled Data API is reported as `configurationRequired`, not disguised as a missing feature.

### Local debug certificate (verified 2026-11-05)

For the debug APK built on this Windows workstation:

- Package: `com.hook.music`
- SHA-1: `E7:CE:71:9B:45:C8:12:A6:5B:01:EC:77:AE:16:31:69:19:47:30:63`

This is a public certificate fingerprint, not a secret. A different machine, regenerated debug keystore, production keystore, or Play App Signing can produce a different fingerprint. Register the certificate used for the installed APK, not this value blindly.

## Google Play services, MicroG, and ReVanced

- The OAuth client targets compatible **system** Google services under `com.google.android.gms`.
- A system GMS-compatible MicroG installation may implement the necessary APIs, but compatibility is **not guaranteed**. Hook checks GoogleApiAvailability first. If the Identity SDK rejects the provider as unavailable/unsupported, Hook reports `servicesUnavailable` and marks support false for that activity's lifetime. Other SDK failures remain their specific error or `unavailable`; a package version alone never proves successful authorization.
- **`app.revanced.android.gms` is a separate ReVanced GmsCore fork, not an OAuth provider supported by Hook.** Detection of that package and its version is informational. In particular, a detected 7.3.0 installation is not treated as a standard system MicroG installation. When both it and normal system GMS are present, authorization uses normal system GMS.
- `revancedMusicInstalled` detects the known package `app.revanced.android.apps.youtube.music`, not custom-renamed APKs or the stock Music package. It does not import that app's account or session.
- The manifest needs Android package visibility entries for `com.google.android.gms`, `app.revanced.android.gms`, and `app.revanced.android.apps.youtube.music` so these checks work on Android 11+.
- No package identity/integrity spoofing or private endpoints are involved.

`status` is a local eligibility check, not an OAuth capability guarantee. It performs no login, consent, or network request. There is no Cloud-config flag that hides the integration before the user can attempt setup.

## Native channel contract

Channel: `hook/youtube_account`. Calls and results use Flutter's standard method codec. An absent optional `nextPageToken` means the end of pagination. Artwork URLs can be null.

| Method | Arguments | Result |
| --- | --- | --- |
| `status` | none | `{supported: bool, systemServicesAvailable: bool, systemServicesVersion: String?, revancedGmsCoreVersion: String?, revancedMusicInstalled: bool, connected: bool}` |
| `connect` | none | `{channelId: String, name: String, artworkUrl: String?}` after authorization, scope validation, and successful `channels.list(mine=true)` |
| `profile` | none | The cached verified profile above, or null; never reauthorizes or makes HTTP requests |
| `playlists` | `{pageToken?: String}` | `{items: [{id: String, title: String, artworkUrl: String?, itemCount: int}], nextPageToken?: String}` |
| `playlistTracks` | `{playlistId: String, pageToken?: String}` | `{items: [{id: String, title: String, artist: String, artworkUrl: String?, durationMs: int}], nextPageToken?: String, unavailableCount: int}` |
| `cancel` | none | null; completes the active operation once with `cancelled`, if any |
| `disconnect` | none | null; clears Hook's local session and cancels the active operation |

Connect explicitly requests account selection through `AuthorizationRequest.Prompt.SELECT_ACCOUNT`; any pending account/permission UI is presented by the Identity SDK and requires user action. A session is not connected until the granted scopes include `youtube.readonly` and channel lookup succeeds. An empty channel response returns `noChannel`.

Playlist pages request at most 50 items. Track pages first call `playlistItems.list`, then `videos.list` with at most 50 distinct video IDs to obtain actual titles, channel names, artwork, and ISO-8601 durations. The returned track ID is the **exact YouTube video ID**, never a playlist-item ID or a search replacement. Playlist order and duplicate videos are preserved. Videos omitted by the API, rejected/deleted/failed uploads, and entries missing required metadata are skipped and counted in `unavailableCount` for that page. `artist` is the API's video channel title, not an inferred recording artist. Metadata visibility does not prove a video can be streamed.

Only one connect/API operation can run at a time. `status`, `profile`, `cancel`, and `disconnect` remain available while it runs. Calling connect again after an operation finishes starts a new account selection and clears the previous local session. Malformed arguments use `unavailable` rather than introducing a separate public error code.

### Public errors

- `cancelled`: user dismissed consent, the caller cancelled/disconnected, the activity closed, or open consent reached its timeout.
- `busy`: another connect/API operation is active.
- `servicesUnavailable`: missing, disabled, outdated, or SDK-incompatible system services. Separate ReVanced GmsCore does not satisfy this requirement.
- `configurationRequired`: Android OAuth registration/configuration mismatch (SDK error 10), disabled Data API, or another recognized project-configuration error.
- `permissionDenied`: required scope was not granted or the API refuses access to a resource.
- `expired`: no current session, a locally expired session, missing access token, or API HTTP 401. Reconnection is explicit, never automatic.
- `noChannel`: no accessible YouTube channel or API `youtubeSignupRequired`.
- `quotaExceeded`: quota/rate-limit response; do not repeatedly retry.
- `network`: network/connection timeout, or transient API server failure.
- `unavailable`: unrecognized SDK/API error, invalid data/arguments, or unavailable resource.

Error messages are sanitized; raw SDK exceptions and API response bodies are never passed to Dart or logged by this integration. A resource-specific permission failure also clears the current local session conservatively.

## Session and request lifetime

The OAuth access token exists **only in native process memory**: no Dart transfer, application logging, preferences, file, or database persistence. The Google Identity provider manages its own consent/token infrastructure outside Hook. Hook discards its local session after process restart, activity destruction, disconnect, API 401, or a conservative 50-minute lifetime; the SDK has no typed token-expiry property. A server may expire a token sooner. There is no background refresh or startup authorization.

Disconnect is local. It does **not** sign the user out of Google/MicroG, remove device accounts, or revoke their cloud consent. The user can separately remove Hook's access in their Google account settings. Cancelling cannot undo consent already accepted in Google's UI, but it prevents a late result from reconnecting Hook.

Consent/authorization has a 3-minute overall timeout, replaced by a 45-second API timeout once authorization completes. HTTP has 10-second connect and 15-second read timeouts and a 2 MiB response cap. Requests run off the main thread, with HTTPS restricted to the fixed `www.googleapis.com/youtube/v3/{channels,playlists,playlistItems,videos}` endpoints. Redirects and URL caching are disabled; caller inputs are encoded query parameters, never request URLs. Artwork is returned as HTTPS metadata only, never fetched with the bearer token.

Cancellation/disposal clears pending Flutter results, timeouts, consent state, authorization-client references, and HTTP futures; sockets are closed off the UI thread. Google's authorization Task cannot itself be cancelled, so generation/identity guards ignore late callbacks. Process-wide non-reused consent request codes prevent an old activity result from being applied to a newer attempt. No stale operation can restore a disconnected session.
