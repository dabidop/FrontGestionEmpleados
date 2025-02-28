import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:gestion_empleados/services/secure_storage_service.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class IncapacidadesService {
  static const String baseUrl = "http://localhost:5219/api/Incapacidades";

  // ✅ Obtener incapacidades por código de empleado
  static Future<List<dynamic>> obtenerIncapacidadesPorEmpleado(
    String codigoEmpleado,
  ) async {
    String? token = await SecureStorageService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/empleado/$codigoEmpleado'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      // 🔥 Mapeo Ajustado para coincidir con la respuesta de la API
      return data
          .map(
            (incapacidad) => {
              'id': incapacidad['idSolicitudIncapacidad'],
              'codigoEmpleado': incapacidad['codigoEmpleado'],
              'fechaInicio': incapacidad['fechaInicioIncapacidad'],
              'fechaFin': incapacidad['fechaFinIncapacidad'],
              'nombreArchivo': incapacidad['nombreArchivo'],
              'tipoArchivo': incapacidad['tipoArchivo'],
              'fechaSolicitud': incapacidad['fechaSolicitud'],
              'estado':
                  incapacidad['estadoIncapacidad'] == true
                      ? "Vigente"
                      : "Expirada",
            },
          )
          .toList();
    } else {
      throw Exception('Error al obtener las incapacidades');
    }
  }

  // ✅ Crear una nueva solicitud de incapacidad
  static Future<void> crearIncapacidad(
    String codigoEmpleado,
    DateTime fechaInicio,
    DateTime fechaFin,
    String nombreArchivo,
    List<int> archivoBytes,
  ) async {
    String? token = await SecureStorageService.getToken();

    var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['CodigoEmpleado'] = codigoEmpleado;
    request.fields['FechaInicio'] = fechaInicio.toIso8601String();
    request.fields['FechaFin'] = fechaFin.toIso8601String();
    request.files.add(
      http.MultipartFile.fromBytes(
        'Archivo',
        archivoBytes,
        filename: nombreArchivo,
      ),
    );

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Error al crear la incapacidad');
    }
  }

  // Obtener detalles de una incapacidad por ID
  static Future<Map<String, dynamic>> obtenerDetallesIncapacidad(int id) async {
    String? token = await SecureStorageService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener los detalles de la incapacidad');
    }
  }

  // Descargar archivo de incapacidad
  static Future<void> descargarArchivo(int id) async {
    String? token = await SecureStorageService.getToken();
    final url = Uri.parse('$baseUrl/$id/archivo');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // 🔥 Obtener directorio de descarga
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/archivo_incapacidad_$id.pdf';

      // 🔥 Guardar el archivo
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // 🔥 Abrir el archivo descargado
      await OpenFile.open(filePath);
    } else {
      throw Exception('Error al descargar el archivo');
    }
  }
}
