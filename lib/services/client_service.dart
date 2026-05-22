import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_strings.dart';
import '../models/client_model.dart';
import 'supabase_service.dart';

class ClientService {
  final Box _box = Hive.box(AppStrings.clientsBox);

  // Get all clients
  List<ClientModel> getClients() {
    final List<ClientModel> list = [];
    for (var key in _box.keys) {
      final value = _box.get(key);
      if (value != null) {
        try {
          final decoded = jsonDecode(value as String);
          list.add(ClientModel.fromJson(decoded as Map<String, dynamic>));
        } catch (e) {
          debugPrint('Error parsing client $key: $e');
        }
      }
    }
    // Sort by newest first
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // Get client by id
  ClientModel? getClientById(String id) {
    final value = _box.get(id);
    if (value != null) {
      try {
        final decoded = jsonDecode(value as String);
        return ClientModel.fromJson(decoded as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error parsing client $id: $e');
      }
    }
    return null;
  }

  // Save client (Create or Update)
  Future<void> saveClient(ClientModel client) async {
    final clientJson = jsonEncode(client.toJson());
    await _box.put(client.id, clientJson);

    // Sync to Supabase if client is active
    final sb = SupabaseService.client;
    if (sb != null) {
      try {
        await sb.from('clients').upsert(client.toJson());
      } catch (e) {
        debugPrint('Supabase client sync error: $e');
      }
    }
  }

  // Delete client
  Future<void> deleteClient(String id) async {
    await _box.delete(id);

    final sb = SupabaseService.client;
    if (sb != null) {
      try {
        await sb.from('clients').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase client delete error: $e');
      }
    }
  }

  // Initialize some demo clients if empty
  Future<void> initializeDemoClients() async {
    if (_box.isEmpty) {
      final now = DateTime.now();
      final list = [
        ClientModel(
          id: 'client-1',
          name: 'Rajesh Sharma',
          phone: '+91 98234 56789',
          email: 'rajesh.sharma@example.com',
          address: 'Flat 402, Sunshine Residency, Aundh, Pune',
          site: 'Roof Top RCC - 3rd Floor',
          capacity: 5.0,
          proposalNumber: 'HET/2026/001',
          status: ClientStatus.lead,
          createdAt: now.subtract(const Duration(days: 10)),
        ),
        ClientModel(
          id: 'client-2',
          name: 'Green Field Industries',
          phone: '+91 20253 47890',
          email: 'admin@greenfield.com',
          address: 'Plot No. 44, MIDC Bhosari, Pune',
          site: 'Industrial Tin Shed - Ground level height 15m',
          capacity: 50.0,
          proposalNumber: 'HET/2026/002',
          status: ClientStatus.surveyPending,
          createdAt: now.subtract(const Duration(days: 8)),
        ),
        ClientModel(
          id: 'client-3',
          name: 'Sunita Patil',
          phone: '+91 99887 76655',
          email: 'sunita.patil@yahoo.com',
          address: 'Row House 5, Royal Palms, Koregaon Park, Pune',
          site: 'RCC Roof with Pergola',
          capacity: 3.2,
          proposalNumber: 'HET/2026/003',
          status: ClientStatus.quotationSent,
          createdAt: now.subtract(const Duration(days: 5)),
        ),
        ClientModel(
          id: 'client-4',
          name: 'Aurobindo Society',
          phone: '+91 94432 10987',
          email: 'contact@aurobindo.org',
          address: 'Main Ashram Complex, Jipmer Road, Pondicherry',
          site: 'Institutional Flat Slab',
          capacity: 15.0,
          proposalNumber: 'HET/2026/004',
          status: ClientStatus.approved,
          createdAt: now.subtract(const Duration(days: 2)),
        ),
      ];

      for (var client in list) {
        await saveClient(client);
      }
    }
  }
}
