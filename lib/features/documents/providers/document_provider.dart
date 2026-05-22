import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/document_model.dart';
import '../../../services/providers.dart';

class DocumentListNotifier extends StateNotifier<List<DocumentModel>> {
  final Ref _ref;

  DocumentListNotifier(this._ref) : super([]) {
    loadDocuments();
  }

  void loadDocuments() {
    state = _ref.read(documentServiceProvider).getDocuments();
  }

  Future<void> saveDocument(DocumentModel doc) async {
    await _ref.read(documentServiceProvider).saveDocument(doc);
    loadDocuments();
  }

  Future<void> deleteDocument(String id) async {
    await _ref.read(documentServiceProvider).deleteDocument(id);
    loadDocuments();
  }
}

final documentListProvider = StateNotifierProvider<DocumentListNotifier, List<DocumentModel>>((ref) {
  return DocumentListNotifier(ref);
});

// Family provider to get documents by client id
final documentsByClientProvider = Provider.family<List<DocumentModel>, String>((ref, clientId) {
  final docs = ref.watch(documentListProvider);
  return docs.where((d) => d.clientId == clientId).toList();
});
