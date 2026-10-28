import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../agreement_controller.dart';

class WhatsappDataCardUi extends StatefulWidget {
  final AgreementController controller;

  const WhatsappDataCardUi({super.key, required this.controller});

  @override
  State<WhatsappDataCardUi> createState() => _WhatsappDataCardUiState();
}

class _WhatsappDataCardUiState extends State<WhatsappDataCardUi> {
  final TextEditingController _phoneController = TextEditingController();

  // واٹس ایپ پر کسٹمر کو میسج بھیجنے کا فلو
  void _sendQuestionsToCustomer() {
    if (widget.controller.fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('براہ کرم پہلے کوئی معاہدہ منتخب کریں!')),
      );
      return;
    }

    // وہ تمام فیلڈز جو QR کوڈ سے فل نہیں ہوئیں
    final missingFields = widget.controller.fields
        .where((f) => !widget.controller.qrData.containsKey(f))
        .toList();

    if (missingFields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمام ضروری معلومات پہلے ہی درج ہیں!')),
      );
      return;
    }

    final selected = Map<String, bool>.fromIterable(missingFields, value: (_) => true);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('گاہک سے مطلوبہ معلومات منتخب کریں'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: missingFields.map((field) {
                  return CheckboxListTile(
                    value: selected[field],
                    title: Text(field, style: const TextStyle(fontSize: 15)),
                    onChanged: (val) {
                      setDialogState(() {
                        selected[field] = val ?? false;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('منسوخ')),
              ElevatedButton.icon(
                icon: const Icon(Icons.send, size: 18),
                label: const Text('واٹس ایپ میسج بنائیں'),
                onPressed: () {
                  Navigator.pop(ctx);
                  _generateAndOpenWhatsapp(selected);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // واٹس ایپ میسج تیار کرنا اور کھولنا
  Future<void> _generateAndOpenWhatsapp(Map<String, bool> selected) async {
    final fieldsToSend = selected.entries.where((e) => e.value).map((e) => e.key).toList();
    if (fieldsToSend.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln('محترم گاہک! نایاب قسط پوائنٹ پر آپ کا معاہدہ تیار کیا جا رہا ہے۔');
    buffer.writeln('براہِ کرم اس میسج کے جواب میں درج ذیل معلومات لکھ کر بھیجیں:\n');
    for (int i = 0; i < fieldsToSend.length; i++) {
      buffer.writeln('${i + 1}. ${fieldsToSend[i]}: ');
    }

    final messageText = buffer.toString();
    String phone = _phoneController.text.trim().replaceAll(' ', '').replaceAll('-', '');

    // پاکستانی نمبر کو بین الاقوامی فارمیٹ میں بدلنا
    if (phone.startsWith('03')) {
      phone = '92${phone.substring(1)}';
    }

    if (phone.isNotEmpty) {
      final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(messageText)}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _copyToClipboard(messageText);
      }
    } else {
      _copyToClipboard(messageText);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('میسج کاپی ہو گیا! گاہک کو واٹس ایپ پر پیسٹ کر کے بھیج دیں۔')),
    );
  }

  // کسٹمر کے جوابی میسج کو کلپ بورڈ سے پکڑ کر فارم میں بھرنا
  Future<void> _pasteAndParseData() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text ?? '';
    if (text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('کلپ بورڈ خالی ہے! پہلے واٹس ایپ سے میسج کاپی کریں۔')),
        );
      }
      return;
    }

    int matchCount = 0;
    final lines = text.split('\n');
    for (var line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        String key = parts[0].replaceAll(RegExp(r'^[0-9]+[\.\-\s]+'), '').trim();
        String val = parts.sublist(1).join(':').trim();

        if (widget.controller.controllers.containsKey(key) && val.isNotEmpty) {
          widget.controller.controllers[key]!.text = val;
          matchCount++;
        }
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $matchCount معلومات خودکار طریقے سے درج ہو گئیں!'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('گاہک سے کوائف بذریعہ واٹس ایپ منگوائیں',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Icon(Icons.chat_bubble_outline, color: Colors.green, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                labelText: 'گاہک کا موبائل نمبر (اختیاری)',
                hintText: '03001234567',
                prefixIcon: const Icon(Icons.phone_android, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // 1. گاہک کو سوالات بھیجنے کا بٹن
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendQuestionsToCustomer,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('سوالات واٹس ایپ کریں', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 2. گاہک کا جواب پیسٹ کرنے کا بٹن
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pasteAndParseData,
                    icon: const Icon(Icons.content_paste, size: 18),
                    label: const Text('جواب آٹو فل کریں', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}