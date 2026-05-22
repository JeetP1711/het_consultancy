import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum QuotationStatus {
  draft,
  submitted,
  approved,
  locked;

  String get displayName {
    switch (this) {
      case QuotationStatus.draft:
        return 'Draft';
      case QuotationStatus.submitted:
        return 'Submitted';
      case QuotationStatus.approved:
        return 'Approved';
      case QuotationStatus.locked:
        return 'Locked';
    }
  }

  Color get color {
    switch (this) {
      case QuotationStatus.draft:
        return Colors.grey;
      case QuotationStatus.submitted:
        return AppColors.quotationSent;
      case QuotationStatus.approved:
        return AppColors.approved;
      case QuotationStatus.locked:
        return AppColors.locked;
    }
  }

  static QuotationStatus fromString(String status) {
    return QuotationStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => QuotationStatus.draft,
    );
  }
}

class QuotationModel {
  final String id;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final String clientEmail;
  final String clientAddress;

  final String proposalNumber;
  final DateTime date;
  final double capacity; // Solar capacity in kW

  // Panel details
  final String panelBrand;
  final int panelWattage;
  final int panelQty;

  // Inverter details
  final String inverterBrand;
  final int inverterQty;

  // Technical Specs
  final String structure;
  final String dcdb;
  final String acdb;
  final String lightningArrestor;
  final String earthing;
  final String cable;
  final String accessories;

  // Financial details
  final double price; // Base price
  final double taxRate; // Tax in % (e.g. 13.8 or 18)
  final double subsidy; // Subsidy amount
  final int installationTime; // installation days

  // Bank details
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String ifscCode;
  final String branch;

  // Other Info
  final String terms;
  final String warranty;
  final String notes;

  // Metadata
  final QuotationStatus status;
  final int version;
  final String? lockedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuotationModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.clientAddress,
    required this.proposalNumber,
    required this.date,
    required this.capacity,
    required this.panelBrand,
    required this.panelWattage,
    required this.panelQty,
    required this.inverterBrand,
    required this.inverterQty,
    required this.structure,
    required this.dcdb,
    required this.acdb,
    required this.lightningArrestor,
    required this.earthing,
    required this.cable,
    required this.accessories,
    required this.price,
    required this.taxRate,
    required this.subsidy,
    required this.installationTime,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.ifscCode,
    required this.branch,
    required this.terms,
    required this.warranty,
    required this.notes,
    required this.status,
    this.version = 1,
    this.lockedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  double get taxAmount => (price * taxRate) / 100;
  double get totalAmount => price + taxAmount;
  double get netPayableAmount => totalAmount - subsidy;

  QuotationModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? clientPhone,
    String? clientEmail,
    String? clientAddress,
    String? proposalNumber,
    DateTime? date,
    double? capacity,
    String? panelBrand,
    int? panelWattage,
    int? panelQty,
    String? inverterBrand,
    int? inverterQty,
    String? structure,
    String? dcdb,
    String? acdb,
    String? lightningArrestor,
    String? earthing,
    String? cable,
    String? accessories,
    double? price,
    double? taxRate,
    double? subsidy,
    int? installationTime,
    String? bankName,
    String? accountName,
    String? accountNumber,
    String? ifscCode,
    String? branch,
    String? terms,
    String? warranty,
    String? notes,
    QuotationStatus? status,
    int? version,
    String? lockedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuotationModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      clientAddress: clientAddress ?? this.clientAddress,
      proposalNumber: proposalNumber ?? this.proposalNumber,
      date: date ?? this.date,
      capacity: capacity ?? this.capacity,
      panelBrand: panelBrand ?? this.panelBrand,
      panelWattage: panelWattage ?? this.panelWattage,
      panelQty: panelQty ?? this.panelQty,
      inverterBrand: inverterBrand ?? this.inverterBrand,
      inverterQty: inverterQty ?? this.inverterQty,
      structure: structure ?? this.structure,
      dcdb: dcdb ?? this.dcdb,
      acdb: acdb ?? this.acdb,
      lightningArrestor: lightningArrestor ?? this.lightningArrestor,
      earthing: earthing ?? this.earthing,
      cable: cable ?? this.cable,
      accessories: accessories ?? this.accessories,
      price: price ?? this.price,
      taxRate: taxRate ?? this.taxRate,
      subsidy: subsidy ?? this.subsidy,
      installationTime: installationTime ?? this.installationTime,
      bankName: bankName ?? this.bankName,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      branch: branch ?? this.branch,
      terms: terms ?? this.terms,
      warranty: warranty ?? this.warranty,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      version: version ?? this.version,
      lockedBy: lockedBy ?? this.lockedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    return QuotationModel(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String? ?? '',
      clientPhone: json['client_phone'] as String? ?? '',
      clientEmail: json['client_email'] as String? ?? '',
      clientAddress: json['client_address'] as String? ?? '',
      proposalNumber: json['proposal_number'] as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      capacity: (json['capacity'] as num).toDouble(),
      panelBrand: json['panel_brand'] as String? ?? '',
      panelWattage: (json['panel_wattage'] as num?)?.toInt() ?? 0,
      panelQty: (json['panel_qty'] as num?)?.toInt() ?? 0,
      inverterBrand: json['inverter_brand'] as String? ?? '',
      inverterQty: (json['inverter_qty'] as num?)?.toInt() ?? 0,
      structure: json['structure'] as String? ?? '',
      dcdb: json['dcdb'] as String? ?? '',
      acdb: json['acdb'] as String? ?? '',
      lightningArrestor: json['lightning_arrestor'] as String? ?? '',
      earthing: json['earthing'] as String? ?? '',
      cable: json['cable'] as String? ?? '',
      accessories: json['accessories'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      taxRate: (json['tax_rate'] as num? ?? 18.0).toDouble(),
      subsidy: (json['subsidy'] as num? ?? 0.0).toDouble(),
      installationTime: (json['installation_time'] as num? ?? 7).toInt(),
      bankName: json['bank_name'] as String? ?? '',
      accountName: json['account_name'] as String? ?? '',
      accountNumber: json['account_number'] as String? ?? '',
      ifscCode: json['ifsc_code'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      terms: json['terms'] as String? ?? '',
      warranty: json['warranty'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      status: QuotationStatus.fromString(json['status'] as String? ?? 'draft'),
      version: (json['version'] as num? ?? 1).toInt(),
      lockedBy: json['locked_by'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'client_name': clientName,
      'client_phone': clientPhone,
      'client_email': clientEmail,
      'client_address': clientAddress,
      'proposal_number': proposalNumber,
      'date': date.toIso8601String(),
      'capacity': capacity,
      'panel_brand': panelBrand,
      'panel_wattage': panelWattage,
      'panel_qty': panelQty,
      'inverter_brand': inverterBrand,
      'inverter_qty': inverterQty,
      'structure': structure,
      'dcdb': dcdb,
      'acdb': acdb,
      'lightning_arrestor': lightningArrestor,
      'earthing': earthing,
      'cable': cable,
      'accessories': accessories,
      'price': price,
      'tax_rate': taxRate,
      'subsidy': subsidy,
      'installation_time': installationTime,
      'bank_name': bankName,
      'account_name': accountName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'branch': branch,
      'terms': terms,
      'warranty': warranty,
      'notes': notes,
      'status': status.name,
      'version': version,
      'locked_by': lockedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
