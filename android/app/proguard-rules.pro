# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Other third-party libraries
-keep class com.example.mylibrary.** { *; }
-keep class com.google.android.play.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Keep Hive-generated TypeAdapters
-keep class **$$Adapter { *; }

# Keep classes with @HiveType and @HiveField annotations
-keepattributes RuntimeVisibleAnnotations

# Prevent Hive from being optimized away
-keep class com.example.myapp.hive.** { *; }

# Optional: Keep classes that extend HiveObject
-keep class * extends io.flutter.plugins.pathprovider.** { *; }

# Keep FlutterLocalNotificationsPlugin to prevent it from being removed or obfuscated
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep native methods used by the plugin
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep classes that are used in reflection
-keepattributes *Annotation*

# Prevent ProGuard from stripping methods called by JNI
-keep class * extends android.app.Service 

# Keep FlutterLocalNotificationsPlugin classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep reflection-based generic classes
-keepattributes Signature
-keepattributes *Annotation*

# Prevent stripping methods used via reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Prevent R8 from removing Android services (important for scheduled notifications)
-keep class * extends android.app.Service { *; }

# Keep classes used in method channels
-keep class io.flutter.plugins.** { *; }


# Keep Gson classes
-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.** { *; }

# Keep flutter_local_notifications classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Prevent obfuscation of classes used by Gson
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Prevent obfuscation of model classes used by Gson
-keep class com.zaim.my_prayer.models.** { *; } # Replace with your package name

# Keep Flutter & AndroidX DataStore
-keep class io.flutter.** { *; }
-keep class androidx.datastore.** { *; }
-dontwarn androidx.datastore.**

# Keep WorkManager (AndroidX Work Runtime)
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

# Keep Play Core (for in-app updates, dynamic feature delivery)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep Orhanobut Hawk (Encrypted Key-Value Storage)
-keep class com.orhanobut.hawk.** { *; }
-dontwarn com.orhanobut.hawk.**

# Keep Java 8 desugaring libraries
-keep class j$.** { *; }
-dontwarn j$.**

# General AndroidX and Kotlin Coroutines
-dontwarn kotlinx.coroutines.**
-dontwarn androidx.lifecycle.**
-dontwarn androidx.annotation.**
-keep class **.mp3

