import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/vacaciones_service.dart';
import 'package:gestion_empleados/views/lista_vacaciones_screen.dart';
import 'package:gestion_empleados/widgets/custom_drawer.dart';
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
  int? diasDescanso;
  int? diasPlata;

  @override
  void initState() {
    super.initState();
    cargarAprobadores();
  }

  Future<bool> _mostrarConfirmacionVacaciones(
    DateTime inicio,
    DateTime fin,
    int dias,
    String aprobador,
  ) async {
    final aprobadorNombre =
        aprobadores.firstWhere((a) => a['codigo'] == aprobador)['nombre'];

    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Confirmar Solicitud"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "¿Estás seguro de registrar esta solicitud de vacaciones?",
                    ),
                    const SizedBox(height: 10),
                    Text("📅 Inicio: ${inicio.toString().split(' ')[0]}"),
                    Text("📅 Fin: ${fin.toString().split(' ')[0]}"),
                    Text("📆 Días solicitados: $dias"),
                    Text("🧑‍💼 Aprobador: $aprobadorNombre"),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Confirmar"),
                  ),
                ],
              ),
        ) ??
        false;
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

    int contarDiasHabiles(DateTime inicio, DateTime fin) {
      int diasHabiles = 0;
      DateTime fecha = inicio;

      while (!fecha.isAfter(fin)) {
        if (fecha.weekday >= DateTime.monday &&
            fecha.weekday <= DateTime.friday) {
          diasHabiles++;
        }
        fecha = fecha.add(Duration(days: 1));
      }

      return diasHabiles;
    }

    //int diasSolicitados = fechaFin!.difference(fechaInicio!).inDays + 1;
    int diasSolicitados = contarDiasHabiles(fechaInicio!, fechaFin!);


    if (diasDescanso == null || diasPlata == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Debes indicar cuántos días son de descanso y cuántos en plata",
          ),
        ),
      );
      return;
    }

    if ((diasDescanso! + diasPlata!) != diasSolicitados) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "La suma de los días debe ser igual a los días solicitados.",
          ),
        ),
      );
      return;
    }

    if (diasPlata! > (diasSolicitados / 2)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Solo puedes solicitar hasta el 50% en compensación económica.",
          ),
        ),
      );
      return;
    }

    if (diasPlata! > diasDescanso!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Los días en plata no pueden ser mayores a los de descanso.",
          ),
        ),
      );
      return;
    }

    // 🔥 Mostrar la alerta de confirmación
    final confirmado = await _mostrarConfirmacionVacaciones(
      fechaInicio!,
      fechaFin!,
      diasSolicitados,
      usuarioAprueba!,
    );

    if (!confirmado) return;

    final resultado = await VacacionesService.solicitarVacaciones(
      codigoEmpleado: codigoEmpleado,
      fechaInicio: fechaInicio!,
      fechaFin: fechaFin!,
      diasSolicitados: diasSolicitados,
      usuarioAprueba: usuarioAprueba!,
      observaciones: "Solicitud generada desde la app.",
      diasDescanso: diasDescanso!, // ✅ NUEVO
      diasPlata: diasPlata!, // ✅ NUEVO
    );

    if (resultado["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solicitud enviada con éxito")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SolicitudesVacacionesScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado["message"] ?? "Error desconocido")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 26, 58),
        title: const Text(
          "Solicitar vacaciones",
          style: TextStyle(color: Colors.white), // 🎯 texto blanco
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: CustomDrawer(perfil: null), // 🔥 Usa el Drawer
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
                      child: Text(
                        "${aprobador["nombre"]} - ${aprobador["cargo"]}",
                        overflow:
                            TextOverflow
                                .ellipsis, // Evita que el texto se desborde
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  usuarioAprueba = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              "Días de descanso y en compensación económica:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Días de descanso"),
              onChanged: (value) {
                diasDescanso = int.tryParse(value);
              },
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Días en plata (máximo 50%)",
              ),
              onChanged: (value) {
                diasPlata = int.tryParse(value);
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
