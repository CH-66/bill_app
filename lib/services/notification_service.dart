import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/bill.dart';
import '../screens/add_bill_screen.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NotificationService._internal();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: androidSettings);
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // 处理通知点击事件
        if (response.payload != null) {
          try {
            final billMap = json.decode(response.payload!);
            final bill = Bill.fromMap(billMap);
            
            // 打开编辑账单页面
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => AddBillScreen(bill: bill),
              ),
            );
          } catch (e) {
            debugPrint('Error processing notification payload: $e');
          }
        }
      },
    );
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> showBillReminder({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'bill_reminder_channel',
      '记账提醒',
      channelDescription: '支付完成后的记账提醒',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // 监听支付通知的方法将在后续实现
  Future<void> startPaymentNotificationListener() async {
    // TODO: 实现支付通知监听
    // 1. 获取通知访问权限
    // 2. 注册通知监听服务
    // 3. 解析通知内容
    // 4. 触发记账提醒
  }
} 