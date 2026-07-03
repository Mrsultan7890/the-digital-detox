import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class UserProfileState {
  final Map<String, dynamic>? profile;
  final Map<String, dynamic>? progress;
  final List<Map<String, dynamic>> achievements;
  final bool isLoading;
  final String? error;

  UserProfileState({
    this.profile,
    this.progress,
    this.achievements = const [],
    this.isLoading = false,
    this.error,
  });

  UserProfileState copyWith({
    Map<String, dynamic>? profile,
    Map<String, dynamic>? progress,
    List<Map<String, dynamic>>? achievements,
    bool? isLoading,
    String? error,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      progress: progress ?? this.progress,
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final ApiService _apiService;

  UserProfileNotifier(this._apiService) : super(UserProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getUserProfile();
      state = state.copyWith(
        profile: response['user'] as Map<String, dynamic>?,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadProgress() async {
    try {
      final response = await _apiService.getUserProgress();
      state = state.copyWith(
        progress: response['progress'] as Map<String, dynamic>?,
      );
    } catch (e) {
      print('Error loading progress: $e');
    }
  }

  Future<void> loadAchievements() async {
    try {
      final response = await _apiService.getAchievements();
      final achievements = (response['achievements'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ?? [];
      state = state.copyWith(achievements: achievements);
    } catch (e) {
      print('Error loading achievements: $e');
    }
  }

  Future<void> loadAll() async {
    await loadProfile();
    await loadProgress();
    await loadAchievements();
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  return UserProfileNotifier(ref.watch(apiServiceProvider));
});
