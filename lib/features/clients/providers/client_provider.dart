import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/client_model.dart';
import '../../../services/providers.dart';

class ClientListNotifier extends StateNotifier<List<ClientModel>> {
  final Ref _ref;

  ClientListNotifier(this._ref) : super([]) {
    loadClients();
  }

  void loadClients() {
    state = _ref.read(clientServiceProvider).getClients();
  }

  Future<void> addClient(ClientModel client) async {
    await _ref.read(clientServiceProvider).saveClient(client);
    loadClients();
  }

  Future<void> updateClient(ClientModel client) async {
    await _ref.read(clientServiceProvider).saveClient(client);
    loadClients();
  }

  Future<void> deleteClient(String id) async {
    await _ref.read(clientServiceProvider).deleteClient(id);
    loadClients();
  }
}

final clientListProvider = StateNotifierProvider<ClientListNotifier, List<ClientModel>>((ref) {
  return ClientListNotifier(ref);
});

// Search and Filter State Providers
final clientSearchQueryProvider = StateProvider<String>((ref) => '');
final clientStatusFilterProvider = StateProvider<ClientStatus?>((ref) => null);

// Reactive filtered list provider
final filteredClientsProvider = Provider<List<ClientModel>>((ref) {
  final clients = ref.watch(clientListProvider);
  final searchQuery = ref.watch(clientSearchQueryProvider).toLowerCase().trim();
  final statusFilter = ref.watch(clientStatusFilterProvider);

  return clients.where((client) {
    final matchesSearch = searchQuery.isEmpty ||
        client.name.toLowerCase().contains(searchQuery) ||
        client.phone.contains(searchQuery) ||
        client.email.toLowerCase().contains(searchQuery) ||
        client.proposalNumber.toLowerCase().contains(searchQuery);

    final matchesStatus = statusFilter == null || client.status == statusFilter;

    return matchesSearch && matchesStatus;
  }).toList();
});
