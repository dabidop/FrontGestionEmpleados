import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/incapacidades_service.dart';
import 'package:gestion_empleados/views/crear_incapacidad_modal.dart';
import 'package:gestion_empleados/views/detalle_incapacidad_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncapacidadesScreen extends StatefulWidget {
  final String codigoEmpleado;

  IncapacidadesScreen({required this.codigoEmpleado});

  @override
  _IncapacidadesScreenState createState() => _IncapacidadesScreenState();
}

class _IncapacidadesScreenState extends State<IncapacidadesScreen> {
  List<dynamic> incapacidades = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarIncapacidades();
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
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Incapacidades')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: incapacidades.length,
                itemBuilder: (context, index) {
                  final incapacidad = incapacidades[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text('Incapacidad: ${incapacidad['id']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Empleado: ${incapacidad['codigoEmpleado']}'),
                          Text(
                            'Fecha: ${incapacidad['fechaInicio']} - ${incapacidad['fechaFin']}',
                          ),
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
