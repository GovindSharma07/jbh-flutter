import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Models/apprenticeship_model.dart';
import 'package:jbh_academy/services/api_service.dart';

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
}