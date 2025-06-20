package com.example.flutter_application_1

import io.flutter.embedding.engine.FlutterEngine
import dev.fluttercommunity.plus.device_info.DeviceInfoPlusPlugin
import io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin
import io.flutter.plugins.localnotifications.FlutterLocalNotificationsPlugin
import io.flutter.plugins.pathprovider.PathProviderPlugin
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin

object GeneratedPluginRegistrant {
    fun registerWith(flutterEngine: FlutterEngine) {
        DeviceInfoPlusPlugin.registerWith(flutterEngine)
        flutterEngine.plugins.add(FlutterAndroidLifecyclePlugin())
        flutterEngine.plugins.add(FlutterLocalNotificationsPlugin())
        flutterEngine.plugins.add(PathProviderPlugin())
        flutterEngine.plugins.add(SharedPreferencesPlugin())
        flutterEngine.plugins.add(PaymentNotificationPlugin())
    }
} 