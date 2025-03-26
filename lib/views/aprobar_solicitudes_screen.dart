import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/api_service.dart';
import 'package:gestion_empleados/services/vacaciones_service.dart';
import 'package:gestion_empleados/widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detalle_solicitud_screen.dart'; // ✅ Importa la pantalla de detalle

class AprobarSolicitudesScreen extends StatefulWidget {
  const AprobarSolicitudesScreen({super.key});

  @override
  _AprobarSolicitudesScreenState createState() =>
      _AprobarSolicitudesScreenState();
}

class _AprobarSolicitudesScreenState extends State<AprobarSolicitudesScreen> {
  List<dynamic> solicitudes = [];
  bool isLoading = true;
  String? codigoAprobador;
  Map<String, dynamic>? perfil;

  @override
  void initState() {
    super.initState();
    cargarSolicitudes();
    _loadPerfil();
  }

  // ✅ Cargar los datos del perfil del usuario desde la API
  Future<void> _loadPerfil() async {
    try {
      var data = await ApiService.getPerfil();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (data != null && data['codigo'] != null) {
        await prefs.setString('codigo_empleado', data['codigo']);
      }

      setState(() {
        perfil = data;
      });
    } catch (e) {
      print('Error al cargar datos del perfil: $e');
    }
  }

  Future<void> cargarSolicitudes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    codigoAprobador = prefs.getString('codigo_empleado');

    if (codigoAprobador != null) {
      try {
        List<dynamic> data =
            await VacacionesService.obtenerSolicitudesPendientes(
              codigoAprobador!,
            );

        // 🔥🔥🔥 PRINT PARA DEPURAR 🔥🔥🔥
        print("🚀 Datos recibidos en Flutter:");
        for (var solicitud in data) {
          print(
            "Empleado: ${solicitud["nombreCompleto"]} | Días: ${solicitud["diasSolicitados"]}",
          );
        }

        setState(() {
          solicitudes = data;
          isLoading = false;
        });
      } catch (e) {
        //print("⚠️ Error al cargar solicitudes: $e");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aprobar Solicitudes")),
      drawer: perfil == null ? null : CustomDrawer(perfil: perfil),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : solicitudes.isEmpty
              ? const Center(child: Text("No hay solicitudes pendientes"))
              : ListView.builder(
                itemCount: solicitudes.length,
                itemBuilder: (context, index) {
                  var solicitud = solicitudes[index];

                  return Card(
                    child: ListTile(
                      title: Text(
                        "Empleado: ${solicitud['nombreCompleto'] ?? 'Desconocido'}",
                      ),
                      subtitle: Text(
                        "Días solicitados: ${solicitud['diasSolicitados']}",
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DetalleSolicitudScreen(
                                  solicitud: solicitud,
                                ),
                          ),
                        ).then(
                          (_) => cargarSolicitudes(),
                        ); // 🔥 Recargar lista al volver
                      },
                    ),
                  );
                },
              ),
    );
  }
}
