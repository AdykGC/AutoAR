import 'package:flutter/material.dart';
import 'package:frontend_mobile/styles/app_styles.dart';

/// =======================================================
/// HOME PAGE
/// Отображает информацию о продукте, компании и системные алерты
/// =======================================================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// ===== PRODUCT INFORMATION =====
  static const productInfo = InfoModel(
    label: "PRODUCT",
    title: "Rubicon Fleet Platform",
    details: [
      "AI-powered vending fleet monitoring and analytics system.",
      "Real-time diagnostics and predictive maintenance alerts.",
      "Smart inventory management with automated restocking insights.",
      "Cloud-based dashboard with enterprise-grade encryption.",
      "Version 2.4.1 — Stable Enterprise Release.",
      "Integrated IoT device orchestration layer.",
      "Advanced anomaly detection powered by ML.",
    ],
  );

  /// ===== COMPANY INFORMATION =====
  static const companyInfo = InfoModel(
    label: "COMPANY",
    title: "Rubicon Technologies",
    details: [
      "Global provider of smart retail automation solutions.",
      "Focused on AI, IoT integration and operational efficiency.",
      "Serving logistics hubs, campuses and airports worldwide.",
      "Mission: Transform vending into autonomous smart commerce.",
      "Enterprise Support: enterprise@rubicon.ai",
      "Founded in 2018 with presence in 12 countries.",
      "Specialized in predictive fleet optimization.",
    ],
  );

  /// ===== SYSTEM ALERTS =====
  static const alerts = [
    AlertModel("#882 - Downtown", "Temperature sensor error", "2M AGO", true),
    AlertModel("#104 - Transit Hub", "Low stock: Beverage Category", "15M AGO", false),
    AlertModel("#022 - Airport", "Connection lost: Re-attempting", "42M AGO", true),
    AlertModel("#551 - Campus", "Weekly scheduled maintenance", "1H AGO", false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,

      /// ================= BODY =================
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// PRODUCT
                  InfoSection(model: productInfo),
                  const SizedBox(height: 20),

                  /// COMPANY
                  InfoSection(model: companyInfo),
                  const SizedBox(height: 28),

                  /// ALERT HEADER
                  const Text(
                    "System Alerts",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// ALERT LIST
                  ...alerts.map((a) => AlertCard(model: a)),
                ],
              ),
            ),
          ),
        ),
      ),

      // /// FLOATING BUTTON
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: const Color(0xFF7500B9),
      //   onPressed: () {},
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

/// =======================================================
/// DATA MODELS
/// =======================================================
class InfoModel {
  final String label;
  final String title;
  final List<String> details;

  const InfoModel({
    required this.label,
    required this.title,
    required this.details,
  });
}

class AlertModel {
  final String unit;
  final String message;
  final String time;
  final bool isError;

  const AlertModel(this.unit, this.message, this.time, this.isError);
}

/// =======================================================
/// INFO SECTION
/// =======================================================
class InfoSection extends StatelessWidget {
  final InfoModel model;

  const InfoSection({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1C2F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LABEL
          Text(
            model.label,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),

          /// TITLE
          Text(
            model.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          /// DETAILS
          ...model.details.map(
            (detail) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ",
                      style: TextStyle(color: Colors.greenAccent)),
                  Expanded(
                    child: Text(
                      detail,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// ALERT CARD
/// =======================================================
class AlertCard extends StatelessWidget {
  final AlertModel model;

  const AlertCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1F1C2F),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(
          model.isError ? Icons.error : Icons.info,
          color: model.isError ? Colors.redAccent : Colors.white70,
        ),
        title: Text(
          model.unit,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          model.message,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Text(
          model.time,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ),
    );
  }
}
