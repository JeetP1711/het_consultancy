import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/settings_model.dart';
import '../../../services/providers.dart';

class SettingsNotifier extends StateNotifier<CompanySettingsModel> {
  final Ref _ref;

  SettingsNotifier(this._ref) : super(CompanySettingsModel()) {
    loadSettings();
  }

  void loadSettings() {
    state = _ref.read(settingsServiceProvider).getSettings();
  }

  Future<void> updateSettings(CompanySettingsModel settings) async {
    await _ref.read(settingsServiceProvider).saveSettings(settings);
    state = settings;
  }

  Future<void> toggleDarkMode(bool isEnabled) async {
    final updated = state.copyWith(isDarkMode: isEnabled);
    await updateSettings(updated);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, CompanySettingsModel>((ref) {
  return SettingsNotifier(ref);
});

final darkModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).isDarkMode;
});
