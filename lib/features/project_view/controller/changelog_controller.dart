import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/apis/db_api.dart';
import 'package:sboom_projlogging/core/utils.dart';
import 'package:sboom_projlogging/model/model.dart';

final ChangelogControllerProvider = StateNotifierProvider((ref) {
  return ChangelogController(dbAPI: ref.watch(DbAPIProvider));
});

final ChangelogListProvider = FutureProvider.family((ref, Project proj) async {
  final changelogger = ref.watch(ChangelogControllerProvider.notifier);
  return changelogger.getListChangelogs(proj);
});

class ChangelogController extends StateNotifier<bool> {
  final DbAPI _dbAPI;
  ChangelogController({required DbAPI dbAPI}) : _dbAPI = dbAPI, super(false);

  Future<List<Changelog>> getListChangelogs(Project proj) async {
    try {
      final list = await _dbAPI.getProjectDetails<Changelog>(
        proj.projectID!,
        DataType.Changelog,
      );
      return list;
    } catch (e, st) {
      return [];
    }
  }

  void createChangelog(
    Project proj,
    String title,
    String text,
    String user,
    BuildContext context,
  ) async {
    final data =
        Changelog(
          title: title,
          text: text,
          createdBy: user,
          createdAt: DateTime.now(),
          projectID: proj.projectID!,
        ).toMap();

    final res = await _dbAPI.createProjectDetail(
      proj.projectID!,
      data,
      DataType.Changelog,
      false,
    );

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, "success create changelog"),
    );
  }
}
