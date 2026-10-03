import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intario_ai/models/project_model.dart';

class LocalStorageService {
  static const String _projectsKey = 'projects';

  Future<List<ProjectModel>> loadProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_projectsKey);

      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;

      return decoded
          .map((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProject(ProjectModel project) async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final current = await loadProjects();

      final updated = [
        project,
        ...current.where((p) => p.id != project.id),
      ];

      await prefs.setString(
        _projectsKey,
        jsonEncode(updated.map((p) => p.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<void> deleteProject(String id) async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final current = await loadProjects();

      final updated = current.where((p) => p.id != id).toList();

      await prefs.setString(
        _projectsKey,
        jsonEncode(updated.map((p) => p.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_projectsKey);
    } catch (_) {}
  }
}