import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/api_service.dart';
import 'package:gestion_empleados/services/vacaciones_service.dart';
import 'package:gestion_empleados/views/solicitar_vacaciones_screen.dart';
import 'package:gestion_empleados/widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class SolicitudesVacacionesScreen extends StatefulWidget {
  const SolicitudesVacacionesScreen({super.key});

  @override
  _SolicitudesVacacionesScreenState createState() =>
      _SolicitudesVacacionesScreenState();
}

class _SolicitudesVacacionesScreenState
    extends State<SolicitudesVacacionesScreen> {
  List<dynamic> solicitudes = [];
  bool isLoading = true;
  String? codigoEmpleado;
  Map<String, dynamic>? perfil;

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "No disponible";

    try {
      initializeDateFormatting(
        "es",
      ); // 👈 Inicializar antes de usar `DateFormat`
      DateTime date = DateTime.parse(dateStr);
      return DateFormat("d MMMM, y", "es").format(date);
    } catch (e) {
      print("❌ Error al formatear fecha: $e");
      return "Formato inválido";
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
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

  Future<void> _cargarSolicitudes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    codigoEmpleado = prefs.getString('codigo_empleado');

    if (codigoEmpleado != null) {
      try {
        List<dynamic> data =
            await VacacionesService.obtenerVacacionesPorEmpleado(
              codigoEmpleado!,
            );
        setState(() {
          solicitudes = data;
          isLoading = false;
        });
      } catch (e) {
        print("Error al cargar solicitudes: $e");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Solicitudes de Vacaciones")),
      drawer: perfil == null ? null : CustomDrawer(perfil: perfil),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : solicitudes.isEmpty
              ? const Center(
                child: Text("No tienes solicitudes de vacaciones registradas."),
              )
              : ListView.builder(
                itemCount: solicitudes.length,
                itemBuilder: (context, index) {
                  var solicitud = solicitudes[index];
                  String? observaciones = solicitud['observaciones'];
                  print("Observaciones para ID ${solicitud['idVacacion']}: '${solicitud['observaciones']}'");
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      title: Text(
                        "Desde: ${_formatDate(solicitud['fechaInicio'])}\nHasta: ${_formatDate(solicitud['fechaFin'])}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Estado: ${solicitud['estado']}"),
                          if (observaciones != null &&
                              observaciones.trim().isNotEmpty)
                            Text("Observaciones: $observaciones"),
                        ],
                      ),
                      trailing: Icon(
                        solicitud['estado'] == "Aprobado" ||
                                solicitud['estado'] == "Aprobada"
                            ? Icons.check_circle_outline
                            : solicitud['estado'] == "Rechazada"
                            ? Icons.cancel_outlined
                            : Icons.pending_outlined,
                        color:
                            solicitud['estado'] == "Aprobada" ||
                                    solicitud['estado'] == "Aprobado"
                                ? Colors.green
                                : solicitud['estado'] == "Rechazada"
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SolicitarVacacionesScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
