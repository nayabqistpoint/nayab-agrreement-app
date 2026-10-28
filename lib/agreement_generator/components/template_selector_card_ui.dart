import 'package:flutter/material.dart';
import '../agreement_controller.dart';
import '../services/template_service.dart';
import 'template_editor_page_ui.dart';

class TemplateSelectorCardUi extends StatefulWidget {
  final AgreementController controller;

  const TemplateSelectorCardUi({super.key, required this.controller});

  @override
  State<TemplateSelectorCardUi> createState() => _TemplateSelectorCardUiState();
}

class _TemplateSelectorCardUiState extends State<TemplateSelectorCardUi> {
  List<String> _pinnedTags = [
    'کسٹمر کا نام',
    'ولدیت',
    'شناختی کارڈ',
    'موبائل ماڈل',
    'IMEI نمبر',
    'ایڈوانس رقم',
    'ماہانہ قسط',
    'ٹوٹل رقم',
    'مدت',
  ];

  void _openEditor({String? title, String? content}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateEditorPageUi(
          initialTitle: title ?? '',
          initialContent: content ?? widget.controller.currentTemplateText,
          pinnedTags: _pinnedTags,
          onSavePermanent: (t, c) {
            setState(() {
              TemplateService.presetTemplates[t] = c;
              widget.controller.selectedPreset = t;
              widget.controller.processTemplate(c);
            });
          },
          onApplyTemporary: (c) {
            setState(() {
              widget.controller.selectedPreset = null;
              widget.controller.processTemplate(c);
            });
          },
          onUpdateTags: (tags) => setState(() => _pinnedTags = tags),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final templates = TemplateService.presetTemplates;

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
                const Text('معاہدے کا فارمیٹ چنیں:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (widget.controller.selectedPreset != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.teal),
                    onPressed: () {
                      final t = widget.controller.selectedPreset!;
                      _openEditor(title: t, content: templates[t]);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: widget.controller.selectedPreset,
              hint: const Text('معاہدہ منتخب کریں'),
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: templates.keys.map((title) {
                return DropdownMenuItem(
                  value: title,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15)),
                      if (templates.length > 1)
                        InkWell(
                          onTap: () {
                            setState(() {
                              templates.remove(title);
                              if (widget.controller.selectedPreset == title) {
                                widget.controller.selectedPreset = null;
                                widget.controller.processTemplate('');
                              }
                            });
                          },
                          child: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null && templates.containsKey(val)) {
                  widget.controller.selectedPreset = val;
                  widget.controller.processTemplate(templates[val]!);
                }
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.note_add_outlined, size: 20),
              label: const Text('نیا معاہدہ بنائیں / ایڈیٹر کھولیں', style: TextStyle(fontSize: 15)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}