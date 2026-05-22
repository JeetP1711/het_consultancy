import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/client_model.dart';
import '../providers/client_provider.dart';

class ClientListScreen extends ConsumerWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredClients = ref.watch(filteredClientsProvider);
    final searchQuery = ref.watch(clientSearchQueryProvider);
    final statusFilter = ref.watch(clientStatusFilterProvider);

    return Scaffold(
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    hintText: 'Search by name, phone, or proposal...',
                    leading: const Icon(Icons.search, size: 20),
                    onChanged: (value) {
                      ref.read(clientSearchQueryProvider.notifier).state = value;
                    },
                    elevation: const MaterialStatePropertyAll(0),
                    backgroundColor: MaterialStatePropertyAll(
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade100
                          : Colors.grey.shade900,
                    ),
                  ),
                ),
              ],
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
                  label: const Text('All Statuses'),
                  selected: statusFilter == null,
                  onSelected: (_) {
                    ref.read(clientStatusFilterProvider.notifier).state = null;
                  },
                ),
                const SizedBox(width: 8),
                ...ClientStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    key: ValueKey(status),
                    child: FilterChip(
                      label: Text(status.displayName),
                      selected: statusFilter == status,
                      selectedColor: status.color.withOpacity(0.2),
                      onSelected: (selected) {
                        ref.read(clientStatusFilterProvider.notifier).state =
                            selected ? status : null;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Client List
          Expanded(
            child: filteredClients.isEmpty
                ? const EmptyState(
                    icon: Icons.people_outline,
                    title: 'No Clients Found',
                    description: 'Try adjusting your search query or filter settings.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: filteredClients.length,
                    itemBuilder: (context, index) {
                      final client = filteredClients[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => context.go('/clients/${client.id}'),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                  child: Text(
                                    client.name[0].toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        client.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.bolt, size: 14, color: Colors.orange.shade800),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${client.capacity} kWp | ${client.proposalNumber}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    StatusBadge(
                                      label: client.status.displayName,
                                      color: client.status.color,
                                    ),
                                    const SizedBox(height: 8),
                                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                                  ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/clients/new'),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
