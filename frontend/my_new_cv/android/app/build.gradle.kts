plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.habtech.cv_pro"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.habtech.cv_pro"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
             isMinifyEnabled = true   // ኮዱን ያሳንሰዋል
             isShrinkResources = true

            signingConfig = signingConfigs.getByName("debug")

        }
    }
}

flutter {
    source = "../.."
}

// 3. ተጨምሯል
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.9.0")) // ቨርዥኑን ወደ 33.9.0 ዝቅ አድርገው (ይበልጥ Stable ነው)
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-config") // ይሄ ለሪሞት ኮንፊግ የግድ ያስፈልጋል!
    implementation("com.google.firebase:firebase-database") // ይሄ ለሪልታይም ዳታቤዝ
}
