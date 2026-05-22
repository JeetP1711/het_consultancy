import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/survey_model.dart';
import '../../../services/providers.dart';

class SurveyListNotifier extends StateNotifier<List<SurveyReportModel>> {
  final Ref _ref;

  SurveyListNotifier(this._ref) : super([]) {
    loadSurveys();
  }

  void loadSurveys() {
    state = _ref.read(surveyServiceProvider).getSurveys();
  }

  Future<void> saveSurvey(SurveyReportModel survey) async {
    await _ref.read(surveyServiceProvider).saveSurvey(survey);
    loadSurveys();
  }
}

final surveyListProvider = StateNotifierProvider<SurveyListNotifier, List<SurveyReportModel>>((ref) {
  return SurveyListNotifier(ref);
});

// Family provider to get survey report by client id
final surveyByClientIdProvider = Provider.family<SurveyReportModel?, String>((ref, clientId) {
  ref.watch(surveyListProvider);
  return ref.read(surveyServiceProvider).getSurveyByClientId(clientId);
});
