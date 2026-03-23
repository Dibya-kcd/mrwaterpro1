# ══════════════════════════════════════════════════════════════════════════════
# proguard-rules.pro — MrWater APK release build rules
# ══════════════════════════════════════════════════════════════════════════════

# ── Flutter ───────────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }

# ── Firebase ──────────────────────────────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
# Keep Firebase model classes (RTDB uses reflection for serialisation)
-keepattributes Signature
-keepattributes *Annotation*
-keepclassmembers class * {
    @com.google.firebase.database.PropertyName *;
}

# ── Google ML Kit (text recognition) ─────────────────────────────────────────
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-dontwarn com.google.mlkit.**

# ── speech_to_text ────────────────────────────────────────────────────────────
-keep class com.csdcorp.speech_to_text.** { *; }

# ── video_player ──────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.videoplayer.** { *; }

# ── share_plus ────────────────────────────────────────────────────────────────
-keep class dev.fluttercommunity.plus.share.** { *; }

# ── image_picker ──────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.imagepicker.** { *; }

# ── printing ──────────────────────────────────────────────────────────────────
-keep class net.nfet.flutter.printing.** { *; }

# ── path_provider ─────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.pathprovider.** { *; }

# ── General Android / Kotlin ──────────────────────────────────────────────────
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-dontwarn sun.misc.**
-dontwarn java.lang.invoke.**

# Keep Kotlin coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembers class kotlinx.coroutines.** {
    volatile <fields>;
}

# Prevent stripping of crash report line numbers
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
