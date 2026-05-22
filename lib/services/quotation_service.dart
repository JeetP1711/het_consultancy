import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_strings.dart';
import '../models/quotation_model.dart';
import 'supabase_service.dart';

class QuotationService {
  final Box _box = Hive.box(AppStrings.quotationsBox);

  // Get all quotations
  List<QuotationModel> getQuotations() {
    final List<QuotationModel> list = [];
    for (var key in _box.keys) {
      final value = _box.get(key);
      if (value != null) {
        try {
          final decoded = jsonDecode(value as String);
          list.add(QuotationModel.fromJson(decoded as Map<String, dynamic>));
        } catch (e) {
          debugPrint('Error parsing quotation $key: $e');
        }
      }
    }
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  // Get quotation by id
  QuotationModel? getQuotationById(String id) {
    final value = _box.get(id);
    if (value != null) {
      try {
        final decoded = jsonDecode(value as String);
        return QuotationModel.fromJson(decoded as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error parsing quotation $id: $e');
      }
    }
    return null;
  }

  // Get quotation versions for a proposal number
  List<QuotationModel> getQuotationVersions(String proposalNumber) {
    return getQuotations()
        .where((q) => q.proposalNumber == proposalNumber)
        .toList()
      ..sort((a, b) => b.version.compareTo(a.version));
  }

  // Save Quotation (Create/Update with locking check & version maintenance)
  Future<QuotationModel> saveQuotation(QuotationModel quotation, {bool createNewVersion = false}) async {
    final existing = getQuotationById(quotation.id);
    
    // 1. Check lock state
    if (existing != null && existing.status == QuotationStatus.locked) {
      throw Exception('This quotation is locked and cannot be edited.');
    }

    QuotationModel updatedQuotation = quotation;

    // 2. Handle versioning
    if (createNewVersion && existing != null) {
      final nextVersion = existing.version + 1;
      final newId = '${existing.proposalNumber}_v$nextVersion';
      updatedQuotation = quotation.copyWith(
        id: newId,
        version: nextVersion,
        status: QuotationStatus.draft, // Reset to draft for new version edits
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      updatedQuotation = quotation.copyWith(
        updatedAt: DateTime.now(),
      );
    }

    final jsonStr = jsonEncode(updatedQuotation.toJson());
    await _box.put(updatedQuotation.id, jsonStr);

    // Sync to Supabase
    final sb = SupabaseService.client;
    if (sb != null) {
      try {
        await sb.from('quotations').upsert(updatedQuotation.toJson());
      } catch (e) {
        debugPrint('Supabase quotation sync error: $e');
      }
    }

    return updatedQuotation;
  }

  // Lock Quotation
  Future<void> lockQuotation(String id, String adminName) async {
    final quotation = getQuotationById(id);
    if (quotation == null) throw Exception('Quotation not found.');

    final lockedQuotation = quotation.copyWith(
      status: QuotationStatus.locked,
      lockedBy: adminName,
      updatedAt: DateTime.now(),
    );

    await _box.put(id, jsonEncode(lockedQuotation.toJson()));

    final sb = SupabaseService.client;
    if (sb != null) {
      try {
        await sb.from('quotations').update({
          'status': QuotationStatus.locked.name,
          'locked_by': adminName,
          'updated_at': DateTime.now().toIso8601String()
        }).eq('id', id);
      } catch (e) {
        debugPrint('Supabase lock sync error: $e');
      }
    }
  }

  // Unlock Quotation (Admin only check is implemented in UI/Router, this enforces it)
  Future<void> unlockQuotation(String id) async {
    final quotation = getQuotationById(id);
    if (quotation == null) throw Exception('Quotation not found.');

    final unlockedQuotation = quotation.copyWith(
      status: QuotationStatus.approved, // Unlock back to approved state
      lockedBy: null,
      updatedAt: DateTime.now(),
    );

    await _box.put(id, jsonEncode(unlockedQuotation.toJson()));

    final sb = SupabaseService.client;
    if (sb != null) {
      try {
        await sb.from('quotations').update({
          'status': QuotationStatus.approved.name,
          'locked_by': null,
          'updated_at': DateTime.now().toIso8601String()
        }).eq('id', id);
      } catch (e) {
        debugPrint('Supabase unlock sync error: $e');
      }
    }
  }

  // Delete Quotation
  Future<void> deleteQuotation(String id) async {
    final quotation = getQuotationById(id);
    if (quotation != null && quotation.status == QuotationStatus.locked) {
      throw Exception('Locked quotations cannot be deleted.');
    }

    await _box.delete(id);

    final sb = SupabaseService.client;
    if (sb != null) {
      try {
        await sb.from('quotations').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase quotation delete error: $e');
      }
    }
  }

  // Demo quotations init
  Future<void> initializeDemoQuotations() async {
    if (_box.isEmpty) {
      final now = DateTime.now();
      final demoQuote = QuotationModel(
        id: 'quote-demo-1',
        clientId: 'client-3',
        clientName: 'Sunita Patil',
        clientPhone: '+91 99887 76655',
        clientEmail: 'sunita.patil@yahoo.com',
        clientAddress: 'Row House 5, Royal Palms, Koregaon Park, Pune',
        proposalNumber: 'HET/2026/003',
        date: now.subtract(const Duration(days: 3)),
        capacity: 3.2,
        panelBrand: 'Waaree Mono PERC',
        panelWattage: 540,
        panelQty: 6,
        inverterBrand: 'Growatt Single Phase',
        inverterQty: 1,
        structure: 'Hot Dip Galvanized MS Structure, elevated 3 feet',
        dcdb: '1 Input 1 Output 1000V DCDB with SPD & Fuse',
        acdb: '1 Input 1 Output Single Phase ACDB with MCB & SPD',
        lightningArrestor: 'Solid Copper conventional LA, 1.5m height',
        earthing: 'Chemical Gel earthing electrodes (3 runs: DC, AC, LA)',
        cable: 'Polycab 4 Sqmm DC Solar cable & 6 Sqmm AC cable',
        accessories: 'Conduits, cable ties, glands, MC4 connectors, earth pit chambers',
        price: 180000.00,
        taxRate: 13.8, // standard solar tax structure
        subsidy: 78000.00, // Government PM-Surya Ghar subsidy
        installationTime: 5,
        bankName: 'State Bank of India',
        accountName: 'HET CONSULTANCY SERVICES',
        accountNumber: '123456789012',
        ifscCode: 'SBIN0001234',
        branch: 'Main Branch',
        terms: '1. Price includes delivery and basic mounting structure.\n2. Customer is responsible for net-metering approvals from local DISCOM.\n3. Payment schedule: 50% advance, 40% on material delivery, 10% post-commissioning.\n4. Site must have clear access and power for installation work.\n5. Any extra civil/electrical work will be billed at actuals.',
        warranty: '5 Years warranty on Inverter.\n10 Years performance warranty on Solar Panels.\n25 Years linear power output warranty on Solar Panels.',
        notes: 'Premium installation with customized elevation to avoid shadow from trees on north side.',
        status: QuotationStatus.approved,
        version: 1,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      );
      
      await saveQuotation(demoQuote);
    }
  }
}
