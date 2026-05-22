import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/quotation_model.dart';
import '../../../models/project_model.dart';
import '../../../services/pdf_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../projects/providers/project_provider.dart';
import '../providers/quotation_provider.dart';

class QuotationDetailScreen extends ConsumerStatefulWidget {
  final String quotationId;

  const QuotationDetailScreen({super.key, required this.quotationId});

  @override
  ConsumerState<QuotationDetailScreen> createState() => _QuotationDetailScreenState();
}

class _QuotationDetailScreenState extends ConsumerState<QuotationDetailScreen> {
  bool _isGeneratingPdf = false;

  Future<void> _handlePrint(QuotationModel q) async {
    setState(() => _isGeneratingPdf = true);
    try {
      await PdfService.printQuotation(q);
    } catch (e) {
      context.showSnackBar('Failed to generate PDF: $e', isError: true);
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _updateStatus(QuotationModel q, QuotationStatus status) async {
    try {
      final updated = q.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await ref.read(quotationListProvider.notifier).saveQuotation(updated);
      context.showSnackBar('Status updated to ${status.displayName}');

      // If approved, sync project stage if exists
      if (status == QuotationStatus.approved) {
        final projects = ref.read(projectListProvider);
        final projectIndex = projects.indexWhere((p) => p.quotationId == q.id);
        if (projectIndex != -1) {
          final project = projects[projectIndex];
          await ref.read(projectListProvider.notifier).updateProjectStage(
            project.id,
            ProjectStage.approval,
            'Quotation approved by customer. Ready for installation booking.',
          );
        }
      }
    } catch (e) {
      context.showSnackBar(e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quotations = ref.watch(quotationListProvider);
    final user = ref.watch(authProvider);

    final q = quotations.firstWhere(
      (item) => item.id == widget.quotationId,
      orElse: () => QuotationModel(
        id: '',
        clientId: '',
        clientName: '',
        clientPhone: '',
        clientEmail: '',
        clientAddress: '',
        proposalNumber: '',
        date: DateTime.now(),
        capacity: 0.0,
        panelBrand: '',
        panelWattage: 0,
        panelQty: 0,
        inverterBrand: '',
        inverterQty: 0,
        price: 0,
        taxRate: 0,
        subsidy: 0,
        installationTime: 0,
        status: QuotationStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (q.id.isEmpty) {
      return const Scaffold(body: Center(child: Text('Quotation not found.')));
    }

    final isLocked = q.status == QuotationStatus.locked;
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Proposal ${q.proposalNumber}'),
        actions: [
          // Edit triggers version update if approved/locked
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: isLocked && user?.role != UserRole.admin
                ? null
                : () {
                    // Navigate to form
                    context.go('/quotations/edit/${q.id}');
                  },
          ),
          if (user?.role == UserRole.admin && isLocked)
            TextButton.icon(
              icon: const Icon(Icons.lock_open, size: 18),
              label: const Text('Unlock'),
              onPressed: () => _updateStatus(q, QuotationStatus.approved),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (isLocked)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This quotation is LOCKED (v${q.version}). Any modifications will require administrator authorization or will generate a new proposal version.',
                          style: TextStyle(color: Colors.red.shade900, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Top Summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: q.status.color.withOpacity(0.08),
                      child: Icon(Icons.description, color: q.status.color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.clientName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Created on ${q.date.day}/${q.date.month}/${q.date.year} | Version ${q.version}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(label: q.status.displayName, color: q.status.color),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Financial Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Financial Summary',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Divider(height: 24),
                    _buildFinanceRow('Base System Cost', formatter.format(q.price)),
                    _buildFinanceRow('GST / Tax (${q.taxRate}%)', formatter.format(q.taxAmount)),
                    _buildFinanceRow('Total Proposal Price', formatter.format(q.totalAmount)),
                    _buildFinanceRow('Govt. Subsidy Estimate', '- ${formatter.format(q.subsidy)}', isSavings: true),
                    const Divider(height: 24),
                    _buildFinanceRow(
                      'Net Investment Post Subsidy',
                      formatter.format(q.netPayableAmount),
                      isGrandTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Technical summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Solar Technical Details',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Divider(height: 24),
                    _buildInfoRow('Solar Target Capacity', '${q.capacity} kWp'),
                    _buildInfoRow('Solar Modules', '${q.panelQty} x ${q.panelBrand} (${q.panelWattage}Wp)'),
                    _buildInfoRow('Solar Inverter', '${q.inverterQty} x ${q.inverterBrand}'),
                    _buildInfoRow('Mounting Structure', q.structure),
                    _buildInfoRow('Distribution Box', 'DCDB: ${q.dcdb} | ACDB: ${q.acdb}'),
                    _buildInfoRow('Protection Systems', 'LA: ${q.lightningArrestor} | Earthing: ${q.earthing}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action row: Print / Lock / Approve
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Generate PDF / Print',
                    icon: Icons.print,
                    isLoading: _isGeneratingPdf,
                    onPressed: () => _handlePrint(q),
                  ),
                ),
                if (!isLocked) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: q.status == QuotationStatus.approved ? 'Lock Proposal' : 'Approve Proposal',
                      type: AppButtonType.secondary,
                      onPressed: () {
                        if (q.status == QuotationStatus.approved) {
                          _updateStatus(q, QuotationStatus.locked);
                        } else {
                          _updateStatus(q, QuotationStatus.approved);
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceRow(String label, String value, {bool isSavings = false, bool isGrandTotal = false}) {
    final style = TextStyle(
      fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w500,
      fontSize: isGrandTotal ? 16 : 14,
      color: isSavings
          ? Colors.green.shade700
          : isGrandTotal
              ? AppColors.primary
              : Colors.black,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
