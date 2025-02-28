import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestion_empleados/services/secure_storage_service.dart';

class ApiService {
  static const String baseUrl = "http://localhost:5219/api/auth";

  // ✅ Método para iniciar sesión o solicitar registro
    static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"Email": email, "Contrasena": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data.containsKey('usuario') && data.containsKey('token')) {
        // ✅ Usuario ya registrado, iniciar sesión
        String token = data['token'];
        await SecureStorageService.storeToken(token);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('codigo_empleado', data['usuario']['codigo_empleado']);
        await prefs.setString('email', data['usuario']['email']);

        // 🔥 Imprimir el token para verificar
        print("🔥 Token almacenado: $token");

        return {"success": true, "isRegistered": true};
      } else {
        // ⚠️ Usuario no registrado, se envió un código de verificación
        return {"success": true, "isRegistered": false, "email": data['email']};
      }
    } else {
      return {"success": false, "message": "Credenciales incorrectas"};
    }
  }


  // ✅ Método para confirmar el código de verificación y registrar al usuario (NO TOCADO)
  static Future<bool> confirmarRegistro(String email, String codigoVerificacion, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/confirmar-registro'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Email": email,
        "CodigoVerificacion": codigoVerificacion,
        "Contrasena": password
      }),
    );

    return response.statusCode == 200;
  }

  // ✅ Método para cerrar sesión (NO TOCADO)
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('codigo_empleado');
    await prefs.remove('email');
  }

    // ✅ Método para obtener el perfil del usuario autenticado
    static Future<Map<String, dynamic>> getPerfil() async {
    String? token = await SecureStorageService.getToken();
    print("🔥 Token leído: $token"); // ✅ Imprimir el token leído

    if (token == null) {
      return {"success": false, "message": "No hay token de autenticación."};
    }

    final response = await http.get(
      Uri.parse('http://localhost:5219/api/usuarios/perfil'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      return {"success": false, "message": "Error al obtener el perfil."};
    }
  }


}
