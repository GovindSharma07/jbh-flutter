import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';

class InstructorService {
  final Dio _dio;

  InstructorService(this._dio);

  // 1. Get the Instructor's Schedule
  Future<List<dynamic>> getInstructorSchedule() async {
    try {
      final response = await _dio.get('/lms/instructor/schedule');
      return response.data['schedule'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load schedule');
    }
  }

  // 2. Start a Live Class
  // This triggers the backend to create the 'live_lectures' entry in DB
  Future<Map<String, dynamic>> startLiveClass({
    required int scheduleId, // Changed to int to match backend expectation
    required String topic,
  }) async {
    try {
      final response = await _dio.post(
        '/lms/instructor/start-class',
        data: {
          'scheduleId': scheduleId,
          'topic': topic,
        },
      );
      // Returns: { success: true, roomId, token, liveLectureId }
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to start class');
    }
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _dio.get('/lms/instructor/dashboard');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load dashboard: $e');
    }
  }
}

// --- PROVIDER ---
final instructorServiceProvider = Provider<InstructorService>((ref) {
  final dio = ref.watch(dioProvider);
  return InstructorService(dio);
});