import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/apis/db_api.dart';
import 'package:sboom_projlogging/core/providers.dart';
import 'package:sboom_projlogging/model/project_model.dart';

final ProjectViewerProvider = StateNotifierProvider((ref) {
  return ProjectViewer(dbAPI: ref.watch(DbAPIProvider));
});

final getListProjProvider = FutureProvider((ref) async {
  return ref.watch(ProjectViewerProvider.notifier).getListProjects();
});

class ProjectViewer extends StateNotifier<bool> {
  final DbAPI _dbAPI;
  ProjectViewer({required DbAPI dbAPI}) : _dbAPI = dbAPI, super(false);

  Future<List<Project>> getListProjects() async {
    try {
      final list = await _dbAPI.getListProjects();
      return list;
    } catch (e, st) {
      return [];
    }
  }
}
