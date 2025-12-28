import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthProviderNotifier extends StateNotifier<AuthState> {
  AuthProviderNotifier() : super(const AuthState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Implement actual login logic with Firebase/Auth service
      await Future.delayed(const Duration(seconds: 2)); // Mock API call
      
      // If successful
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userEmail: email,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
  
  Future<void> logout() async {
    state = const AuthState();
  }
}

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? userEmail;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.userEmail,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? userEmail,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userEmail: userEmail ?? this.userEmail,
      error: error ?? this.error,
    );
  }
}

final authProviderNotifier = StateNotifierProvider<AuthProviderNotifier, AuthState>(
  (ref) => AuthProviderNotifier(),
);