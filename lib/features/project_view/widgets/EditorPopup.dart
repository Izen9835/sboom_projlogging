import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sboom_projlogging/apis/storage_api.dart';

Future<void> showEditorPopup(
  BuildContext context, {
  QuillController? controller,
  required void Function(QuillController, String titleText)
  onSaved, // titleText required, non-nullable
  bool hasTitle = true,
  String? initialTitle,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) {
      return EditorPopup(
        controller: controller,
        onSaved: onSaved,
        hasTitle: hasTitle,
        initialTitle: initialTitle,
      );
    },
  );
}

class EditorPopup extends ConsumerStatefulWidget {
  final QuillController? controller;
  final void Function(QuillController, String titleText)
  onSaved; // titleText non-nullable and required
  final bool hasTitle;
  final String? initialTitle;

  const EditorPopup({
    Key? key,
    this.controller,
    required this.onSaved,
    this.hasTitle = true,
    this.initialTitle,
  }) : super(key: key);

  @override
  ConsumerState<EditorPopup> createState() => _EditorPopupState();
}

class _EditorPopupState extends ConsumerState<EditorPopup> {
  late QuillController _controller;
  late TextEditingController _titleController;
  String? _titleError;
  String? _contentError;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? QuillController.basic();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<String?> onRequestPickImage(context) async {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return "";

      final storageAPI = ref.read(StorageAPIProvider);
      final url = await storageAPI.uploadMedia(pickedFile);
      return url;
    }

    return Center(
      child: Material(
        color: Colors.white,
        elevation: 12,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 700,
          height: widget.hasTitle ? 500 : 450,
          child: Column(
            children: [
              if (widget.hasTitle)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: const OutlineInputBorder(),
                      errorText: _titleError,
                    ),
                    onChanged: (_) {
                      if (_titleError != null) {
                        setState(() {
                          _titleError = null;
                        });
                      }
                    },
                  ),
                ),
              QuillSimpleToolbar(
                controller: _controller,
                config: QuillSimpleToolbarConfig(
                  multiRowsDisplay: true,
                  embedButtons: FlutterQuillEmbeds.toolbarButtons(
                    imageButtonOptions: QuillToolbarImageButtonOptions(
                      imageButtonConfig: QuillToolbarImageConfig(
                        onRequestPickImage: onRequestPickImage,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: QuillEditor.basic(
                          controller: _controller,
                          config: QuillEditorConfig(
                            embedBuilders: FlutterQuillEmbeds.editorWebBuilders(
                              imageEmbedConfig: QuillEditorImageEmbedConfig(),
                            ),
                          ),
                        ),
                      ),
                      if (_contentError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _contentError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        final titleText =
                            widget.hasTitle ? _titleController.text.trim() : "";
                        final delta = _controller.document.toDelta();

                        setState(() {
                          _titleError = null;
                          _contentError = null;
                        });

                        // Validate title (if applicable)
                        if (widget.hasTitle && titleText.isEmpty) {
                          setState(() {
                            _titleError = 'Title cannot be empty';
                          });
                          return; // stop saving
                        }

                        // Validate content (non-empty)
                        // Check if document is empty or only contains just empty block(s)
                        bool isContentEmpty =
                            delta.isEmpty ||
                            (delta.length == 1 &&
                                (delta.first.data == '\n' ||
                                    delta.first.data
                                        .toString()
                                        .trim()
                                        .isEmpty));

                        if (isContentEmpty) {
                          setState(() {
                            _contentError = 'Content cannot be empty';
                          });
                          return; // stop saving
                        }

                        // If valid, call onSaved and close dialog
                        widget.onSaved(_controller, titleText);
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
