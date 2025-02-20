import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://localhost:5219/api/auth";

  // Método para iniciar sesión o solicitar registro
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"Email": email, "Contrasena": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data.containsKey('usuario')) {
        // ✅ Usuario ya registrado, iniciar sesión
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('codigo_empleado', data['usuario']['codigo_empleado']);
        await prefs.setString('email', data['usuario']['email']);

        return {"success": true, "isRegistered": true};
      } else {
        // ⚠️ Usuario no registrado, se envió un código de verificación
        return {"success": true, "isRegistered": false, "email": data['email']};
      }
    } else {
      return {"success": false, "message": "Credenciales incorrectas"};
    }
  }

  // Método para confirmar el código de verificación y registrar al usuario
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

  // Método para cerrar sesión
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('codigo_empleado');
    await prefs.remove('email');
  }
}