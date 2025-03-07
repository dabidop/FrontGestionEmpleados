import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/incapacidades_service.dart';
import 'package:gestion_empleados/widgets/custom_drawer.dart';

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
      print("Valor recibido: ${datos['estadoIncapacidad']}");
      print("Tipo de dato: ${datos['estadoIncapacidad'].runtimeType}");
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
    if (isLoading || detalles == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Detalle de Incapacidad')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    bool estado = detalles!['estadoIncapacidad'] == true;

    return Scaffold(
      appBar: AppBar(title: Text('Detalle de Incapacidad')),
      drawer: CustomDrawer(perfil: null),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Incapacidad #${detalles!['idSolicitudIncapacidad']}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Código Empleado: ${detalles!['codigoEmpleado']}'),
            Text('Fecha Inicio: ${detalles!['fechaInicioIncapacidad']}'),
            Text('Fecha Fin: ${detalles!['fechaFinIncapacidad']}'),
            Text('Fecha Solicitud: ${detalles!['fechaSolicitud']}'),
            Text('Nombre Archivo: ${detalles!['nombreArchivo']}'),
            Text('Tipo Archivo: ${detalles!['tipoArchivo']}'),
            Text(
              'Estado: ${estado ? "Vigente" : "Expirada"}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: estado ? Colors.green : Colors.red,
              ),
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
