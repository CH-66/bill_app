import 'package:flutter/foundation.dart';
import '../models/bill.dart';
import '../services/database_service.dart';

class BillProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Bill> _bills = [];
  
  List<Bill> get bills => _bills;

  Future<void> loadBills() async {
    _bills = await _databaseService.getAllBills();
    notifyListeners();
  }

  Future<void> addBill(Bill bill) async {
    await _databaseService.insertBill(bill);
    await loadBills();
  }

  Future<void> updateBill(Bill bill) async {
    await _databaseService.updateBill(bill);
    await loadBills();
  }

  Future<void> deleteBill(int id) async {
    await _databaseService.deleteBill(id);
    await loadBills();
  }

  Future<List<Bill>> getBillsByDate(DateTime date) async {
    return await _databaseService.getBillsByDate(date);
  }

  double getTotalExpense() {
    return _bills
        .where((bill) => bill.type == 'expense')
        .fold(0, (sum, bill) => sum + bill.amount);
  }

  double getTotalIncome() {
    return _bills
        .where((bill) => bill.type == 'income')
        .fold(0, (sum, bill) => sum + bill.amount);
  }

  Map<String, double> getCategoryExpenses() {
    final Map<String, double> categoryExpenses = {};
    for (var bill in _bills.where((b) => b.type == 'expense')) {
      categoryExpenses[bill.category] = 
          (categoryExpenses[bill.category] ?? 0) + bill.amount;
    }
    return categoryExpenses;
  }
} 