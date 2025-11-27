import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/state/auth_notifier.dart';
import 'package:jbh_academy/services/secure_storage_service.dart';
import "dart:io";

// Ensure this IP is correct for your setup (10.92.128.86 for physical device via WiFi)
// Replace the const String _baseUrl line with this getter:
String get _baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000/api'; // Android Emulator localhost
  } else if (Platform.isIOS) {
    return 'http://127.0.0.1:3000/api'; // iOS Simulator localhost
  } else {
    return 'http://localhost:3000/api'; // Web or Desktop
  }
  // Note: For physical devices, you must still use your computer's LAN IP (e.g., 192.168.x.x)
}

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