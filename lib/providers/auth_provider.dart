import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkStatus();
  }

  static const _keyAuth = 'is_authenticated';

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuth = prefs.getBool(_keyAuth) ?? false;
    state = state.copyWith(isAuthenticated: isAuth);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyAuth, true);
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } else {
      state = state.copyWith(
        isLoading: false, 
        error: 'Invalid credentials. Password must be at least 6 characters.'
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAuth, false);
    state = const AuthState(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
