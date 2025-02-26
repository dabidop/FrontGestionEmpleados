import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final _storage = FlutterSecureStorage();

  // Guardar el token JWT
  static Future<void> storeToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // Recuperar el token JWT
  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // Borrar el token JWT
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }
}
