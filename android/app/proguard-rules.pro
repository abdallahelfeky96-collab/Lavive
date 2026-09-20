# Flutter / Dart engine entry points — R8 must not strip or rename these.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# share_plus / shared_preferences reflection surface (if pulled in).
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# App deep link model + JSON (de)serialization — keep field names intact so
# jsonEncode/jsonDecode produced by json_serializable keeps working.
-keep class com.vegesea.app.models.** { *; }
-keep class com.vegesea.app.layout.** { *; }

# Keep source-file + line info so the generated mapping.txt is actually
# useful for Play's deobfuscation (and for your own crash deobfuscation).
-keepattributes SourceFile,LineNumberTable

# Kotlin stdlib reflection used by kotlin.jvm internal helpers.
-dontwarn kotlin.**

# Flutter engine's Play Store *deferred* component download support references
# com.google.android.play.core (SplitCompat / PlayCoreSplitApplication) but only
# through optional code paths guarded at runtime. We don't ship split APKs, so
# tell R8 to leave those unresolved references alone instead of failing.
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.tasks.**
-dontwarn com.google.android.play.core.**
# Engine references these only from undocumented/optional code paths (split
# compat, deferred download). Missing at runtime by design; suppress.
-dontwarn com.google.android.play.core.**
-dontwarn org.slf4j.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.tasks.**
