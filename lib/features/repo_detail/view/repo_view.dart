import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/common/common.dart';
import 'package:sboom_projlogging/core/utils.dart';
import 'package:sboom_projlogging/features/repo_detail/controller/repo_controller.dart';
import 'package:sboom_projlogging/features/repo_detail/widgets/EditorPopup.dart';
import 'package:sboom_projlogging/model/repo_model.dart';

class RepoDetailView extends ConsumerWidget {
  final Repo repo;

  const RepoDetailView({Key? key, required this.repo}) : super(key: key);

  // Route function for navigation
  static MaterialPageRoute route({required Repo repo}) {
    return MaterialPageRoute(builder: (_) => RepoDetailView(repo: repo));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          repo.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(repo.description ?? 'No description'),
            const SizedBox(height: 16),
            Text(
              'Language:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(repo.language ?? 'Unknown'),
            const SizedBox(height: 30),
            Expanded(
              child: ref
                  .watch(changeLogsListProvider(repo))
                  .when(
                    data: (clogs) {
                      if (clogs.isEmpty) {
                        return Center(child: Text('No changelogs found'));
                      }
                      print('Number of changelogs: ${clogs.length}');
                      return ListView.builder(
                        itemCount: clogs.length,
                        itemBuilder: (context, index) {
                          final clog = clogs[index];
                          return ListTile(
                            title: Text(clog.title ?? 'No title'),
                            subtitle: Text(clog.text ?? ''),
                            trailing: Text(clog.createdBy ?? ''),
                            onTap: () {
                              Navigator.of(
                                context,
                              ).push(RepoDetailView.route(repo: repo));
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Loader(),
                    error: (e, st) => ErrorText(error: e.toString()),
                  ),
            ),
            const Spacer(),
            // Button to open the editor popup
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  showEditorPopup(
                    context,
                    onSaved: (controller) {
                      final plainText = controller.document.toPlainText();
                      // Do whatever you want with the edited content here
                      print('Edited text from popup: $plainText');
                      showSnackBar(context, 'Text saved from editor popup!');
                    },
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Open Editor Popup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
