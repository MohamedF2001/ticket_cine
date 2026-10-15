// Remove conflicting legacy env variable if present to prevent AndroidLocationsException
run {
    try {
        val peClass = Class.forName("java.lang.ProcessEnvironment")
        listOf("theEnvironment", "theUnmodifiableEnvironment", "theCaseInsensitiveEnvironment").forEach { fieldName ->
            try {
                val field = peClass.getDeclaredField(fieldName)
                field.isAccessible = true
                (field.get(null) as? MutableMap<Any, Any>)?.keys?.removeIf {
                    it.toString().equals("ANDROID_PREFS_ROOT", ignoreCase = true)
                }
            } catch (_: Throwable) {}
        }
    } catch (_: Throwable) {}
}

pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
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
}

include(":app")
