import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/api_service.dart';
import 'package:gestion_empleados/views/login_screen.dart';

class ConfirmarRecuperacionScreen extends StatefulWidget {
  final String email;

  ConfirmarRecuperacionScreen({required this.email});

  @override
  _ConfirmarRecuperacionScreenState createState() =>
      _ConfirmarRecuperacionScreenState();
}

class _ConfirmarRecuperacionScreenState
    extends State<ConfirmarRecuperacionScreen> {
  final codigoController = TextEditingController();
  final nuevaController = TextEditingController();
  final confirmarController = TextEditingController();
  bool cargando = false;

  void _restablecer() async {
    final codigo = codigoController.text.trim();
    final nueva = nuevaController.text.trim();
    final confirmar = confirmarController.text.trim();

    if (codigo.isEmpty || nueva.isEmpty || confirmar.isEmpty) {
      _mostrar("Todos los campos son obligatorios");
      return;
    }

    if (nueva != confirmar) {
      _mostrar("Las contraseñas no coinciden");
      return;
    }

    setState(() => cargando = true);

    final ok = await ApiService.confirmarRecuperacion(
      widget.email,
      codigo,
      nueva,
    );

    setState(() => cargando = false);

    if (ok) {
      _mostrar("Contraseña actualizada correctamente");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } else {
      _mostrar("Error al actualizar la contraseña");
    }
  }

  void _mostrar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Confirmar Recuperación")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: codigoController,
              decoration: InputDecoration(labelText: "Código de verificación"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: nuevaController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Nueva contraseña"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: confirmarController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirmar nueva contraseña",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: cargando ? null : _restablecer,
              child: Text("Actualizar contraseña"),
            ),
          ],
        ),
      ),
    );
  }
}
