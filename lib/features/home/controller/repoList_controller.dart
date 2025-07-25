import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/apis/auth_api.dart';
import 'package:sboom_projlogging/apis/repo_api.dart';
import 'package:sboom_projlogging/core/type_defs.dart';
import 'package:sboom_projlogging/core/utils.dart';
import 'package:sboom_projlogging/features/repo_detail/widgets/EditorPopup.dart';
import 'package:sboom_projlogging/model/repo_model.dart';

final gitHubControlProvider = StateNotifierProvider((ref) {
  return GithubViewcontroller(
    authAPI: ref.watch(authAPIProvider),
    repoAPI: ref.watch(RepoAPIProvider),
  );
});

final reposListProvider = FutureProvider((ref) async {
  return ref.watch(gitHubControlProvider.notifier).getReposList();
});

class GithubViewcontroller extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  final RepoAPI _repoAPI;
  GithubViewcontroller({required AuthAPI authAPI, required RepoAPI repoAPI})
    : _authAPI = authAPI,
      _repoAPI = repoAPI,
      super(false);

  // this function should be put in a github side handler...
  // it should be replaced with a function that instead fetches from the db
  // Future<List<Repo>> getReposList() async {
  //   try {
  //     final reposList = await _authAPI.getGitHubPublicRepos();
  //     return reposList
  //         .cast<Map<String, dynamic>>() // make sure it's typed as Map
  //         .map((map) {
  //           // Generate new unique repoId
  //           final repoID = ID.unique();
  //           // Create Repo instance, passing repoId and other data from map
  //           // Assuming fromMap does NOT set repoId, so create manually
  //           return Repo.fromMap(map).copyWith(repoID: repoID);
  //         })
  //         .toList();
  //   } catch (e, st) {
  //     return [];
  //   }
  // }

  Future<List<Repo>> getReposList() async {
    final res = await _repoAPI.getReposFromDB();

    return res.fold((l) => <Repo>[], (r) => r);
  }

  void saveReposToDB(List<Repo> reposList, BuildContext context) async {
    final res = await _repoAPI.saveReposToDB(reposList);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, "saved repos to db success"),
    );
  }
}
