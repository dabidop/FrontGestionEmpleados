import 'package:flutter/material.dart';
import 'package:gestion_empleados/views/incapacidades_screen.dart';
import 'package:gestion_empleados/views/index_screen.dart';
import 'package:gestion_empleados/views/lista_vacaciones_screen.dart';
import 'package:gestion_empleados/views/login_screen.dart';
import 'package:gestion_empleados/views/hojas_de_vida_screen.dart';
import 'package:gestion_empleados/views/cartas_laborales_screen.dart';
import 'package:gestion_empleados/views/colillas_nomina_screen.dart';
import 'package:gestion_empleados/views/aprobar_solicitudes_screen.dart';
import 'package:gestion_empleados/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  final Map<String, dynamic>? perfil;

  const CustomDrawer({Key? key, required this.perfil}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // 🔥 Imagen de la empresa en la parte superior
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: Colors.blue,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                    'assets/imgalv.png',
                  ), // Asegúrate de agregar la imagen a assets
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home), // 🔥 Ícono de inicio
            title: Text("Inicio"),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => IndexScreen(),
                ), // 🔥 Redirige a Inicio
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: const Text('Hojas de Vida'),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? codigoEmpleado =
                  perfil?['codigo'] ?? prefs.getString('codigo_empleado');

              print("🔍 Código de empleado antes de navegar: $codigoEmpleado");

              if (codigoEmpleado != null) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            HojasDeVidaScreen(codigoEmpleado: codigoEmpleado),
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
            leading: Icon(Icons.business),
            title: const Text('Certificados Laborales'),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? codigoEmpleado =
                  perfil?['codigo'] ?? prefs.getString('codigo_empleado');

              print("🔍 Código de empleado antes de navegar: $codigoEmpleado");

              if (codigoEmpleado != null) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            CartaLaboralPage(codigoEmpleado: codigoEmpleado),
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
            leading: Icon(Icons.local_hospital),
            title: const Text('Incapacidades'),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? codigoEmpleado = prefs.getString('codigo_empleado');
              if (codigoEmpleado != null) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            IncapacidadesScreen(codigoEmpleado: codigoEmpleado),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.beach_access),
            title: const Text('Solicitudes de Vacaciones'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SolicitudesVacacionesScreen(),
                ),
              );
            },
          ),
          if (perfil != null && perfil!['esAprobador'] == true)
            ListTile(
              leading: Icon(Icons.verified),
              title: const Text('Aprobar Solicitudes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AprobarSolicitudesScreen(),
                  ),
                );
              },
            ),
          ListTile(
            leading: Icon(Icons.payments),
            title: const Text('Colillas de Nómina'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ColillasNominaScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () async {
              bool? confirmLogout = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Confirmar cierre de sesión"),
                    content: Text(
                      "¿Estás seguro de que quieres cerrar sesión?",
                    ),
                    actions: [
                      TextButton(
                        onPressed:
                            () =>
                                Navigator.of(context).pop(false), // ❌ Cancelar
                        child: Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed:
                            () =>
                                Navigator.of(context).pop(true), // ✅ Confirmar
                        child: Text("Cerrar sesión"),
                      ),
                    ],
                  );
                },
              );

              if (confirmLogout == true) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('codigo_empleado');

                await ApiService.logout();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
