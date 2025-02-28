import 'package:flutter/material.dart';
import 'package:gestion_empleados/views/incapacidades_screen.dart';
import 'package:gestion_empleados/views/login_screen.dart';
import 'package:gestion_empleados/services/api_service.dart';
import 'package:gestion_empleados/views/hojas_de_vida_screen.dart';
import 'package:gestion_empleados/views/cartas_laborales_screen.dart';
import 'package:gestion_empleados/views/colillas_nomina_screen.dart';
import 'package:gestion_empleados/views/solicitudes_vacaciones_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  _IndexScreenState createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
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
      setState(() {
        perfil = data;
      });
    } catch (e) {
      print('Error al cargar datos del perfil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menú Principal"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      // 🔥 Menú desplegable con el Drawer (Restaurado)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: const Text('Hojas de Vida'),
              onTap: () {
                // Verificar que el perfil y el código del empleado estén disponibles
                if (perfil != null && perfil!['codigo'] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => HojasDeVidaScreen(
                            codigoEmpleado:
                                perfil!['codigo'], // ✅ Pasa el código del empleado
                          ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Código de empleado no disponible'),
                    ),
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Incapacidades'),
              onTap: () async {
                // 🔥 Obtener el código del empleado desde SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? codigoEmpleado = prefs.getString('codigo_empleado');

                if (codigoEmpleado != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => IncapacidadesScreen(
                            codigoEmpleado: codigoEmpleado,
                          ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Código de empleado no disponible'),
                    ),
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Cartas Laborales'),
              onTap: () {
                if (perfil != null && perfil!['codigo'] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CartaLaboralPage(
                            codigoEmpleado: perfil!['codigo'],
                          ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Código de empleado no disponible'),
                    ),
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Colillas de Nómina'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ColillasNominaScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Solicitudes de Vacaciones'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SolicitudesVacacionesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // 🔥 Contenido principal: Información detallada del usuario
      body:
          perfil == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Información del Usuario",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // 🔥 Solo muestra los campos que EXISTEN en el JSON
                          ...perfil!.entries.map(
                            (entry) => Text(
                              "${entry.key}: ${entry.value}",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
