import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/state/auth_notifier.dart';
import 'package:jbh_academy/services/secure_storage_service.dart';

// Ensure this IP is correct for your setup (10.92.128.86 for physical device via WiFi)
const String _baseUrl = 'http://10.92.128.86:3000/api';

final dioProvider = Provider.family<Dio, Ref>((ref, externalRef) {
  final dio = Dio(BaseOptions(baseUrl: _baseUrl));
  final secureStorageService = externalRef.read(secureStorageServiceProvider);

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await secureStorageService.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (e, handler) async {
      // --- FIX: Check if this is a login request ---
      final isLoginRequest = e.requestOptions.path.contains('/auth/login');

      // Only trigger global logout if it's NOT a login request
      if ((e.response?.statusCode == 401 || e.response?.statusCode == 403) && !isLoginRequest) {
        AuthNotifier.triggerLogout(externalRef);
      }
      return handler.next(e);
    },
  ));

  return dio;
});