import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    void onAddSummary() async {
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

    return ref
        .watch(SummaryInfoProvider(proj))
        .when(
          data: (summary) {
            if (summary.text.trim().isEmpty) {
              // Show Add Summary button if no summary
              return TextButton.icon(
                icon: Icon(Icons.add),
                label: Text('Add Summary'),
                onPressed: onAddSummary,
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
                      onPressed: () {
                        // Your edit handler here
                      },
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
