import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/bill_provider.dart';
import 'services/notification_service.dart';
import 'services/payment_notification_service.dart';
import 'screens/add_bill_screen.dart';

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
        navigatorKey: NotificationService.instance.navigatorKey,
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
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('需要通知权限才能监听支付消息'),
            duration: Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    // 检查通知访问权限
    final hasNotificationAccess = await PaymentNotificationService.instance.checkNotificationPermission();
    if (!hasNotificationAccess) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('需要通知访问权限'),
            content: const Text('为了监听支付消息，需要授予通知访问权限。请在设置中启用。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  PaymentNotificationService.instance.openNotificationSettings();
                },
                child: const Text('去设置'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // 启动支付通知监听
    PaymentNotificationService.instance.startListening();

    // 加载账单数据
    await Provider.of<BillProvider>(context, listen: false).loadBills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('智能记账助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<BillProvider>(context, listen: false).loadBills();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              PaymentNotificationService.instance.openNotificationSettings();
            },
          ),
        ],
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
                  subtitle: Text('${bill.category} - ${bill.date.toString().split('.')[0]}'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddBillScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
