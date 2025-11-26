// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/state/auth_notifier.dart';
import 'package:jbh_academy/services/secure_storage_service.dart';

// Base URL for the backend - Use 10.0.2.2 for Android emulator to access localhost
const String _baseUrl = 'http://localhost:3000/api';

// --- FIX: Change to Provider.family, taking the Ref as a dependency (externalRef) ---
final dioProvider = Provider.family<Dio, Ref>((ref, externalRef) {
  final dio = Dio(BaseOptions(baseUrl: _baseUrl));
  final secureStorageService = externalRef.read(secureStorageServiceProvider);

  // Add the Interceptor for JWT and Auth Error handling
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await secureStorageService.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (e, handler) async {
      // Handle Authentication Errors (401/403)
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        // Use the static helper method to trigger logout
        AuthNotifier.triggerLogout(externalRef);
      }
      return handler.next(e);
    },
  ));

  return dio;
});