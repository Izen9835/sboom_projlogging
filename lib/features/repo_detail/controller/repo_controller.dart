import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/apis/repo_api.dart';
import 'package:sboom_projlogging/model/changelog_model.dart';
import 'package:sboom_projlogging/model/repo_model.dart';

final repoControllerProvider = StateNotifierProvider((ref) {
  return RepoController(repoAPI: ref.watch(RepoAPIProvider));
});

final changeLogsListProvider = FutureProvider.family((ref, Repo repo) async {
  final repoController = ref.watch(repoControllerProvider.notifier);
  return repoController.listChangelogs(repo);
});

class RepoController extends StateNotifier<bool> {
  final RepoAPI _repoAPI;
  RepoController({required RepoAPI repoAPI}) : _repoAPI = repoAPI, super(false);

  Future<List<Changelog>> listChangelogs(Repo repo) async {
    final res = await _repoAPI.getChangelogsFromRepo(repo);

    return res.fold(
      (l) {
        print('failde');
        print(l.message);
        return <Changelog>[];
      },
      (r) {
        print('bruh');
        print('this is $r');
        return r;
      },
    );
  }
}
