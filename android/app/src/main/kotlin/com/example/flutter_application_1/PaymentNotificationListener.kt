package com.example.flutter_application_1

import android.app.Notification
import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.EventChannel
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class PaymentNotificationListener : NotificationListenerService() {
    companion object {
        private const val WECHAT_PACKAGE = "com.tencent.mm"
        private const val ALIPAY_PACKAGE = "com.eg.android.AlipayGphone"
        
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val packageName = sbn.packageName
        
        if (packageName != WECHAT_PACKAGE && packageName != ALIPAY_PACKAGE) {
            return
        }

        val notification = sbn.notification
        val extras = notification.extras
        val title = extras.getString(Notification.EXTRA_TITLE) ?: ""
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""

        // 解析支付信息
        val paymentInfo = when (packageName) {
            WECHAT_PACKAGE -> parseWeChatPayment(title, text)
            ALIPAY_PACKAGE -> parseAlipayPayment(title, text)
            else -> null
        }

        // 发送支付信息到 Flutter
        paymentInfo?.let {
            eventSink?.success(it.toString())
        }
    }

    private fun parseWeChatPayment(title: String, text: String): JSONObject? {
        // 微信支付成功的通知标题通常包含"支付成功"
        if (!title.contains("支付成功")) {
            return null
        }

        // 解析金额和商家信息
        val amountRegex = "¥([0-9.]+)".toRegex()
        val amountMatch = amountRegex.find(text)
        val amount = amountMatch?.groupValues?.get(1)?.toDoubleOrNull() ?: return null

        // 尝试提取商家名称
        val merchantName = text.substringBefore("消费")

        return JSONObject().apply {
            put("type", "wechat")
            put("amount", amount)
            put("merchant", merchantName.trim())
            put("timestamp", SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.CHINA).format(Date()))
        }
    }

    private fun parseAlipayPayment(title: String, text: String): JSONObject? {
        // 支付宝支付成功的通知标题通常包含"支付宝支付"或"支付成功"
        if (!title.contains("支付宝支付") && !title.contains("支付成功")) {
            return null
        }

        // 解析金额和商家信息
        val amountRegex = "¥([0-9.]+)".toRegex()
        val amountMatch = amountRegex.find(text)
        val amount = amountMatch?.groupValues?.get(1)?.toDoubleOrNull() ?: return null

        // 尝试提取商家名称
        val merchantName = text.substringBefore("支付成功").trim()

        return JSONObject().apply {
            put("type", "alipay")
            put("amount", amount)
            put("merchant", merchantName)
            put("timestamp", SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.CHINA).format(Date()))
        }
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        // 服务连接成功
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        // 服务断开连接
    }
} 