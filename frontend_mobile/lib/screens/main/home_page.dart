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
    label: "PROJECT",
    title: "Rubicon Payment Module",
    details: [
      "Hardware-software solution for cashless vending transactions.",
      "Legacy system modernization via pulse emulation (ESP32).",
      "IoT-integrated architecture using MQTT and WebSockets.",
      "Secure QR-payment flow and real-time status monitoring.",
      "Final Year Diploma Project — Version 1.0.0 (2026).",
      "Engineered for high reliability and galvanic signal isolation.",
      "Centralized fleet management for vending operators.",
    ],
  );

  /// ===== ACADEMIC TEAM INFORMATION =====
  static const companyInfo = InfoModel(
    label: "DEVELOPERS",
    title: "SDU Engineering Team",
    details: [
      "Faculty of Engineering, SDU University.",
      "Major: 6B06102 — Computer Science.",
      "Authors: Tuyakbayev T., Altynbek A., Kumkay S.",
      "Supervisor: Alseitova A. | Co-supervisor: Koishybayev I.",
      "Location: Kaskelen, Kazakhstan.",
      "Focus: Embedded Systems, IoT, and Fintech Integration.",
      "Domain: Embedded Systems & Digital Transformation.",
    ],
  );

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
                ],
              ),
            ), 
          ),
        ),
      ),
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
