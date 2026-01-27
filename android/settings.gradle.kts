pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            val propFile = file("local.properties")
            if (propFile.exists()) {
                propFile.inputStream().use { properties.load(it) }
            }
            properties.getProperty("flutter.sdk") ?: System.getenv("FLUTTER_ROOT")
                ?: throw GradleException("Flutter SDK not found. Define 'flutter.sdk' in local.properties or set FLUTTER_ROOT environment variable.")
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("com.google.gms.google-services") version "4.4.0" apply false
}

include(":app")
