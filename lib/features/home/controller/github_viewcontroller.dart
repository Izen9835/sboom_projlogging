import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/apis/auth_api.dart';
import 'package:sboom_projlogging/features/repo_detail/widgets/EditorPopup.dart';
import 'package:sboom_projlogging/model/repo_model.dart';

final gitHubControlProvider = StateNotifierProvider((ref) {
  return GithubViewcontroller(authAPI: ref.watch(authAPIProvider));
});

final reposListProvider = FutureProvider((ref) async {
  return ref.watch(gitHubControlProvider.notifier).getReposList();
});

class GithubViewcontroller extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  GithubViewcontroller({required AuthAPI authAPI})
    : _authAPI = authAPI,
      super(false);

  Future<List<Repo>> getReposList() async {
    try {
      final reposList = await _authAPI.getGitHubPublicRepos();
      return reposList
          .cast<Map<String, dynamic>>() // make sure it's typed as Map
          .map((map) => Repo.fromMap(map))
          .toList();
    } catch (e, st) {
      return [];
    }
  }
}
