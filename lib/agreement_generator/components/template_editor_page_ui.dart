import 'package:flutter/material.dart';

class TemplateEditorPageUi extends StatefulWidget {
  final String initialTitle;
  final String initialContent;
  final List<String> pinnedTags;
  final Function(String title, String content) onSavePermanent;
  final Function(String content) onApplyTemporary;
  final Function(List<String> updatedTags) onUpdateTags;

  const TemplateEditorPageUi({
    super.key,
    required this.initialTitle,
    required this.initialContent,
    required this.pinnedTags,
    required this.onSavePermanent,
    required this.onApplyTemporary,
    required this.onUpdateTags,
  });

  @override
  State<TemplateEditorPageUi> createState() => _TemplateEditorPageUiState();
}

class _TemplateEditorPageUiState extends State<TemplateEditorPageUi> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late List<String> _currentTags;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _bodyController = TextEditingController(text: widget.initialContent);
    _currentTags = List.from(widget.pinnedTags);
  }

  void _insertTag(String tagName) {
    final text = _bodyController.text;
    final selection = _bodyController.selection;
    final tagToInsert = '{{$tagName}}';

    if (selection.start >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, tagToInsert);
      _bodyController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + tagToInsert.length),
      );
    } else {
      _bodyController.text += tagToInsert;
    }
  }

  void _showAddCustomTagDialog() {
    final tagInput = TextEditingController();
    bool pinTag = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('نیا ٹیگ شامل کریں'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tagInput,
                  autofocus: true,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'ٹیگ کا نام',
                    hintText: 'مثلاً: ضامن کا فون نمبر',
                    border: OutlineInputBorder(),
                  ),
                ),
                CheckboxListTile(
                  value: pinTag,
                  title: const Text('اوپر بار میں پن کریں', style: TextStyle(fontSize: 14)),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (v) => setDialogState(() => pinTag = v ?? true),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('منسوخ')),
              ElevatedButton(
                onPressed: () {
                  final name = tagInput.text.trim();
                  if (name.isNotEmpty) {
                    _insertTag(name);
                    if (pinTag && !_currentTags.contains(name)) {
                      setState(() => _currentTags.add(name));
                      widget.onUpdateTags(_currentTags);
                    }
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('درج کریں'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('معاہدہ ایڈیٹر', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.teal.shade800,
          foregroundColor: Colors.white,
          actions: [
            TextButton.icon(
              onPressed: () {
                final content = _bodyController.text.trim();
                if (content.isNotEmpty) {
                  widget.onApplyTemporary(content);
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.flash_on, color: Colors.amberAccent, size: 20),
              label: const Text('صرف لاگو کریں', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: TextField(
                controller: _titleController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'معاہدے کا عنوان',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade300)),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 16, color: Colors.teal),
                    label: const Text('نیا ٹیگ', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.teal.shade50,
                    onPressed: _showAddCustomTagDialog,
                  ),
                  const SizedBox(width: 8),
                  ..._currentTags.map((tag) => Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: InputChip(
                          label: Text(tag),
                          backgroundColor: Colors.white,
                          onPressed: () => _insertTag(tag),
                          onDeleted: () {
                            setState(() => _currentTags.remove(tag));
                            widget.onUpdateTags(_currentTags);
                          },
                          deleteIcon: const Icon(Icons.close, size: 14),
                        ),
                      )),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _bodyController,
                  maxLines: null,
                  expands: true,
                  textAlign: TextAlign.right,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 16, height: 1.8),
                  decoration: const InputDecoration(
                    hintText: 'یہاں معاہدے کی تحریر لکھیں اور اوپر دیے گئے بٹنوں سے ٹیگز شامل کریں...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -1))],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  final title = _titleController.text.trim();
                  final content = _bodyController.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('معاہدے کا نام لکھنا ضروری ہے!')),
                    );
                    return;
                  }
                  if (content.isNotEmpty) {
                    widget.onSavePermanent(title, content);
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('ٹیمپلیٹ مستقل محفوظ کریں', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}