import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/services/secure_storage_service.dart';
import 'package:jbh_academy/state/auth_notifier.dart';
// Ensure backend_endpoint.dart is imported or define baseUrl
import '../backend_endpoint.dart';

// FIX: Change Provider.family -> Provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));

  // FIX: Use 'ref' directly instead of 'externalRef'
  final secureStorageService = ref.read(secureStorageServiceProvider);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await secureStorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) async {
        final isLoginRequest = e.requestOptions.path.contains('/auth/login');

        if ((e.response?.statusCode == 401 || e.response?.statusCode == 403) &&
            !isLoginRequest) {
          // FIX: Pass the internal 'ref' if triggerLogout expects Ref
          AuthNotifier.triggerLogout(ref);
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});