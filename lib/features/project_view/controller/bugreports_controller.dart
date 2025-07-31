import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/apis/db_api.dart';
import 'package:sboom_projlogging/core/utils.dart';
import 'package:sboom_projlogging/model/model.dart';

final BugReportControllerProvider = StateNotifierProvider((ref) {
  return BugReportController(dbAPI: ref.watch(DbAPIProvider));
});

final BugReportListProvider = FutureProvider.family<List<BugReport>, Project?>((
  ref,
  proj,
) async {
  final bugReportController = ref.watch(BugReportControllerProvider.notifier);
  // Pass empty string if no project specified
  final projectID = proj?.projectID ?? '';
  return bugReportController.getListBugReports(projectID);
});

class BugReportController extends StateNotifier<bool> {
  final DbAPI _dbAPI;
  BugReportController({required DbAPI dbAPI}) : _dbAPI = dbAPI, super(false);

  // Now accept projectID string, empty means no filter
  // Will return all the bugreports, without filtering by project
  Future<List<BugReport>> getListBugReports(String projectID) async {
    try {
      final list = await _dbAPI.getProjectDetails<BugReport>(
        projectID,
        DataType.BugReport,
      );
      return list;
    } catch (e, st) {
      return [];
    }
  }

  void createBugReport(
    Project proj,
    String title,
    String text,
    String user,
    BuildContext context,
  ) async {
    final data =
        BugReport(
          title: title,
          text: text,
          createdBy: user,
          createdAt: DateTime.now(),
          projectID: proj.projectID!,
        ).toMap();

    final res = await _dbAPI.createProjectDetail(
      projectID: proj.projectID!,
      data: data,
      dataType: DataType.BugReport,
      stayUnique: false,
    );

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, "success create bug report"),
    );
  }
}
