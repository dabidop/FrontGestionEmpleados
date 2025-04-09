import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/api_service.dart';
import 'package:gestion_empleados/widgets/custom_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:ui';


class CartaLaboralPage extends StatefulWidget {
  final String codigoEmpleado;

  CartaLaboralPage({required this.codigoEmpleado});

  @override
  _CartaLaboralPageState createState() => _CartaLaboralPageState();
}

class _CartaLaboralPageState extends State<CartaLaboralPage> {
  final storage = FlutterSecureStorage();
  bool drawerAbierto = false;
  String? pdfUrl;
  String viewID = "pdfIframe-${UniqueKey().toString()}";
  Map<String, dynamic>? perfil;

  // 🔹 Controladores para los campos de entrada
  TextEditingController destinatarioController = TextEditingController();
  String empresaSeleccionada = "ALV"; // Valor por defecto

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 26, 58),
        title: const Text(
          "Certificados laborales",
          style: TextStyle(color: Colors.white), // 🎯 texto blanco
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
                setState(() {
                  drawerAbierto = true;
                });
              },
              
            );
          },
        ),
      ),
      drawer: perfil == null ? null : CustomDrawer(perfil: perfil),
      onDrawerChanged: (isOpen) {
        setState(() {
          drawerAbierto = isOpen;
        });
      },
      body: SingleChildScrollView(
        // 🔥 Ahora toda la pantalla puede desplazarse
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Campo para ingresar el destinatario
              Text(
                "Destinatario:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: destinatarioController,
                decoration: InputDecoration(
                  hintText: "Ingrese el nombre del destinatario",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // 🔹 Dropdown para seleccionar la empresa
              Text(
                "Seleccione la empresa:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: empresaSeleccionada,
                items: [
                  DropdownMenuItem(
                    value: "ALV",
                    child: Text("GRUPO ALV S.A.S"),
                  ),
                  DropdownMenuItem(
                    value: "DENIM",
                    child: Text("DENIM LOVERS S.A.S"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    empresaSeleccionada = value!;
                  });
                },
              ),
              SizedBox(height: 20),

              // 🔹 Botón para generar la carta laboral
              Center(
                child: ElevatedButton(
                  onPressed: generarCartaLaboral,
                  child: Text("Generar Carta Laboral"),
                ),
              ),

              SizedBox(height: 30),

              // 🔹 Visor PDF (con tamaño fijo para evitar problemas)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10), // 🆕 Margen lateral
                child: pdfUrl != null && !drawerAbierto
                    ? SizedBox(
                      height: 600,
                      child:
                          kIsWeb
                              ? HtmlElementView(viewType: viewID)
                              : Center(
                                child: Text(
                                  "Previsualización no disponible en esta plataforma",
                                ),
                              ),
                    )
                    : Center(child: Text("Ingrese los datos y genere la carta")),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Función para generar la carta laboral con los datos ingresados
  Future<void> generarCartaLaboral() async {
    String apiUrl =
        "http://localhost:5219/api/CartasLaborales/generar/${widget.codigoEmpleado}/${destinatarioController.text}/${empresaSeleccionada}";

    String? token = await storage.read(key: "jwt_token");
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: No se encontró el token de autenticación"),
        ),
      );
      return;
    }

    try {
      final respuesta = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (respuesta.statusCode == 200) {
        final jsonData = jsonDecode(respuesta.body);
        String urlArchivo = jsonData['url'];
        urlArchivo = urlArchivo.replaceAll("https://localhost:5219", "");

        setState(() {
          pdfUrl =
              "$urlArchivo?timestamp=${DateTime.now().millisecondsSinceEpoch}";
          viewID = "pdfIframe-${UniqueKey().toString()}"; // 🔥 Forzar recarga
        });

        // 🔹 Registrar el iframe solo en Flutter Web
        if (kIsWeb) {
          ui.platformViewRegistry.registerViewFactory(
            viewID,
            (int viewId) =>
                html.IFrameElement()
                  ..src = pdfUrl
                  ..style.border = 'none'
                  ..width = '100%'
                  ..height = '100%',
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al generar la carta laboral")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión")));
    }
  }

  // 🔹 Función para descargar el PDF
  Future<void> descargarPDF() async {
    if (pdfUrl != null) {
      if (await canLaunch(pdfUrl!)) {
        await launch(pdfUrl!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se pudo abrir el enlace de descarga")),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No se encontró la URL del PDF")));
    }
  }
}
