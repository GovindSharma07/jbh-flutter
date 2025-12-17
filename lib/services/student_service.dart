import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';

class StudentService {
  final Dio _dio;

  StudentService(this._dio);

  // 1. Get Student's Timetable (includes live status)
  Future<List<dynamic>> getTodaySchedule() async {
    try {
      final response = await _dio.get('/lms/student/timetable');
      return response.data['schedule'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load schedule');
    }
  }

  // 2. Get a Token to Join the Class
  Future<String> getJoinToken() async {
    try {
      final response = await _dio.post('/lms/student/join-class');
      return response.data['token'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get join token');
    }
  }
}

// --- PROVIDER ---
final studentServiceProvider = Provider<StudentService>((ref) {
  final dio = ref.watch(dioProvider(ref));
  return StudentService(dio);
});