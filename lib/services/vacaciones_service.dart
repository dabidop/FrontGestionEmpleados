import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gestion_empleados/services/secure_storage_service.dart';

class VacacionesService {
  static const String baseUrl = "http://localhost:5219/api/Vacaciones";
  // 🔥 Caché de nombres de empleados
  static Map<String, String> cacheNombresEmpleados = {};

  static Future<String> obtenerNombreEmpleado(String codigoEmpleado) async {
    // 🔥 1️⃣ Si ya tenemos el nombre en caché, lo devolvemos sin llamar a la API
    if (cacheNombresEmpleados.containsKey(codigoEmpleado)) {
      return cacheNombresEmpleados[codigoEmpleado]!;
    }

    // 🔥 2️⃣ Si no está en caché, hacemos la solicitud a la API
    String? token = await SecureStorageService.getToken();
    final response = await http.get(
      Uri.parse("http://localhost:5219/api/usuarios/perfil"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      // 🔥 3️⃣ Guardamos el nombre en caché para futuras consultas
      String nombreCompleto =
          "${data['nombre']} ${data['nombre2'] ?? ''} ${data['apellido']} ${data['apellido2'] ?? ''}"
              .trim();
      cacheNombresEmpleados[codigoEmpleado] = nombreCompleto;

      return nombreCompleto;
    } else {
      return "Desconocido";
    }
  }

  // ✅ 1️⃣ Obtener solicitudes pendientes para el aprobador logeado
  static Future<List<dynamic>> obtenerSolicitudesPendientes(
    String codigoAprobador,
  ) async {
    String? token = await SecureStorageService.getToken();

    if (token == null) {
      return [];
    }

    final response = await http.get(
      Uri.parse(
        'http://localhost:5219/api/Vacaciones/pendientes/$codigoAprobador',
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> solicitudes = jsonDecode(response.body);
      print("🔥 Solicitudes filtradas: ${solicitudes.length}");
      return solicitudes;
    } else {
      print("⚠️ Error al obtener solicitudes: ${response.statusCode}");
      return [];
    }
  }

  // ✅ 2️⃣ Aprobar o rechazar solicitud de vacaciones
  static Future<bool> actualizarEstadoSolicitud({
    required int idVacacion,
    required String nuevoEstado,
    required String usuarioAprueba,
    String? observaciones,
  }) async {
    String? token = await SecureStorageService.getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/aprobar/$idVacacion'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "estado": nuevoEstado,
        "usuarioAprueba": usuarioAprueba,
        "observaciones": observaciones ?? "",
      }),
    );

    return response.statusCode == 200;
  }

  // ✅ 3️⃣ Obtener lista de aprobadores (Gerentes, Directores, Coordinadores)
  static Future<List<Map<String, String>>> obtenerAprobadores() async {
    String? token = await SecureStorageService.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/aprobadores"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      return data
          .map<Map<String, String>>(
            (aprobador) => {
              "codigo": aprobador["codigo"].toString().trim(),
              "nombre":
                  "${aprobador["nombre"].toString().trim()} ${aprobador["apellido"].toString().trim()}",
              "cargo":
                  aprobador["cargo"]?.toString().trim() ??
                  "Sin cargo", // 🔥 Aquí aseguramos que el cargo nunca sea null
            },
          )
          .toList();
    } else {
      throw Exception("Error al obtener la lista de aprobadores");
    }
  }

  // ✅ 5️⃣ Obtener las solicitudes de vacaciones de un empleado
  static Future<List<dynamic>> obtenerVacacionesPorEmpleado(
    String codigoEmpleado,
  ) async {
    String? token = await SecureStorageService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/empleado/$codigoEmpleado'), // Endpoint correcto
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener las solicitudes de vacaciones');
    }
  }

  // ✅ 4️⃣ Solicitar vacaciones
  static Future<bool> solicitarVacaciones({
    required String codigoEmpleado,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required int diasSolicitados,
    required String usuarioAprueba,
    required String observaciones,
  }) async {
    String? token = await SecureStorageService.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/solicitar"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "codigoEmpleado": codigoEmpleado,
        "fechaSolicitud": DateTime.now().toIso8601String(),
        "fechaInicio": fechaInicio.toIso8601String(),
        "fechaFin": fechaFin.toIso8601String(),
        "diasSolicitados": diasSolicitados,
        "estado": "Pendiente",
        "usuarioAprueba": usuarioAprueba,
        "fechaAprobacion": null,
        "observaciones": observaciones,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Error al solicitar vacaciones: ${response.body}");
      return false;
    }
  }
}
