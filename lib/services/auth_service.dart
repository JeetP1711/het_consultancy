import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_strings.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  final Box _authBox = Hive.box(AppStrings.authBox);

  // Hardcoded demo accounts mapping
  static const Map<String, Map<String, dynamic>> _demoAccounts = {
    'admin@het.com': {
      'id': 'demo-admin-id',
      'email': 'admin@het.com',
      'name': 'HET Admin',
      'role': 'admin',
      'password': 'Admin123',
    },
    'sales@het.com': {
      'id': 'demo-sales-id',
      'email': 'sales@het.com',
      'name': 'HET Sales Executive',
      'role': 'sales',
      'password': 'Sales123',
    },
    'engineer@het.com': {
      'id': 'demo-engineer-id',
      'email': 'engineer@het.com',
      'name': 'HET Field Engineer',
      'role': 'engineer',
      'password': 'Engineer123',
    },
    'accounts@het.com': {
      'id': 'demo-accounts-id',
      'email': 'accounts@het.com',
      'name': 'HET Accounts Manager',
      'role': 'accounts',
      'password': 'Accounts123',
    },
  };

  UserModel? get currentUser {
    final userJson = _authBox.get('current_user');
    if (userJson != null) {
      try {
        final decoded = jsonDecode(userJson as String);
        return UserModel.fromJson(decoded as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error parsing stored user: $e');
      }
    }
    return null;
  }

  Future<UserModel> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    // Check demo accounts first for easy offline access and testing
    if (_demoAccounts.containsKey(cleanEmail)) {
      final demo = _demoAccounts[cleanEmail]!;
      if (demo['password'] == cleanPassword) {
        final user = UserModel(
          id: demo['id'] as String,
          email: demo['email'] as String,
          name: demo['name'] as String,
          role: UserRole.fromString(demo['role'] as String),
          createdAt: DateTime.now(),
        );
        await _saveUserSession(user);
        return user;
      } else {
        throw Exception('Invalid password for demo account.');
      }
    }

    // Try Supabase auth if configured
    final client = SupabaseService.client;
    if (client != null) {
      try {
        final response = await client.auth.signInWithPassword(
          email: cleanEmail,
          password: cleanPassword,
        );
        
        if (response.user != null) {
          // Query user role from the 'users' table
          final userData = await client
              .from('users')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();

          final role = userData != null ? (userData['role'] as String? ?? 'sales') : 'sales';
          final name = userData != null ? (userData['name'] as String? ?? cleanEmail.split('@').first) : cleanEmail.split('@').first;

          final user = UserModel(
            id: response.user!.id,
            email: cleanEmail,
            name: name,
            role: UserRole.fromString(role),
            createdAt: DateTime.now(),
          );
          
          await _saveUserSession(user);
          return user;
        } else {
          throw Exception('Authentication failed');
        }
      } catch (e) {
        throw Exception('Login error: ${e.toString()}');
      }
    }

    throw Exception('User account not found or offline mode active.');
  }

  Future<void> logout() async {
    await _authBox.delete('current_user');
    final client = SupabaseService.client;
    if (client != null) {
      try {
        await client.auth.signOut();
      } catch (e) {
        debugPrint('Supabase signout error: $e');
      }
    }
  }

  Future<void> _saveUserSession(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _authBox.put('current_user', userJson);
  }
}
