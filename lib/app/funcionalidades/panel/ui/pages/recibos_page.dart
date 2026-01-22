import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/mis_recibos/ui/mis_recibos_page.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class RecibosPage extends StatelessWidget {
  const RecibosPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ AppShell ya dibuja TopBar + BottomNav
    // Aquí va SOLO el contenido del centro.
    return const ColoredBox(
      color: ColoresApp.blanco,
      child: MisRecibosPage(),
    );
  }
}
