import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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
      return (response.data as List).map((e) => Course.fromJson(e)).toList();
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

  Future<void> addModule(int courseId, String title) async {
    try {
      await _dio.post(
        '/courses/$courseId/modules',
        data: {
          'title': title,
          'order': 0, // Backend handles order usually, or pass it if needed
        },
      );
    } catch (e) {
      throw Exception('Failed to add module: $e');
    }
  }

  // --- NEW: Upload Logic using File Picker ---
  Future<String> uploadCourseImage(PlatformFile file) async {
    try {
      final fileName = file.name;
      final extension = file.extension ?? 'png'; // Fallback
      final contentType = 'image/$extension';

      // 1. Get Presigned URL from Backend
      final response = await _dio.post(
        '/admin/upload-url',
        data: {
          'fileName': fileName,
          'fileType': contentType,
          'folder': 'courses',
        },
      );

      final uploadUrl = response.data['uploadUrl'];
      final publicUrl = response.data['publicUrl'];

      // 2. Upload Content to B2/S3
      // We use a fresh Dio instance to avoid attaching our API Tokens to the S3 request
      final s3Dio = Dio();

      if (kIsWeb || file.bytes != null) {
        // WEB: Upload Raw Bytes
        await s3Dio.put(
          uploadUrl,
          data: file.bytes, // Uint8List directly
          options: Options(
            headers: {'Content-Type': contentType, 'Content-Length': file.size},
          ),
        );
      } else {
        // MOBILE: Upload from File Path
        final ioFile = File(file.path!);
        await s3Dio.put(
          uploadUrl,
          data: ioFile.openRead(), // Stream for better memory usage on mobile
          options: Options(
            headers: {
              'Content-Type': contentType,
              'Content-Length': await ioFile.length(),
            },
          ),
        );
      }

      return publicUrl;
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  // NEW: Upload Lesson Content (Video/PDF) with Progress
  Future<String> uploadLessonContent(
    PlatformFile file, {
    required Function(double progress) onProgress,
  }) async {
    try {
      final fileName = file.name;
      final extension = file.extension ?? 'mp4'; // Fallback

      // Determine correct mime type
      String contentType;
      if (['pdf'].contains(extension.toLowerCase())) {
        contentType = 'application/pdf';
      } else {
        contentType = 'video/$extension';
      }

      // 1. Get Presigned URL for 'lessons' folder
      final response = await _dio.post(
        '/admin/upload-url',
        data: {
          'fileName': fileName,
          'fileType': contentType,
          'folder': 'lessons', // Organize content here
        },
      );

      final uploadUrl = response.data['uploadUrl'];
      final publicUrl = response.data['publicUrl'];

      // 2. Upload with Progress Tracking
      final s3Dio = Dio(); // Fresh instance

      final data = kIsWeb ? file.bytes : File(file.path!).openRead();
      final length = kIsWeb ? file.size : await File(file.path!).length();

      await s3Dio.put(
        uploadUrl,
        data: data,
        options: Options(
          headers: {'Content-Type': contentType, 'Content-Length': length},
        ),
        onSendProgress: (sent, total) {
          // Calculate percentage (0.0 to 1.0)
          final progress = sent / total;
          onProgress(progress);
        },
      );

      return publicUrl;
    } catch (e) {
      throw Exception('Lesson upload failed: $e');
    }
  }

  // Fetch Course Detail (Reuse existing endpoint but strictly for admin viewing)
  Future<Course> getCourseDetail(int courseId) async {
    try {
      final response = await _dio.get('/courses/$courseId');
      return Course.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load course detail: $e');
    }
  }

  Future<void> deleteModule(int moduleId) async {
    try {
      await _dio.delete('/modules/$moduleId');
    } catch (e) {
      throw Exception('Failed to delete module: $e');
    }
  }

  // NEW: Delete Lesson
  Future<void> deleteLesson(int lessonId) async {
    try {
      await _dio.delete('/lessons/$lessonId');
    } catch (e) {
      throw Exception('Failed to delete lesson: $e');
    }
  }

  // Updated addLesson to accept contentType
  Future<void> addLesson({
    required int moduleId,
    required String title,
    required String contentUrl,
    required String contentType, // 'video' or 'pdf'
    bool isFree = false,
  }) async {
    try {
      await _dio.post(
        '/lessons',
        data: {
          'moduleId': moduleId,
          'title': title,
          'contentUrl': contentUrl,
          'contentType': contentType, // Sending the selected type
          'isFree': isFree,
        },
      );
    } catch (e) {
      throw Exception('Failed to add lesson: $e');
    }
  }

  // NEW: Reorder Modules
  Future<void> reorderModules(
    int courseId,
    List<Map<String, dynamic>> updates,
  ) async {
    try {
      await _dio.put(
        '/courses/$courseId/modules/reorder',
        data: {'updates': updates},
      );
    } catch (e) {
      throw Exception('Failed to reorder modules: $e');
    }
  }

  // NEW: Reorder Lessons
  Future<void> reorderLessons(
    int moduleId,
    List<Map<String, dynamic>> updates,
  ) async {
    try {
      await _dio.put(
        '/modules/$moduleId/lessons/reorder',
        data: {'updates': updates},
      );
    } catch (e) {
      throw Exception('Failed to reorder lessons: $e');
    }
  }

  Future<void> toggleCoursePublishStatus(int courseId, bool isPublished) async {
    try {
      // Calls the new PATCH route we created in Step 1
      await _dio.patch(
        '/courses/$courseId/publish',
        data: {'is_published': isPublished},
      );
    } catch (e) {
      throw Exception('Failed to update publish status: $e');
    }
  }
}

// Provider
final adminServicesProvider = Provider<AdminService>((ref) {
  final dio = ref.watch(dioProvider(ref));
  return AdminService(dio);
});

// Future Provider to Fetch Courses easily in the UI
final allCoursesProvider = FutureProvider.autoDispose<List<Course>>((
  ref,
) async {
  final service = ref.watch(adminServicesProvider);
  return service.getAllCourses();
});
