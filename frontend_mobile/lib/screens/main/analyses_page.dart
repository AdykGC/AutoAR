/* [ Flutter ] */
import 'package:flutter/material.dart';

/* [ Models ] */
import 'package:frontend_mobile/models/machine.dart';
import 'package:frontend_mobile/models/analytics_data.dart';

/* [ Services ] */
import 'package:frontend_mobile/services/machine/machine_list_service.dart';
import 'package:frontend_mobile/services/machine_analytics/analytics_service.dart';

/* [ Styles ] */
import 'package:frontend_mobile/styles/app_styles.dart';

import 'package:fl_chart/fl_chart.dart';

class AnalysesPage extends StatefulWidget {
  const AnalysesPage({super.key});

  @override
  State<AnalysesPage> createState() => _AnalysesPageState();
}

class _AnalysesPageState extends State<AnalysesPage> {
  List<Machine> machines = [];
  Machine? selectedMachine;

  DateTimeRange? selectedRange;
  AnalyticsData? analytics;
  bool isLoadingAnalytics = false;
  bool isLoading = true;

  List<FlSpot> revenueSpots = [];
  List<BarChartGroupData> salesBars = [];
  List<PieChartSectionData> productPie = [];

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  // =======================================================
  // Загрузка аппаратов
  // =======================================================
  Future<void> _loadMachines() async {
    try {
      print('🚀 _loadMachines started');
      final list = await MachineListService.fetchMachines();
      print('✅ fetchMachines returned: $list');

      final loadedMachines = list
        .map((json) => Machine.fromJson(json))
        .toList();
      print('✅ loadedMachines: $loadedMachines');

      setState(() {
        machines = loadedMachines;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print('❌ ERROR: $e');
      print('❌ STACK: $stackTrace');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  // =======================================================
  // Загрузка аналитики
  // =======================================================
  Future<void> _loadAnalytics() async {
    if (selectedMachine == null || selectedRange == null) return;

    setState(() => isLoadingAnalytics = true);

    try {
      final data = await MachineAnalyticsService.getAnalytics(
        machineId: selectedMachine!.id,
        startDate: selectedRange!.start,
        endDate: selectedRange!.end,
      );

      // ✅ Сохраняем и строим графики из реальных данных
      setState(() {
        analytics = data;

        // Индекс по порядку (1, 2, 3...) для оси X графика
        revenueSpots = data.revenue
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
            .toList();

        salesBars = data.sales
            .asMap()
            .entries
            .map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.count.toDouble(),
                      color: Colors.green,
                      width: 18,
                    )
                  ],
                ))
            .toList();

        isLoadingAnalytics = false;
      });
    } catch (e) {
      setState(() => isLoadingAnalytics = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _buildFallbackCharts() {
    final machine = selectedMachine!;
    setState(() {
      revenueSpots = [FlSpot(1, machine.balance ?? 0)];
      salesBars = [
        BarChartGroupData(x: 1, barRods: [
          BarChartRodData(toY: 4, color: Colors.green, width: 18)
        ]),
      ];
    });
  }

  // =======================================================
  // Выбор даты
  // =======================================================
  Future<void> _pickDateRange() async {
    final now = DateTime.now();

    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: now,
      initialDateRange: selectedRange,
    );

    if (result != null) {
      setState(() {
        selectedRange = result;
      });
      _loadAnalytics();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppStyles.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 📅 Дата
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedRange == null
                      ? 'Выберите период'
                      : '${selectedRange!.start.toString().split(' ')[0]} - ${selectedRange!.end.toString().split(' ')[0]}',
                  style: const TextStyle(color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: _pickDateRange,
                  child: const Text('Дата'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🏪 Аппарат
            DropdownButtonFormField<Machine>(
              dropdownColor: AppStyles.dashboardCard,
              value: selectedMachine,
              hint: const Text(
                "Выберите аппарат",
                style: TextStyle(color: Colors.white),
              ),
              items: machines.map((machine) {
                return DropdownMenuItem<Machine>(
                  value: machine,
                  child: Text(
                    machine.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMachine = value;
                });
                _loadAnalytics();
              },
            ),

            const SizedBox(height: 20),

            // 📊 Контент
            Expanded(
              child: selectedMachine == null
                  ? const Center(
                      child: Text(
                        "Выберите аппарат",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildInfoCard("Тип", selectedMachine!.type),
                          const SizedBox(height: 10),
                          _buildInfoCard(
                              "Локация",
                              selectedMachine!.location ?? "Не указана"),
                          const SizedBox(height: 10),
                          _buildInfoCard(
                              "MAC аддресс",
                              selectedMachine!.macAddress ?? "Не указана"),
                          const SizedBox(height: 20),
                          _buildRevenueChart(),
                          const SizedBox(height: 20),
                          _buildSalesChart(),
                          const SizedBox(height: 10),
                          _buildTextStats(),             // ← добавь
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // =======================================================
  // 📦 Карточка инфы
  // =======================================================
  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppStyles.dashboardCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
  // =======================================================
  // Карточка с графиком
  // =======================================================
  Widget _cardWrapper(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppStyles.dashboardCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(height: 250, child: child),
        ],
      ),
    );
  }

  // =======================================================
// Заглушка "нет данных"
// =======================================================
Widget _buildEmptyChart(String title) {
  return _cardWrapper(
    title,
    const Center(
      child: Text(
        'Нет данных за выбранный период',
        style: TextStyle(color: Colors.white38, fontSize: 14),
      ),
    ),
  );
}

// =======================================================
// 📈 LineChart — выручка
// =======================================================
Widget _buildRevenueChart() {
  if (revenueSpots.isEmpty) return _buildEmptyChart("Выручка");

  final maxY = revenueSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

  return _cardWrapper(
    "Выручка",
    LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY * 1.2,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${s.y.toStringAsFixed(0)} ₸',
                      const TextStyle(color: Colors.white),
                    ))
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: revenueSpots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
            ),
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0.3),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: Colors.lightBlueAccent,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
          ),
        ],
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Colors.white12, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, _) => Text(
                _formatAmount(value),
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (analytics == null || index < 0 || index >= analytics!.sales.length) return const SizedBox();
                final d = analytics!.sales[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${d.day.toString().padLeft(2,'0')}.${d.month.toString().padLeft(2,'0')}',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    ),
  );
}

// =======================================================
// 📊 BarChart — продажи
// =======================================================
Widget _buildSalesChart() {
  if (salesBars.isEmpty) return _buildEmptyChart("Продажи");

  final maxY = salesBars
      .expand((g) => g.barRods.map((r) => r.toY))
      .reduce((a, b) => a > b ? a : b);

  return _cardWrapper(
    "Продажи",
    BarChart(
      BarChartData(
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
              '${rod.toY.toInt()} шт.',
              const TextStyle(color: Colors.white),
            ),
          ),
        ),
        barGroups: salesBars
            .map((g) => BarChartGroupData(
                  x: g.x,
                  barRods: g.barRods
                      .map((r) => BarChartRodData(
                            toY: r.toY,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ))
                      .toList(),
                ))
            .toList(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Colors.white12, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (analytics == null || index < 0 || index >= analytics!.revenue.length) return const SizedBox();
                final d = analytics!.revenue[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${d.day.toString().padLeft(2,'0')}.${d.month.toString().padLeft(2,'0')}',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    ),
  );
}

// Хелпер: форматирует числа (1200 → 1.2K)
String _formatAmount(double value) {
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
  return value.toInt().toString();
}

  // =======================================================
// 📋 Текстовая статистика под графиками
// =======================================================
Widget _buildTextStats() {
  if (analytics == null) return const SizedBox.shrink();

  final totalRevenue = analytics!.revenue.fold(0.0, (sum, p) => sum + p.amount);
  final totalSales = analytics!.sales.fold(0, (sum, p) => sum + p.count);
  final avgCheck = totalSales > 0 ? totalRevenue / totalSales : 0.0;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppStyles.dashboardCard,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Итого за период',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildStatRow(Icons.attach_money, 'Выручка', '${_formatAmount(totalRevenue)} ₸', const Color(0xFF69F0AE)),
        const Divider(color: Colors.white12, height: 20),
        _buildStatRow(Icons.receipt_long, 'Транзакций', '$totalSales шт.', Colors.lightBlueAccent),
        if (totalSales > 0) ...[
          const Divider(color: Colors.white12, height: 20),
          _buildStatRow(Icons.trending_up, 'Средний чек', '${avgCheck.toStringAsFixed(0)} ₸', Colors.orangeAccent),
        ],
      ],
    ),
  );
}

Widget _buildStatRow(IconData icon, String label, String value, Color color) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
      Text(
        value,
        style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ],
  );
}
}