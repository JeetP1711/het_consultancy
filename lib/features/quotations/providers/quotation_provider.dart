import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/quotation_model.dart';
import '../../../services/providers.dart';
import '../../auth/providers/auth_provider.dart';

class QuotationListNotifier extends StateNotifier<List<QuotationModel>> {
  final Ref _ref;

  QuotationListNotifier(this._ref) : super([]) {
    loadQuotations();
  }

  void loadQuotations() {
    state = _ref.read(quotationServiceProvider).getQuotations();
  }

  Future<QuotationModel> saveQuotation(QuotationModel quotation, {bool createNewVersion = false}) async {
    final saved = await _ref.read(quotationServiceProvider).saveQuotation(quotation, createNewVersion: createNewVersion);
    loadQuotations();
    return saved;
  }

  Future<void> lockQuotation(String id) async {
    final currentUser = _ref.read(authProvider);
    final adminName = currentUser?.name ?? 'Admin';
    await _ref.read(quotationServiceProvider).lockQuotation(id, adminName);
    loadQuotations();
  }

  Future<void> unlockQuotation(String id) async {
    await _ref.read(quotationServiceProvider).unlockQuotation(id);
    loadQuotations();
  }

  Future<void> deleteQuotation(String id) async {
    await _ref.read(quotationServiceProvider).deleteQuotation(id);
    loadQuotations();
  }
}

final quotationListProvider = StateNotifierProvider<QuotationListNotifier, List<QuotationModel>>((ref) {
  return QuotationListNotifier(ref);
});

// Search and Filter State Providers
final quotationSearchQueryProvider = StateProvider<String>((ref) => '');
final quotationStatusFilterProvider = StateProvider<QuotationStatus?>((ref) => null);

// Reactive filtered list provider
final filteredQuotationsProvider = Provider<List<QuotationModel>>((ref) {
  final quotations = ref.watch(quotationListProvider);
  final searchQuery = ref.watch(quotationSearchQueryProvider).toLowerCase().trim();
  final statusFilter = ref.watch(quotationStatusFilterProvider);

  return quotations.where((q) {
    final matchesSearch = searchQuery.isEmpty ||
        q.clientName.toLowerCase().contains(searchQuery) ||
        q.proposalNumber.toLowerCase().contains(searchQuery) ||
        q.panelBrand.toLowerCase().contains(searchQuery) ||
        q.inverterBrand.toLowerCase().contains(searchQuery);

    final matchesStatus = statusFilter == null || q.status == statusFilter;

    return matchesSearch && matchesStatus;
  }).toList();
});

// Version list provider by proposal number
final quotationVersionsProvider = FamilyProvider<List<QuotationModel>, String>((ref, proposalNumber) {
  ref.watch(quotationListProvider); // watch list to trigger updates
  return ref.read(quotationServiceProvider).getQuotationVersions(proposalNumber);
});
