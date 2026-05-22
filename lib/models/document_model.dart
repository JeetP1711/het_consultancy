enum DocumentType {
  quotation,
  bill,
  photo,
  certificate;

  String get displayName {
    switch (this) {
      case DocumentType.quotation:
        return 'Quotation';
      case DocumentType.bill:
        return 'Invoice / Bill';
      case DocumentType.photo:
        return 'Site Photo';
      case DocumentType.certificate:
        return 'Government Certificate';
    }
  }

  static DocumentType fromString(String type) {
    return DocumentType.values.firstWhere(
      (e) => e.name.toLowerCase() == type.toLowerCase(),
      orElse: () => DocumentType.photo,
    );
  }
}

class DocumentModel {
  final String id;
  final String clientId;
  final String clientName;
  final String fileName;
  final String filePath; // Local path or web URL
  final String fileSize;
  final DocumentType type;
  final DateTime uploadedAt;

  DocumentModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.type,
    required this.uploadedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String? ?? '',
      fileName: json['file_name'] as String,
      filePath: json['file_path'] as String,
      fileSize: json['file_size'] as String? ?? '0 KB',
      type: DocumentType.fromString(json['type'] as String? ?? 'photo'),
      uploadedAt: DateTime.tryParse(json['uploaded_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'client_name': clientName,
      'file_name': fileName,
      'file_path': filePath,
      'file_size': fileSize,
      'type': type.name,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}
