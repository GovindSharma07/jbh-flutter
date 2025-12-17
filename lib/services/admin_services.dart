import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Models/user_model.dart';
import 'package:jbh_academy/services/api_service.dart';

import '../Models/course_model.dart';

// --- 1. SINGLE SOURCE OF TRUTH FOR ADMIN SERVICE ---
final adminServicesProvider = Provider<AdminService>((ref) {
  final dio = ref.watch(dioProvider(ref));
  return AdminService(dio);
});

// --- 2. HELPER PROVIDERS ---

// Helper to get only Instructors/Admins
final allInstructorsProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final service = ref.watch(adminServicesProvider);
  final users = await service.getAllUsers();
  // Filter locally for now
  return users.where((u) => u.role == 'instructor' || u.role == 'admin').toList();
});

// Helper to fetch all courses
final allCoursesProvider = FutureProvider.autoDispose<List<Course>>((ref) async {
  final service = ref.watch(adminServicesProvider);
  return service.getAllCourses();
});

class AdminService {
  final Dio _dio;

  AdminService(this._dio);

  // --- User Management ---

  Future<List<User>> getAllUsers() async {
    try {
      final response = await _dio.get('/admin/users');
      return (response.data as List).map((e) => User.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch users';
    }
  }

  Future<void> createUser({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    try {
      await _dio.post(
        '/admin/users',
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
        },
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to create user';
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _dio.delete('/admin/users/$userId');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to delete user';
    }
  }

  Future<void> blockUser(int userId) async {
    try {
      await _dio.patch('/admin/users/$userId/block');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to block user';
    }
  }

  // --- Course Management ---

  Future<List<Course>> getAllCourses() async {
    try {
      final response = await _dio.get('/courses');
      return (response.data as List).map((e) => Course.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch courses: $e');
    }
  }

  // --- RESTORED MISSING METHOD ---
  Future<Course> getCourseDetail(int courseId) async {
    try {
      final response = await _dio.get('/courses/$courseId');
      return Course.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load course detail: $e');
    }
  }
  // ------------------------------

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

  Future<void> toggleCoursePublishStatus(int courseId, bool isPublished) async {
    try {
      await _dio.patch(
        '/courses/$courseId/publish',
        data: {'is_published': isPublished},
      );
    } catch (e) {
      throw Exception('Failed to update publish status: $e');
    }
  }

  // --- Module & Lesson Management ---

  Future<void> addModule(int courseId, String title) async {
    try {
      await _dio.post(
        '/courses/$courseId/modules',
        data: {'title': title, 'order': 0},
      );
    } catch (e) {
      throw Exception('Failed to add module: $e');
    }
  }

  Future<void> deleteModule(int moduleId) async {
    try {
      await _dio.delete('/modules/$moduleId');
    } catch (e) {
      throw Exception('Failed to delete module: $e');
    }
  }

  Future<void> reorderModules(int courseId, List<Map<String, dynamic>> updates) async {
    try {
      await _dio.put('/courses/$courseId/modules/reorder', data: {'updates': updates});
    } catch (e) {
      throw Exception('Failed to reorder modules: $e');
    }
  }

  Future<void> addLesson({
    required int moduleId,
    required String title,
    required String contentUrl,
    required String contentType,
    bool isFree = false,
  }) async {
    try {
      await _dio.post(
        '/lessons',
        data: {
          'moduleId': moduleId,
          'title': title,
          'contentUrl': contentUrl,
          'contentType': contentType,
          'isFree': isFree,
        },
      );
    } catch (e) {
      throw Exception('Failed to add lesson: $e');
    }
  }

  Future<void> deleteLesson(int lessonId) async {
    try {
      await _dio.delete('/lessons/$lessonId');
    } catch (e) {
      throw Exception('Failed to delete lesson: $e');
    }
  }

  Future<void> reorderLessons(int moduleId, List<Map<String, dynamic>> updates) async {
    try {
      await _dio.put('/modules/$moduleId/lessons/reorder', data: {'updates': updates});
    } catch (e) {
      throw Exception('Failed to reorder lessons: $e');
    }
  }

  // --- Storage / Uploads ---

  Future<String> uploadCourseImage(PlatformFile file) async {
    try {
      final fileName = file.name;
      final extension = file.extension ?? 'png';
      final contentType = 'image/$extension';

      final response = await _dio.post(
        '/admin/upload-url',
        data: {'fileName': fileName, 'fileType': contentType, 'folder': 'courses'},
      );

      final uploadUrl = response.data['uploadUrl'];
      final publicUrl = response.data['publicUrl'];

      final s3Dio = Dio();

      if (kIsWeb || file.bytes != null) {
        await s3Dio.put(
          uploadUrl,
          data: file.bytes,
          options: Options(headers: {'Content-Type': contentType, 'Content-Length': file.size}),
        );
      } else {
        final ioFile = File(file.path!);
        await s3Dio.put(
          uploadUrl,
          data: ioFile.openRead(),
          options: Options(headers: {'Content-Type': contentType, 'Content-Length': await ioFile.length()}),
        );
      }
      return publicUrl;
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  Future<String> uploadLessonContent(PlatformFile file, {required Function(double progress) onProgress}) async {
    try {
      final fileName = file.name;
      final extension = file.extension ?? 'mp4';
      String contentType = ['pdf'].contains(extension.toLowerCase()) ? 'application/pdf' : 'video/$extension';

      final response = await _dio.post(
        '/admin/upload-url',
        data: {'fileName': fileName, 'fileType': contentType, 'folder': 'lessons'},
      );

      final uploadUrl = response.data['uploadUrl'];
      final publicUrl = response.data['publicUrl'];

      final s3Dio = Dio();
      final data = kIsWeb ? file.bytes : File(file.path!).openRead();
      final length = kIsWeb ? file.size : await File(file.path!).length();

      await s3Dio.put(
        uploadUrl,
        data: data,
        options: Options(headers: {'Content-Type': contentType, 'Content-Length': length}),
        onSendProgress: (sent, total) => onProgress(sent / total),
      );

      return publicUrl;
    } catch (e) {
      throw Exception('Lesson upload failed: $e');
    }
  }

  // --- Timetable Management ---

  Future<void> createScheduleSlot(Map<String, dynamic> data) async {
    try {
      await _dio.post(
        '/admin/timetable',
        data: data,
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to create schedule slot';
    }
  }

  Future<void> deleteScheduleSlot(int scheduleId) async {
    try {
      await _dio.delete('/admin/timetable/$scheduleId');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to delete schedule slot';
    }
  }
}