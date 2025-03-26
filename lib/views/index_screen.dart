import 'package:flutter/material.dart';
import 'package:gestion_empleados/views/login_screen.dart';
import 'package:gestion_empleados/services/api_service.dart';
import 'package:gestion_empleados/widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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

  void _abrirModalCambiarContrasena() {
    showDialog(
      context: context,
      builder: (context) {
        final actualController = TextEditingController();
        final nuevaController = TextEditingController();
        final confirmarController = TextEditingController();

        return AlertDialog(
          title: Text("Cambiar contraseña"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: actualController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Contraseña actual",
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: nuevaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Nueva contraseña",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: confirmarController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirmar nueva contraseña",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              child: Text("Guardar"),
              onPressed: () async {
                final actual = actualController.text.trim();
                final nueva = nuevaController.text.trim();
                final confirmar = confirmarController.text.trim();

                if (actual.isEmpty || nueva.isEmpty || confirmar.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Todos los campos son obligatorios"),
                    ),
                  );
                  return;
                }

                if (nueva != confirmar) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Las contraseñas nuevas no coinciden"),
                    ),
                  );
                  return;
                }

                final ok = await ApiService.cambiarContrasena(actual, nueva);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? "Contraseña actualizada correctamente"
                          : "Error al cambiar la contraseña",
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
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
      //print('Error al cargar datos del perfil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 📌 Obtener horas y valor por hora
    double horas = (perfil?["horas_laboradas"] ?? 0).toDouble();
    double valorHora = (perfil?["valor_hora"] ?? 0).toDouble();
    double salarioCalculado = horas * valorHora;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
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
      body:
          perfil == null
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
                                      Expanded(
                                        child: _buildInfoList(
                                          true,
                                          horas,
                                          valorHora,
                                          salarioCalculado,
                                          constraints
                                              .maxWidth, // Solo agrego el ancho para manejar la responsividad
                                        ),
                                      ),
                                    ],
                                  )
                                  : _buildInfoList(
                                    true,
                                    horas,
                                    valorHora,
                                    salarioCalculado,
                                    constraints
                                        .maxWidth, // Se mantiene la estructura
                                  );
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

  // 📌 Función para formatear el dinero en pesos colombianos
  String _formatCurrency(double value) {
    final format = NumberFormat("#,##0", "es_CO"); // 🔹 Formato sin decimales
    return "\$ ${format.format(value)} pesos"; // 🔥 Asegura que el signo esté antes
  }

  // 📌 Función para convertir el tipo de contrato y el sexo en un valor más legible
  String _formatValue(String? key, String? value) {
    if (key == "contrato") {
      switch (value?.trim().toUpperCase()) {
        case "INDEF":
          return "Indefinido";
        case "FIJO":
          return "Fijo";
        default:
          return "Desconocido";
      }
    } else if (key == "sexo") {
      switch (value?.trim().toUpperCase()) {
        case "F":
          return "Femenino";
        case "M":
          return "Masculino";
        default:
          return "No especificado";
      }
    }
    return value ?? "No disponible";
  }

  // 📌 Construye las listas de información en columnas
  Widget _buildInfoList(
    bool isLeft,
    double horas,
    double valorHora,
    double salario,
    double
    screenWidth, // Solo agrego el ancho de la pantalla, sin tocar más nada
  ) {
    List<Widget> columna1 = [
      _buildInfoTile(Icons.badge, "Cédula", perfil?["codigo"]),
      _buildInfoTile(Icons.email, "Correo", perfil?["email"]),
      _buildInfoTile(Icons.account_box, "Cargo", perfil?["cargo"]),
      _buildInfoTile(Icons.phone, "Teléfono", perfil?["telefono"]),
      _buildInfoTile(
        Icons.calendar_today,
        "Fecha de nacimiento",
        _formatDate(perfil?["fecha_nacimiento"]),
      ),
    ];

    List<Widget> columna2 = [
      _buildInfoTile(
        Icons.child_friendly,
        "Hijos",
        perfil?["hijos"].toString(),
      ),
      _buildInfoTile(Icons.timer, "Horas por mes", horas.toString()),
      _buildInfoTile(
        Icons.attach_money,
        "Valor por Hora",
        _formatCurrency(valorHora),
      ),
      _buildInfoTile(
        Icons.monetization_on,
        "Salario base",
        _formatCurrency(salario),
      ),
      _buildInfoTile(Icons.location_city, "Dirección", perfil?["direccion"]),
    ];

    List<Widget> columna3 = [
      _buildInfoTile(
        Icons.article,
        "Tipo de contrato",
        _formatValue("contrato", perfil?["contrato"]),
      ),
      _buildInfoTile(
        Icons.calendar_today,
        "Fecha de ingreso",
        _formatDate(perfil?["fecha_ingreso"]),
      ),
      _buildInfoTile(
        Icons.transgender,
        "Sexo",
        _formatValue("sexo", perfil?["sexo"]),
      ),

      // 🔐 Botón para cambiar contraseña
      Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ElevatedButton.icon(
          onPressed: _abrirModalCambiarContrasena,
          icon: Icon(Icons.lock_outline),
          label: Text("Cambiar contraseña"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 249, 240),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    ];

    // 📌 Si la pantalla es menor a 500px, mostrar en una sola columna
    if (screenWidth < 500) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [...columna1, ...columna2, ...columna3],
      );
    }

    // 📌 Si la pantalla es mayor a 500px, mantener las 3 columnas
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Column(children: columna1)),
        SizedBox(width: 16), // Espaciado entre columnas
        Expanded(child: Column(children: columna2)),
        SizedBox(width: 16),
        Expanded(child: Column(children: columna3)),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "No disponible";

    try {
      // Aseguramos que no haya espacios raros y forzamos el formato
      DateTime date = DateTime.parse(dateStr.trim());
      // Formateamos correctamente la fecha
      return DateFormat(
        "d MMMM, y",
        "es",
      ).format(date); // Ejemplo: "17 septiembre, 1991"
    } catch (e) {
      //print("❌ Error al formatear fecha: $e");
      return "Formato inválido";
    }
  }

  // 📌 Función para construir un ListTile con icono y texto
  Widget _buildInfoTile(IconData icon, String label, String? value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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