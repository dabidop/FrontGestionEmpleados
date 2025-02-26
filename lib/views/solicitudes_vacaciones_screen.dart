import 'package:flutter/material.dart';

class SolicitudesVacacionesScreen extends StatelessWidget {
  const SolicitudesVacacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solicitudes de Vacaciones"),
      ),
      body: const Center(
        child: Text(
          "Aquí irán las Solicitudes de Vacaciones",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
