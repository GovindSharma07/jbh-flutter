import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/services/secure_storage_service.dart';
import 'package:jbh_academy/state/auth_notifier.dart';

import '../backend_endpoint.dart';

final dioProvider = Provider.family<Dio, Ref>((ref, externalRef) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  final secureStorageService = externalRef.read(secureStorageServiceProvider);

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
        // --- FIX: Check if this is a login request ---
        final isLoginRequest = e.requestOptions.path.contains('/auth/login');

        // Only trigger global logout if it's NOT a login request
        if ((e.response?.statusCode == 401 || e.response?.statusCode == 403) &&
            !isLoginRequest) {
          AuthNotifier.triggerLogout(externalRef);
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});
