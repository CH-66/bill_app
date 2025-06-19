import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bill.dart';
import '../providers/bill_provider.dart';

class AddBillScreen extends StatefulWidget {
  final Bill? bill;
  
  const AddBillScreen({super.key, this.bill});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  String _selectedCategory = '餐饮';
  String _selectedPaymentMethod = 'alipay';
  String _selectedType = 'expense';
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    '餐饮', '交通', '购物', '娱乐', '居住',
    '医疗', '教育', '其他'
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.bill?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.bill?.description ?? '',
    );
    if (widget.bill != null) {
      _selectedCategory = widget.bill!.category;
      _selectedPaymentMethod = widget.bill!.paymentMethod;
      _selectedType = widget.bill!.type;
      _selectedDate = widget.bill!.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveBill() {
    if (_formKey.currentState!.validate()) {
      final bill = Bill(
        id: widget.bill?.id,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        category: _selectedCategory,
        date: _selectedDate,
        paymentMethod: _selectedPaymentMethod,
        type: _selectedType,
      );

      if (widget.bill == null) {
        Provider.of<BillProvider>(context, listen: false).addBill(bill);
      } else {
        Provider.of<BillProvider>(context, listen: false).updateBill(bill);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bill == null ? '添加账单' : '编辑账单'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 金额输入
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '金额',
                  prefixText: '¥',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入金额';
                  }
                  if (double.tryParse(value) == null) {
                    return '请输入有效的金额';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 描述输入
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入描述';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 类型选择
              Row(
                children: [
                  const Text('类型：'),
                  const SizedBox(width: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'expense',
                        label: Text('支出'),
                      ),
                      ButtonSegment(
                        value: 'income',
                        label: Text('收入'),
                      ),
                    ],
                    selected: {_selectedType},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedType = newSelection.first;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 分类选择
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: '分类',
                ),
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
              const SizedBox(height: 16),

              // 支付方式选择
              Row(
                children: [
                  const Text('支付方式：'),
                  const SizedBox(width: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'alipay',
                        label: Text('支付宝'),
                      ),
                      ButtonSegment(
                        value: 'wechat',
                        label: Text('微信'),
                      ),
                    ],
                    selected: {_selectedPaymentMethod},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedPaymentMethod = newSelection.first;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 日期选择
              ListTile(
                title: const Text('日期'),
                subtitle: Text(
                  '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveBill,
        label: const Text('保存'),
        icon: const Icon(Icons.save),
      ),
    );
  }
} 