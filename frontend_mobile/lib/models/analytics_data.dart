class AnalyticsData {
  final List<RevenuePoint> revenue;        // выручка по дням/месяцам
  final List<SalesPoint> sales;            // продажи по дням
  final List<ProductPopularity> popularity; // популярность товаров

  AnalyticsData({
    required this.revenue,
    required this.sales,
    required this.popularity,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
  final analyticsJson = json['analytics'] as Map<String, dynamic>;

  final totalRevenue = (analyticsJson['total_revenue'] ?? 0).toDouble();
  final txCount = (analyticsJson['transactions_count'] ?? 0) as int;

  // ✅ Если бэк уже отдаёт daily — используем, иначе fallback на агрегат
  List<RevenuePoint> revenue;
  List<SalesPoint> sales;

  if (analyticsJson.containsKey('daily') && analyticsJson['daily'] != null) {
    final daily = analyticsJson['daily'] as List<dynamic>;
    revenue = daily
        .map((d) => RevenuePoint(
              date: DateTime.parse(d['date']),
              amount: (d['revenue'] ?? 0).toDouble(),
            ))
        .toList();
    sales = daily
        .map((d) => SalesPoint(
              date: DateTime.parse(d['date']),
              count: (d['count'] ?? 0) as int,
            ))
        .toList();
  } else {
    // Старый fallback — одна точка с агрегатом
    revenue = [RevenuePoint(date: DateTime.now(), amount: totalRevenue)];
    sales = [SalesPoint(date: DateTime.now(), count: txCount)];
  }

  return AnalyticsData(revenue: revenue, sales: sales, popularity: []);
}
}

class RevenuePoint {
  final DateTime date;
  final double amount;

  RevenuePoint({required this.date, required this.amount});
}

class SalesPoint {
  final DateTime date;
  final int count;

  SalesPoint({required this.date, required this.count});
}

class ProductPopularity {
  final String productName;
  final double percentage; // доля в процентах (0–100)

  ProductPopularity({required this.productName, required this.percentage});

  factory ProductPopularity.fromJson(Map<String, dynamic> json) =>
      ProductPopularity(
        productName: json['product_name'],
        percentage: json['percentage'].toDouble(),
      );
}