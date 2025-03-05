import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/vacaciones_service.dart';
import 'package:gestion_empleados/views/solicitar_vacaciones_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SolicitudesVacacionesScreen extends StatefulWidget {
  const SolicitudesVacacionesScreen({super.key});

  @override
  _SolicitudesVacacionesScreenState createState() => _SolicitudesVacacionesScreenState();
}

class _SolicitudesVacacionesScreenState extends State<SolicitudesVacacionesScreen> {
  List<dynamic> solicitudes = [];
  bool isLoading = true;
  String? codigoEmpleado;

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
  }

  Future<void> _cargarSolicitudes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    codigoEmpleado = prefs.getString('codigo_empleado');

    if (codigoEmpleado != null) {
      try {
        List<dynamic> data = await VacacionesService.obtenerVacacionesPorEmpleado(codigoEmpleado!);
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : solicitudes.isEmpty
              ? const Center(child: Text("No tienes solicitudes de vacaciones registradas."))
              : ListView.builder(
                  itemCount: solicitudes.length,
                  itemBuilder: (context, index) {
                    var solicitud = solicitudes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(
                          "Desde: ${solicitud['fechaInicio']}  Hasta: ${solicitud['fechaFin']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Estado: ${solicitud['estado']}"),
                        trailing: Icon(
                          solicitud['estado'] == "Aprobada"
                              ? Icons.check_circle_outline
                              : solicitud['estado'] == "Rechazada"
                                  ? Icons.cancel_outlined
                                  : Icons.pending_outlined,
                          color: solicitud['estado'] == "Aprobada"
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
            MaterialPageRoute(builder: (context) => SolicitarVacacionesScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
