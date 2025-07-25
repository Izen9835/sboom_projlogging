import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/apis/github_api.dart';
import 'package:sboom_projlogging/model/project_model.dart';

final gitHubControlProvider = StateNotifierProvider((ref) {
  return GithubViewcontroller(githubAPI: ref.watch(GithubAPIProvider));
});

class GithubViewcontroller extends StateNotifier<bool> {
  final GithubAPI _githubAPI;
  GithubViewcontroller({required GithubAPI githubAPI})
    : _githubAPI = githubAPI,
      super(false);

  // Future<List<Repo>> getReposList() async {
  //   try {
  //     final reposList = await _githubAPI.getGitHubPublicRepos();
  //     return reposList
  //         .cast<Map<String, dynamic>>() // make sure it's typed as Map
  //         .map((map) => Repo.fromMap(map))
  //         .toList();
  //   } catch (e, st) {
  //     return [];
  //   }
  // }
}
