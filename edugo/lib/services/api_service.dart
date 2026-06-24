import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String? _resolvedBaseUrl;
  static String? _authToken;
  static Map<String, dynamic>? currentUser;

  static String get baseUrl {
    return _resolvedBaseUrl ?? 'https://ai-pipeline-u7tf.onrender.com/api/v1';
  }

  static Future<String> resolveBaseUrl() async {
    if (_resolvedBaseUrl != null) return _resolvedBaseUrl!;

    if (kIsWeb) {
      _resolvedBaseUrl = 'http://127.0.0.1:8000/api/v1';
      return _resolvedBaseUrl!;
    }

    // Try fast local candidates first (instant on same network)
    final List<Map<String, dynamic>> candidates = [
      // Android Emulator loopback
      if (Platform.isAndroid)
        {'url': 'http://10.0.2.2:8000/api/v1', 'timeout': 1000},
      // iOS Simulator / macOS desktop localhost
      {'url': 'http://127.0.0.1:8000/api/v1', 'timeout': 1000},
      {'url': 'http://localhost:8000/api/v1', 'timeout': 1000},
      // Physical device LAN IP — developer's machine on same WiFi
      {'url': 'http://10.3.8.131:8000/api/v1', 'timeout': 1500},
      // Cloud backend — last resort (Render free tier may have cold start delay)
      {'url': 'https://ai-pipeline-u7tf.onrender.com/api/v1', 'timeout': 12000},
    ];

    for (final candidate in candidates) {
      final urlStr = candidate['url'] as String;
      final timeoutMs = candidate['timeout'] as int;
      try {
        final url = Uri.parse('$urlStr/subjects');
        final response = await http
            .get(url, headers: {'Accept': 'application/json'})
            .timeout(Duration(milliseconds: timeoutMs));
        if (response.statusCode == 200) {
          _resolvedBaseUrl = urlStr;
          debugPrint('ApiService: Dynamic URL selected: $_resolvedBaseUrl');
          return _resolvedBaseUrl!;
        }
      } catch (e) {
        debugPrint('ApiService: Try candidate $urlStr failed: $e');
      }
    }

    // Default fallback — cloud backend
    _resolvedBaseUrl = 'https://ai-pipeline-u7tf.onrender.com/api/v1';
    debugPrint('ApiService: Fallback to $_resolvedBaseUrl');
    return _resolvedBaseUrl!;
  }

  /// Build headers that include the auth token when available.
  static Map<String, String> _authHeaders({bool includeContentType = false}) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  /// Clear auth state and force re-resolve on next login.
  static void logout() {
    _authToken = null;
    _resolvedBaseUrl = null;
    currentUser = null;
  }

  /// Send a message (announcement) to the teacher.
  static Future<Map<String, dynamic>> sendMessage({
    required String title,
    required String body,
  }) async {
    final url = Uri.parse('$baseUrl/announcements');
    final response = await http.post(
      url,
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({
        'title': title,
        'body': body,
        'priority': 'Normal',
        'target_grades': [],
        'target_sections': [],
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Nachricht konnte nicht gesendet werden');
    }
  }

  /// Log in with email and password. Stores the JWT token for future requests.
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _authToken = data['token'] as String?;
      currentUser = data['user'] as Map<String, dynamic>?;
      return data;
    } else {
      final body = jsonDecode(response.body);
      final message = body['detail'] ?? body['message'] ?? 'Login fehlgeschlagen';
      throw Exception(message);
    }
  }

  /// Register a new account. Stores the JWT token for future requests.
  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name, {
    String? grade,
    String? section,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'role': 'student',
        'grade': grade,
        'section': section,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _authToken = data['token'] as String?;
      currentUser = data['user'] as Map<String, dynamic>?;
      return data;
    } else {
      final body = jsonDecode(response.body);
      final message = body['detail'] ?? body['message'] ?? 'Registrierung fehlgeschlagen';
      throw Exception(message);
    }
  }

  /// Fetch all published quizzes from the teacher backend.
  static Future<List<Map<String, dynamic>>> fetchQuizzes() async {
    final grade = currentUser?['grade'] as String?;
    final section = currentUser?['section'] as String?;

    final Map<String, String> params = {};
    if (grade != null) params['grade'] = grade;
    if (section != null) params['section'] = section;

    final uri = Uri.parse('$baseUrl/quizzes').replace(queryParameters: params);
    final response = await http.get(uri, headers: _authHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch quizzes: ${response.statusCode}');
    }
  }

  /// Fetch all subjects and level trees from the teacher backend.
  static Future<List<Map<String, dynamic>>> fetchSubjects() async {
    final url = Uri.parse('$baseUrl/subjects');
    final response = await http.get(url, headers: _authHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch subjects: ${response.statusCode}');
    }
  }

  /// Submit quiz results back to the backend for grading.
  /// Returns the graded result (score, correct count, etc).
  static Future<Map<String, dynamic>> submitResult({
    required int quizId,
    required String studentName,
    required List<Map<String, dynamic>> answers,
  }) async {
    final url = Uri.parse('$baseUrl/quiz-results');
    final response = await http.post(
      url,
      headers: _authHeaders(includeContentType: true),
      body: jsonEncode({
        'quiz_id': quizId,
        'student_name': studentName,
        'answers': answers,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit result: ${response.statusCode}');
    }
  }

  /// Fetch all announcements sent by the teacher.
  static Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
    final url = Uri.parse('$baseUrl/announcements');
    final response = await http.get(url, headers: _authHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch announcements: ${response.statusCode}');
    }
  }
}
