import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gestion_empleados/services/incapacidades_service.dart';

class CrearIncapacidadModal extends StatefulWidget {
  final String codigoEmpleado;

  CrearIncapacidadModal({required this.codigoEmpleado});

  @override
  _CrearIncapacidadModalState createState() => _CrearIncapacidadModalState();
}

class _CrearIncapacidadModalState extends State<CrearIncapacidadModal> {
  DateTime? fechaInicio;
  DateTime? fechaFin;
  PlatformFile? archivo;

  Future<void> _seleccionarArchivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        archivo = result.files.first;
      });
    }
  }

  Future<void> _crearIncapacidad() async {
    if (fechaInicio != null && fechaFin != null && archivo != null) {
      try {
        await IncapacidadesService.crearIncapacidad(
          widget.codigoEmpleado,
          fechaInicio!,
          fechaFin!,
          archivo!.name,
          archivo!.bytes!,
        );

        // 🔥 Cierra el modal
        Navigator.pop(context);

        // 🔥 Muestra un mensaje de éxito
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Incapacidad creada con éxito')));
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear la incapacidad')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos')),
      );
    }
  }

  Future<void> _seleccionarFechaInicio() async {
    DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha != null) {
      setState(() {
        fechaInicio = fecha;
      });
    }
  }

  Future<void> _seleccionarFechaFin() async {
    DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha != null) {
      setState(() {
        fechaFin = fecha;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Crear Incapacidad',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // 🔥 Campo para seleccionar Fecha de Inicio
            ListTile(
              title: Text('Fecha Inicio'),
              subtitle: Text(
                fechaInicio != null
                    ? fechaInicio.toString().split(' ')[0]
                    : 'Seleccione la fecha',
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: _seleccionarFechaInicio,
            ),
            SizedBox(height: 10),

            // 🔥 Campo para seleccionar Fecha Fin
            ListTile(
              title: Text('Fecha Fin'),
              subtitle: Text(
                fechaFin != null
                    ? fechaFin.toString().split(' ')[0]
                    : 'Seleccione la fecha',
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: _seleccionarFechaFin,
            ),
            SizedBox(height: 10),

            // 🔥 Botón para seleccionar archivo
            ElevatedButton(
              onPressed: _seleccionarArchivo,
              child: Text(archivo == null ? 'Seleccionar PDF' : archivo!.name),
            ),
            SizedBox(height: 10),

            // 🔥 Botón para crear la incapacidad
            ElevatedButton(
              onPressed: _crearIncapacidad,
              child: Text('Crear Incapacidad'),
            ),
          ],
        ),
      ),
    );
  }
}
