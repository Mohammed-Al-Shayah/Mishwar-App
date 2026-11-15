import java.util.Properties
import java.io.FileInputStream

val secretsProperties = Properties()
val secretsPropertiesFile = rootProject.file("secrets.properties")

if (secretsPropertiesFile.exists()) {
    FileInputStream(secretsPropertiesFile).use {
        secretsProperties.load(it)
    }
}

val mapsApiKey = secretsProperties.getProperty("MAPS_API_KEY", "")

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.shayah.mishwar"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.shayah.mishwar"

        minSdk = maxOf(23, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
