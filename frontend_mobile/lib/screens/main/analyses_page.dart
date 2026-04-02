/* [ Flutter ] */
import 'package:flutter/material.dart';

/* [ Models ] */
import 'package:frontend_mobile/models/machine.dart';
import 'package:frontend_mobile/models/analytics_data.dart';

/* [ Services ] */
import 'package:frontend_mobile/services/machine_list_service.dart';
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

  // 🔥 ДАННЫЕ ДЛЯ ГРАФИКОВ (потом заменишь на API)
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
      final data = await MachineListService.fetchMachines();

      final loadedMachines =
          data.map((json) => Machine.fromJson(json)).toList();

      setState(() {
        machines = loadedMachines;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  // =======================================================
  // ЗАГРУЗКА АНАЛИТИКИ (подключишь backend сюда)
  // =======================================================
  Future<void> _loadAnalytics() async {
    if (selectedMachine == null || selectedRange == null) return;

    setState(() {
      isLoadingAnalytics = true;
      analytics = null; // сброс старых данных
    });

    try {
      final data = await MachineAnalyticsService.getAnalytics(
        machineId: selectedMachine!.id,
        startDate: selectedRange!.start,
        endDate: selectedRange!.end,
      );

      // Преобразуем данные в формат для графиков
      setState(() {
        analytics = data;

        // revenueSpots для LineChart
        revenueSpots = data.revenue
            .map((point) => FlSpot(point.day.toDouble(), point.amount))
            .toList();

        // salesBars для BarChart
        salesBars = data.sales
            .map((point) => BarChartGroupData(
                  x: point.day,
                  barRods: [
                    BarChartRodData(toY: point.count.toDouble(), color: Colors.green, width: 18)
                  ],
                ))
            .toList();

        isLoadingAnalytics = false;
      });
    } catch (e) {
      setState(() => isLoadingAnalytics = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Ошибка загрузки аналитики: $e')));
      }
    }
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
                      child: Column(
                        children: [
                          _buildInfoCard("Тип", selectedMachine!.type),
                          const SizedBox(height: 10),

                          _buildInfoCard(
                              "Локация",
                              selectedMachine!.location ?? "Не указана"),

                          const SizedBox(height: 20),

                          _buildRevenueChart(),
                          const SizedBox(height: 20),

                          _buildSalesChart(),
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
// ВСПОМОГАТЕЛЬНЫЙ МЕТОД — Карточка с графиком
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
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(height: 250, child: child),
      ],
    ),
  );
}

// =======================================================
// 📈 LineChart — выручка
// =======================================================
Widget _buildRevenueChart() {
  if (revenueSpots.isEmpty) return const SizedBox.shrink();

  return _cardWrapper(
    "Выручка",
    LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: revenueSpots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
            ),
            barWidth: 4,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [Colors.blueAccent.withOpacity(0.3), Colors.lightBlueAccent.withOpacity(0.1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: FlDotData(show: true),
          ),
        ],
        // остальные настройки как у вас (gridData, titlesData и т.д.)
        gridData: FlGridData(show: true, drawHorizontalLine: true, horizontalInterval: 50, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 1)),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, _) => Text(value.toInt().toString(), style: const TextStyle(color: Colors.white70, fontSize: 12)))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) => Text('День ${value.toInt()}', style: const TextStyle(color: Colors.white70, fontSize: 12)))),
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
  if (salesBars.isEmpty) return const SizedBox.shrink();

  return _cardWrapper(
    "Продажи",
    BarChart(
      BarChartData(
        barGroups: salesBars,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, _) => Text(value.toInt().toString(), style: const TextStyle(color: Colors.white70, fontSize: 12)))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) => Text('День ${value.toInt()}', style: const TextStyle(color: Colors.white70, fontSize: 12)))),
        ),
        borderData: FlBorderData(show: false),
      ),
    ),
  );
}


}
