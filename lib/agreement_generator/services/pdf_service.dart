import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateAndPrintAgreement({
    required String templateText,
    required Map<String, String> fieldValues,
  }) async {
    String finalText = templateText;
    fieldValues.forEach((field, val) {
      finalText = finalText.replaceAll('{{$field}}', val);
    });

    final pdf = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/jameel.ttf');
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: ttf),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey700, width: 1.5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text(
                      'نایاب قسط پوائنٹ',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Divider(thickness: 1),
                  pw.SizedBox(height: 15),
                  pw.Text(
                    finalText,
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 16,
                      lineSpacing: 2.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Agreement_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}