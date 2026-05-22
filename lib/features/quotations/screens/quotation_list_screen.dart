import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/quotation_model.dart';
import '../providers/quotation_provider.dart';

class QuotationListScreen extends ConsumerWidget {
  const QuotationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredQuotes = ref.watch(filteredQuotationsProvider);
    final search = ref.watch(quotationSearchQueryProvider);
    final statusFilter = ref.watch(quotationStatusFilterProvider);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: SearchBar(
              hintText: 'Search quotations by client or proposal...',
              leading: const Icon(Icons.search),
              onChanged: (val) {
                ref.read(quotationSearchQueryProvider.notifier).state = val;
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
                  label: const Text('All Statuses'),
                  selected: statusFilter == null,
                  onSelected: (_) {
                    ref.read(quotationStatusFilterProvider.notifier).state = null;
                  },
                ),
                const SizedBox(width: 8),
                ...QuotationStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(status.displayName),
                      selected: statusFilter == status,
                      selectedColor: status.color.withOpacity(0.2),
                      onSelected: (selected) {
                        ref.read(quotationStatusFilterProvider.notifier).state =
                            selected ? status : null;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Quotation List
          Expanded(
            child: filteredQuotes.isEmpty
                ? const EmptyState(
                    icon: Icons.description_outlined,
                    title: 'No Quotations Found',
                    description: 'Draft a quotation or solar proposal for one of your clients.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: filteredQuotes.length,
                    itemBuilder: (context, index) {
                      final q = filteredQuotes[index];
                      final isLocked = q.status == QuotationStatus.locked;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => context.go('/quotations/${q.id}'),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: q.status.color.withOpacity(0.1),
                                  child: Icon(
                                    isLocked ? Icons.lock_outline : Icons.description_outlined,
                                    color: q.status.color,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        q.clientName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Capacity: ${q.capacity} kWp | ${q.proposalNumber} (v${q.version})',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    StatusBadge(
                                      label: q.status.displayName,
                                      color: q.status.color,
                                      icon: isLocked ? Icons.lock : null,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '₹${(q.netPayableAmount / 1000).toStringAsFixed(1)}k',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
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
        onPressed: () => context.go('/quotations/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
