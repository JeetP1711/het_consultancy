import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_strings.dart';
import '../models/project_model.dart';
import 'supabase_service.dart';

class ProjectService {
  final Box _box = Hive.box(AppStrings.projectsBox);

  // Get all projects
  List<ProjectModel> getProjects() {
    final List<ProjectModel> list = [];
    for (var key in _box.keys) {
      final value = _box.get(key);
      if (value != null) {
        try {
          final decoded = jsonDecode(value as String);
          list.add(ProjectModel.fromJson(decoded as Map<String, dynamic>));
        } catch (e) {
          debugPrint('Error parsing project $key: $e');
        }
      }
    }
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  // Get project by id
  ProjectModel? getProjectById(String id) {
    final value = _box.get(id);
    if (value != null) {
      try {
        final decoded = jsonDecode(value as String);
        return ProjectModel.fromJson(decoded as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error parsing project $id: $e');
      }
    }
    return null;
  }

  // Save Project (Create or Update)
  Future<void> saveProject(ProjectModel project) async {
    final jsonStr = jsonEncode(project.toJson());
    await _box.put(project.id, jsonStr);

    // Sync to Supabase
    final sb = SupabaseService.client;
    if (sb != null) {
      try {
        await sb.from('projects').upsert(project.toJson());
      } catch (e) {
        debugPrint('Supabase project sync error: $e');
      }
    }
  }

  // Update project stage
  Future<void> updateProjectStage(String id, ProjectStage stage, String note) async {
    final project = getProjectById(id);
    if (project == null) throw Exception('Project not found');

    final updated = project.copyWith(
      stage: stage,
      notes: note,
      updatedAt: DateTime.now(),
    );
    await saveProject(updated);
  }

  // Demo projects init
  Future<void> initializeDemoProjects() async {
    if (_box.isEmpty) {
      final now = DateTime.now();
      final list = [
        ProjectModel(
          id: 'proj-demo-1',
          clientId: 'client-3',
          clientName: 'Sunita Patil',
          quotationId: 'quote-demo-1',
          stage: ProjectStage.approval,
          notes: 'Customer signed quotation and submitted subsidy papers. Awaiting dispatch of solar modules.',
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        ProjectModel(
          id: 'proj-demo-2',
          clientId: 'client-4',
          clientName: 'Aurobindo Society',
          quotationId: '',
          stage: ProjectStage.survey,
          notes: 'Site survey completed. Engineering team is drafting the structural drawings and electrical single line diagram.',
          updatedAt: now,
        ),
      ];
      for (var p in list) {
        await saveProject(p);
      }
    }
  }
}
