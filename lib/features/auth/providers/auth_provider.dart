import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_model.dart';
import '../../../services/providers.dart';

class AuthNotifier extends StateNotifier<UserModel?> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(null) {
    _loadSession();
  }

  void _loadSession() {
    state = _ref.read(authServiceProvider).currentUser;
  }

  Future<void> login(String email, String password) async {
    final user = await _ref.read(authServiceProvider).login(email, password);
    state = user;
  }

  Future<void> logout() async {
    await _ref.read(authServiceProvider).logout();
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(ref);
});

final userRoleProvider = Provider<UserRole?>((ref) {
  final user = ref.watch(authProvider);
  return user?.role;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) != null;
});
