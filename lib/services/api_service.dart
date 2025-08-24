import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mero_vidya_library/models/subject_model.dart';
import '../models/class_model.dart';
import '../models/chapter_model.dart';
import '../models/video_model.dart';

class ApiServices {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/merolibrary';

  // =============================
  //  1. Fetch all classes
  // =============================
  static Future<List<SchoolClass>> fetchClasses() async {
    final response = await http.get(Uri.parse('$baseUrl/classurls/'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => SchoolClass.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load classes from the API.');
    }
  }

  // =============================
  //  2. Fetch subjects by class ID
  // =============================
  static Future<List<ClassSubject>> fetchSubjectsByClass(int classId) async {
    final url = Uri.parse(
      '$baseUrl/subjecturls/?class_id=$classId&format=json',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ClassSubject.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load subjects.');
    }
  }

  // =============================
  //  3. Fetch chapters by subject ID
  // =============================
  static Future<List<SubjectChapter>> fetchChaptersBySubject(
    int subjectId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/chapterurls/?subject_id=$subjectId&format=json',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => SubjectChapter.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chapters.');
    }
  }

  // =============================
  //  4. Fetch videos by chapter ID
  // =============================
  static Future<List<ChapterVideo>> fetchVideosByChapter(int chapterId) async {
    final url = Uri.parse(
      '$baseUrl/videourls/?chapter_id=$chapterId&format=json',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ChapterVideo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load videos.');
    }
  }

  // =============================
  //  5. Fetch saved video progress
  // =============================
  static Future<Map<int, double>> fetchVideoProgress(
    int userId,
    int chapterId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/video-progress/?user_id=$userId&chapter_id=$chapterId',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return {
        for (var item in data) item['video_id']: item['progress'].toDouble(),
      };
    } else {
      throw Exception('Failed to fetch video progress.');
    }
  }

  // =============================
  //  6. Save/Update video progress
  // =============================
  static Future<void> saveVideoProgress(
    int userId,
    int videoId,
    double progress,
  ) async {
    final url = Uri.parse('$baseUrl/video-progress/');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "video_id": videoId,
        "progress": progress,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save video progress.');
    }
  }

  // =============================
  //  DUMMY SIGNUP (for UI design)
  // =============================
  static Future<Map<String, dynamic>> registerUser(
    String username,
    String email,
    String password,
  ) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));

    // Dummy response
    return {
      "success": true,
      "data": {
        "id": 1,
        "username": username,
        "email": email,
        "token": "dummy_signup_token_123",
      },
    };
  }

  // =============================
  //  DUMMY LOGIN (for UI design)
  // =============================
  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));

    // Dummy response
    return {
      "success": true,
      "data": {
        "id": 1,
        "username": "DummyUser",
        "email": email,
        "token": "dummy_login_token_456",
      },
    };
  }
}
