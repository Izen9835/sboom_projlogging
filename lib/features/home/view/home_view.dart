import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/common/common.dart';
import 'package:sboom_projlogging/features/home/controller/repoList_controller.dart';
import 'package:sboom_projlogging/features/repo_detail/view/repo_view.dart';

class HomeView extends ConsumerWidget {
  static route() => MaterialPageRoute(builder: (context) => HomeView());

  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Projects",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton(
            onPressed:
                () => ref
                    .read(gitHubControlProvider.notifier)
                    .saveReposToDB(ref.read(reposListProvider).value!, context),
            child: Text("upload"),
          ),
        ],
      ),
      body: ref
          .watch(reposListProvider)
          .when(
            data:
                (repos) => ListView.builder(
                  itemCount: repos.length,
                  itemBuilder: (context, index) {
                    final repo = repos[index];

                    print('number of repos: ${repos.length}');

                    return ListTile(
                      title: Text(repo.name),
                      subtitle: Text(repo.description ?? 'No description'),
                      trailing: Text(repo.language ?? 'Unknown'),
                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(RepoDetailView.route(repo: repo));
                      },
                    );
                  },
                ),
            error: (error, st) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
