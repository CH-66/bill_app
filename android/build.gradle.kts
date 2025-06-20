plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    compileSdk = 34
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
val flutterRoot = System.getenv("FLUTTER_ROOT")
apply(from = "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle")