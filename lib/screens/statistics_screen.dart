import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/bill_provider.dart';
import '../models/bill.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Bill> _getMonthlyBills(List<Bill> bills) {
    return bills.where((bill) =>
      bill.date.year == _selectedMonth.year &&
      bill.date.month == _selectedMonth.month
    ).toList();
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month - 1,
                1,
              );
            });
          },
        ),
        Text(
          DateFormat('yyyy年MM月').format(_selectedMonth),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month + 1,
                1,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard(List<Bill> bills) {
    final monthlyBills = _getMonthlyBills(bills);
    final totalExpense = monthlyBills
        .where((bill) => bill.type == 'expense')
        .fold(0.0, (sum, bill) => sum + bill.amount);
    final totalIncome = monthlyBills
        .where((bill) => bill.type == 'income')
        .fold(0.0, (sum, bill) => sum + bill.amount);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('支出', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '¥${totalExpense.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('收入', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '¥${totalIncome.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              '结余: ¥${(totalIncome - totalExpense).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: totalIncome >= totalExpense ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(List<Bill> bills) {
    final monthlyBills = _getMonthlyBills(bills);
    final Map<String, double> categoryExpenses = {};
    
    for (var bill in monthlyBills.where((b) => b.type == 'expense')) {
      categoryExpenses[bill.category] = 
          (categoryExpenses[bill.category] ?? 0) + bill.amount;
    }

    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];

    int colorIndex = 0;
    categoryExpenses.forEach((category, amount) {
      sections.add(
        PieChartSectionData(
          value: amount,
          title: '$category\n¥${amount.toStringAsFixed(0)}',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          color: colors[colorIndex % colors.length],
        ),
      );
      colorIndex++;
    });

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 0,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildBarChart(List<Bill> bills) {
    final monthlyBills = _getMonthlyBills(bills);
    final Map<int, double> dailyExpenses = {};
    final Map<int, double> dailyIncomes = {};

    for (var bill in monthlyBills) {
      final day = bill.date.day;
      if (bill.type == 'expense') {
        dailyExpenses[day] = (dailyExpenses[day] ?? 0) + bill.amount;
      } else {
        dailyIncomes[day] = (dailyIncomes[day] ?? 0) + bill.amount;
      }
    }

    final List<BarChartGroupData> barGroups = [];
    for (int i = 1; i <= 31; i++) {
      if (dailyExpenses[i] != null || dailyIncomes[i] != null) {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: dailyExpenses[i] ?? 0,
                color: Colors.red,
                width: 8,
              ),
              BarChartRodData(
                toY: dailyIncomes[i] ?? 0,
                color: Colors.green,
                width: 8,
              ),
            ],
          ),
        );
      }
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: barGroups.fold(0.0, (max, group) {
            final groupMax = group.barRods.fold(
              0.0,
              (max, rod) => rod.toY > max ? rod.toY : max,
            );
            return groupMax > max ? groupMax : max;
          }) * 1.2,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text('¥${value.toInt()}');
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString());
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计分析'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '总览'),
            Tab(text: '支出分析'),
            Tab(text: '收支趋势'),
          ],
        ),
      ),
      body: Consumer<BillProvider>(
        builder: (context, billProvider, child) {
          final bills = billProvider.bills;
          
          return Column(
            children: [
              _buildMonthSelector(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 总览页面
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildSummaryCard(bills),
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              '月度收支趋势',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildBarChart(bills),
                        ],
                      ),
                    ),
                    // 支出分析页面
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              '支出分类占比',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildPieChart(bills),
                        ],
                      ),
                    ),
                    // 收支趋势页面
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              '日收支情况',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildBarChart(bills),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 