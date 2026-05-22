import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/app_scaffold.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/clients/screens/client_list_screen.dart';
import '../../features/clients/screens/client_detail_screen.dart';
import '../../features/clients/screens/client_form_screen.dart';
import '../../features/quotations/screens/quotation_list_screen.dart';
import '../../features/quotations/screens/quotation_form_screen.dart';
import '../../features/quotations/screens/quotation_detail_screen.dart';
import '../../features/projects/screens/project_list_screen.dart';
import '../../features/projects/screens/project_detail_screen.dart';
import '../../features/survey/screens/survey_form_screen.dart';
import '../../features/survey/screens/survey_detail_screen.dart';
import '../../features/documents/screens/document_list_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final isAuth = authState != null;

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';
      if (!isAuth) {
        return '/login';
      }
      if (loggingIn) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Bottom Navigation Shell
      ShellRoute(
        builder: (context, state, child) {
          return AppScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          
          // Clients Routes
          GoRoute(
            path: '/clients',
            builder: (context, state) => const ClientListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const ClientFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ClientFormScreen(clientId: id);
                },
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ClientDetailScreen(clientId: id);
                },
              ),
            ],
          ),

          // Quotations Routes
          GoRoute(
            path: '/quotations',
            builder: (context, state) => const QuotationListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const QuotationFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return QuotationFormScreen(quotationId: id);
                },
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return QuotationDetailScreen(quotationId: id);
                },
              ),
            ],
          ),

          // Projects Routes
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ProjectDetailScreen(projectId: id);
                },
              ),
            ],
          ),

          // Settings Route
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // Site Survey Forms & Details (Outside main shell but accessible easily)
      GoRoute(
        parentNavigatorKey: navigatorKey,
        path: '/survey/form/:clientId',
        builder: (context, state) {
          final clientId = state.pathParameters['clientId']!;
          return SurveyFormScreen(clientId: clientId);
        },
      ),
      GoRoute(
        parentNavigatorKey: navigatorKey,
        path: '/survey/detail/:clientId',
        builder: (context, state) {
          final clientId = state.pathParameters['clientId']!;
          return SurveyDetailScreen(clientId: clientId);
        },
      ),

      // Document Vault
      GoRoute(
        parentNavigatorKey: navigatorKey,
        path: '/documents/:clientId',
        builder: (context, state) {
          final clientId = state.pathParameters['clientId']!;
          return DocumentListScreen(clientId: clientId);
        },
      ),
    ],
  );
});
