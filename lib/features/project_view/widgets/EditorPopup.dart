import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

Future<void> showEditorPopup(
  BuildContext context, {
  QuillController? controller,
  void Function(QuillController)? onSaved,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) {
      return EditorPopup(controller: controller, onSaved: onSaved);
    },
  );
}

class EditorPopup extends StatefulWidget {
  final QuillController? controller;
  final void Function(QuillController)? onSaved;

  const EditorPopup({Key? key, this.controller, this.onSaved})
    : super(key: key);

  @override
  State<EditorPopup> createState() => _EditorPopupState();
}

class _EditorPopupState extends State<EditorPopup> {
  late QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? QuillController.basic();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.white,
        elevation: 12,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 700,
          height: 450,
          child: Column(
            children: [
              // The updated toolbar using QuillSimpleToolbar
              QuillSimpleToolbar(
                controller: _controller,
                config: QuillSimpleToolbarConfig(
                  multiRowsDisplay: true,
                  embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                ),
              ),

              // Editor area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: QuillEditor.basic(
                    controller: _controller,
                    config: QuillEditorConfig(
                      embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                    ),
                  ),
                ),
              ),

              // Buttons at bottom
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.onSaved != null) {
                          widget.onSaved!(_controller);
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
