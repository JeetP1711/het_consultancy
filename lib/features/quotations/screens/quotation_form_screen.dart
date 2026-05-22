import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/client_model.dart';
import '../../../models/quotation_model.dart';
import '../../../models/project_model.dart';
import '../../clients/providers/client_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../projects/providers/project_provider.dart';
import '../providers/quotation_provider.dart';

class QuotationFormScreen extends ConsumerStatefulWidget {
  final String? quotationId;

  const QuotationFormScreen({super.key, this.quotationId});

  @override
  ConsumerState<QuotationFormScreen> createState() => _QuotationFormScreenState();
}

class _QuotationFormScreenState extends ConsumerState<QuotationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Customer
  ClientModel? _selectedClient;
  final _custNameController = TextEditingController();
  final _custPhoneController = TextEditingController();
  final _custEmailController = TextEditingController();
  final _custAddressController = TextEditingController();
  final _proposalNumberController = TextEditingController();
  final _capacityController = TextEditingController();

  // Technical Specs
  final _panelBrandController = TextEditingController();
  final _panelWattageController = TextEditingController();
  final _panelQtyController = TextEditingController();
  final _inverterBrandController = TextEditingController();
  final _inverterQtyController = TextEditingController();
  final _structureController = TextEditingController();
  final _dcdbController = TextEditingController();
  final _acdbController = TextEditingController();
  final _laController = TextEditingController();
  final _earthingController = TextEditingController();
  final _cableController = TextEditingController();
  final _accessoriesController = TextEditingController();

  // Financial & Banks
  final _priceController = TextEditingController();
  final _taxRateController = TextEditingController();
  final _subsidyController = TextEditingController();
  final _installTimeController = TextEditingController();
  
  final _bankNameController = TextEditingController();
  final _accNameController = TextEditingController();
  final _accNumController = TextEditingController();
  final _ifscController = TextEditingController();
  final _branchController = TextEditingController();

  // Notes & T&C
  final _termsController = TextEditingController();
  final _warrantyController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  int _version = 1;
  QuotationStatus _status = QuotationStatus.draft;

  @override
  void initState() {
    super.initState();
    _initDefaults();
    if (widget.quotationId != null) {
      _loadQuotation();
    }
  }

  void _initDefaults() {
    final settings = ref.read(settingsProvider);
    _taxRateController.text = '13.8'; // Solar Standard GST
    _installTimeController.text = '7';
    _bankNameController.text = settings.bankName;
    _accNameController.text = settings.accountName;
    _accNumController.text = settings.accountNumber;
    _ifscController.text = settings.ifscCode;
    _branchController.text = settings.branch;
    _termsController.text = settings.termsTemplate;
    _warrantyController.text = settings.warrantyTemplate;

    _panelBrandController.text = 'Waaree Mono PERC';
    _panelWattageController.text = '540';
    _inverterBrandController.text = 'Growatt On-Grid';
    _inverterQtyController.text = '1';
    _structureController.text = 'Hot Dip Galvanized MS Structure, elevated 3 feet';
    _dcdbController.text = '1 Input 1 Output 1000V DCDB with SPD & Fuse';
    _acdbController.text = '1 Input 1 Output Single/Three Phase ACDB with MCB & SPD';
    _laController.text = 'Solid Copper conventional LA, 1.5m height';
    _earthingController.text = 'Chemical Gel earthing electrodes (3 runs: DC, AC, LA)';
    _cableController.text = 'Polycab 4/6 Sqmm DC Solar cable & AC cable';
    _accessoriesController.text = 'Conduits, cable ties, glands, MC4 connectors';
  }

  void _loadQuotation() {
    final q = ref.read(quotationListProvider).firstWhere((item) => item.id == widget.quotationId);
    _custNameController.text = q.clientName;
    _custPhoneController.text = q.clientPhone;
    _custEmailController.text = q.clientEmail;
    _custAddressController.text = q.clientAddress;
    _proposalNumberController.text = q.proposalNumber;
    _capacityController.text = q.capacity.toString();

    _panelBrandController.text = q.panelBrand;
    _panelWattageController.text = q.panelWattage.toString();
    _panelQtyController.text = q.panelQty.toString();
    _inverterBrandController.text = q.inverterBrand;
    _inverterQtyController.text = q.inverterQty.toString();
    
    _structureController.text = q.structure;
    _dcdbController.text = q.dcdb;
    _acdbController.text = q.acdb;
    _laController.text = q.lightningArrestor;
    _earthingController.text = q.earthing;
    _cableController.text = q.cable;
    _accessoriesController.text = q.accessories;

    _priceController.text = q.price.toString();
    _taxRateController.text = q.taxRate.toString();
    _subsidyController.text = q.subsidy.toString();
    _installTimeController.text = q.installationTime.toString();

    _bankNameController.text = q.bankName;
    _accNameController.text = q.accountName;
    _accNumController.text = q.accountNumber;
    _ifscController.text = q.ifscCode;
    _branchController.text = q.branch;

    _termsController.text = q.terms;
    _warrantyController.text = q.warranty;
    _notesController.text = q.notes;
    
    _version = q.version;
    _status = q.status;
  }

  void _autofillFromClient(ClientModel client) {
    setState(() {
      _selectedClient = client;
      _custNameController.text = client.name;
      _custPhoneController.text = client.phone;
      _custEmailController.text = client.email;
      _custAddressController.text = client.address;
      _proposalNumberController.text = client.proposalNumber;
      _capacityController.text = client.capacity.toString();
      
      // Auto-calculate default panel quantity based on capacity & wattage (e.g. 5kW / 540W = 9 panels)
      final wattage = double.tryParse(_panelWattageController.text) ?? 540;
      if (wattage > 0) {
        final panelQty = (client.capacity * 1000 / wattage).ceil();
        _panelQtyController.text = panelQty.toString();
      }
      
      // Auto-calculate sample price (e.g. ₹55,000 per kW)
      _priceController.text = (client.capacity * 55000).toStringAsFixed(0);
      
      // Auto-calculate PM Surya Ghar subsidy estimate
      // e.g. ₹30,000/kW up to 2kW (max 60k) + 18k for 3rd kW (max 78k)
      double sub = 0;
      if (client.capacity >= 3.0) {
        sub = 78000;
      } else if (client.capacity >= 2.0) {
        sub = 60000;
      } else if (client.capacity >= 1.0) {
        sub = 30000;
      }
      _subsidyController.text = sub.toStringAsFixed(0);
    });
  }

  @override
  void dispose() {
    _custNameController.dispose();
    _custPhoneController.dispose();
    _custEmailController.dispose();
    _custAddressController.dispose();
    _proposalNumberController.dispose();
    _capacityController.dispose();
    _panelBrandController.dispose();
    _panelWattageController.dispose();
    _panelQtyController.dispose();
    _inverterBrandController.dispose();
    _inverterQtyController.dispose();
    _structureController.dispose();
    _dcdbController.dispose();
    _acdbController.dispose();
    _laController.dispose();
    _earthingController.dispose();
    _cableController.dispose();
    _accessoriesController.dispose();
    _priceController.dispose();
    _taxRateController.dispose();
    _subsidyController.dispose();
    _installTimeController.dispose();
    _bankNameController.dispose();
    _accNameController.dispose();
    _accNumController.dispose();
    _ifscController.dispose();
    _branchController.dispose();
    _termsController.dispose();
    _warrantyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit(QuotationStatus targetStatus) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final isNew = widget.quotationId == null;
      final qId = widget.quotationId ?? const Uuid().v4();
      final clientId = _selectedClient?.id ?? (isNew ? 'client-3' : 'client-3'); // Fallback link

      final quotation = QuotationModel(
        id: qId,
        clientId: clientId,
        clientName: _custNameController.text.trim(),
        clientPhone: _custPhoneController.text.trim(),
        clientEmail: _custEmailController.text.trim(),
        clientAddress: _custAddressController.text.trim(),
        proposalNumber: _proposalNumberController.text.trim(),
        date: DateTime.now(),
        capacity: double.tryParse(_capacityController.text.trim()) ?? 0.0,
        panelBrand: _panelBrandController.text.trim(),
        panelWattage: int.tryParse(_panelWattageController.text.trim()) ?? 540,
        panelQty: int.tryParse(_panelQtyController.text.trim()) ?? 0,
        inverterBrand: _inverterBrandController.text.trim(),
        inverterQty: int.tryParse(_inverterQtyController.text.trim()) ?? 1,
        structure: _structureController.text.trim(),
        dcdb: _dcdbController.text.trim(),
        acdb: _acdbController.text.trim(),
        lightningArrestor: _laController.text.trim(),
        earthing: _earthingController.text.trim(),
        cable: _cableController.text.trim(),
        accessories: _accessoriesController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        taxRate: double.tryParse(_taxRateController.text.trim()) ?? 18.0,
        subsidy: double.tryParse(_subsidyController.text.trim()) ?? 0.0,
        installationTime: int.tryParse(_installTimeController.text.trim()) ?? 7,
        bankName: _bankNameController.text.trim(),
        accountName: _accNameController.text.trim(),
        accountNumber: _accNumController.text.trim(),
        ifscCode: _ifscController.text.trim(),
        branch: _branchController.text.trim(),
        terms: _termsController.text.trim(),
        warranty: _warrantyController.text.trim(),
        notes: _notesController.text.trim(),
        status: targetStatus,
        version: _version,
        createdAt: isNew ? DateTime.now() : DateTime.now(), // fallback
        updatedAt: DateTime.now(),
      );

      final saved = await ref.read(quotationListProvider.notifier).saveQuotation(quotation);

      // Create linked project in the list if submitted/approved
      if (targetStatus == QuotationStatus.submitted || targetStatus == QuotationStatus.approved) {
        final existingProj = ref.read(projectListProvider).any((p) => p.clientId == clientId);
        if (!existingProj) {
          final newProj = ProjectModel(
            id: 'proj-${const Uuid().v4()}',
            clientId: clientId,
            clientName: _custNameController.text.trim(),
            quotationId: saved.id,
            stage: ProjectStage.quotation,
            notes: 'Quotation generated and submitted to customer.',
            updatedAt: DateTime.now(),
          );
          await ref.read(projectListProvider.notifier).saveProject(newProj);
        }
      }

      if (mounted) {
        context.showSnackBar('Quotation saved as ${targetStatus.displayName}');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientListProvider);
    final isEdit = widget.quotationId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Quotation' : 'New Solar Quotation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Client Selection Dropdown (Only for new)
              if (!isEdit && clients.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Client (Autofills Details)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<ClientModel>(
                          decoration: const InputDecoration(labelText: 'Choose Client'),
                          items: clients.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text('${c.name} (${c.capacity} kWp)'),
                            );
                          }).toList(),
                          onChanged: (client) {
                            if (client != null) {
                              _autofillFromClient(client);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Customer Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _custNameController,
                        label: 'Customer Name',
                        validator: (val) => Validators.required(val, 'Customer name'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _custPhoneController,
                              label: 'Phone',
                              keyboardType: TextInputType.phone,
                              validator: Validators.phone,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              controller: _custEmailController,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _custAddressController,
                        label: 'Installation Address',
                        maxLines: 2,
                        validator: (val) => Validators.required(val, 'Address'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _proposalNumberController,
                              label: 'Proposal Number',
                              validator: (val) => Validators.required(val, 'Proposal Number'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              controller: _capacityController,
                              label: 'Capacity (kWp)',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (val) => Validators.number(val, 'Capacity'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Technical specs
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Solar Panel & Inverter Specs',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: AppTextField(
                              controller: _panelBrandController,
                              label: 'Panel Brand',
                              validator: (val) => Validators.required(val, 'Panel Brand'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _panelWattageController,
                              label: 'Wattage (Wp)',
                              keyboardType: TextInputType.number,
                              validator: (val) => Validators.number(val, 'Wattage'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _panelQtyController,
                              label: 'Quantity',
                              keyboardType: TextInputType.number,
                              validator: (val) => Validators.number(val, 'Quantity'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: AppTextField(
                              controller: _inverterBrandController,
                              label: 'Inverter Brand',
                              validator: (val) => Validators.required(val, 'Inverter Brand'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              controller: _inverterQtyController,
                              label: 'Inverter Qty',
                              keyboardType: TextInputType.number,
                              validator: (val) => Validators.number(val, 'Quantity'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Electrical & structural specs
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Balance of System (BOS)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(controller: _structureController, label: 'Mounting Structure Type'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: AppTextField(controller: _dcdbController, label: 'DC Distribution Box (DCDB)')),
                          const SizedBox(width: 16),
                          Expanded(child: AppTextField(controller: _acdbController, label: 'AC Distribution Box (ACDB)')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: AppTextField(controller: _laController, label: 'Lightning Arrestor (LA)')),
                          const SizedBox(width: 16),
                          Expanded(child: AppTextField(controller: _earthingController, label: 'Earthing System')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: AppTextField(controller: _cableController, label: 'Solar & Grid Cabling')),
                          const SizedBox(width: 16),
                          Expanded(child: AppTextField(controller: _accessoriesController, label: 'Installation Accessories')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Pricing
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Financial Breakdown & Time',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _priceController,
                              label: 'Base System Price (INR)',
                              keyboardType: TextInputType.number,
                              validator: (val) => Validators.number(val, 'Price'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              controller: _taxRateController,
                              label: 'Tax rate / GST (%)',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (val) => Validators.number(val, 'GST rate'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _subsidyController,
                              label: 'Estimated Subsidy (INR)',
                              keyboardType: TextInputType.number,
                              validator: (val) => Validators.number(val, 'Subsidy'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              controller: _installTimeController,
                              label: 'Installation time (Days)',
                              keyboardType: TextInputType.number,
                              validator: (val) => Validators.number(val, 'Installation Time'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bank details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bank Account Details (Displayed on PDF)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(controller: _accNameController, label: 'Account Name'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: AppTextField(controller: _bankNameController, label: 'Bank Name')),
                          const SizedBox(width: 16),
                          Expanded(child: AppTextField(controller: _accNumController, label: 'Account Number')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: AppTextField(controller: _ifscController, label: 'IFSC Code')),
                          const SizedBox(width: 16),
                          Expanded(child: AppTextField(controller: _branchController, label: 'Branch')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Terms & templates
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Templates & Notes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(controller: _termsController, label: 'Terms & Conditions Template', maxLines: 3),
                      const SizedBox(height: 16),
                      AppTextField(controller: _warrantyController, label: 'Warranty Policy Template', maxLines: 2),
                      const SizedBox(height: 16),
                      AppTextField(controller: _notesController, label: 'Proposal Specific Notes', maxLines: 3),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Row of Save Actions
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Save as Draft',
                      type: AppButtonType.secondary,
                      isLoading: _isLoading,
                      onPressed: () => _submit(QuotationStatus.draft),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      label: 'Submit Proposal',
                      isLoading: _isLoading,
                      onPressed: () => _submit(QuotationStatus.submitted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
