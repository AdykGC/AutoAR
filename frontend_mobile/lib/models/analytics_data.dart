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
    return AnalyticsData(
      revenue: (json['revenue'] as List)
          .map((e) => RevenuePoint.fromJson(e))
          .toList(),
      sales: (json['sales'] as List)
          .map((e) => SalesPoint.fromJson(e))
          .toList(),
      popularity: (json['popularity'] as List)
          .map((e) => ProductPopularity.fromJson(e))
          .toList(),
    );
  }
}

class RevenuePoint {
  final int day;     // или timestamp
  final double amount;

  RevenuePoint({required this.day, required this.amount});

  factory RevenuePoint.fromJson(Map<String, dynamic> json) =>
      RevenuePoint(day: json['day'], amount: json['amount'].toDouble());
}

class SalesPoint {
  final int day;
  final int count;

  SalesPoint({required this.day, required this.count});

  factory SalesPoint.fromJson(Map<String, dynamic> json) =>
      SalesPoint(day: json['day'], count: json['count']);
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