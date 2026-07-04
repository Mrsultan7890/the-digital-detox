import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // VMware server IP - apna actual IP yahan daalo
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.217:8080/api',
  );

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // Response parse karo - error ho ya success
  Map<String, dynamic> _parse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        // FastAPI error format: {"detail": "..."}
        final detail = body['detail'] ?? body['error'] ?? 'Something went wrong';
        return {'success': false, 'error': detail};
      }
    } catch (e) {
      return {'success': false, 'error': 'Server error (${response.statusCode})'};
    }
  }

  // Auth
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({'username': username, 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      return _parse(response);
    } catch (e) {
      return {'success': false, 'error': 'Cannot connect to server. Check your connection.'};
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      return _parse(response);
    } catch (e) {
      return {'success': false, 'error': 'Cannot connect to server. Check your connection.'};
    }
  }

  // Tasks
  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/categories'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      return _parse(response);
    } catch (e) {
      return {'categories': []};
    }
  }

  Future<Map<String, dynamic>> getTasksByCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/category/$categoryId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      return _parse(response);
    } catch (e) {
      return {'tasks': []};
    }
  }

  Future<Map<String, dynamic>> getTask(String taskId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/$taskId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      return _parse(response);
    } catch (e) {
      return {'error': 'Failed to load task'};
    }
  }

  Future<Map<String, dynamic>> submitAnswer(String taskId, String answer, {int? timeTaken}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks/$taskId/submit'),
        headers: _headers,
        body: jsonEncode({'answer': answer, 'timeTaken': timeTaken}),
      ).timeout(const Duration(seconds: 10));
      return _parse(response);
    } catch (e) {
      return {'correct': false, 'error': 'Failed to submit answer'};
    }
  }

  Future<Map<String, dynamic>> getHint(String taskId, int hintLevel) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks/$taskId/hint'),
        headers: _headers,
        body: jsonEncode({'hintLevel': hintLevel}),
      ).timeout(const Duration(seconds: 10));
      return _parse(response);
    } catch (e) {
      return {'error': 'Failed to get hint'};
    }
  }

  Future<Map<String, dynamic>> getDailyChallenge() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/daily'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      return _parse(response);
    } catch (e) {
      return {'challenge': null};
    }
  }

  // User
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      return _parse(response);
    } catch (e) {
      return {'user': null};
    }
  }

  Future<Map<String, dynamic>> getUserProgress() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/progress'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      return _parse(response);
    } catch (e) {
      return {'progress': null};
    }
  }

  Future<Map<String, dynamic>> getAchievements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/achievements'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      return _parse(response);
    } catch (e) {
      return {'achievements': []};
    }
  }

  // Leaderboard
  Future<Map<String, dynamic>> getLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/global'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      return _parse(response);
    } catch (e) {
      return {'leaderboard': []};
    }
  }
}
