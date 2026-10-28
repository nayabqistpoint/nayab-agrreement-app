import 'dart:convert';
import 'package:flutter/material.dart';
import 'services/qr_scanner_service.dart';
import 'services/template_service.dart';
import 'services/pdf_service.dart';

class AgreementController extends ChangeNotifier {
  String? selectedPreset;
  String currentTemplateText = '';
  final Map<String, TextEditingController> controllers = {};
  List<String> fields = [];
  Map<String, dynamic> qrData = {};

  // ٹیمپلیٹ سے ڈائنامک فیلڈز اور کنٹرولرز تیار کرنا
  void processTemplate(String template) {
    currentTemplateText = template;
    fields = TemplateService.extractFields(template);

    for (var c in controllers.values) {
      c.dispose();
    }
    controllers.clear();

    for (var field in fields) {
      final initialVal = qrData[field]?.toString() ?? '';
      controllers[field] = TextEditingController(text: initialVal);
    }
    notifyListeners();
  }

  // لائیو کیمرہ سکینر کھولنا اور QR ڈیٹا داخل کرنا
  Future<void> scanQr(BuildContext context) async {
    final rawData = await QrScannerService.scanQrCode(context);
    if (rawData == null || rawData.isEmpty) return;

    try {
      final Map<String, dynamic> data = jsonDecode(rawData);
      qrData = data;
      data.forEach((key, value) {
        if (controllers.containsKey(key)) {
          controllers[key]!.text = value.toString();
        }
      });
      notifyListeners();
      if (context.mounted) {
        _showSnackbar(context, '✅ کیو آر کوڈ سے تفصیلات خود بخود درج ہو گئیں!');
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(context, 'کیو آر کوڈ کا ڈیٹا درست فارمیٹ میں نہیں ہے!', isError: true);
      }
    }
  }

  // نیا کسٹمر آنے پر فارم خالی کرنا
  void resetForm(BuildContext context) {
    selectedPreset = null;
    currentTemplateText = '';
    for (var c in controllers.values) {
      c.dispose();
    }
    controllers.clear();
    fields.clear();
    qrData.clear();
    notifyListeners();
    _showSnackbar(context, 'فارم دوبارہ سے صاف کر دیا گیا ہے۔');
  }

  // پی ڈی ایف بنا کر پرنٹ و شیئر کرنا
  Future<void> generateAndPrint(BuildContext context) async {
    if (currentTemplateText.isEmpty) {
      _showSnackbar(context, 'براہ کرم پہلے کوئی معاہدہ منتخب کریں!', isError: true);
      return;
    }

    final fieldValues = controllers.map((k, v) => MapEntry(k, v.text));
    await PdfService.generateAndPrintAgreement(
      templateText: currentTemplateText,
      fieldValues: fieldValues,
    );
  }

  void _showSnackbar(BuildContext context, String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontFamily: 'JameelNoori', fontSize: 16),
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.teal.shade700,
      ),
    );
  }

  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}