import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/settings_model.dart';
import '../providers/settings_provider.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _gstController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accNameController = TextEditingController();
  final _accNumController = TextEditingController();
  final _ifscController = TextEditingController();
  final _branchController = TextEditingController();
  final _termsController = TextEditingController();
  final _warrantyController = TextEditingController();

  String _logoPath = '';
  String _sigPath = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = ref.read(settingsProvider);
    _gstController.text = settings.gstNumber;
    _bankNameController.text = settings.bankName;
    _accNameController.text = settings.accountName;
    _accNumController.text = settings.accountNumber;
    _ifscController.text = settings.ifscCode;
    _branchController.text = settings.branch;
    _termsController.text = settings.termsTemplate;
    _warrantyController.text = settings.warrantyTemplate;
    _logoPath = settings.logoPath;
    _sigPath = settings.signaturePath;
  }

  @override
  void dispose() {
    _gstController.dispose();
    _bankNameController.dispose();
    _accNameController.dispose();
    _accNumController.dispose();
    _ifscController.dispose();
    _branchController.dispose();
    _termsController.dispose();
    _warrantyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    try {
      final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (file != null) {
        setState(() {
          if (isLogo) {
            _logoPath = file.path;
          } else {
            _sigPath = file.path;
          }
        });
        context.showSnackBar('${isLogo ? 'Logo' : 'Signature'} chosen.');
      }
    } catch (e) {
      context.showSnackBar('Error picking image: $e', isError: true);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final current = ref.read(settingsProvider);
      final updated = current.copyWith(
        gstNumber: _gstController.text.trim(),
        bankName: _bankNameController.text.trim(),
        accountName: _accNameController.text.trim(),
        accountNumber: _accNumController.text.trim(),
        ifscCode: _ifscController.text.trim(),
        branch: _branchController.text.trim(),
        termsTemplate: _termsController.text.trim(),
        warrantyTemplate: _warrantyController.text.trim(),
        logoPath: _logoPath,
        signaturePath: _sigPath,
      );

      await ref.read(settingsProvider.notifier).updateSettings(updated);
      if (mounted) {
        context.showSnackBar('Company configuration updated.');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = ref.watch(darkModeProvider);
    final user = ref.watch(authProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Logo and Signature section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assets & Branding',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _logoPath.isEmpty
                                    ? Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: const Icon(Icons.business, size: 40, color: Colors.grey),
                                      )
                                    : const Icon(Icons.verified, color: Colors.green, size: 64),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _pickImage(true),
                                  icon: const Icon(Icons.upload, size: 16),
                                  label: const Text('Company Logo'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                _sigPath.isEmpty
                                    ? Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: const Icon(Icons.draw, size: 40, color: Colors.grey),
                                      )
                                    : const Icon(Icons.verified, color: Colors.blue, size: 64),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _pickImage(false),
                                  icon: const Icon(Icons.upload, size: 16),
                                  label: const Text('Authorized Sign'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // GST & Finance details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GST & Bank Settings',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _gstController,
                        label: 'GST Identification Number (GSTIN)',
                        hint: 'e.g. 27AAAAA1111A1Z1',
                        validator: (val) => Validators.required(val, 'GST Number'),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _accNameController,
                        label: 'Account Beneficiary Name',
                        hint: 'e.g. HET CONSULTANCY SERVICES',
                        validator: (val) => Validators.required(val, 'Account name'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _bankNameController,
                              label: 'Bank Name',
                              hint: 'e.g. State Bank of India',
                              validator: (val) => Validators.required(val, 'Bank Name'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              controller: _accNumController,
                              label: 'Account Number',
                              hint: 'e.g. 1234567890',
                              keyboardType: TextInputType.number,
                              validator: (val) => Validators.required(val, 'Account number'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _ifscController,
                              label: 'IFSC Code',
                              hint: 'e.g. SBIN0001234',
                              validator: (val) => Validators.required(val, 'IFSC Code'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              controller: _branchController,
                              label: 'Branch Location',
                              hint: 'e.g. Pune Main Branch',
                              validator: (val) => Validators.required(val, 'Branch'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quotation templates
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quotation Template T&Cs',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _termsController,
                        label: 'Standard Terms & Conditions (One per line)',
                        hint: '1. Price includes structural mounting...',
                        maxLines: 4,
                        validator: (val) => Validators.required(val, 'Terms template'),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _warrantyController,
                        label: 'Standard Warranty Template',
                        hint: '5 Years inverter warranty...',
                        maxLines: 3,
                        validator: (val) => Validators.required(val, 'Warranty template'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Theme / App actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preferences & Account',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Enable Dark Theme'),
                        value: darkMode,
                        onChanged: (val) {
                          ref.read(settingsProvider.notifier).toggleDarkMode(val);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Log Out Session', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        onTap: () {
                          ref.read(authProvider.notifier).logout();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Save Configuration',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
