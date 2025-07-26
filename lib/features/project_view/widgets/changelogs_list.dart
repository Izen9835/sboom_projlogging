import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/apis/auth_api.dart';
import 'package:sboom_projlogging/common/common.dart';
import 'package:sboom_projlogging/core/utils.dart';
import 'package:sboom_projlogging/features/project_view/controller/changelog_controller.dart';
import 'package:sboom_projlogging/model/model.dart';

class ChangelogsList extends ConsumerWidget {
  final Project proj;
  const ChangelogsList({super.key, required this.proj});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onAddChangelog() async {
      final user = await ref.read(currentUserProvider);
      if (user != null) {
        ref
            .read(ChangelogControllerProvider.notifier)
            .createChangelog(
              proj,
              "here is your hardcoded title",
              "random text",
              user.name,
              context,
            );
      } else {
        showSnackBar(context, "no user information found");
      }
    }

    return Container(
      height: 200,
      width: 200,
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
                            subtitle: Text(clog.text ?? 'No description'),
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
