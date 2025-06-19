import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bill.dart';
import 'notification_service.dart';
import 'database_service.dart';

class PaymentNotificationService {
  static final PaymentNotificationService instance = PaymentNotificationService._internal();
  final MethodChannel _channel = const MethodChannel('payment_notification_plugin');
  final EventChannel _eventChannel = const EventChannel('payment_notification_events');
  final DatabaseService _databaseService = DatabaseService.instance;
  final NotificationService _notificationService = NotificationService.instance;

  PaymentNotificationService._internal();

  Future<bool> checkNotificationPermission() async {
    try {
      final bool hasPermission = await _channel.invokeMethod('checkNotificationPermission');
      return hasPermission;
    } on PlatformException catch (e) {
      print('Failed to check notification permission: ${e.message}');
      return false;
    }
  }

  Future<void> openNotificationSettings() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } on PlatformException catch (e) {
      print('Failed to open notification settings: ${e.message}');
    }
  }

  void startListening() {
    _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) async {
        try {
          final Map<String, dynamic> paymentInfo = json.decode(event.toString());
          
          // 创建账单记录
          final bill = Bill(
            amount: paymentInfo['amount'],
            description: paymentInfo['merchant'],
            category: '其他', // 默认分类，用户可以在记账时修改
            date: DateTime.parse(paymentInfo['timestamp']),
            paymentMethod: paymentInfo['type'],
            type: 'expense',
          );

          // 保存到数据库
          await _databaseService.insertBill(bill);

          // 显示记账提醒通知
          await _notificationService.showBillReminder(
            title: '新支付提醒',
            body: '您刚刚在${bill.description}支付了¥${bill.amount}，点击进行记账',
            payload: json.encode(bill.toMap()),
          );
        } catch (e) {
          print('Error processing payment notification: $e');
        }
      },
      onError: (error) {
        print('Error from payment notification stream: $error');
      },
    );
  }
} 