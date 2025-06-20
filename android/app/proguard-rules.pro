# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.platform.** { *; }

# Keep our custom classes
-keep class com.example.flutter_application_1.** { *; }

# Keep JSON classes
-keep class org.json.** { *; }
-keepclassmembers class org.json.** { *; }

# Keep Notification related classes
-keep class android.app.Notification { *; }
-keep class android.app.NotificationManager { *; }
-keep class android.service.notification.NotificationListenerService { *; }
-keep class android.service.notification.StatusBarNotification { *; }

# Keep SQLite related classes
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# Keep Kotlin Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# Keep Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Keep Device Info Plus
-keep class dev.fluttercommunity.plus.device_info.** { *; }

# Multidex
-keep class androidx.multidex.** { *; }

# General
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Remove debug logs in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
} 