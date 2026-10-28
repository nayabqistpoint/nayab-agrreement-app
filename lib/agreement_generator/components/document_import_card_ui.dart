import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:archive/archive.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import '../agreement_controller.dart';

class DocumentImportCardUi extends StatelessWidget {
  final AgreementController controller;

  const DocumentImportCardUi({super.key, required this.controller});

  // براؤزر سے فائل منتخب کرنے کا محفوظ طریقہ
  void _pickFileFromDevice({
    required BuildContext context,
    required String acceptedTypes,
    required Function(String fileName, List<int> bytes) onFileLoaded,
  }) {
    if (kIsWeb) {
      final input = html.FileUploadInputElement()..accept = acceptedTypes;
      input.click();

      input.onChange.listen((event) {
        final files = input.files;
        if (files == null || files.isEmpty) return;

        final file = files.first;
        final reader = html.FileReader();

        reader.onLoadEnd.listen((e) {
          final result = reader.result;
          if (result is Uint8List) {
            onFileLoaded(file.name, result);
          } else if (result is ByteBuffer) {
            onFileLoaded(file.name, result.asUint8List());
          } else if (result is List<int>) {
            onFileLoaded(file.name, result);
          }
        });

        reader.readAsArrayBuffer(file);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('یہ فیچر فی الحال ویب پر لائیو ٹیسٹ ہو رہا ہے۔')),
      );
    }
  }

  // ورڈ یا ٹیکسٹ فائل منتخب کر کے متن نکالنا
  void _pickWordOrTextFile(BuildContext context) {
    _pickFileFromDevice(
      context: context,
      acceptedTypes: '.txt,.docx',
      onFileLoaded: (fileName, bytes) {
        String extractedText = '';
        final lower = fileName.toLowerCase();

        try {
          if (lower.endsWith('.txt')) {
            extractedText = utf8.decode(bytes, allowMalformed: true);
          } else if (lower.endsWith('.docx')) {
            final archive = ZipDecoder().decodeBytes(bytes);
            final documentXml = archive.findFile('word/document.xml');
            if (documentXml != null) {
              final content = utf8.decode(documentXml.content as List<int>, allowMalformed: true);
              extractedText = content
                  .replaceAll(RegExp(r'<w:p.*?>'), '\n')
                  .replaceAll(RegExp(r'<[^>]*>'), '')
                  .replaceAll('&quot;', '"')
                  .replaceAll('&apos;', "'")
                  .replaceAll('&amp;', '&')
                  .replaceAll('&lt;', '<')
                  .replaceAll('&gt;', '>')
                  .trim();
            }
          }

          if (extractedText.trim().isNotEmpty) {
            controller.selectedPreset = null;
            controller.processTemplate(extractedText.trim());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ فائل "$fileName" سے متن کامیابی سے لوڈ ہو گیا!', textDirection: TextDirection.rtl),
                backgroundColor: Colors.teal.shade700,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('فائل میں سے کوئی اردو متن حاصل نہیں ہو سکا!')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فائل پڑھنے میں رکاوٹ: $e')),
          );
        }
      },
    );
  }

  // پی ڈی ایف فائل منتخب کرنا
  void _pickPdfFile(BuildContext context) {
    _pickFileFromDevice(
      context: context,
      acceptedTypes: '.pdf',
      onFileLoaded: (fileName, bytes) {
        try {
          final raw = String.fromCharCodes(bytes);
          final tagRegex = RegExp(r'\{\{(.*?)\}\}');

          if (tagRegex.hasMatch(raw)) {
            controller.selectedPreset = null;
            controller.processTemplate(raw);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ پی ڈی ایف "$fileName" سے ٹیمپلیٹ حاصل کر لیا گیا!'),
                backgroundColor: Colors.teal.shade700,
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (ctx) => Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  title: Text('پی ڈی ایف موصول: $fileName'),
                  content: const Text(
                    'یہ پی ڈی ایف بنیادی ٹیکسٹ کی بجائے تصویر/پرنٹڈ پیج پر مشتمل لگ رہی ہے۔\n\n'
                    'تصویر والی پی ڈی ایف سے اردو پڑھنے کے لیے پائتھن او سی آر (OCR) کی ضرورت ہوتی ہے۔ فی الحال سادہ ورڈ (.docx) یا ٹیکسٹ (.txt) فائل استعمال کریں۔',
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ٹھیک ہے')),
                  ],
                ),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('پی ڈی ایف پڑھنے میں خرابی: $e')),
          );
        }
      },
    );
  }

  void _showOcrPythonNotice(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          icon: const Icon(Icons.computer, size: 40, color: Colors.blue),
          title: const Text('پائتھن او سی آر سروس'),
          content: const Text(
            'کاغذ پر لکھی یا سکین شدہ تصویر سے اردو متن نکالنے کے لیے کمپیوٹر پر پائتھن سرور کا آن ہونا لازمی ہے۔\n\n'
            'اگر کمپیوٹر بند ہے تو براہِ کرم ٹیکسٹ (.txt) یا ورڈ فائل استعمال کریں۔',
            style: TextStyle(fontSize: 15, height: 1.6),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('سمجھ گیا'),
            ),
          ],
        ),
      ),
    );
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('دستاویز اپلوڈ کریں / ٹیمپلیٹ امپورٹ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('آف لائن سپورٹ',
                      style: TextStyle(fontSize: 12, color: Colors.teal)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickWordOrTextFile(context),
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: const Text('ورڈ / ٹیکسٹ', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickPdfFile(context),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text('پی ڈی ایف', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showOcrPythonNotice(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue.shade50.withValues(alpha: 0.5),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.document_scanner, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'کاغذی معاہدے کی تصویر سے متن پڑھیں (OCR)',
                        style: TextStyle(fontSize: 13, color: Colors.blueAccent),
                      ),
                    ),
                    Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}