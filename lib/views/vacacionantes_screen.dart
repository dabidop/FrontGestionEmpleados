import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/api_service.dart';
import 'package:gestion_empleados/widgets/custom_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gestion_empleados/services/secure_storage_service.dart';

class VacacionantesScreen extends StatefulWidget {
  const VacacionantesScreen({Key? key}) : super(key: key);

  @override
  _VacacionantesScreenState createState() => _VacacionantesScreenState();
}

class _VacacionantesScreenState extends State<VacacionantesScreen> {
  List<dynamic> vacacionantes = [];
  bool isLoading = true;
  bool isUnauthorized = false;
  Map<String, dynamic>? perfil;

  @override
  void initState() {
    super.initState();
    _fetchVacacionantes();
    _loadPerfil();
  }

  Future<void> _loadPerfil() async {
    var data = await ApiService.getPerfil();
    setState(() {
      perfil = data;
    });
  }

  Future<void> _fetchVacacionantes() async {
    String? token = await SecureStorageService.getToken();
    print("🔹 Token enviado en Vacacionantes: $token"); // Debug

    final response = await http.get(
      Uri.parse("http://localhost:5219/api/Vacaciones/vacacionantes"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        vacacionantes = json.decode(response.body);
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
      print("⚠️ Error al obtener vacacionantes: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 26, 58),
        title: const Text(
          "Empleados en vacaciones",
          style: TextStyle(color: Colors.white), // 🎯 texto blanco
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: CustomDrawer(perfil: perfil),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : isUnauthorized
              ? const Center(
                child: Text(
                  "⚠️ No autorizado. Inicie sesión nuevamente.",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              )
              : vacacionantes.isEmpty
              ? const Center(child: Text("No hay empleados de vacaciones"))
              : ListView.builder(
                itemCount: vacacionantes.length,
                itemBuilder: (context, index) {
                  final empleado = vacacionantes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: ListTile(
                      title: Text(empleado['nombre']),
                      subtitle: Text("Cargo: ${empleado['cargo']}"),
                      trailing: Text(
                        "Hasta:\n${_formatDate(empleado['fechaFin'])}",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
    );
  }

  String _formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return "${date.day}/${date.month}/${date.year}";
  }
}
