plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.espressif"
    compileSdk = 35 // flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.cepfrontend"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26 // flutter.minSdkVersion
        targetSdk = 35 // flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildFeatures {
        viewBinding = true
        buildConfig = true
    }

    buildTypes {
        getByName("release") {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so lutter run --release works.
            signingConfig = signingConfigs.getByName("debug")
            resValue("string", "proof_of_possesion", "abcd1234")
            resValue("string", "wifi_base_url", "192.168.4.1:80")
            resValue("string", "wifi_device_name_prefix", "PROV_")
            resValue("string", "ble_device_name_prefix", "PROV_")
            buildConfigField("boolean", "isQrCodeSupported", "true")
            buildConfigField("boolean", "isSettingsAllowed", "true")
            buildConfigField("boolean", "isFilteringByPrefixAllowed", "true")
        }
        getByName("debug") {
            resValue("string", "proof_of_possesion", "abcd1234")
            resValue("string", "wifi_base_url", "192.168.4.1:80")
            resValue("string", "wifi_device_name_prefix", "PROV_")
            resValue("string", "ble_device_name_prefix", "PROV_")
            buildConfigField("boolean", "isQrCodeSupported", "true")
            buildConfigField("boolean", "isSettingsAllowed", "true")
            buildConfigField("boolean", "isFilteringByPrefixAllowed", "true")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.3.1")
    implementation("androidx.constraintlayout:constraintlayout:2.1.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.preference:preference:1.2.1")

    implementation("com.google.protobuf:protobuf-javalite:3.18.0")
    implementation("com.google.crypto.tink:tink-android:1.12.0")
    implementation(project(":provisioning"))

    implementation("org.greenrobot:eventbus:3.3.1")
    implementation("com.github.yuriy-budiyev:code-scanner:2.1.2")
    implementation("com.github.firdausmaulan:AVLoadingIndicatorView:2.3.0")

    implementation("com.google.android.gms:play-services-threadnetwork:16.2.1")

    // CameraX
    val camerax_version = "1.5.1"
    implementation("androidx.camera:camera-core:${camerax_version}")
    implementation("androidx.camera:camera-camera2:${camerax_version}")
    implementation("androidx.camera:camera-lifecycle:${camerax_version}")
    implementation("androidx.camera:camera-view:${camerax_version}")
    
    // Guava (ListenableFuture)
    implementation("com.google.guava:guava:31.1-android")
    implementation("androidx.camera:camera-view:${camerax_version}")

    // ML Kit for QR code scanning
    implementation("com.google.mlkit:barcode-scanning:17.3.0")
}
