import 'package:flutter/material.dart';
import 'package:gestion_empleados/views/login_screen.dart';
import 'package:gestion_empleados/services/api_service.dart';
import 'package:gestion_empleados/widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  _IndexScreenState createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  Map<String, dynamic>? perfil;

  @override
  void initState() {
    super.initState();
    _loadPerfil();
  }

  // ✅ Cargar los datos del perfil del usuario desde la API
  Future<void> _loadPerfil() async {
    try {
      var data = await ApiService.getPerfil();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (data != null && data['codigo'] != null) {
        await prefs.setString('codigo_empleado', data['codigo']);
      }

      setState(() {
        perfil = data;
      });
    } catch (e) {
      print('Error al cargar datos del perfil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 📌 Obtener horas y valor por hora
    double horas = (perfil?["horas"] ?? 0).toDouble();
    double valorHora = (perfil?["valor_hora"] ?? 0).toDouble();
    double salarioCalculado = horas * valorHora;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Menú Principal"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      drawer: CustomDrawer(perfil: perfil),
      body: perfil == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // 📌 Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            _getIniciales(perfil?["nombre"]),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // 📌 Nombre y Cargo
                        Text(
                          perfil?["nombre"] ?? "Usuario Desconocido",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          perfil?["cargo"] ?? "Cargo no disponible",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const Divider(height: 30),

                        // 📌 Diseño con Columnas Responsivas
                        LayoutBuilder(
                          builder: (context, constraints) {
                            bool isWideScreen = constraints.maxWidth > 600;
                            return isWideScreen
                                ? Row(
                                    children: [
                                      Expanded(child: _buildInfoList(true, horas, valorHora, salarioCalculado)),
                                      Expanded(child: _buildInfoList(false, horas, valorHora, salarioCalculado)),
                                    ],
                                  )
                                : _buildInfoList(true, horas, valorHora, salarioCalculado);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // 📌 Construye las listas de información en columnas
  Widget _buildInfoList(bool isLeft, double horas, double valorHora, double salario) {
    List<Widget> items = isLeft
        ? [
            _buildInfoTile(Icons.badge, "Código", perfil?["codigo"]),
            _buildInfoTile(Icons.email, "Correo", perfil?["correo"]),
            _buildInfoTile(Icons.phone, "Teléfono", perfil?["telefono"]),
          ]
        : [
            _buildInfoTile(Icons.location_city, "Empresa", perfil?["empresa"]),
            _buildInfoTile(Icons.timer, "Horas trabajadas", horas.toString()),
            _buildInfoTile(Icons.attach_money, "Valor por Hora", "\$${valorHora.toStringAsFixed(2)}"),
            _buildInfoTile(Icons.monetization_on, "Salario Calculado", "\$${salario.toStringAsFixed(2)}"),
          ];

    return Column(children: items);
  }

  // 📌 Función para construir un ListTile con icono y texto
  Widget _buildInfoTile(IconData icon, String label, String? value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(value ?? "No disponible"),
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    );
  }

  // 📌 Obtener iniciales para el Avatar
  String _getIniciales(String? nombre) {
    if (nombre == null || nombre.isEmpty) return "U";
    List<String> partes = nombre.split(" ");
    String iniciales = partes.map((e) => e.isNotEmpty ? e[0] : "").join();
    return iniciales.toUpperCase();
  }
}
