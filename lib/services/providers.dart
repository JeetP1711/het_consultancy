import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';
import 'client_service.dart';
import 'quotation_service.dart';
import 'project_service.dart';
import 'survey_service.dart';
import 'document_service.dart';
import 'settings_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final clientServiceProvider = Provider<ClientService>((ref) {
  return ClientService();
});

final quotationServiceProvider = Provider<QuotationService>((ref) {
  return QuotationService();
});

final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService();
});

final surveyServiceProvider = Provider<SurveyService>((ref) {
  return SurveyService();
});

final documentServiceProvider = Provider<DocumentService>((ref) {
  return DocumentService();
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});
