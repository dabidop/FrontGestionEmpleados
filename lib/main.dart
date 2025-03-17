import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/login_screen.dart';
import 'views/index_screen.dart';
import 'package:intl/date_symbol_data_local.dart'; // 👈 Importación necesaria

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 👈 Asegura la inicialización
  await initializeDateFormatting('es', null); // 👈 Carga los datos del idioma español
  runApp(const GestionEmpleadosApp());
}

class GestionEmpleadosApp extends StatefulWidget {
  const GestionEmpleadosApp({super.key});

  @override
  _GestionEmpleadosAppState createState() => _GestionEmpleadosAppState();
}

class _GestionEmpleadosAppState extends State<GestionEmpleadosApp> {
  String? codigoEmpleado;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      codigoEmpleado = prefs.getString('codigo_empleado');
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestión de Empleados',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : codigoEmpleado != null
              ? const IndexScreen()
              : const LoginScreen(),
    );
  }
}