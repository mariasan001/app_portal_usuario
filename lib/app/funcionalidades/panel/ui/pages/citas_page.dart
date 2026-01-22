import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/mis_tramites/ui/mis_citas_page.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class TramitesPage extends StatelessWidget {
  const TramitesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ AppShell ya dibuja TopBar + BottomNav
    // Aquí va SOLO el contenido del centro.
    return const ColoredBox(
      color: ColoresApp.blanco,
      child: MisCitasPage(),
    );
  }
}
