import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  /// Use 10.0.2.2 for Android emulator, localhost for iOS simulator / macOS
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    // iOS simulator + macOS desktop
    return 'http://localhost:8000/api/v1';
  }

  /// Fetch all published quizzes from the teacher backend.
  static Future<List<Map<String, dynamic>>> fetchQuizzes() async {
    final url = Uri.parse('$baseUrl/quizzes');
    final response = await http.get(url, headers: {'Accept': 'application/json'});

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
    final response = await http.get(url, headers: {'Accept': 'application/json'});

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
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
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
}
