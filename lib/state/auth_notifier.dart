import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Models/user_model.dart';
import 'package:jbh_academy/services/api_service.dart';
import 'package:jbh_academy/services/secure_storage_service.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;
  final SecureStorageService _storage;
  final Ref ref;

  AuthNotifier(this._dio, this.ref, this._storage) : super(AuthState(isLoading: true)) {
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

// In lib/state/auth_notifier.dart

  Future<void> verifyOtps(String? emailOtp, String? mobileOtp) async {
    if (state.tempEmail == null) return;

    // 1. Initialize flags with current values
    bool currentEmailVerified = state.isEmailVerified;
    bool currentPhoneVerified = state.isPhoneVerified;

    // 2. Set loading state, preserving current progress
    state = state.asLoading().copyWith(
      tempEmail: state.tempEmail,
      isEmailVerified: currentEmailVerified,
      isPhoneVerified: currentPhoneVerified,
    );

    try {
      // 3. Verify Email (if not already verified and OTP provided)
      if (!currentEmailVerified && emailOtp != null && emailOtp.isNotEmpty) {
        await _dio.post('/auth/verify-email', data: {
          'email': state.tempEmail,
          'code': emailOtp,
        });

        // SUCCESS: Update flag AND State immediately
        // This acts as a "save point" in case the next step fails
        currentEmailVerified = true;
        state = state.copyWith(
          isEmailVerified: true,
          error: null,
        );
      }

      // 4. Verify Phone (if not already verified and OTP provided)
      if (!currentPhoneVerified && mobileOtp != null && mobileOtp.isNotEmpty) {
        await _dio.post('/auth/verify-phone', data: {
          'email': state.tempEmail,
          'code': mobileOtp,
        });

        // SUCCESS: Update flag
        currentPhoneVerified = true;
      }

      // 5. Final Completion Check
      if (currentEmailVerified && currentPhoneVerified) {
        // Success: Clear temp state to allow login navigation
        state = AuthState.initial();
      } else {
        // Partial Success: Update state with whatever passed
        state = state.copyWith(
          isLoading: false,
          isEmailVerified: currentEmailVerified,
          isPhoneVerified: currentPhoneVerified,
          error: null,
        );
      }

    } on DioException catch (e) {
      // 6. On Error: Use the LOCAL flags (currentEmailVerified) to preserve progress
      state = state.asError(_extractErrorMessage(e)).copyWith(
        tempEmail: state.tempEmail,
        isEmailVerified: currentEmailVerified, // Uses the updated value
        isPhoneVerified: currentPhoneVerified, // Uses the updated value
      );
    } catch (e) {
      state = state.asError('Verification failed.').copyWith(
        tempEmail: state.tempEmail,
        isEmailVerified: currentEmailVerified,
        isPhoneVerified: currentPhoneVerified,
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