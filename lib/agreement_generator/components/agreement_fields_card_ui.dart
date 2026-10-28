import 'package:flutter/material.dart';
import '../agreement_controller.dart';

class AgreementFieldsCardUi extends StatelessWidget {
  final AgreementController controller;

  const AgreementFieldsCardUi({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.fields.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text(
            'شروع کرنے کے لیے اوپر دیے گئے آپشن سے معاہدہ منتخب کریں یا کسٹم معاہدہ درج کریں۔',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, color: Colors.black54),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ضروری کوائف درج کریں:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('کل خانے: ${controller.fields.length}', style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 12),
        ...controller.fields.map((field) {
          final isAutoFilled = controller.qrData.containsKey(field);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TextField(
              controller: controller.controllers[field],
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: field,
                prefixIcon: isAutoFilled ? const Icon(Icons.check_circle, color: Colors.teal, size: 20) : null,
                helperText: isAutoFilled ? 'کیو آر کوڈ سے خودکار بھرا گیا' : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: isAutoFilled ? Colors.teal.shade50 : Colors.white,
              ),
            ),
          );
        }),
      ],
    );
  }
}