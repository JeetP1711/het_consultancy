import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_strings.dart';
import '../models/survey_model.dart';
import 'supabase_service.dart';

class SurveyService {
  final Box _box = Hive.box(AppStrings.surveysBox);

  // Get surveys
  List<SurveyReportModel> getSurveys() {
    final List<SurveyReportModel> list = [];
    for (var key in _box.keys) {
      final value = _box.get(key);
      if (value != null) {
        try {
          final decoded = jsonDecode(value as String);
          list.add(SurveyReportModel.fromJson(decoded as Map<String, dynamic>));
        } catch (e) {
          debugPrint('Error parsing survey $key: $e');
        }
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // Get survey by client id
  SurveyReportModel? getSurveyByClientId(String clientId) {
    for (var key in _box.keys) {
      final value = _box.get(key);
      if (value != null) {
        try {
          final decoded = jsonDecode(value as String);
          final report = SurveyReportModel.fromJson(decoded as Map<String, dynamic>);
          if (report.clientId == clientId) {
            return report;
          }
        } catch (_) {}
      }
    }
    return null;
  }

  // Save Survey Report
  Future<void> saveSurvey(SurveyReportModel survey) async {
    final jsonStr = jsonEncode(survey.toJson());
    await _box.put(survey.id, jsonStr);

    // Sync to Supabase
    final sb = SupabaseService.client;
    if (sb != null) {
      try {
        await sb.from('survey_reports').upsert(survey.toJson());
      } catch (e) {
        debugPrint('Supabase survey sync error: $e');
      }
    }
  }

  // Initialize demo surveys
  Future<void> initializeDemoSurveys() async {
    if (_box.isEmpty) {
      final now = DateTime.now();
      final demoSurvey = SurveyReportModel(
        id: 'survey-demo-1',
        clientId: 'client-3',
        clientName: 'Sunita Patil',
        photos: [], // empty list for demo, pickers will allow adding
        measurements: 'Roof area: 350 sq ft. Clear usable area: 280 sq ft.',
        roofNotes: 'Flat RCC roof. Access via internal staircase. Clear sun exposure from 9 AM to 5 PM. Minor shading from water tank on west side, avoid placement within 4 feet.',
        gpsLocation: '18.5362° N, 73.8940° E',
        engineerNotes: 'Recommend 3.2 kW capacity with 540W modules. Elevated structure of 3 feet required to clear the parapet wall shadows.',
        createdAt: now.subtract(const Duration(days: 4)),
      );
      await saveSurvey(demoSurvey);
    }
  }
}
