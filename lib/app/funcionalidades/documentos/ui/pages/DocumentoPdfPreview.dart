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
        surfaceTintColor: ColoresApp.blanco,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 0.15,
          ),
        ),
      ),
      body: Container(
        color: ColoresApp.inputBg.withOpacity(0.55),
        child: PdfPreview(
          // ✅ FIX: build recibe PdfPageFormat
          build: (format) => buildBytes(),
          allowPrinting: true,
          allowSharing: true,
          canChangePageFormat: false,
          canChangeOrientation: false,
          canDebug: false,
          loadingWidget: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
