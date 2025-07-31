import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/apis/auth_api.dart';
import 'package:sboom_projlogging/common/common.dart';
import 'package:sboom_projlogging/core/utils.dart';
import 'package:sboom_projlogging/features/project_view/controller/bugreports_controller.dart';
import 'package:sboom_projlogging/features/project_view/controller/changelog_controller.dart';
import 'package:sboom_projlogging/features/project_view/widgets/EditorPopup.dart';
import 'package:sboom_projlogging/model/model.dart';
import 'package:sboom_projlogging/core/core.dart';

class BugReportsList extends ConsumerWidget {
  final Project? proj; // made nullable
  const BugReportsList({super.key, this.proj}); // proj no longer required

  QuillController deltaToController(String deltaJson) {
    return QuillController(
      document: Document.fromJson(jsonDecode(deltaJson)),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onAddBugReport() async {
      final user = await ref.read(currentUserProvider);
      if (user != null) {
        showEditorPopup(
          context,
          onSaved: (controller, titleText) async {
            final text = jsonEncode(controller.document.toDelta().toJson());
            if (proj == null) {
              showSnackBar(context, 'no project ID specified');
              return;
            } else if (titleText == null) {
              showSnackBar(context, "title cannot be empty!");
              return;
            }

            ref
                .read(BugReportControllerProvider.notifier)
                .createBugReport(proj!, titleText, text, user.name, context);
          },
        );
      } else {
        showSnackBar(context, "no user information found");
      }
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Bug Report'),
            onPressed: onAddBugReport,
          ),
          const SizedBox(height: 12),
          ref
              .watch(BugReportListProvider(proj))
              .when(
                data: (bugreps) {
                  if (bugreps.isEmpty) {
                    return const Center(child: Text('No bug reports yet.'));
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bugreps.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final bugrep = bugreps[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                bugrep.title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              // Rich text content with QuillEditor
                              SizedBox(
                                height: 100,
                                child: QuillEditor(
                                  controller: deltaToController(bugrep.text),
                                  focusNode: FocusNode(),
                                  scrollController: ScrollController(),
                                  config: QuillEditorConfig(
                                    embedBuilders:
                                        FlutterQuillEmbeds.editorBuilders(),
                                    showCursor: false,
                                    autoFocus: false,
                                    expands: false,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Metadata row with createdBy, createdAt, projectID
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    bugrep.createdBy,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(bugrep.createdAt),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    bugrep.projectID,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                error: (error, stack) => ErrorText(error: error.toString()),
                loading: () => const Loader(),
              ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  return "${dt.year.toString().padLeft(4, '0')}-"
      "${dt.month.toString().padLeft(2, '0')}-"
      "${dt.day.toString().padLeft(2, '0')} "
      "${dt.hour.toString().padLeft(2, '0')}:"
      "${dt.minute.toString().padLeft(2, '0')}";
}
