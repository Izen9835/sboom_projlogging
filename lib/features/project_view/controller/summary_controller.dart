import 'package:appwrite/appwrite.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/apis/db_api.dart';
import 'package:sboom_projlogging/core/utils.dart';
import 'package:sboom_projlogging/model/model.dart';

final SummaryControllerProvider = StateNotifierProvider((ref) {
  return SummaryController(dbAPI: ref.watch(DbAPIProvider));
});

final SummaryInfoProvider = FutureProvider.family((ref, Project proj) async {
  final sumcontroller = ref.read(SummaryControllerProvider.notifier);
  return sumcontroller.getSummary(proj);
});

class SummaryController extends StateNotifier<bool> {
  final DbAPI _dbAPI;
  SummaryController({required DbAPI dbAPI}) : _dbAPI = dbAPI, super(false);

  Future<Summary> getSummary(Project proj) async {
    try {
      final list = await _dbAPI.getProjectDetails<Summary>(
        proj.projectID!,
        DataType.Summary,
      );
      if (list == null || list.isEmpty)
        return Summary(text: "", projectID: "", id: "");
      return list[0];
    } catch (e, st) {
      print(e);
      print(st);
      return Summary(text: "summary retrieval error", projectID: "", id: "");
    }
  }

  void createSummary(
    Project proj,
    String text,
    String user,
    BuildContext context,
  ) async {
    final data =
        Summary(
          text: text,
          projectID: proj.projectID!,
          id: ID.unique(),
        ).toMap();

    final res = await _dbAPI.createProjectDetail(
      projectID: proj.projectID!,
      data: data,
      dataType: DataType.Summary,
      stayUnique: true,
    );

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, "summary created!"),
    );
  }

  void updateSummary(
    Summary oldSummary,
    String text,
    BuildContext context,
  ) async {
    final data = oldSummary.copyWith(text: text);

    final res = await _dbAPI.updateProjectDetail(
      data: data,
      dataType: DataType.Summary,
    );
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, "summary updated!"),
    );
  }
}
