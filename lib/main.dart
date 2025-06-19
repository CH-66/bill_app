import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/bill_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BillProvider(),
      child: MaterialApp(
        title: '智能记账助手',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 请求通知权限
    final hasPermission = await NotificationService.instance.requestNotificationPermission();
    if (hasPermission) {
      await NotificationService.instance.startPaymentNotificationListener();
    } else {
      // TODO: 显示权限请求说明
    }

    // 加载账单数据
    await Provider.of<BillProvider>(context, listen: false).loadBills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('智能记账助手'),
      ),
      body: Consumer<BillProvider>(
        builder: (context, billProvider, child) {
          final bills = billProvider.bills;
          if (bills.isEmpty) {
            return const Center(
              child: Text('暂无记账数据'),
            );
          }

          return ListView.builder(
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              return ListTile(
                title: Text(bill.description),
                subtitle: Text('${bill.category} - ${bill.date}'),
                trailing: Text(
                  '¥${bill.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: bill.type == 'expense' ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 实现手动添加账单功能
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
