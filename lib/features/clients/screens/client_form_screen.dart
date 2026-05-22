import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/client_model.dart';
import '../providers/client_provider.dart';

class ClientFormScreen extends ConsumerStatefulWidget {
  final String? clientId;

  const ClientFormScreen({super.key, this.clientId});

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _siteController = TextEditingController();
  final _capacityController = TextEditingController();
  final _proposalController = TextEditingController();
  
  ClientStatus _status = ClientStatus.lead;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.clientId != null) {
      _loadClientData();
    } else {
      // Auto-generate proposal number for convenience
      final now = DateTime.now();
      _proposalController.text = 'HET/${now.year}/${100 + now.millisecond}';
    }
  }

  void _loadClientData() {
    final client = ref.read(clientListProvider).firstWhere((c) => c.id == widget.clientId);
    _nameController.text = client.name;
    _phoneController.text = client.phone;
    _emailController.text = client.email;
    _addressController.text = client.address;
    _siteController.text = client.site;
    _capacityController.text = client.capacity.toString();
    _proposalController.text = client.proposalNumber;
    _status = client.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _siteController.dispose();
    _capacityController.dispose();
    _proposalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final client = ClientModel(
        id: widget.clientId ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        site: _siteController.text.trim(),
        capacity: double.tryParse(_capacityController.text.trim()) ?? 0.0,
        proposalNumber: _proposalController.text.trim(),
        status: _status,
        createdAt: widget.clientId != null
            ? ref.read(clientListProvider).firstWhere((c) => c.id == widget.clientId).createdAt
            : DateTime.now(),
      );

      if (widget.clientId != null) {
        await ref.read(clientListProvider.notifier).updateClient(client);
        if (mounted) context.showSnackBar('Client updated successfully');
      } else {
        await ref.read(clientListProvider.notifier).addClient(client);
        if (mounted) context.showSnackBar('Client added successfully');
      }

      if (mounted) {
        context.pop();
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
    final isEdit = widget.clientId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Client Record' : 'Add New Client'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'General Details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _nameController,
                        label: 'Client / Company Name',
                        hint: 'e.g. Rajesh Kumar',
                        validator: (val) => Validators.required(val, 'Client name'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hint: 'e.g. +91 99999 88888',
                              keyboardType: TextInputType.phone,
                              validator: Validators.phone,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'e.g. name@domain.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Technical Specs',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _addressController,
                        label: 'Physical Address',
                        hint: 'Enter full installation location',
                        maxLines: 2,
                        validator: (val) => Validators.required(val, 'Address'),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _siteController,
                        label: 'Site Description',
                        hint: 'e.g. RCC Flat roof 2nd floor, shadow free area',
                        validator: (val) => Validators.required(val, 'Site description'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _capacityController,
                              label: 'Solar Capacity (kWp)',
                              hint: 'e.g. 5.0',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (val) => Validators.number(val, 'Target capacity'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              controller: _proposalController,
                              label: 'Proposal Code',
                              hint: 'e.g. HET/2026/001',
                              validator: (val) => Validators.required(val, 'Proposal code'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status Classification',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<ClientStatus>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Client Progress Stage',
                        ),
                        items: ClientStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.displayName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _status = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: isEdit ? 'Update Client' : 'Add Client',
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
