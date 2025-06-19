import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bill.dart';
import '../providers/bill_provider.dart';
import 'add_bill_screen.dart';

class BillListScreen extends StatefulWidget {
  const BillListScreen({super.key});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  String _searchQuery = '';
  String _selectedCategory = '全部';
  String _selectedType = '全部';
  String _selectedPaymentMethod = '全部';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['全部', '餐饮', '交通', '购物', '娱乐', '居住', '医疗', '教育', '其他'];
  final List<String> _types = ['全部', 'expense', 'income'];
  final List<String> _paymentMethods = ['全部', 'alipay', 'wechat'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Bill> _filterBills(List<Bill> bills) {
    return bills.where((bill) {
      // 搜索过滤
      if (_searchQuery.isNotEmpty &&
          !bill.description.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // 分类过滤
      if (_selectedCategory != '全部' && bill.category != _selectedCategory) {
        return false;
      }

      // 类型过滤
      if (_selectedType != '全部' && bill.type != _selectedType) {
        return false;
      }

      // 支付方式过滤
      if (_selectedPaymentMethod != '全部' && bill.paymentMethod != _selectedPaymentMethod) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账单管理'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Column(
            children: [
              // 搜索框
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索账单...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              // 筛选选项
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // 分类筛选
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    // 类型筛选
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        value: _selectedType,
                        items: _types.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type == 'expense' ? '支出' : type == 'income' ? '收入' : '全部'),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedType = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    // 支付方式筛选
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        value: _selectedPaymentMethod,
                        items: _paymentMethods.map((String method) {
                          return DropdownMenuItem<String>(
                            value: method,
                            child: Text(
                              method == 'alipay' ? '支付宝' :
                              method == 'wechat' ? '微信' : '全部'
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedPaymentMethod = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<BillProvider>(
        builder: (context, billProvider, child) {
          final filteredBills = _filterBills(billProvider.bills);
          
          if (filteredBills.isEmpty) {
            return const Center(
              child: Text('没有找到符合条件的账单'),
            );
          }

          return ListView.builder(
            itemCount: filteredBills.length,
            itemBuilder: (context, index) {
              final bill = filteredBills[index];
              return Dismissible(
                key: Key(bill.id.toString()),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  billProvider.deleteBill(bill.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('账单已删除'),
                      action: SnackBarAction(
                        label: '撤销',
                        onPressed: () {
                          billProvider.addBill(bill);
                        },
                      ),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(bill.description),
                  subtitle: Text(
                    '${bill.category} - ${bill.date.toString().split('.')[0]}\n'
                    '${bill.paymentMethod == 'alipay' ? '支付宝' : '微信'}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    '¥${bill.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: bill.type == 'expense' ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddBillScreen(bill: bill),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 