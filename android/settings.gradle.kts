pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        def propertiesFile = file("local.properties")
        if (propertiesFile.exists()) {
            propertiesFile.withInputStream { properties.load(it) }
            def sdkPath = properties.getProperty("flutter.sdk")
            if (sdkPath != null) {
                return sdkPath
            }
        }
        return System.getenv("FLUTTER_ROOT")
    }()

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.2.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
}

include(":app")
