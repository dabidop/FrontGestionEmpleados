import 'package:flutter/material.dart';
import 'package:gestion_empleados/widgets/custom_drawer.dart';

class ColillasNominaScreen extends StatelessWidget {
  const ColillasNominaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Colillas de Nómina"),
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
