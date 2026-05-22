import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/extensions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/document_model.dart';
import '../providers/document_provider.dart';
import '../../clients/providers/client_provider.dart';

class DocumentListScreen extends ConsumerStatefulWidget {
  final String clientId;

  const DocumentListScreen({super.key, required this.clientId});

  @override
  ConsumerState<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends ConsumerState<DocumentListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final platformFile = result.files.single;
        final client = ref.read(clientListProvider).firstWhere((c) => c.id == widget.clientId);
        
        // Choose type dialog
        final selectedType = await _showTypeSelectionDialog();
        if (selectedType == null) return;

        final sizeInKb = (platformFile.size / 1024).toStringAsFixed(1);
        final sizeText = platformFile.size > 1024 * 1024
            ? '${(platformFile.size / (1024 * 1024)).toStringAsFixed(1)} MB'
            : '$sizeInKb KB';

        final newDoc = DocumentModel(
          id: const Uuid().v4(),
          clientId: widget.clientId,
          clientName: client.name,
          fileName: platformFile.name,
          filePath: platformFile.path!,
          fileSize: sizeText,
          type: selectedType,
          uploadedAt: DateTime.now(),
        );

        await ref.read(documentListProvider.notifier).saveDocument(newDoc);
        if (mounted) {
          context.showSnackBar('Document uploaded successfully.');
        }
      }
    } catch (e) {
      context.showSnackBar('Error choosing file: $e', isError: true);
    }
  }

  Future<DocumentType?> _showTypeSelectionDialog() async {
    return showDialog<DocumentType>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Document Category'),
        children: DocumentType.values.map((type) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, type),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(_getIconForType(type), size: 20),
                  const SizedBox(width: 12),
                  Text(type.displayName),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconForType(DocumentType type) {
    switch (type) {
      case DocumentType.quotation:
        return Icons.description_outlined;
      case DocumentType.bill:
        return Icons.receipt_long_outlined;
      case DocumentType.photo:
        return Icons.image_outlined;
      case DocumentType.certificate:
        return Icons.verified_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(clientListProvider).firstWhere(
          (c) => c.id == widget.clientId,
          orElse: () => throw Exception('Client not found'),
        );
    final allDocs = ref.watch(documentsByClientProvider(widget.clientId));

    return Scaffold(
      appBar: AppBar(
        title: Text('${client.name} - Vault'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All Files'),
            Tab(text: 'Quotations'),
            Tab(text: 'Invoices/Bills'),
            Tab(text: 'Site Photos'),
            Tab(text: 'Certificates'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDocsList(allDocs),
          _buildDocsList(allDocs.where((d) => d.type == DocumentType.quotation).toList()),
          _buildDocsList(allDocs.where((d) => d.type == DocumentType.bill).toList()),
          _buildDocsList(allDocs.where((d) => d.type == DocumentType.photo).toList()),
          _buildDocsList(allDocs.where((d) => d.type == DocumentType.certificate).toList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadFile,
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _buildDocsList(List<DocumentModel> docs) {
    if (docs.isEmpty) {
      return const EmptyState(
        icon: Icons.folder_open_outlined,
        title: 'Folder is Empty',
        description: 'Upload quotations, bills, photos, or certificates.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              child: Icon(_getIconForType(doc.type), color: Theme.of(context).colorScheme.primary),
            ),
            title: Text(
              doc.fileName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${doc.fileSize} | Uploaded ${doc.uploadedAt.day}/${doc.uploadedAt.month}/${doc.uploadedAt.year}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(doc.id),
            ),
            onTap: () {
              context.showSnackBar('Opening document: ${doc.fileName}');
            },
          ),
        );
      },
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document?'),
        content: const Text('Are you sure you want to delete this file from the client vault?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(documentListProvider.notifier).deleteDocument(id);
              if (mounted) {
                context.showSnackBar('Document deleted.');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
