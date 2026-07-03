import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

const _storage = FlutterSecureStorage();
const _tokenKey = 'auth_token';

class AuthState {
  final bool isAuthenticated;
  final String? token;
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.token,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    Map<String, dynamic>? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(AuthState()) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      _apiService.setToken(token);
      state = state.copyWith(
        isAuthenticated: true,
        token: token,
      );
      await loadUserProfile();
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.login(username, password);

      if (response['success'] == true) {
        final token = response['token'] as String;
        await _storage.write(key: _tokenKey, value: token);
        _apiService.setToken(token);

        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          user: response['user'] as Map<String, dynamic>?,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response['error'] ?? 'Login failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.register(username, email, password);

      if (response['success'] == true) {
        final token = response['token'] as String;
        await _storage.write(key: _tokenKey, value: token);
        _apiService.setToken(token);

        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          user: response['user'] as Map<String, dynamic>?,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response['error'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    state = AuthState();
  }

  Future<void> loadUserProfile() async {
    try {
      final response = await _apiService.getUserProfile();
      if (response['user'] != null) {
        state = state.copyWith(user: response['user'] as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }
}

final apiServiceProvider = Provider((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiServiceProvider));
});
