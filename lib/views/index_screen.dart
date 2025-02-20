import 'package:flutter/material.dart';
import 'package:gestion_empleados/views/login_screen.dart';
import 'package:gestion_empleados/services/api_service.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key}); // ✅ Agregamos `super.key` para evitar warnings

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _menuButton(context, "Hojas de Vida"),
            _menuButton(context, "Cartas Laborales"),
            _menuButton(context, "Colillas de Nómina"),
            _menuButton(context, "Solicitudes de Vacaciones"),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("$title aún no está implementado."),
          ));
        },
        child: Text(title),
      ),
    );
  }
}
