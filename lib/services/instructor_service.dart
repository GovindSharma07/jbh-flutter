import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart'; // Import to access dioProvider

class InstructorService {
  final Dio _dio;

  InstructorService(this._dio);

  // 1. Get the Instructor's Schedule
  Future<Map<String, dynamic>> getInstructorSchedule() async {
    try {
      // No need for baseUrl or headers - Dio handles them!
      final response = await _dio.get('/lms/instructor/schedule');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load schedule');
    }
  }

  // 2. Start a Live Class
  Future<Map<String, dynamic>> startLiveClass({
    required String scheduleId,
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
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to start class');
    }
  }
}

// --- PROVIDER DEFINITION ---
// This allows the UI to ask for "instructorServiceProvider" and get an instance with Dio ready.
final instructorServiceProvider = Provider<InstructorService>((ref) {
  // We pass 'ref' to dioProvider because it is defined as a .family provider in your api_service.dart
  final dio = ref.watch(dioProvider(ref));
  return InstructorService(dio);
});