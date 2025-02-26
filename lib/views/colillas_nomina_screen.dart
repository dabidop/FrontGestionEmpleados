import 'package:flutter/material.dart';

class ColillasNominaScreen extends StatelessWidget {
  const ColillasNominaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Colillas de Nómina"),
      ),
      body: const Center(
        child: Text(
          "Aquí irán las Colillas de Nómina",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
