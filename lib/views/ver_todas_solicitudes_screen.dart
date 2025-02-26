import 'package:flutter/material.dart';

class VerTodasSolicitudesScreen extends StatelessWidget {
  const VerTodasSolicitudesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ver Todas las Solicitudes"),
      ),
      body: const Center(
        child: Text(
          "Aquí se mostrarán todas las solicitudes",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
