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
apply(from = "$rootDir/../packages/flutter_tools/gradle/flutter.gradle")