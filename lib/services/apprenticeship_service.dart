import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Models/apprenticeship_model.dart';
import 'package:jbh_academy/services/api_service.dart';
import 'package:mime/mime.dart';

final apprenticeshipServiceProvider = Provider<ApprenticeshipService>((ref) {
  final dio = ref.watch(dioProvider(ref));
  return ApprenticeshipService(dio);
});

class ApprenticeshipService {
  final Dio _dio;
  ApprenticeshipService(this._dio);

  Future<List<Apprenticeship>> getAllApprenticeships() async {
    try {
      final response = await _dio.get('/apprenticeships');
      return (response.data as List)
          .map((e) => Apprenticeship.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to load apprenticeships';
    }
  }

  Future<void> apply(int apprenticeshipId, int resumeId, String message) async {
    try {
      await _dio.post('/apprenticeships/apply', data: {
        'apprenticeship_id': apprenticeshipId,
        'resume_id': resumeId,
        'message': message,
      });
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to apply';
    }
  }

  // --- NEW: Upload Job Image ---
  Future<String> uploadJobImage(String filePath, String fileName) async {
    try {
      // 1. Get Presigned URL
      final mimeType = lookupMimeType(filePath) ?? 'image/jpeg';
      final presignRes = await _dio.post('/apprenticeships/upload-url', data: {
        'fileName': fileName,
        'fileType': mimeType,
      });

      final String uploadUrl = presignRes.data['uploadUrl'];
      final String publicUrl = presignRes.data['publicUrl'];

      // 2. Upload to Cloud (Use fresh Dio to avoid Auth headers)
      final uploadDio = Dio();
      final fileBytes = await File(filePath).readAsBytes();

      await uploadDio.put(
        uploadUrl,
        data: fileBytes,
        options: Options(
          headers: {
            'Content-Type': mimeType,
            'Content-Length': fileBytes.length,
          },
        ),
      );

      return publicUrl; // Return the cloud URL to be saved in DB
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to upload image';
    }
  }

  // Modified Create Method
  Future<void> createApprenticeship(Map<String, dynamic> data) async {
    try {
      await _dio.post('/apprenticeships', data: data);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to create apprenticeship';
    }
  }
}