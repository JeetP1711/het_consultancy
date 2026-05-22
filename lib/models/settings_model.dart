class CompanySettingsModel {
  final String companyName;
  final String companyAddress;
  final String companyPhone;
  final String companyEmail;
  final String gstNumber;

  // Default Bank Details for quotation PDF
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String ifscCode;
  final String branch;

  // Templates
  final String termsTemplate;
  final String warrantyTemplate;

  // Custom paths/base64
  final String logoPath; // Base64 representation or URL or asset
  final String signaturePath; // Base64 or local file path

  final bool isDarkMode;

  CompanySettingsModel({
    this.companyName = 'HET Consultancy',
    this.companyAddress = '101, Solar Heights, Energy Street, India',
    this.companyPhone = '+91 98765 43210',
    this.companyEmail = 'info@het.com',
    this.gstNumber = '27AAAAA1111A1Z1',
    this.bankName = 'State Bank of India',
    this.accountName = 'HET CONSULTANCY SERVICES',
    this.accountNumber = '123456789012',
    this.ifscCode = 'SBIN0001234',
    this.branch = 'Main Branch',
    this.termsTemplate = '1. Price includes delivery and basic mounting structure.\n2. Customer is responsible for net-metering approvals from local DISCOM.\n3. Payment schedule: 50% advance, 40% on material delivery, 10% post-commissioning.\n4. Site must have clear access and power for installation work.\n5. Any extra civil/electrical work will be billed at actuals.',
    this.warrantyTemplate = '5 Years warranty on Inverter.\n10 Years performance warranty on Solar Panels.\n25 Years linear power output warranty on Solar Panels.',
    this.logoPath = '',
    this.signaturePath = '',
    this.isDarkMode = false,
  });

  CompanySettingsModel copyWith({
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? companyEmail,
    String? gstNumber,
    String? bankName,
    String? accountName,
    String? accountNumber,
    String? ifscCode,
    String? branch,
    String? termsTemplate,
    String? warrantyTemplate,
    String? logoPath,
    String? signaturePath,
    bool? isDarkMode,
  }) {
    return CompanySettingsModel(
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyPhone: companyPhone ?? this.companyPhone,
      companyEmail: companyEmail ?? this.companyEmail,
      gstNumber: gstNumber ?? this.gstNumber,
      bankName: bankName ?? this.bankName,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      branch: branch ?? this.branch,
      termsTemplate: termsTemplate ?? this.termsTemplate,
      warrantyTemplate: warrantyTemplate ?? this.warrantyTemplate,
      logoPath: logoPath ?? this.logoPath,
      signaturePath: signaturePath ?? this.signaturePath,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  factory CompanySettingsModel.fromJson(Map<String, dynamic> json) {
    return CompanySettingsModel(
      companyName: json['company_name'] as String? ?? 'HET Consultancy',
      companyAddress: json['company_address'] as String? ?? '101, Solar Heights, Energy Street, India',
      companyPhone: json['company_phone'] as String? ?? '+91 98765 43210',
      companyEmail: json['company_email'] as String? ?? 'info@het.com',
      gstNumber: json['gst_number'] as String? ?? '27AAAAA1111A1Z1',
      bankName: json['bank_name'] as String? ?? 'State Bank of India',
      accountName: json['account_name'] as String? ?? 'HET CONSULTANCY SERVICES',
      accountNumber: json['account_number'] as String? ?? '123456789012',
      ifscCode: json['ifsc_code'] as String? ?? 'SBIN0001234',
      branch: json['branch'] as String? ?? 'Main Branch',
      termsTemplate: json['terms_template'] as String? ?? '',
      warrantyTemplate: json['warranty_template'] as String? ?? '',
      logoPath: json['logo_path'] as String? ?? '',
      signaturePath: json['signature_path'] as String? ?? '',
      isDarkMode: json['is_dark_mode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'company_address': companyAddress,
      'company_phone': companyPhone,
      'company_email': companyEmail,
      'gst_number': gstNumber,
      'bank_name': bankName,
      'account_name': accountName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'branch': branch,
      'terms_template': termsTemplate,
      'warranty_template': warrantyTemplate,
      'logo_path': logoPath,
      'signature_path': signaturePath,
      'is_dark_mode': isDarkMode,
    };
  }
}
