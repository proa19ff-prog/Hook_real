# Hook release shrink rules. Flutter's own embedding rules are bundled with
# the Gradle plugin; these cover the native channels and Google SDKs this app
# talks to via reflection.

# MethodChannel handlers are looked up by the embedding; keep them intact.
-keep class com.hook.music.** { *; }

# audio_service runs the foreground service and media button receiver from
# the manifest; reflection keeps them, but their callback wiring needs names.
-keep class com.ryanheise.audioservice.** { *; }

# Google Identity (AuthorizationClient) and ML Kit communicate over GMS
# internally with protobuf + reflection; the published consumer rules of
# play-services-auth / mlkit usually suffice, these are a safety net.
-if class com.google.android.gms.auth.api.identity.**
-keep class com.google.android.gms.auth.api.identity.** { *; }
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_language_id.** { *; }

# Dart/Flutter reads stack traces for ErrorReporting in debug; keep line
# numbers so release crashes remain diagnosable.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
