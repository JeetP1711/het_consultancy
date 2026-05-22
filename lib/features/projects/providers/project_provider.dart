import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/project_model.dart';
import '../../../services/providers.dart';

class ProjectListNotifier extends StateNotifier<List<ProjectModel>> {
  final Ref _ref;

  ProjectListNotifier(this._ref) : super([]) {
    loadProjects();
  }

  void loadProjects() {
    state = _ref.read(projectServiceProvider).getProjects();
  }

  Future<void> saveProject(ProjectModel project) async {
    await _ref.read(projectServiceProvider).saveProject(project);
    loadProjects();
  }

  Future<void> updateProjectStage(String id, ProjectStage stage, String note) async {
    await _ref.read(projectServiceProvider).updateProjectStage(id, stage, note);
    loadProjects();
  }
}

final projectListProvider = StateNotifierProvider<ProjectListNotifier, List<ProjectModel>>((ref) {
  return ProjectListNotifier(ref);
});

// Search and Filter State Providers
final projectSearchQueryProvider = StateProvider<String>((ref) => '');
final projectStageFilterProvider = StateProvider<ProjectStage?>((ref) => null);

// Reactive filtered list provider
final filteredProjectsProvider = Provider<List<ProjectModel>>((ref) {
  final projects = ref.watch(projectListProvider);
  final searchQuery = ref.watch(projectSearchQueryProvider).toLowerCase().trim();
  final stageFilter = ref.watch(projectStageFilterProvider);

  return projects.where((p) {
    final matchesSearch = searchQuery.isEmpty ||
        p.clientName.toLowerCase().contains(searchQuery) ||
        p.notes.toLowerCase().contains(searchQuery);

    final matchesStage = stageFilter == null || p.stage == stageFilter;

    return matchesSearch && matchesStage;
  }).toList();
});
