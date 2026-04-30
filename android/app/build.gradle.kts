import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    
}
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
android {
    namespace = "com.smatechgroup.smacredit"
    compileSdk = flutter.compileSdkVersion
    ndkVersion="27.0.12077973"
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        isCoreLibraryDesugaringEnabled = true
    }

     kotlin {
        jvmToolchain(17)
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }


    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storePassword = keystoreProperties.getProperty("storePassword")

            // This assumes your .jks file is inside the android/app/ folder
            val stFile = keystoreProperties.getProperty("storeFile")
            if (stFile != null) {
                storeFile = file(stFile)
            }
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.smatechgroup.tese"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled=true

    }

    buildTypes {
        release {
            ndk {
                debugSymbolLevel = "SYMBOL_TABLE"
            }

            isMinifyEnabled = true
            isShrinkResources = true
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
        }
    }

    packaging {
        jniLibs {
            pickFirsts.add("**/*.so")
//            keepDebugSymbols.add("**/*.so")
//
//            // If it still fails, try adding this to avoid conflicts
//            pickFirsts.add("**/*.so")
//            doNotStrip.add("**/*.so")
        }
    }
}
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.6.0"))
   implementation("com.google.firebase:firebase-analytics")
   coreLibraryDesugaring ("com.android.tools:desugar_jdk_libs:2.0.3")

}
flutter {
    source = "../.."
}
