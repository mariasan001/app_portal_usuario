import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class DocumentoPdfPreviewPage extends StatelessWidget {
  final String title;
  final Future<Uint8List> Function() buildBytes;

  const DocumentoPdfPreviewPage({
    super.key,
    required this.title,
    required this.buildBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      appBar: AppBar(
        backgroundColor: ColoresApp.blanco,
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: PdfPreview(
        build: (_) => buildBytes(),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
      ),
    );
  }
}
