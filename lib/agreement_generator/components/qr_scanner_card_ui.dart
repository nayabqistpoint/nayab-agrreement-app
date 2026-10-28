import 'package:flutter/material.dart';
import '../agreement_controller.dart';

class QrScannerCardUi extends StatelessWidget {
  final AgreementController controller;

  const QrScannerCardUi({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => controller.scanQr(context),
      icon: const Icon(Icons.qr_code_scanner, size: 26),
      label: const Text('پیکج کیو آر کوڈ سکین کریں', style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}