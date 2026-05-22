import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_strings.dart';
import '../models/document_model.dart';
import 'supabase_service.dart';

class DocumentService {
  final Box _box = Hive.box(AppStrings.documentsBox);

  // Get all documents
  List<DocumentModel> getDocuments() {
    final List<DocumentModel> list = [];
    for (var key in _box.keys) {
      final value = _box.get(key);
      if (value != null) {
        try {
          final decoded = jsonDecode(value as String);
          list.add(DocumentModel.fromJson(decoded as Map<String, dynamic>));
        } catch (e) {
          debugPrint('Error parsing document $key: $e');
        }
      }
    }
    list.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return list;
  }

  // Get documents for client
  List<DocumentModel> getDocumentsByClient(String clientId) {
    return getDocuments().where((d) => d.clientId == clientId).toList();
  }

  // Save document metadata
  Future<void> saveDocument(DocumentModel doc) async {
    final jsonStr = jsonEncode(doc.toJson());
    await _box.put(doc.id, jsonStr);

    final sb = SupabaseService.client;
    if (sb != null) {
      try {
        await sb.from('documents').upsert(doc.toJson());
      } catch (e) {
        debugPrint('Supabase document sync error: $e');
      }
    }
  }

  // Delete document
  Future<void> deleteDocument(String id) async {
    await _box.delete(id);

    final sb = SupabaseService.client;
    if (sb != null) {
      try {
        await sb.from('documents').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase document delete error: $e');
      }
    }
  }

  // Initialize demo documents
  Future<void> initializeDemoDocuments() async {
    if (_box.isEmpty) {
      final now = DateTime.now();
      final list = [
        DocumentModel(
          id: 'doc-demo-1',
          clientId: 'client-3',
          clientName: 'Sunita Patil',
          fileName: 'Quotation_Sunita_Patil_v1.pdf',
          filePath: 'mock_path_quotation.pdf',
          fileSize: '142 KB',
          type: DocumentType.quotation,
          uploadedAt: now.subtract(const Duration(days: 3)),
        ),
        DocumentModel(
          id: 'doc-demo-2',
          clientId: 'client-3',
          clientName: 'Sunita Patil',
          fileName: 'Electricity_Bill_March2026.pdf',
          filePath: 'mock_path_bill.pdf',
          fileSize: '850 KB',
          type: DocumentType.bill,
          uploadedAt: now.subtract(const Duration(days: 4)),
        ),
        DocumentModel(
          id: 'doc-demo-3',
          clientId: 'client-3',
          clientName: 'Sunita Patil',
          fileName: 'Roof_View_North.jpg',
          filePath: 'mock_path_photo.jpg',
          fileSize: '1.2 MB',
          type: DocumentType.photo,
          uploadedAt: now.subtract(const Duration(days: 4)),
        ),
      ];

      for (var doc in list) {
        await saveDocument(doc);
      }
    }
  }
}
