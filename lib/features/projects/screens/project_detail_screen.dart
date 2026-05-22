import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/project_model.dart';
import '../providers/project_provider.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final _noteController = TextEditingController();
  ProjectStage? _selectedStage;
  bool _isLoading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showUpdateDialog(ProjectModel project) {
    _selectedStage = project.stage;
    _noteController.text = project.notes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Project Stage'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ProjectStage>(
                  value: _selectedStage,
                  decoration: const InputDecoration(labelText: 'Target Stage'),
                  items: ProjectStage.values.map((stage) {
                    return DropdownMenuItem(
                      value: stage,
                      child: Text(stage.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => _selectedStage = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Stage Progress Notes',
                    hintText: 'Enter details of materials dispatched, installations done, etc.',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_selectedStage == null) return;
                      setDialogState(() => _isLoading = true);
                      try {
                        await ref
                            .read(projectListProvider.notifier)
                            .updateProjectStage(
                              project.id,
                              _selectedStage!,
                              _noteController.text.trim(),
                            );
                        if (mounted) {
                          Navigator.pop(context);
                          context.showSnackBar('Project stage updated successfully.');
                        }
                      } catch (e) {
                        if (mounted) {
                          context.showSnackBar(e.toString(), isError: true);
                        }
                      } finally {
                        setDialogState(() => _isLoading = false);
                      }
                    },
              child: const Text('Save Stage'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectListProvider);
    final project = projects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse: () => ProjectModel(
        id: '',
        clientId: '',
        clientName: '',
        quotationId: '',
        stage: ProjectStage.survey,
        notes: '',
        updatedAt: DateTime.now(),
      ),
    );

    if (project.id.isEmpty) {
      return const Scaffold(body: Center(child: Text('Project not found.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${project.clientName} - Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.go('/clients/${project.clientId}'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: project.stage.color.withOpacity(0.1),
                      radius: 28,
                      child: Icon(Icons.solar_power, size: 28, color: project.stage.color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.clientName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last updated on ${project.updatedAt.day}/${project.updatedAt.month}/${project.updatedAt.year}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(label: project.stage.displayName, color: project.stage.color),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Timeline details
            const Text(
              'Installation Timeline Stages',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...ProjectStage.values.map((stage) {
              final isCompleted = ProjectStage.values.indexOf(stage) <= ProjectStage.values.indexOf(project.stage);
              final isCurrent = stage == project.stage;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: isCompleted ? stage.color : Colors.grey.shade300,
                        child: Icon(
                          isCompleted ? Icons.check : Icons.circle,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      if (stage != ProjectStage.completed)
                        Container(
                          width: 2.5,
                          height: 70,
                          color: isCompleted ? stage.color : Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stage.displayName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                              color: isCurrent ? Colors.black : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isCurrent) ...[
                            Text(
                              project.notes,
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                          ] else if (isCompleted) ...[
                            Text(
                              'Stage completed successfully.',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ] else ...[
                            Text(
                              'Awaiting stage execution.',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 32),
            AppButton(
              label: 'Update Stage Progress',
              onPressed: () => _showUpdateDialog(project),
            ),
          ],
        ),
      ),
    );
  }
}
