import 'package:flutter/material.dart';
import 'agreement_controller.dart';
import 'components/qr_scanner_card_ui.dart';
import 'components/document_import_card_ui.dart';
import 'components/whatsapp_data_card_ui.dart';
import 'components/template_selector_card_ui.dart';
import 'components/agreement_fields_card_ui.dart';
import 'components/action_buttons_ui.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  late final AgreementController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AgreementController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نایاب قسط پوائنٹ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          centerTitle: true,
          backgroundColor: Colors.teal.shade800,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'فارم خالی کریں',
              onPressed: () => _controller.resetForm(context),
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. کیو آر کارڈ
              QrScannerCardUi(controller: _controller),
              const SizedBox(height: 14),

              // 2. دستاویزات اپلوڈ / امپورٹ کارڈ
              DocumentImportCardUi(controller: _controller),
              const SizedBox(height: 14),

              // 3. واٹس ایپ ڈیٹا ایکسچینج کارڈ
              WhatsappDataCardUi(controller: _controller),
              const SizedBox(height: 14),

              // 4. معاہدہ چننے اور ایڈیٹر کا کارڈ
              TemplateSelectorCardUi(controller: _controller),
              const SizedBox(height: 18),

              // 5. تمام خودکار فیلڈز
              AgreementFieldsCardUi(controller: _controller),
              const SizedBox(height: 18),

              // 6. پرنٹ / شیئر ایکشن بٹن
              ActionButtonsUi(controller: _controller),
            ],
          ),
        ),
      ),
    );
  }
}