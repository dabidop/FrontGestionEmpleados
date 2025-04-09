import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/api_service.dart';
import 'package:gestion_empleados/services/vacaciones_service.dart';
import 'package:gestion_empleados/widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetalleSolicitudScreen extends StatefulWidget {
  final Map<String, dynamic> solicitud;

  const DetalleSolicitudScreen({super.key, required this.solicitud});

  @override
  _DetalleSolicitudScreenState createState() => _DetalleSolicitudScreenState();
}

class _DetalleSolicitudScreenState extends State<DetalleSolicitudScreen> {
  String estadoSeleccionado = "Aprobada"; // ✅ Opción por defecto
  final TextEditingController observacionesController = TextEditingController();
  bool enviando = false;
  Map<String, dynamic>? perfil;

  @override
  void initState() {
    super.initState();
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
      //print('Error al cargar datos del perfil: $e');
    }
  }

  Future<void> actualizarEstado() async {
    setState(() {
      enviando = true;
    });

    bool success = await VacacionesService.actualizarEstadoSolicitud(
      idVacacion: widget.solicitud['idVacacion'],
      nuevoEstado: estadoSeleccionado,
      usuarioAprueba: widget.solicitud['usuarioAprueba'],
      observaciones: observacionesController.text,
    );

    setState(() {
      enviando = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solicitud actualizada con éxito")),
      );
      Navigator.pop(context, true); // 🔥 Volver a la lista y recargar
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al actualizar la solicitud")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 26, 58),
        title: const Text(
          "Detalle de solicitud",
          style: TextStyle(color: Colors.white), // 🎯 texto blanco
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: perfil == null ? null : CustomDrawer(perfil: perfil),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Empleado: ${widget.solicitud['codigoEmpleado']}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text("Fecha Inicio: ${widget.solicitud['fechaInicio']}"),
            Text("Fecha Fin: ${widget.solicitud['fechaFin']}"),
            Text("Días de descanso: ${widget.solicitud['diasDescanso'] ?? 0}"),
            Text("Días en plata: ${widget.solicitud['diasPlata'] ?? 0}"),
            Text(
              "Valor pago en plata: \$${widget.solicitud['valorPagoPlata']?.toStringAsFixed(0) ?? '0'}",
            ),
            const SizedBox(height: 20),

            // ✅ Dropdown para seleccionar estado
            DropdownButton<String>(
              value: estadoSeleccionado,
              items:
                  ["Aprobada", "Rechazada"].map((String estado) {
                    return DropdownMenuItem(value: estado, child: Text(estado));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  estadoSeleccionado = value!;
                });
              },
            ),
            const SizedBox(height: 10),

            // ✅ Campo de observaciones
            TextField(
              controller: observacionesController,
              decoration: const InputDecoration(
                labelText: "Observaciones (opcional)",
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Botón de confirmar
            ElevatedButton(
              onPressed: enviando ? null : actualizarEstado,
              child: Text(enviando ? "Enviando..." : "Confirmar"),
            ),
          ],
        ),
      ),
    );
  }
}
