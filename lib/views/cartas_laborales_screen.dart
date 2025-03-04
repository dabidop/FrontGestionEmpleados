import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

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

  // 🔹 Controladores para los campos de entrada
  TextEditingController destinatarioController = TextEditingController();
  String empresaSeleccionada = "ALV"; // Valor por defecto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Carta Laboral")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Campo para ingresar el destinatario
            Text("Destinatario:", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: destinatarioController,
              decoration: InputDecoration(
                hintText: "Ingrese el nombre del destinatario",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // 🔹 Dropdown para seleccionar la empresa
            Text("Seleccione la empresa:", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: empresaSeleccionada,
              items: [
                DropdownMenuItem(value: "ALV", child: Text("GRUPO ALV S.A.S")),
                DropdownMenuItem(value: "DENIM", child: Text("DENIM LOVERS S.A.S")),
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

            // 🔹 Si hay un PDF, mostrarlo
            pdfUrl != null
                ? Expanded(
                    child: kIsWeb
                        ? HtmlElementView(viewType: viewID)
                        : Center(child: Text("Previsualización no disponible en esta plataforma")),
                  )
                : Center(child: Text("Ingrese los datos y genere la carta")),
          ],
        ),
      ),
      floatingActionButton: pdfUrl != null
          ? FloatingActionButton(
              onPressed: descargarPDF,
              child: Icon(Icons.download),
            )
          : null,
    );
  }

  // 🔹 Función para generar la carta laboral con los datos ingresados
  Future<void> generarCartaLaboral() async {
    String apiUrl =
        "http://localhost:5219/api/CartasLaborales/generar/${widget.codigoEmpleado}/${destinatarioController.text}/${empresaSeleccionada}";

    String? token = await storage.read(key: "jwt_token");
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: No se encontró el token de autenticación")),
      );
      return;
    }

    try {
      final respuesta = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      if (respuesta.statusCode == 200) {
        final jsonData = jsonDecode(respuesta.body);
        String urlArchivo = jsonData['url'];
        urlArchivo = urlArchivo.replaceAll("https://localhost:5219", "");

        setState(() {
          pdfUrl = urlArchivo;
        });

        // 🔹 Registrar el iframe solo en Flutter Web
        if (kIsWeb) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al generar la carta laboral")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión")),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se encontró la URL del PDF")),
      );
    }
  }
}
