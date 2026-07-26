plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // namespace는 구 값 유지 — R 클래스·MainActivity(.MainActivity) 해석 기준이라
    // 바꾸면 android/app/src/main/kotlin/com/giltech/mylibrary/MainActivity.kt를
    // 옮기고 package 선언까지 고쳐야 한다. namespace ≠ applicationId는 AGP 정식
    // 지원 조합이므로 그대로 둔다. 정리는 별도 커밋으로.
    namespace = "com.giltech.mylibrary"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // v03 전환: 구 도서 앱(com.giltech.mylibrary)과 별개 앱으로 설치되도록
        // 분리. 이 값이 온디바이스 앱 정체성이라, 같으면 기존 앱을 덮어쓴다.
        // Play 게시 후에는 변경 불가 — 게시 전인 지금 확정한다.
        applicationId = "com.giltech.classicshelf"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
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
