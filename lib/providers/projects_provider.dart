import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intario_ai/services/local_storage_service.dart';
import 'package:intario_ai/models/project_model.dart';

class ProjectsNotifier extends StateNotifier<List<ProjectModel>> {
  ProjectsNotifier() : super([]) {
    Future.microtask(() => loadProjects());
  }

  final _storage = LocalStorageService();

  Future<void> loadProjects() async {
    final projects = await _storage.loadProjects();
    state = projects;
  }

  Future<void> saveProject(ProjectModel project) async {
    await _storage.saveProject(project);
    state = [
      project,
      ...state.where((p) => p.id != project.id),
    ];
  }

  Future<void> deleteProject(String id) async {
    await _storage.deleteProject(id);
    state = state.where((p) => p.id != id).toList();
  }

  Future<void> clearAll() async {
    await _storage.clearAll();
    state = [];
  }
}

final projectsProvider =
StateNotifierProvider<ProjectsNotifier, List<ProjectModel>>(
      (ref) => ProjectsNotifier(),
);