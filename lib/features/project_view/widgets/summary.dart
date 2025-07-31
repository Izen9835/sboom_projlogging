import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/apis/auth_api.dart';
import 'package:sboom_projlogging/common/common.dart';
import 'package:sboom_projlogging/core/core.dart';
import 'package:sboom_projlogging/features/project_view/controller/summary_controller.dart';
import 'package:sboom_projlogging/features/project_view/widgets/EditorPopup.dart';
import 'package:sboom_projlogging/model/model.dart';

class SummaryInfo extends ConsumerWidget {
  final Project proj;

  const SummaryInfo({Key? key, required this.proj}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onCreateSummary() async {
      final user = await ref.read(currentUserProvider);
      if (user != null) {
        showEditorPopup(
          context,
          hasTitle: false,
          onSaved: (controller, titleText) {
            if (proj == null) {
              showSnackBar(context, "no project ID found");
              return;
            }
            ref
                .read(SummaryControllerProvider.notifier)
                .createSummary(
                  proj,
                  controller.document.toPlainText(),
                  user.name,
                  context,
                );
          },
        );
      }
    }

    void onUpdateSummary() async {
      final user = await ref.read(currentUserProvider);
      if (user != null) {
        final summary = ref
            .read(SummaryInfoProvider(proj))
            .maybeWhen(data: (value) => value, orElse: () => null);
        if (summary == null) {
          showSnackBar(context, "Summary not found");
          return;
        }

        final doc =
            summary.text.isEmpty ? quill.Document() : quill.Document()
              ..insert(0, summary.text);

        final controller = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );

        showEditorPopup(
          context,
          controller: controller,
          hasTitle: false,
          onSaved: (updatedController, titleText) {
            ref
                .read(SummaryControllerProvider.notifier)
                .updateSummary(
                  summary,
                  updatedController.document.toPlainText(),
                  context,
                );
          },
        );
      }
    }

    return ref
        .watch(SummaryInfoProvider(proj))
        .when(
          data: (summary) {
            if (summary.text.trim().isEmpty) {
              // Show Add Summary button if no summary
              return TextButton.icon(
                icon: Icon(Icons.add),
                label: Text('Add Summary'),
                onPressed: onCreateSummary,
              );
            }
            // Show title, summary, and edit icon if there is summary text
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: onUpdateSummary,
                      tooltip: 'Edit Summary',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        summary.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          error: (error, stack) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
