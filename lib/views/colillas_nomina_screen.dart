import 'package:flutter/material.dart';
import 'package:gestion_empleados/widgets/custom_drawer.dart';

class ColillasNominaScreen extends StatelessWidget {
  const ColillasNominaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 26, 58),
        title: const Text(
          "Colillas de nómina",
          style: TextStyle(color: Colors.white), // 🎯 texto blanco
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: CustomDrawer(perfil: null), // 🔥 Usa el Drawer
      body: const Center(
        child: Text(
          "Aquí irán las Colillas de Nómina",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
