## Flutter Local Notifications ProGuard Rules

# Keep the flutter_local_notifications plugin classes
-keep class com.dexterous.** { *; }

# Keep notification-related classes
-keep class android.app.Notification { *; }
-keep class android.app.NotificationManager { *; }
-keep class android.app.AlarmManager { *; }
-keep class android.app.PendingIntent { *; }

# Keep Gson (often used by notification plugins)
-keepattributes Signature
-keepattributes *Annotation*

# Keep workmanager classes
-keep class androidx.work.** { *; }
