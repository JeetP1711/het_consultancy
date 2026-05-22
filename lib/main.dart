import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/settings/providers/settings_provider.dart';
import 'services/client_service.dart';
import 'services/quotation_service.dart';
import 'services/project_service.dart';
import 'services/survey_service.dart';
import 'services/document_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open Hive Boxes
  await Hive.openBox(AppStrings.settingsBox);
  await Hive.openBox(AppStrings.clientsBox);
  await Hive.openBox(AppStrings.quotationsBox);
  await Hive.openBox(AppStrings.projectsBox);
  await Hive.openBox(AppStrings.surveysBox);
  await Hive.openBox(AppStrings.documentsBox);
  await Hive.openBox(AppStrings.authBox);

  // Initialize Demo Datasets for offline/evaluation usage
  final clientService = ClientService();
  final quotationService = QuotationService();
  final projectService = ProjectService();
  final surveyService = SurveyService();
  final documentService = DocumentService();

  await clientService.initializeDemoClients();
  await quotationService.initializeDemoQuotations();
  await projectService.initializeDemoProjects();
  await surveyService.initializeDemoSurveys();
  await documentService.initializeDemoDocuments();

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDark = ref.watch(darkModeProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
