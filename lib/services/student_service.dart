import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';

class StudentService {
  final Dio _dio;

  StudentService(this._dio);

  // 1. Get Student's Timetable
  Future<List<dynamic>> getTodaySchedule() async {
    try {
      final response = await _dio.get('/lms/student/timetable');
      return response.data['schedule'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load schedule');
    }
  }

  // 2. Join Live Class (Marks Attendance + Gets Token)
  // We send the liveLectureId so the backend knows which class to mark 'Present' for.
  Future<Map<String, dynamic>> joinLiveLecture(int liveLectureId) async {
    try {
      final response = await _dio.post(
        '/lms/student/join-class',
        data: {
          'liveLectureId': liveLectureId,
        },
      );
      // Returns: { success: true, token, roomId, meetingUrl }
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to join class');
    }
  }

  // 3. Get Lesson Details (For Watching Recordings)
  Future<Map<String, dynamic>> getLessonDetails(int lessonId) async {
    try {
      final response = await _dio.get('/lms/student/lesson/$lessonId');
      // Returns: { success: true, lesson: { ... content_url, content_type ... } }
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load lesson details');
    }
  }

  Future<List<dynamic>> getRecordedLectures({String? courseId, String? dateFilter}) async {
    try {
      // Backend Endpoint: You need to implement GET /lms/student/recordings
      // For now, let's assume this returns a list of lessons that are 'video' type
      final response = await _dio.get(
          '/lms/student/recordings',
          queryParameters: {
            if (courseId != null && courseId != 'Sub') 'courseId': courseId,
            if (dateFilter != null && dateFilter != 'Date') 'filter': dateFilter,
          }
      );
      return response.data['recordings'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load recordings');
    }
  }

  Future<List<dynamic>> getAttendance() async {
    try {
      final response = await _dio.get('/lms/student/attendance');
      // Expecting backend to return { success: true, attendance: [...] }
      return response.data['attendance'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load attendance');
    }
  }

  Future<List<dynamic>> getWeeklyTimetable() async {
    try {
      final response = await _dio.get('/lms/student/timetable/weekly');
      return response.data['schedule'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load timetable');
    }
  }
}

// --- PROVIDER ---
final studentServiceProvider = Provider<StudentService>((ref) {
  final dio = ref.watch(dioProvider);
  return StudentService(dio);
});