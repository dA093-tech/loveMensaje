# ProGuard rules for HookLove

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep model classes
-keep class com.hooklove.app.** { *; }

# Keep R8 from stripping generic signatures
-keepattributes Signature
-keepattributes *Annotation*

# Keep Gson/Json serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
}
