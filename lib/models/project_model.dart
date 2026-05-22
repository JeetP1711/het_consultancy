import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum ProjectStage {
  survey,
  quotation,
  approval,
  installation,
  completed;

  String get displayName {
    switch (this) {
      case ProjectStage.survey:
        return 'Site Survey';
      case ProjectStage.quotation:
        return 'Quotation';
      case ProjectStage.approval:
        return 'Approval & Booking';
      case ProjectStage.installation:
        return 'Installation';
      case ProjectStage.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case ProjectStage.survey:
        return AppColors.surveyPending;
      case ProjectStage.quotation:
        return AppColors.quotationSent;
      case ProjectStage.approval:
        return AppColors.lead;
      case ProjectStage.installation:
        return AppColors.solarOrange;
      case ProjectStage.completed:
        return AppColors.completed;
    }
  }

  static ProjectStage fromString(String stage) {
    return ProjectStage.values.firstWhere(
      (e) => e.name.toLowerCase() == stage.toLowerCase(),
      orElse: () => ProjectStage.survey,
    );
  }
}

class ProjectModel {
  final String id;
  final String clientId;
  final String clientName;
  final String quotationId;
  final ProjectStage stage;
  final String notes;
  final DateTime updatedAt;

  ProjectModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.quotationId,
    required this.stage,
    required this.notes,
    required this.updatedAt,
  });

  ProjectModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? quotationId,
    ProjectStage? stage,
    String? notes,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      quotationId: quotationId ?? this.quotationId,
      stage: stage ?? this.stage,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String? ?? '',
      quotationId: json['quotation_id'] as String? ?? '',
      stage: ProjectStage.fromString(json['stage'] as String? ?? 'survey'),
      notes: json['notes'] as String? ?? '',
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'client_name': clientName,
      'quotation_id': quotationId,
      'stage': stage.name,
      'notes': notes,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
