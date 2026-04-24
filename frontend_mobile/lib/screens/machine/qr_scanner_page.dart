import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatelessWidget {
  const QrScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Сканирование QR"),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final barcodes = capture.barcodes;

          if (barcodes.isNotEmpty) {
            final code = barcodes.first.rawValue;

            if (code != null) {
              Navigator.pop(context, code);
            }
          }
        },
      ),
    );
  }
}
