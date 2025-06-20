pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.application") version "7.3.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
    // Flutter specific settings
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
}

include(":app")

// This is required to provide the Flutter tooling with the Gradle project structure.
apply(from = "${System.getenv("FLUTTER_ROOT")}/packages/flutter_tools/gradle/app_plugin_loader.gradle")
