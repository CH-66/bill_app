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