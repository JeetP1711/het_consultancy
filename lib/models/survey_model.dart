class SurveyReportModel {
  final String id;
  final String clientId;
  final String clientName;
  final List<String> photos; // base64 or local file paths or urls
  final String measurements; // e.g. "20 x 40 feet" or JSON structure
  final String roofNotes; // e.g. "Flat RCC, shadows from south building"
  final String gpsLocation; // e.g. "12.9716° N, 77.5946° E"
  final String engineerNotes; // engineer recommendations
  final DateTime createdAt;

  SurveyReportModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.photos,
    required this.measurements,
    required this.roofNotes,
    required this.gpsLocation,
    required this.engineerNotes,
    required this.createdAt,
  });

  SurveyReportModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    List<String>? photos,
    String? measurements,
    String? roofNotes,
    String? gpsLocation,
    String? engineerNotes,
    DateTime? createdAt,
  }) {
    return SurveyReportModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      photos: photos ?? this.photos,
      measurements: measurements ?? this.measurements,
      roofNotes: roofNotes ?? this.roofNotes,
      gpsLocation: gpsLocation ?? this.gpsLocation,
      engineerNotes: engineerNotes ?? this.engineerNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory SurveyReportModel.fromJson(Map<String, dynamic> json) {
    return SurveyReportModel(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String? ?? '',
      photos: List<String>.from(json['photos'] as List? ?? []),
      measurements: json['measurements'] as String? ?? '',
      roofNotes: json['roof_notes'] as String? ?? '',
      gpsLocation: json['gps_location'] as String? ?? '',
      engineerNotes: json['engineer_notes'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'client_name': clientName,
      'photos': photos,
      'measurements': measurements,
      'roof_notes': roofNotes,
      'gps_location': gpsLocation,
      'engineer_notes': engineerNotes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
