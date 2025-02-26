import 'package:flutter/material.dart';

class CartasLaboralesScreen extends StatelessWidget {
  const CartasLaboralesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cartas Laborales"),
      ),
      body: const Center(
        child: Text(
          "Aquí irán las Cartas Laborales",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
