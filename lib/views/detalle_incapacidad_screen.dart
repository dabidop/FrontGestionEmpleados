import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/incapacidades_service.dart';

class DetalleIncapacidadScreen extends StatefulWidget {
  final int id;

  DetalleIncapacidadScreen({required this.id});

  @override
  _DetalleIncapacidadScreenState createState() =>
      _DetalleIncapacidadScreenState();
}

class _DetalleIncapacidadScreenState extends State<DetalleIncapacidadScreen> {
  Map<String, dynamic>? detalles;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDetalles();
  }

  Future<void> _cargarDetalles() async {
    try {
      final datos = await IncapacidadesService.obtenerDetallesIncapacidad(
        widget.id,
      );
      setState(() {
        detalles = datos;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar detalles: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _descargarArchivo() async {
    try {
      await IncapacidadesService.descargarArchivo(widget.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Archivo descargado con éxito')));
    } catch (e) {
      print('Error al descargar el archivo: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al descargar el archivo')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle de Incapacidad')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : detalles == null
              ? Center(child: Text('No se encontraron detalles'))
              : Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Incapacidad #${detalles!['idSolicitudIncapacidad']}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Código Empleado: ${detalles!['codigoEmpleado']}'),
                    Text(
                      'Fecha Inicio: ${detalles!['fechaInicioIncapacidad']}',
                    ),
                    Text('Fecha Fin: ${detalles!['fechaFinIncapacidad']}'),
                    Text('Fecha Solicitud: ${detalles!['fechaSolicitud']}'),
                    Text('Nombre Archivo: ${detalles!['nombreArchivo']}'),
                    Text('Tipo Archivo: ${detalles!['tipoArchivo']}'),
                    Text(
                      'Estado: ${detalles!['estadoIncapacidad'] ? "Vigente" : "Expirada"}',
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _descargarArchivo,
                      icon: Icon(Icons.download),
                      label: Text('Descargar Archivo'),
                    ),
                  ],
                ),
              ),
    );
  }
}
