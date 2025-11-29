// lib/services/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

class SecureStorageService {
  final FlutterSecureStorage _storage;
  static const _tokenKey = 'jwt_token';
  static const _roleKey = 'user_role';


  SecureStorageService(this._storage);

  Future<void> saveSession(String token,String role) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<String?> getRole() async {
    return _storage.read(key: _roleKey);
  }


  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(ref.watch(secureStorageProvider));
});