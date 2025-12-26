# ProGuard rules for AI Math app

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Hive database classes
-keep class hive.** { *; }
-keep class * extends hive.TypeAdapter { *; }

# Keep just_audio classes
-keep class com.google.android.exoplayer2.** { *; }

# Keep model classes for JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Prevent obfuscation of classes with toJson/fromJson methods
-keepclassmembers class * {
    public <init>(...);
    public java.util.Map toJson();
    public static ** fromJson(java.util.Map);
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
}
