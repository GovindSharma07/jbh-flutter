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

  // --- FIX: Static method required by dioProvider to break the cycle ---
  static void triggerLogout(Ref ref) {
    ref.read(authNotifierProvider.notifier).logout();
  }
  // ----------------------------------------------------------------------

  String _extractErrorMessage(DioException e) {
    return e.response?.data?['message'] ?? 'Network error. Please try again.';
  }

  // ------------------------------------
  // CORE AUTHENTICATION LIFECYCLE
  // ------------------------------------

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

  // ------------------------------------
  // LOGIN / REGISTER
  // ------------------------------------

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
      state = state.asError(_extractErrorMessage(e));
    } catch (e) {
      state = state.asError('An unexpected error occurred during login.');
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

      state = AuthState.initial().copyWith(tempEmail: email, error: null);

    } on DioException catch (e) {
      state = state.asError(_extractErrorMessage(e));
    } catch (e) {
      state = state.asError('An unexpected error occurred during registration.');
    }
  }

  // ------------------------------------
  // VERIFICATION
  // ------------------------------------

  Future<void> verifyEmail(String token) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.post('/auth/verify-email', data: {
        'token': token,
      });

      state = state.copyWith(isLoading: false, error: null);

    } on DioException catch (e) {
      state = state.asError(_extractErrorMessage(e));
    } catch (e) {
      state = state.asError('An unexpected error occurred during email verification.');
    }
  }

  Future<void> verifyPhone(String email, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.post('/auth/verify-phone', data: {
        'email': email,
        'code': code,
      });

      state = AuthState.initial().copyWith(tempEmail: null, error: null);

    } on DioException catch (e) {
      state = state.asError(_extractErrorMessage(e));
    } catch (e) {
      state = state.asError('An unexpected error occurred during phone verification.');
    }
  }

  // ------------------------------------
  // PASSWORD RESET
  // ------------------------------------

  Future<void> requestPasswordReset(String email) async {
    state = state.asLoading().copyWith(tempEmail: email);
    try {
      await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });

      state = AuthState.initial().copyWith(tempEmail: email, error: null);

    } on DioException catch (e) {
      state = state.asError(_extractErrorMessage(e));
    } catch (e) {
      state = state.asError('An unexpected error occurred during password reset request.');
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // Use the corrected dioProvider, passing the current ref instance
  final dio = ref.watch(dioProvider(ref));
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthNotifier(dio, ref, storage);
});