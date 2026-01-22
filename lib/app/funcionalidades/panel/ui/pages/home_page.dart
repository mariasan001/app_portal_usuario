// lib/app/funcionalidades/panel/ui/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/home/ui/inicio_tab.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ AppShell ya dibuja:
    // - AppTopBar
    // - AppBottomNav
    //
    // Aquí SOLO va el contenido del centro (Inicio).
    return const ColoredBox(
      color: ColoresApp.blanco,
      child: InicioTab(),
    );
  }
}
