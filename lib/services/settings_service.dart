import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_strings.dart';
import '../models/settings_model.dart';
import 'supabase_service.dart';

class SettingsService {
  final Box _box = Hive.box(AppStrings.settingsBox);

  CompanySettingsModel getSettings() {
    final value = _box.get('company_settings');
    if (value != null) {
      try {
        final decoded = jsonDecode(value as String);
        return CompanySettingsModel.fromJson(decoded as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error parsing settings: $e');
      }
    }
    return CompanySettingsModel(); // Returns defaults
  }

  Future<void> saveSettings(CompanySettingsModel settings) async {
    final jsonStr = jsonEncode(settings.toJson());
    await _box.put('company_settings', jsonStr);

    final sb = SupabaseService.client;
    if (sb != null) {
      try {
        final user = sb.auth.currentUser;
        if (user != null) {
          await sb.from('settings').upsert({
            'user_id': user.id,
            ...settings.toJson(),
          });
        }
      } catch (e) {
        debugPrint('Supabase settings sync error: $e');
      }
    }
  }
}
