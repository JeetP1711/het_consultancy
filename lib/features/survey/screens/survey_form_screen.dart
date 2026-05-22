import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/survey_model.dart';
import '../../../models/client_model.dart';
import '../providers/survey_provider.dart';
import '../../clients/providers/client_provider.dart';

class SurveyFormScreen extends ConsumerStatefulWidget {
  final String clientId;

  const SurveyFormScreen({super.key, required this.clientId});

  @override
  ConsumerState<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends ConsumerState<SurveyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _measurementsController = TextEditingController();
  final _roofNotesController = TextEditingController();
  final _gpsController = TextEditingController();
  final _engineerNotesController = TextEditingController();
  
  final List<String> _selectedPhotos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _gpsController.text = '18.5204° N, 73.8567° E'; // Default Pune, India GPS coordinate for convenience
    _loadExistingSurvey();
  }

  void _loadExistingSurvey() {
    final existing = ref.read(surveyByClientIdProvider(widget.clientId));
    if (existing != null) {
      _measurementsController.text = existing.measurements;
      _roofNotesController.text = existing.roofNotes;
      _gpsController.text = existing.gpsLocation;
      _engineerNotesController.text = existing.engineerNotes;
      _selectedPhotos.addAll(existing.photos);
    }
  }

  @override
  void dispose() {
    _measurementsController.dispose();
    _roofNotesController.dispose();
    _gpsController.dispose();
    _engineerNotesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? file = await picker.pickImage(imageQuality: 70, source: source);
      if (file != null) {
        setState(() {
          _selectedPhotos.add(file.path);
        });
      }
    } catch (e) {
      context.showSnackBar('Error picking image: $e', isError: true);
    }
  }

  void _gpsDetect() {
    // Simulate detecting GPS coordinates
    setState(() {
      _gpsController.text = '18.5204° N, 73.8567° E';
    });
    context.showSnackBar('GPS Coordinates captured!');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final client = ref.read(clientListProvider).firstWhere((c) => c.id == widget.clientId);
      final existing = ref.read(surveyByClientIdProvider(widget.clientId));

      final survey = SurveyReportModel(
        id: existing?.id ?? const Uuid().v4(),
        clientId: widget.clientId,
        clientName: client.name,
        photos: _selectedPhotos,
        measurements: _measurementsController.text.trim(),
        roofNotes: _roofNotesController.text.trim(),
        gpsLocation: _gpsController.text.trim(),
        engineerNotes: _engineerNotesController.text.trim(),
        createdAt: existing?.createdAt ?? DateTime.now(),
      );

      await ref.read(surveyListProvider.notifier).saveSurvey(survey);
      
      // Update Client status to "Quotation Sent" or "Survey Completed"
      final updatedClient = client.copyWith(status: ClientStatus.quotationSent);
      await ref.read(clientListProvider.notifier).updateClient(updatedClient);

      if (mounted) {
        context.showSnackBar('Survey report saved successfully.');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Site Survey Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photos section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upload Site Photos',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedPhotos.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _selectedPhotos.length) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: InkWell(
                                  onTap: () => _showImageSourceSheet(),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                        width: 1.5,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo_outlined, size: 28),
                                        SizedBox(height: 8),
                                        Text(
                                          'Add Photo',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            final photoPath = _selectedPhotos[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.image, size: 36, color: Colors.grey),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.red.withOpacity(0.8),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.close, size: 14, color: Colors.white),
                                        onPressed: () {
                                          setState(() {
                                            _selectedPhotos.removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Technical section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Site Dimensions & Location',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _measurementsController,
                        label: 'Measurements (Length x Width in feet)',
                        hint: 'e.g. Roof: 30 x 40 ft, Parapet: 3 ft height',
                        validator: (val) => Validators.required(val, 'Measurements'),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _gpsController,
                        label: 'GPS Location coordinates',
                        hint: 'e.g. 18.5204° N, 73.8567° E',
                        validator: (val) => Validators.required(val, 'GPS Location'),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.my_location),
                          onPressed: _gpsDetect,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _roofNotesController,
                        label: 'Roof Obstruction Notes',
                        hint: 'Shadow from staircase tower, water tank, vents, etc.',
                        maxLines: 3,
                        validator: (val) => Validators.required(val, 'Roof notes'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Recommendations section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Engineer Recommendations',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _engineerNotesController,
                        label: 'Electrical & Structural Notes',
                        hint: 'Structure elevation height, cable routing distance, etc.',
                        maxLines: 4,
                        validator: (val) => Validators.required(val, 'Engineer notes'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Save Survey Report',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Capture from Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
