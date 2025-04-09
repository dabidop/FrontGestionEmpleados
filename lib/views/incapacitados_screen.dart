import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/api_service.dart';
import 'package:gestion_empleados/widgets/custom_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gestion_empleados/services/secure_storage_service.dart';
import 'package:gestion_empleados/services/incapacidades_service.dart';

class IncapacitadosScreen extends StatefulWidget {
  const IncapacitadosScreen({Key? key}) : super(key: key);

  @override
  _IncapacitadosScreenState createState() => _IncapacitadosScreenState();
}

class _IncapacitadosScreenState extends State<IncapacitadosScreen> {
  List<dynamic> incapacitados = [];
  bool isLoading = true;
  bool isUnauthorized = false;
  
  Map<String, dynamic>? perfil;

  @override
  void initState() {
    super.initState();
    _fetchIncapacitados();
    _loadPerfil();
  }

  Future<void> _loadPerfil() async {
    var data = await ApiService.getPerfil();
    setState(() {
      perfil = data;
    });
  }

  Future<void> _fetchIncapacitados() async {
    String? token = await SecureStorageService.getToken();
    print("🔹 Token enviado en Incapacitados: $token");

    final response = await http.get(
      Uri.parse("http://localhost:5219/api/Incapacidades/incapacitados"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      setState(() {
        incapacitados = data.map((incapacidad) {
          return {
            'id': incapacidad['idSolicitudIncapacidad'] ?? 0,
            'codigoEmpleado': incapacidad['codigoEmpleado'] ?? "Desconocido",
            'fechaInicio': incapacidad['fechaInicioIncapacidad'] ?? "Fecha no disponible",
            'fechaFin': incapacidad['fechaFinIncapacidad'] ?? "Fecha no disponible",
            'nombre': incapacidad['nombre']?.trim() ?? "Sin nombre",
            'cargo': incapacidad['cargo']?.trim() ?? "Sin cargo",
            'email': incapacidad['email']?.trim() ?? "No disponible",
            'estado': (incapacidad['estadoIncapacidad'] == true) ? "Vigente" : "Expirada",
            'nombreArchivo': incapacidad['nombreArchivo'] ?? "", // ✅ Nombre del archivo
          };
        }).toList();

        isLoading = false;
        isUnauthorized = false;
      });
    } else if (response.statusCode == 401) {
      setState(() {
        isLoading = false;
        isUnauthorized = true;
      });
      print("⚠️ Error 401: No autorizado.");
    } else {
      setState(() => isLoading = false);
      print("⚠️ Error al obtener incapacitados: ${response.statusCode}");
    }
  }

  Future<void> _descargarArchivo(int id) async {
    try {
      await IncapacidadesService.descargarArchivo(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📥 Archivo descargado con éxito')),
      );
    } catch (e) {
      print("⚠️ Error al descargar archivo: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error al descargar el archivo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 26, 58),
        title: const Text(
          "Empleados incapacitados",
          style: TextStyle(color: Colors.white), // 🎯 texto blanco
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: CustomDrawer(perfil: perfil),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isUnauthorized
              ? const Center(
                  child: Text(
                    "⚠️ No autorizado. Inicie sesión nuevamente.",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : incapacitados.isEmpty
                  ? const Center(child: Text("No hay empleados incapacitados"))
                  : ListView.builder(
                      itemCount: incapacitados.length,
                      itemBuilder: (context, index) {
                        final empleado = incapacitados[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Text(
                              empleado['nombre'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Cargo: ${empleado['cargo']}"),
                                const SizedBox(height: 5),
                                empleado['nombreArchivo'].isNotEmpty
                                    ? ElevatedButton.icon(
                                        onPressed: () => _descargarArchivo(empleado['id']),
                                        icon: const Icon(Icons.download),
                                        label: const Text("Descargar Comprobante"),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        ),
                                      )
                                    : const Text(
                                        "❌ Sin comprobante",
                                        style: TextStyle(color: Colors.red),
                                      ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Hasta: ${_formatDate(empleado['fechaFin'])}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr == "Fecha no disponible") return "Fecha no disponible";
    
    try {
      DateTime date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "Fecha inválida";
    }
  }
}
