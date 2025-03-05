import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/vacaciones_service.dart';

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
      appBar: AppBar(title: const Text("Detalle Solicitud")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Empleado: ${widget.solicitud['codigoEmpleado']}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Fecha Inicio: ${widget.solicitud['fechaInicio']}"),
            Text("Fecha Fin: ${widget.solicitud['fechaFin']}"),
            const SizedBox(height: 20),

            // ✅ Dropdown para seleccionar estado
            DropdownButton<String>(
              value: estadoSeleccionado,
              items: ["Aprobada", "Rechazada"].map((String estado) {
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
              decoration: const InputDecoration(labelText: "Observaciones (opcional)"),
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
