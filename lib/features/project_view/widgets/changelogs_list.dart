import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/apis/auth_api.dart';
import 'package:sboom_projlogging/common/common.dart';
import 'package:sboom_projlogging/core/utils.dart';
import 'package:sboom_projlogging/features/project_view/controller/changelog_controller.dart';
import 'package:sboom_projlogging/features/project_view/widgets/EditorPopup.dart';
import 'package:sboom_projlogging/model/model.dart';
import 'package:sboom_projlogging/core/core.dart';

class ChangelogsList extends ConsumerWidget {
  final Project proj;
  const ChangelogsList({super.key, required this.proj});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onAddChangelog() async {
      final user = await ref.read(currentUserProvider);

      if (user != null) {
        showEditorPopup(
          context,
          onSaved: (controller) async {
            final text = jsonEncode(controller.document.toDelta().toJson());
            ref
                .read(ChangelogControllerProvider.notifier)
                .createChangelog(
                  proj,
                  "here is your hardcoded title",
                  text,
                  user.name,
                  context,
                );
            print('Edited text from popup: $text');
            showSnackBar(context, 'Text saved from editor popup!');
          },
        );
      } else {
        showSnackBar(context, "no user information found");
      }
    }

    return Container(
      height: 600,
      width: 1300,
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: onAddChangelog,
            label: Icon(Icons.add),
          ),
          ref
              .watch(ChangelogListProvider(proj))
              .when(
                data:
                    (clogs) => SizedBox(
                      height: 160,
                      child: ListView.builder(
                        itemCount: clogs.length,
                        itemBuilder: (context, index) {
                          final clog = clogs[index];

                          return ListTile(
                            title: Text(clog.title),
                            subtitle: SizedBox(
                              height:
                                  100, // constrain height to avoid infinite height error
                              child: QuillEditor(
                                controller: deltaToController(clog.text),
                                focusNode: FocusNode(),
                                scrollController: ScrollController(),
                                config: QuillEditorConfig(
                                  // readOnly: true,
                                  showCursor: false,
                                  autoFocus: false,
                                  expands: false,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            onTap: () {},
                          );
                        },
                      ),
                    ),
                error: (error, st) => ErrorText(error: error.toString()),
                loading: () => const Loader(),
              ),
        ],
      ),
    );
  }
}
