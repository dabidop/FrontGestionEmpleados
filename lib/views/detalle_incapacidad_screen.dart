import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/api_service.dart';
import 'package:gestion_empleados/services/incapacidades_service.dart';
import 'package:gestion_empleados/widgets/custom_drawer.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Map<String, dynamic>? perfil;

  @override
  void initState() {
    super.initState();
    _loadPerfil();
    _cargarDetalles();
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

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return "No disponible";

    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat("d MMMM, y", "es").format(date);
      // Ejemplo de salida: "28 febrero, 2025"
    } catch (e) {
      //print("❌ Error al formatear fecha: $e");
      return "Formato inválido";
    }
  }

  Future<void> _cargarDetalles() async {
    try {
      final datos = await IncapacidadesService.obtenerDetallesIncapacidad(
        widget.id,
      );
      //print("Valor recibido: ${datos['estadoIncapacidad']}");
      //print("Tipo de dato: ${datos['estadoIncapacidad'].runtimeType}");
      setState(() {
        detalles = datos;
        isLoading = false;
      });
    } catch (e) {
      //print('Error al cargar detalles: $e');
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
      //print('Error al descargar el archivo: $e');
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

    bool estado = DateTime.parse(
      detalles!['fechaFinIncapacidad'],
    ).isAfter(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 26, 58),
        title: const Text(
          "Detalle de incapacidad",
          style: TextStyle(color: Colors.white), // 🎯 texto blanco
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: perfil == null ? null : CustomDrawer(perfil: perfil),
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
            Text('Empleado: ${perfil?['nombre'] ?? 'No disponible'} ${perfil?['nombre2']} ${perfil?['apellido']} ${perfil?['apellido2']}'),
            Text(
              'Fecha Inicio: ${_formatDate(detalles!['fechaInicioIncapacidad'])}',
            ),
            Text('Fecha Fin: ${_formatDate(detalles!['fechaFinIncapacidad'])}'),
            Text(
              'Fecha Solicitud: ${_formatDate(detalles!['fechaSolicitud'])}',
            ),
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
