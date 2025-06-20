package com.example.flutter_application_1

import io.flutter.app.FlutterApplication
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin

class FlutterPluginRegistrant : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
    }

    companion object {
        fun registerWith(flutterEngine: FlutterEngine) {
            try {
                flutterEngine.plugins.add(PaymentNotificationPlugin())
            } catch (e: Exception) {
                // 处理注册失败的情况
            }
        }
    }
} 