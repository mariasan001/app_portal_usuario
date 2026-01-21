// lib/app/funcionalidades/home/ui/home_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/home/ui/inicio_tab.dart';

import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/widgets/app_bottom_nav.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/widgets/app_more_sheet.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/widgets/app_top_bar.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  int _lastIndex = 0;

  void _openMoreSheet() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: Material(
            color: ColoresApp.blanco,
            child: AppMoreSheet(
              onPerfil: () => Navigator.pop(ctx),
              onConfig: () => Navigator.pop(ctx),
              onAyuda: () => Navigator.pop(ctx),
              onLogout: () {
                Navigator.pop(ctx);
                context.go('/login');
              },
            ),
          ),
        );
      },
    );
  }

  void _onTapNav(int i) {
    if (i <= 3) {
      setState(() {
        _index = i;
        _lastIndex = i;
      });
      return;
    }
    setState(() => _index = _lastIndex);
    _openMoreSheet();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      // ✅ Tu InicioTab ahora mostrará el noticiero + enlaces institucionales
      const InicioTab(),

      const _PlaceholderTab(title: 'Servicios (placeholder)'),
      const _PlaceholderTab(title: 'Mis trámites (placeholder)'),
      const _PlaceholderTab(title: 'Recibos (placeholder)'),
    ];

    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(
              // ✅ te recomiendo que AppTopBar internamente formatee:
              // "Hola," delgado y "Sagma" más pesado, sin duplicar texto.
              nombre: 'Hola, Sagma 👋',
              hintSearch: 'Buscar servicio, trámite o recibo...',
            ),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: pages,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: _onTapNav,
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  const _PlaceholderTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ColoresApp.texto,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
