import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Models/course_model.dart';
import 'api_service.dart';

class CourseService {
  final Dio _dio;

  CourseService(this._dio);

  // 1. Fetch All Courses (For Feed)
  Future<List<Course>> getAllCourses() async {
    try {
      final response = await _dio.get('/courses');
      return (response.data as List).map((e) => Course.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }

  // 2. Fetch My Enrolled Courses
  Future<List<Course>> getMyCourses() async {
    try {
      final response = await _dio.get('/my-courses');
      // The backend returns a list of objects with a "course" property inside the enrollment
      // or directly the course list depending on your backend logic.
      // Based on your backend code: "EnrollmentService.getMyCourses" returns the course details directly.
      return (response.data as List).map((e) => Course.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load my courses: $e');
    }
  }

  // 3. Enroll in a Course
  Future<void> enrollInCourse(int courseId) async {
    try {
      await _dio.post('/courses/$courseId/enroll');
    } on DioException catch (e) {
      // Extract backend error message if available
      throw Exception(e.response?.data['message'] ?? 'Enrollment failed');
    }
  }

  // --- NEW PAYMENT METHODS ---

  // 1. Create Razorpay Order
  Future<Map<String, dynamic>> createPaymentOrder(int courseId) async {
    try {
      final response = await _dio.post('/payments/create-order', data: {
        'courseId': courseId,
      });
      return response.data; // Returns { keyId, order: { id, amount, ... } }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create order');
    }
  }

  // 2. Verify Payment & Enroll
  Future<void> verifyPayment(Map<String, dynamic> data) async {
    try {
      await _dio.post('/payments/verify', data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Payment verification failed');
    }
  }

  // 3. Free Enrollment (Keep for free courses)
  Future<void> enrollFree(int courseId) async {
    try {
      await _dio.post('/courses/$courseId/enroll');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Enrollment failed');
    }
  }
}

// --- PROVIDERS ---

final courseServiceProvider = Provider<CourseService>((ref) {
  final dio = ref.watch(dioProvider(ref));
  return CourseService(dio);
});

// Provider to fetch ALL courses (Auto-refreshing)
final courseListProvider = FutureProvider.autoDispose<List<Course>>((ref) async {
  final service = ref.watch(courseServiceProvider);
  return service.getAllCourses();
});

// Provider to fetch MY courses
final myCoursesProvider = FutureProvider.autoDispose<List<Course>>((ref) async {
  final service = ref.watch(courseServiceProvider);
  return service.getMyCourses();
});