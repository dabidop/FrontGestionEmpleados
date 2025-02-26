import 'package:flutter/material.dart';

class AprobarSolicitudesScreen extends StatelessWidget {
  const AprobarSolicitudesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aprobar Solicitudes"),
      ),
      body: const Center(
        child: Text(
          "Aquí irán las solicitudes para aprobar",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
