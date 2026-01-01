pluginManagement {
    val flutterSdkPath = try {
        val properties = java.util.Properties()
        java.io.File("local.properties").inputStream().use { properties.load(it) }
        properties.getProperty("flutter.sdk")
    } catch (e: Exception) {
        null
    }

    checkNotNull(flutterSdkPath) { "flutter.sdk not set in local.properties" }
    settings.extra["flutterSdkPath"] = flutterSdkPath

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false // তোমার ভার্সন ভিন্ন হতে পারে, লাল দাগ দিলে আগেরটা রেখো
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false // তোমার ভার্সন ভিন্ন হতে পারে
    
    // 🔥 এই লাইনটিই আমাদের দরকার:
    id("com.google.gms.google-services") version "4.4.1" apply false
}

include(":app")