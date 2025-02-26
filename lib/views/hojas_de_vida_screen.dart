import 'package:flutter/material.dart';

class HojasDeVidaScreen extends StatelessWidget {
  const HojasDeVidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hojas de Vida"),
      ),
      body: const Center(
        child: Text(
          "Aquí irán las Hojas de Vida",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
