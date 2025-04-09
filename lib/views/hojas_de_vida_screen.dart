import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gestion_empleados/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:gestion_empleados/widgets/custom_drawer.dart'; // Importa el Drawer

class HojasDeVidaScreen extends StatefulWidget {
  final String codigoEmpleado;

  HojasDeVidaScreen({required this.codigoEmpleado});

  @override
  _HojasDeVidaScreenState createState() => _HojasDeVidaScreenState();
}

class _HojasDeVidaScreenState extends State<HojasDeVidaScreen> {
  final storage = FlutterSecureStorage();
  bool drawerAbierto = false;
  String? pdfUrl;
  String viewID = "pdfIframe-${UniqueKey().toString()}";
  String empresaSeleccionada = "ALV"; // Valor por defecto
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
      //print('Error al cargar datos del perfil: $e');
    }
  }

  Future<void> generarHojaDeVida() async {
    String apiUrl =
        "http://localhost:5219/api/HojasDeVida/generar/${widget.codigoEmpleado}/${empresaSeleccionada}";

    String? token = await storage.read(key: "jwt_token");
    if (token == null) {
      //print("❌ No se encontró el token JWT.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: No se encontró el token de autenticación"),
        ),
      );
      return;
    }

    // 🔥 IMPRIMIMOS EL TOKEN Y LOS HEADERS PARA VERIFICARLO
    //print("🔥 Token enviado en la petición: $token");
    //print("🔥 URL de la petición: $apiUrl");

    try {
      final respuesta = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      //print("🔍 Código de respuesta HTTP: ${respuesta.statusCode}");
      //print("🔍 Cuerpo de la respuesta: ${respuesta.body}");

      if (respuesta.statusCode == 200) {
        final jsonData = jsonDecode(respuesta.body);
        String urlArchivo = jsonData['url'];
        visualizarPDF(urlArchivo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al generar la hoja de vida")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión")));
    }
  }

  void visualizarPDF(String url) async {
    if (kIsWeb) {
      // 🚀 WEB: Usa iframe en la misma vista
      setState(() {
        pdfUrl = "$url?timestamp=${DateTime.now().millisecondsSinceEpoch}";
        viewID = "pdfIframe-${UniqueKey().toString()}";
      });

      ui.platformViewRegistry.registerViewFactory(viewID, (int viewId) {
        final iframe =
            html.IFrameElement()
              ..src = pdfUrl
              ..style.border = 'none'
              ..style.width = '100%'
              ..style.height = '600px'
              ..style.visibility = 'hidden';

        iframe.onLoad.listen((event) {
          Future.delayed(Duration(milliseconds: 200), () {
            iframe.style.visibility = 'visible';
            setState(() {});
          });
        });

        return iframe;
      });

      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {});
      });
    } else {
      // 📱 MÓVIL: Abrir en visor de PDF
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("No se pudo abrir el PDF")));
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 26, 58),
        title: const Text(
          "Hojas de vida",
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
        // 🔥 Ahora puedes hacer scroll en la pantalla completa
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Center(
                child: ElevatedButton(
                  onPressed: generarHojaDeVida,
                  child: Text("Generar Hoja de Vida"),
                ),
              ),
              SizedBox(height: 30),
              pdfUrl != null && !drawerAbierto
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
                  : Center(
                    child: Text(
                      "Seleccione una empresa y genere la hoja de vida",
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
