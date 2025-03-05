import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/vacaciones_service.dart';
import 'package:gestion_empleados/views/lista_vacaciones_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SolicitarVacacionesScreen extends StatefulWidget {
  @override
  _SolicitarVacacionesScreenState createState() =>
      _SolicitarVacacionesScreenState();
}

class _SolicitarVacacionesScreenState extends State<SolicitarVacacionesScreen> {
  DateTime? fechaInicio;
  DateTime? fechaFin;
  String? usuarioAprueba;
  bool enviando = false;
  List<Map<String, String>> aprobadores = [];

  @override
  void initState() {
    super.initState();
    cargarAprobadores();
  }

  // ✅ Obtener aprobadores desde la API
  Future<void> cargarAprobadores() async {
    try {
      List<Map<String, String>> lista =
          await VacacionesService.obtenerAprobadores();
      setState(() {
        aprobadores = lista;
      });
    } catch (e) {
      print("Error al obtener aprobadores: $e");
    }
  }

  // ✅ Obtener código de empleado del usuario logueado
  Future<String?> getCodigoEmpleado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('codigo_empleado');
  }

  // ✅ Método para seleccionar fechas
  Future<void> seleccionarFecha(BuildContext context, bool esInicio) async {
    DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        if (esInicio) {
          fechaInicio = fechaSeleccionada;
        } else {
          fechaFin = fechaSeleccionada;
        }
      });
    }
  }

  // ✅ Validar y enviar la solicitud
  Future<void> enviarSolicitud() async {
    if (fechaInicio == null || fechaFin == null || usuarioAprueba == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return;
    }

    // ✅ Obtener el código del empleado desde SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? codigoEmpleado = prefs.getString("codigo_empleado");

    if (codigoEmpleado == null || codigoEmpleado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: No se encontró el código de empleado"),
        ),
      );
      return;
    }

    int diasSolicitados = fechaFin!.difference(fechaInicio!).inDays + 1;

    bool success = await VacacionesService.solicitarVacaciones(
      codigoEmpleado: codigoEmpleado, // ✅ Ahora lo obtenemos correctamente
      fechaInicio: fechaInicio!,
      fechaFin: fechaFin!,
      diasSolicitados: diasSolicitados,
      usuarioAprueba: usuarioAprueba!,
      observaciones: "Solicitud generada desde la app.",
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solicitud enviada con éxito")),
      );

      // 🔥 Redirigir automáticamente a la lista de solicitudes
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SolicitudesVacacionesScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al enviar la solicitud")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Solicitar Vacaciones")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Selecciona las fechas:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text(
                "Inicio: ${fechaInicio != null ? fechaInicio.toString().split(' ')[0] : "Seleccionar"}",
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    fechaInicio = picked;
                  });
                }
              },
            ),
            ListTile(
              title: Text(
                "Fin: ${fechaFin != null ? fechaFin.toString().split(' ')[0] : "Seleccionar"}",
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: fechaInicio ?? DateTime.now(),
                  firstDate: fechaInicio ?? DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    fechaFin = picked;
                  });
                }
              },
            ),
            Text(
              "Selecciona el aprobador:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: usuarioAprueba,
              hint: Text("Selecciona un aprobador"),
              isExpanded: true,
              items:
                  aprobadores.map((aprobador) {
                    return DropdownMenuItem<String>(
                      value: aprobador["codigo"],
                      child: Text(aprobador["nombre"]!),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  usuarioAprueba = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: enviarSolicitud,
              child: Text("Enviar Solicitud"),
            ),
          ],
        ),
      ),
    );
  }
}
