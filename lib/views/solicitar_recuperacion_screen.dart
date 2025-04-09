import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/api_service.dart';
import 'confirmar_recuperacion_screen.dart';

class SolicitarRecuperacionScreen extends StatefulWidget {
  @override
  _SolicitarRecuperacionScreenState createState() => _SolicitarRecuperacionScreenState();
}

class _SolicitarRecuperacionScreenState extends State<SolicitarRecuperacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _enviarCodigo() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final success = await ApiService.enviarCodigoRecuperacion(email);

    setState(() => _isLoading = false);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmarRecuperacionScreen(email: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar el código. Verifica el correo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 26, 58),
        title: const Text(
          "Recuperar contraseña",
          style: TextStyle(color: Colors.white), // 🎯 texto blanco
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Ingresa tu correo para enviarte un código de recuperación"),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Correo electrónico"),
                validator: (value) =>
                    value != null && value.contains('@') ? null : "Correo inválido",
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _enviarCodigo,
                      child: Text("Enviar código"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
