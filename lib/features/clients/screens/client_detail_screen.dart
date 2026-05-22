import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/client_model.dart';
import '../../../models/project_model.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../projects/providers/project_provider.dart';
import '../providers/client_provider.dart';

class ClientDetailScreen extends ConsumerWidget {
  final String clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientListProvider);
    final client = clients.firstWhere((c) => c.id == clientId, orElse: () => ClientModel(
      id: '',
      name: '',
      phone: '',
      email: '',
      address: '',
      site: '',
      capacity: 0,
      proposalNumber: '',
      status: ClientStatus.lead,
      createdAt: DateTime.now(),
    ));

    if (client.id.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Client not found.')),
      );
    }

    final user = ref.watch(authProvider);
    final projects = ref.watch(projectListProvider);
    
    // Find linked project if exists
    final project = projects.firstWhere(
      (p) => p.clientId == client.id,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(client.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/clients/edit/${client.id}'),
          ),
          if (user?.role == UserRole.admin)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref, client.id),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive Card layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: context.isTablet ? 7 : 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(context, client),
                      const SizedBox(height: 24),
                      _buildQuickActions(context, client),
                    ],
                  ),
                ),
                if (context.isTablet) ...[
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 5,
                    child: _buildTimelineCard(context, project, client),
                  ),
                ],
              ],
            ),
            if (!context.isTablet) ...[
              const SizedBox(height: 24),
              _buildTimelineCard(context, project, client),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, ClientModel client) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Client Specifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                StatusBadge(label: client.status.displayName, color: client.status.color),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow(context, Icons.phone_outlined, 'Phone', client.phone),
            _buildDetailRow(context, Icons.email_outlined, 'Email', client.email),
            _buildDetailRow(context, Icons.location_on_outlined, 'Address', client.address),
            _buildDetailRow(context, Icons.roofing_outlined, 'Site / Roof Details', client.site),
            _buildDetailRow(context, Icons.solar_power_outlined, 'Target Capacity', '${client.capacity} kWp'),
            _buildDetailRow(context, Icons.bookmark_border_rounded, 'Proposal Reference', client.proposalNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ClientModel client) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workflow Shortcuts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionButton(
                  icon: Icons.checklist_rtl_rounded,
                  label: 'Site Survey',
                  color: AppColors.surveyPending,
                  onTap: () => context.push('/survey/form/${client.id}'),
                ),
                _ActionButton(
                  icon: Icons.description_outlined,
                  label: 'Generate Quote',
                  color: AppColors.quotationSent,
                  onTap: () => context.go('/quotations/new?clientId=${client.id}'),
                ),
                _ActionButton(
                  icon: Icons.folder_shared_outlined,
                  label: 'Document Vault',
                  color: AppColors.lead,
                  onTap: () => context.push('/documents/${client.id}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, ProjectModel project, ClientModel client) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Installation Tracker',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (project.id.isEmpty) ...[
              const Center(
                child: Text(
                  'No active project tracker. Create a quotation to initialize installation tracker.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ] else ...[
              ...ProjectStage.values.map((stage) {
                final isCompleted = ProjectStage.values.indexOf(stage) <= ProjectStage.values.indexOf(project.stage);
                final isCurrent = stage == project.stage;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: isCompleted
                              ? stage.color
                              : Colors.grey.shade300,
                          child: Icon(
                            isCompleted ? Icons.check : Icons.circle,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                        if (stage != ProjectStage.completed)
                          Container(
                            width: 2,
                            height: 40,
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
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                color: isCurrent ? Colors.black : Colors.grey.shade600,
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(height: 4),
                              Text(
                                project.notes,
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client?'),
        content: const Text('Are you sure you want to permanently delete this client record? All linked quotes and folders will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(clientListProvider.notifier).deleteClient(id);
              if (context.mounted) {
                context.showSnackBar('Client deleted successfully.');
                context.go('/clients');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
