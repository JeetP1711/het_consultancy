import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/project_model.dart';
import '../providers/project_provider.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredProjects = ref.watch(filteredProjectsProvider);
    final search = ref.watch(projectSearchQueryProvider);
    final stageFilter = ref.watch(projectStageFilterProvider);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: SearchBar(
              hintText: 'Search projects by client or notes...',
              leading: const Icon(Icons.search),
              onChanged: (val) {
                ref.read(projectSearchQueryProvider.notifier).state = val;
              },
              elevation: const MaterialStatePropertyAll(0),
              backgroundColor: MaterialStatePropertyAll(
                Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade100
                    : Colors.grey.shade900,
              ),
            ),
          ),

          // Horizontal Filter Chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                FilterChip(
                  label: const Text('All Stages'),
                  selected: stageFilter == null,
                  onSelected: (_) {
                    ref.read(projectStageFilterProvider.notifier).state = null;
                  },
                ),
                const SizedBox(width: 8),
                ...ProjectStage.values.map((stage) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(stage.displayName),
                      selected: stageFilter == stage,
                      selectedColor: stage.color.withOpacity(0.2),
                      onSelected: (selected) {
                        ref.read(projectStageFilterProvider.notifier).state =
                            selected ? stage : null;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Project List
          Expanded(
            child: filteredProjects.isEmpty
                ? const EmptyState(
                    icon: Icons.assignment_outlined,
                    title: 'No Projects Found',
                    description: 'Start site surveys or generate proposals to track installations.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => context.go('/projects/${project.id}'),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: project.stage.color.withOpacity(0.1),
                                  child: Icon(Icons.bolt, color: project.stage.color),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        project.clientName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        project.notes,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                StatusBadge(
                                  label: project.stage.displayName,
                                  color: project.stage.color,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
