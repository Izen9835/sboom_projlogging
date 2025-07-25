import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/apis/db_api.dart';
import 'package:sboom_projlogging/apis/github_api.dart';
import 'package:sboom_projlogging/core/utils.dart';
import 'package:sboom_projlogging/model/project_model.dart';

final GithubAccessProvider = StateNotifierProvider<GithubAccess, bool>((ref) {
  return GithubAccess(
    githubAPI: ref.watch(GithubAPIProvider),
    dbAPI: ref.watch(dbAPIProvider),
  );
});

final repoListProvider = FutureProvider((ref) async {
  final gitAccess = ref.watch(GithubAccessProvider.notifier);
  return gitAccess.getListGithubRepo();
});

class GithubAccess extends StateNotifier<bool> {
  final GithubAPI _githubAPI;
  final dbAPI _dbAPI;
  GithubAccess({required GithubAPI githubAPI, required dbAPI dbAPI})
    : _githubAPI = githubAPI,
      _dbAPI = dbAPI,
      super(false);

  Future<List<Project>> getListGithubRepo() async {
    try {
      final reposList = await _githubAPI.getGitHubPublicRepos();
      final res =
          reposList
              .cast<Map<String, dynamic>>() // make sure it's typed as Map
              .map((map) {
                // Generate new unique repoId
                final projectID = ID.unique();
                // Create Repo instance, passing repoId and other data from map
                // Assuming fromMap does NOT set repoId, so create manually
                return Project.fromMap(map).copyWith(projectID: projectID);
              })
              .toList();
      return res;
    } catch (e, st) {
      print(e);
      return [];
    }
  }

  void trxToDB(List<Project>? projectsList, BuildContext context) async {
    final res = await _dbAPI.createListModel(projectsList);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, "success trx to db"),
    );
  }
}
