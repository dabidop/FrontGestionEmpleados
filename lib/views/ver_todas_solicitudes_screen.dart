import 'package:flutter/material.dart';
import 'package:gestion_empleados/widgets/custom_drawer.dart';

class VerTodasSolicitudesScreen extends StatelessWidget {
  const VerTodasSolicitudesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ver Todas las Solicitudes"),
      ),
      drawer: CustomDrawer(perfil: null), // 🔥 Usa el Drawer
      body: const Center(
        child: Text(
          "Aquí se mostrarán todas las solicitudes",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
