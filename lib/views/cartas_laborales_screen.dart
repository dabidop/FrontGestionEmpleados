import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import 'dart:ui' as ui; // ✅ Import correcto

class CartaLaboralPage extends StatefulWidget {
  final String codigoEmpleado;

  CartaLaboralPage({required this.codigoEmpleado});

  @override
  _CartaLaboralPageState createState() => _CartaLaboralPageState();
}

class _CartaLaboralPageState extends State<CartaLaboralPage> {
  final storage = FlutterSecureStorage();
  String? pdfUrl;
  String viewID = "pdfIframe-${UniqueKey().toString()}";

  @override
  void initState() {
    super.initState();
    generarCartaLaboral();
  }

  Future<void> generarCartaLaboral() async {
    // ✅ URL correcta del endpoint
    String apiUrl = "http://localhost:5219/api/CartasLaborales/generar/${widget.codigoEmpleado}";

    // 🔒 Obtener el token almacenado
    String? token = await storage.read(key: "jwt_token");

    if (token == null) {
      print("❌ Error: No se encontró el token JWT.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: No se encontró el token de autenticación")),
      );
      return;
    }

    try {
      // ✅ Solicitud al endpoint correcto
      final respuesta = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // ✅ Procesar la respuesta
      if (respuesta.statusCode == 200) {
        // ✅ Convertir la respuesta a JSON
        final jsonData = jsonDecode(respuesta.body);

        // ✅ Extraer la URL del PDF
        String urlArchivo = jsonData['url'];

        // 🔥 Reemplazar `localhost` por una URL relativa para evitar problemas de CORS y HTTPS
        urlArchivo = urlArchivo.replaceAll("https://localhost:5219", "");

        setState(() {
          pdfUrl = urlArchivo;
        });

        // 🔥 Registrar el `iframe` en el DOM solo en Flutter Web
        if (kIsWeb) {
          // ✅ Forma correcta de registrar el iframe en Flutter Web
          ui.platformViewRegistry.registerViewFactory(
            viewID,
            (int viewId) => html.IFrameElement()
              ..src = pdfUrl
              ..style.border = 'none'
              ..width = '100%'
              ..height = '100%',
          );
        }
      } else {
        print("❌ Error: ${respuesta.reasonPhrase}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al generar la carta laboral")),
        );
      }
    } catch (e) {
      print("❌ Error en la solicitud: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión")),
      );
    }
  }

  Future<void> descargarPDF() async {
    if (pdfUrl != null) {
      // 🔥 Utiliza url_launcher para abrir el PDF en otra pestaña y permitir su descarga
      if (await canLaunch(pdfUrl!)) {
        await launch(pdfUrl!);
      } else {
        print("❌ No se pudo abrir el enlace de descarga.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se pudo abrir el enlace de descarga")),
        );
      }
    } else {
      print("⚠️ No se encontró la URL del PDF.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se encontró la URL del PDF")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carta Laboral"),
      ),
      body: pdfUrl != null
          ? Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                child: kIsWeb
                    ? HtmlElementView(viewType: viewID)
                    : Center(child: Text("Previsualización no disponible en esta plataforma")),
              ),
            )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: descargarPDF,
        child: Icon(Icons.download),
      ),
    );
  }
}
