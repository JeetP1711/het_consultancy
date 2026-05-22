import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum ClientStatus {
  lead,
  surveyPending,
  quotationSent,
  approved,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case ClientStatus.lead:
        return 'Lead';
      case ClientStatus.surveyPending:
        return 'Survey Pending';
      case ClientStatus.quotationSent:
        return 'Quotation Sent';
      case ClientStatus.approved:
        return 'Approved';
      case ClientStatus.completed:
        return 'Completed';
      case ClientStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case ClientStatus.lead:
        return AppColors.lead;
      case ClientStatus.surveyPending:
        return AppColors.surveyPending;
      case ClientStatus.quotationSent:
        return AppColors.quotationSent;
      case ClientStatus.approved:
        return AppColors.approved;
      case ClientStatus.completed:
        return AppColors.completed;
      case ClientStatus.cancelled:
        return AppColors.cancelled;
    }
  }

  static ClientStatus fromString(String status) {
    return ClientStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.replaceAll(' ', '').toLowerCase(),
      orElse: () => ClientStatus.lead,
    );
  }
}

class ClientModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String site;
  final double capacity; // Solar capacity in kW
  final String proposalNumber;
  final ClientStatus status;
  final DateTime createdAt;

  ClientModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.site,
    required this.capacity,
    required this.proposalNumber,
    required this.status,
    required this.createdAt,
  });

  ClientModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? site,
    double? capacity,
    String? proposalNumber,
    ClientStatus? status,
    DateTime? createdAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      site: site ?? this.site,
      capacity: capacity ?? this.capacity,
      proposalNumber: proposalNumber ?? this.proposalNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      site: json['site'] as String,
      capacity: (json['capacity'] as num).toDouble(),
      proposalNumber: json['proposal_number'] as String,
      status: ClientStatus.fromString(json['status'] as String? ?? 'lead'),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'site': site,
      'capacity': capacity,
      'proposal_number': proposalNumber,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
