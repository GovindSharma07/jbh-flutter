import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Models/apprenticeship_model.dart'; // For Resume model
import 'package:jbh_academy/services/api_service.dart';
import 'package:mime/mime.dart';

import '../Models/resume_model.dart';

final resumeServiceProvider = Provider<ResumeService>((ref) {
  final dio = ref.watch(dioProvider(ref));
  return ResumeService(dio);
});

class ResumeService {
  final Dio _dio;
  ResumeService(this._dio);

  Future<List<Resume>> getMyResumes() async {
    final response = await _dio.get('/resumes');
    return (response.data as List).map((e) => Resume.fromJson(e)).toList();
  }

  Future<void> deleteResume(int resumeId) async {
    try {
      await _dio.delete('/resumes/$resumeId');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to delete resume';
    }
  }

  // Atomicity: The UI calls this ONE method to handle the complex upload flow
  Future<Resume> uploadResume(String filePath, String fileName) async {
    try {
      // 1. Get Presigned URL
      final mimeType = lookupMimeType(filePath) ?? 'application/pdf';
      final presignRes = await _dio.post('/resumes/upload-url', data: {
        'fileName': fileName,
        'fileType': mimeType,
      });

      final String uploadUrl = presignRes.data['uploadUrl'];
      final String publicUrl = presignRes.data['publicUrl'];

      // 2. Upload file to Cloudflare/B2 (Using a fresh Dio to avoid Auth headers)
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

      // 3. Confirm to Backend to save metadata
      final saveRes = await _dio.post('/resumes', data: {
        'name': fileName,
        'file_url': publicUrl,
      });

      return Resume.fromJson(saveRes.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to upload resume';
    } catch (e) {
      throw 'An unexpected error occurred during upload';
    }
  }
}