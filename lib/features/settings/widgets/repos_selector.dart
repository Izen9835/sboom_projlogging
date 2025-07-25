import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/features/settings/controller/github_access.dart';

class ReposSelector extends ConsumerStatefulWidget {
  const ReposSelector({super.key});

  @override
  ConsumerState<ReposSelector> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<ReposSelector> {
  @override
  Widget build(BuildContext context) {
    final repoList = ref.watch(repoListProvider).value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Upload all public repos to the appwrite db: "),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(GithubAccessProvider.notifier).trxToDB(repoList, context);
          },
          label: Icon(Icons.upload),
        ),
      ],
    );
  }
}
