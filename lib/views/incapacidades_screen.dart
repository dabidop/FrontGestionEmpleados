import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/api_service.dart';
import 'package:gestion_empleados/services/incapacidades_service.dart';
import 'package:gestion_empleados/views/crear_incapacidad_modal.dart';
import 'package:gestion_empleados/views/detalle_incapacidad_screen.dart';
import 'package:gestion_empleados/widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class IncapacidadesScreen extends StatefulWidget {
  final String codigoEmpleado;

  IncapacidadesScreen({required this.codigoEmpleado});

  @override
  _IncapacidadesScreenState createState() => _IncapacidadesScreenState();
}

class _IncapacidadesScreenState extends State<IncapacidadesScreen> {
  List<dynamic> incapacidades = [];
  bool isLoading = true;
  Map<String, dynamic>? perfil;

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

  @override
  void initState() {
    super.initState();
    _cargarIncapacidades();
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

  Future<void> _cargarIncapacidades() async {
    try {
      final datos = await IncapacidadesService.obtenerIncapacidadesPorEmpleado(
        widget.codigoEmpleado,
      );
      setState(() {
        incapacidades = datos;
        isLoading = false;
      });
    } catch (e) {
      //print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 26, 58),
        title: const Text(
          "Incapacidades",
          style: TextStyle(color: Colors.white), // 🎯 texto blanco
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: perfil == null ? null : CustomDrawer(perfil: perfil),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: incapacidades.length,
                itemBuilder: (context, index) {
                  final incapacidad = incapacidades.reversed.toList()[index]; 
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text('Incapacidad: ${incapacidad['id']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Empleado: ${perfil?['nombre'] ?? 'No disponible'} ${perfil?['nombre2']} ${perfil?['apellido']} ${perfil?['apellido2']}'),
                          Text('Código de empleado: ${incapacidad['codigoEmpleado']}'),
                          Text('Desde: ${_formatDate(incapacidad['fechaInicio'])}'),
                          Text('Hasta: ${_formatDate(incapacidad['fechaFin'])}'),
                          Text('Archivo: ${incapacidad['nombreArchivo']}'),
                          Text('Estado: ${incapacidad['estado']}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DetalleIncapacidadScreen(
                                  id: incapacidad['id'],
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 🔥 Abre el modal y espera a que se cierre
          await showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder:
                (context) => CrearIncapacidadModal(
                  codigoEmpleado: widget.codigoEmpleado,
                ),
          );

          // 🔥 Recarga la lista cuando el modal se cierra
          setState(() {
            isLoading = true;
          });
          _cargarIncapacidades();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
