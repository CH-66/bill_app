import 'package:intl/intl.dart';

class Bill {
  final int? id;
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  final String paymentMethod; // 'wechat' or 'alipay'
  final String type; // 'expense' or 'income'

  Bill({
    this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.paymentMethod,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category': category,
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(date),
      'paymentMethod': paymentMethod,
      'type': type,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'],
      amount: map['amount'],
      description: map['description'],
      category: map['category'],
      date: DateFormat('yyyy-MM-dd HH:mm:ss').parse(map['date']),
      paymentMethod: map['paymentMethod'],
      type: map['type'],
    );
  }
} 