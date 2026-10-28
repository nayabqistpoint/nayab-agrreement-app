import 'package:flutter/material.dart';
import '../agreement_controller.dart';

class ActionButtonsUi extends StatelessWidget {
  final AgreementController controller;

  const ActionButtonsUi({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.fields.isEmpty) return const SizedBox.shrink();

    return ElevatedButton.icon(
      onPressed: () => controller.generateAndPrint(context),
      icon: const Icon(Icons.print, size: 26),
      label: const Text('معاہدہ تیار کریں و پرنٹ / شیئر کریں', style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}