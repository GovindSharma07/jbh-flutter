import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Models/user_model.dart';
import 'package:jbh_academy/services/api_service.dart';
import 'package:jbh_academy/services/secure_storage_service.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;
  final SecureStorageService _storage;
  final Ref ref;

  AuthNotifier(this._dio, this.ref, this._storage) : super(AuthState.initial()) {
    fetchAuthenticatedUser();
  }

  static void triggerLogout(Ref ref) {
    ref.read(authNotifierProvider.notifier).logout();
  }

  String _extractErrorMessage(DioException e) {
    return e.response?.data?['message'] ?? 'Network error. Please try again.';
  }

  Future<void> fetchAuthenticatedUser() async {
    final token = await _storage.getToken();
    if (token == null) {
      state = AuthState.initial();
      return;
    }
    state = state.asLoading();
    try {
      final response = await _dio.get('/users/me');
      final user = User.fromJson(response.data);
      state = state.asAuthenticated(user, token);
    } on DioException catch (_) {
      await logout();
    }
  }

  Future<void> logout() async {
    await _storage.deleteToken();
    state = AuthState.initial();
  }

  Future<void> login(String email, String password) async {
    state = state.asLoading();
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['token'] as String;
      await _storage.saveToken(token);
      await fetchAuthenticatedUser();

    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        // --- EXTRACT FLAGS FROM BACKEND ---
        final data = e.response?.data;
        state = AuthState.initial().copyWith(
          tempEmail: email,
          error: null,
          isEmailVerified: data['isEmailVerified'] ?? false,
          isPhoneVerified: data['isPhoneVerified'] ?? false,
        );
      } else {
        state = state.asError(_extractErrorMessage(e));
      }
    } catch (e) {
      state = state.asError('Unexpected error during login.');
    }
  }

  Future<void> register(String fullName, String email, String password, String phone) async {
    state = state.asLoading().copyWith(tempEmail: email);
    try {
      await _dio.post('/auth/register', data: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
      });
      // Initial registration state: both are false
      state = AuthState.initial().copyWith(
          tempEmail: email,
          error: null,
          isEmailVerified: false,
          isPhoneVerified: false
      );
    } on DioException catch (e) {
      state = state.asError(_extractErrorMessage(e));
    } catch (e) {
      state = state.asError('Unexpected error during registration.');
    }
  }

  // --- UPDATED: Accept nullable codes to verify only what is needed ---
  Future<void> verifyOtps(String? emailOtp, String? mobileOtp) async {
    if (state.tempEmail == null) return;

    // Retain all current flags while loading
    state = state.asLoading().copyWith(
      tempEmail: state.tempEmail,
      isEmailVerified: state.isEmailVerified,
      isPhoneVerified: state.isPhoneVerified,
    );

    try {
      // Only call verify-email if a code was provided
      if (emailOtp != null && emailOtp.isNotEmpty) {
        await _dio.post('/auth/verify-email', data: {
          'email': state.tempEmail,
          'code': emailOtp,
        });
      }

      // Only call verify-phone if a code was provided
      if (mobileOtp != null && mobileOtp.isNotEmpty) {
        await _dio.post('/auth/verify-phone', data: {
          'email': state.tempEmail,
          'code': mobileOtp,
        });
      }

      // If we reach here, whatever we attempted succeeded.
      // Success: clear everything to navigate to login.
      state = AuthState.initial();

    } on DioException catch (e) {
      // Preserve flags on error so UI doesn't flicker/reset
      state = state.asError(_extractErrorMessage(e)).copyWith(
        tempEmail: state.tempEmail,
        isEmailVerified: state.isEmailVerified,
        isPhoneVerified: state.isPhoneVerified,
      );
    } catch (e) {
      state = state.asError('Verification failed.').copyWith(
        tempEmail: state.tempEmail,
        isEmailVerified: state.isEmailVerified,
        isPhoneVerified: state.isPhoneVerified,
      );
    }
  }

  Future<void> resendOtps() async {
    if (state.tempEmail == null) return;
    try {
      await _dio.post('/auth/resend-otp', data: {'email': state.tempEmail});
    } on DioException catch (e) {
      throw _extractErrorMessage(e);
    }
  }

  // ... (rest of class same as before) ...
  Future<void> requestPasswordReset(String email) async {
    state = state.asLoading().copyWith(tempEmail: email);
    try {
      await _dio.post('/auth/forgot-password', data: {'email': email});
      state = AuthState.initial().copyWith(tempEmail: email, error: null);
    } on DioException catch (e) {
      state = state.asError(_extractErrorMessage(e));
    }
  }

  Future<void> resetPassword(String otp, String newPassword) async {
    if(state.tempEmail == null) return;
    state = state.asLoading().copyWith(tempEmail: state.tempEmail);
    try {
      await _dio.post('/auth/reset-password', data: {
        'email': state.tempEmail,
        'otp': otp,
        'newPassword': newPassword
      });
      state = AuthState.initial();
    } on DioException catch (e) {
      state = state.asError(_extractErrorMessage(e)).copyWith(tempEmail: state.tempEmail);
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dio = ref.watch(dioProvider(ref));
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthNotifier(dio, ref, storage);
});