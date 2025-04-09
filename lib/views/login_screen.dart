import 'package:flutter/material.dart';
import 'package:gestion_empleados/views/solicitar_recuperacion_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestion_empleados/views/index_screen.dart';
import 'package:gestion_empleados/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  }); // ✅ Agregamos `super.key` para evitar warnings

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController codigoVerificacionController =
      TextEditingController();
  bool isLoading = false;
  bool necesitaVerificacion = false;
  String emailPendiente = "";

  Future<void> _login() async {
    setState(() => isLoading = true);

    var response = await ApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (response["success"]) {
      if (response["isRegistered"]) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const IndexScreen()),
        );
      } else {
        setState(() {
          necesitaVerificacion = true;
          emailPendiente = response["email"];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Código enviado a ${response["email"]}. Ingrésalo para continuar.<br>",
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "Error en el login")),
      );
    }
  }

  Future<void> _confirmarRegistro() async {
    setState(() => isLoading = true);

    bool success = await ApiService.confirmarRegistro(
      emailPendiente,
      codigoVerificacionController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registro confirmado. Ahora puedes iniciar sesión."),
        ),
      );
      setState(() {
        necesitaVerificacion = false;
        emailController.clear();
        passwordController.clear();
        codigoVerificacionController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código incorrecto o expirado.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Iniciar Sesión",
          style: TextStyle(color: Colors.white), // 🎯 texto blanco
        ),
        backgroundColor: const Color.fromARGB(255, 26, 26, 58),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Image.asset(
                        'assets/logo_login.png',
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Correo Electrónico",
                        ),
                      ),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: "Contraseña",
                        ),
                        obscureText: true,
                      ),
                      if (necesitaVerificacion) ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: codigoVerificacionController,
                          decoration: const InputDecoration(
                            labelText: "Código de Verificación",
                          ),
                        ),
                        const SizedBox(height: 10),
                        isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                              onPressed: _confirmarRegistro,
                              child: const Text("Confirmar Registro"),
                            ),
                      ] else ...[
                        const SizedBox(height: 20),
                        isLoading
                            ? const CircularProgressIndicator()
                            : Column(
                              children: [
                                ElevatedButton(
                                  onPressed: _login,
                                  child: const Text("Ingresar"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                SolicitarRecuperacionScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "¿Olvidaste tu contraseña?",
                                    style: TextStyle(color: Colors.blueAccent),
                                  ),
                                ),
                              ],
                            ),
                      ],
                      const Spacer(), // para empujar el contenido si hay espacio
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
