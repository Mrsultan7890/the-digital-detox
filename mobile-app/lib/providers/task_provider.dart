import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class TaskState {
  final List<Map<String, dynamic>> categories;
  final Map<String, dynamic>? currentTask;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? submitResult;

  TaskState({
    this.categories = const [],
    this.currentTask,
    this.isLoading = false,
    this.error,
    this.submitResult,
  });

  TaskState copyWith({
    List<Map<String, dynamic>>? categories,
    Map<String, dynamic>? currentTask,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? submitResult,
  }) {
    return TaskState(
      categories: categories ?? this.categories,
      currentTask: currentTask ?? this.currentTask,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      submitResult: submitResult,
    );
  }
}

class TaskNotifier extends StateNotifier<TaskState> {
  final ApiService _apiService;

  TaskNotifier(this._apiService) : super(TaskState());

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getCategories();
      final categories = (response['categories'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadTask(String taskId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final task = await _apiService.getTask(taskId);
      state = state.copyWith(
        currentTask: task,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> submitAnswer(String taskId, String answer, {int? timeTaken}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _apiService.submitAnswer(taskId, answer);
      state = state.copyWith(
        submitResult: result,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> getHint(String taskId, int hintLevel) async {
    try {
      return await _apiService.getHint(taskId, hintLevel);
    } catch (e) {
      throw Exception('Failed to get hint: $e');
    }
  }

  void clearSubmitResult() {
    state = state.copyWith(submitResult: null);
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(ref.watch(apiServiceProvider));
});
