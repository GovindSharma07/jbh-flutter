import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Models/user_model.dart';
import 'package:jbh_academy/services/api_service.dart';

import '../Models/course_model.dart';

final adminServiceProvider = Provider<AdminService>((ref) {
  final dio = ref.watch(dioProvider(ref));
  return AdminService(dio);
});

class AdminService {
  final Dio _dio;
  AdminService(this._dio);

  // --- User Management ---

  // Get all users (with optional role filter)
  Future<List<User>> getAllUsers() async {
    try {
      // Backend should implement: GET /admin/users
      final response = await _dio.get('/admin/users');
      return (response.data as List).map((e) => User.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch users';
    }
  }

  // Create a specific user (Admin/Instructor)
  Future<void> createUser({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String role, // 'admin', 'instructor', 'student'
  }) async {
    try {
      // Backend should implement: POST /admin/users
      await _dio.post('/admin/users', data: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role,
      });
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to create user';
    }
  }

  // Delete User
  Future<void> deleteUser(int userId) async {
    try {
      await _dio.delete('/admin/users/$userId');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to delete user';
    }
  }

  // Block User (Placeholder for future backend implementation)
  Future<void> blockUser(int userId) async {
    try {
      // Assuming backend has PATCH /admin/users/:id/block
      await _dio.patch('/admin/users/$userId/block');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to block user';
    }
  }

  Future<List<Course>> getAllCourses() async {
    try {
      final response = await _dio.get('/courses');
      return (response.data as List)
          .map((e) => Course.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch courses: $e');
    }
  }

  Future<void> createCourse(Course course) async {
    try {
      await _dio.post('/courses', data: course.toJson());
    } catch (e) {
      throw Exception('Failed to create course: $e');
    }
  }

  Future<void> updateCourse(int id, Course course) async {
    try {
      await _dio.put('/courses/$id', data: course.toJson());
    } catch (e) {
      throw Exception('Failed to update course: $e');
    }
  }

  Future<void> deleteCourse(int id) async {
    try {
      await _dio.delete('/courses/$id');
    } catch (e) {
      throw Exception('Failed to delete course: $e');
    }
  }
}

// Provider
final adminServicesProvider = Provider<AdminService>((ref) {
  final dio = ref.watch(dioProvider(ref));
  return AdminService(dio);
});

// Future Provider to Fetch Courses easily in the UI
final allCoursesProvider = FutureProvider.autoDispose<List<Course>>((ref) async {
  final service = ref.watch(adminServicesProvider);
  return service.getAllCourses();
});