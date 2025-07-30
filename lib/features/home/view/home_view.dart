import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/common/common.dart';
import 'package:sboom_projlogging/features/home/controller/project_viewer.dart';
import 'package:sboom_projlogging/features/project_view/view/project_view.dart';

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
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, 'settings');
            },
            label: Icon(Icons.settings),
          ),
        ],
      ),
      body: ref
          .watch(getListProjProvider)
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
                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(ProjectViewPage.route(proj: repo));
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
