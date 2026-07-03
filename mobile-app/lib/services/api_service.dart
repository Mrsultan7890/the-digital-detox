import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Auth APIs
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  // Task APIs
  Future<Map<String, dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tasks/categories'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getTasksByCategory(int categoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tasks/category/$categoryId'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getTask(String taskId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tasks/$taskId'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> submitAnswer(String taskId, String answer, {int? timeTaken}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks/$taskId/submit'),
      headers: _headers,
      body: jsonEncode({'answer': answer, 'timeTaken': timeTaken}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getHint(String taskId, int hintLevel) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks/$taskId/hint'),
      headers: _headers,
      body: jsonEncode({'hintLevel': hintLevel}),
    );
    return jsonDecode(response.body);
  }

  // User APIs
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/profile'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getUserProgress() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/progress'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // Leaderboard APIs
  Future<Map<String, dynamic>> getLeaderboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/leaderboard/global'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }
}
