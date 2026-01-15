import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      showDragHandle: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return AppMoreSheet(
          onPerfil: () {
            Navigator.pop(context);
            // TODO: navegar a perfil
            // context.go('/perfil');
          },
          onConfig: () {
            Navigator.pop(context);
            // TODO: navegar a configuración
            // context.go('/config');
          },
          onAyuda: () {
            Navigator.pop(context);
            // TODO: navegar a ayuda
            // context.go('/ayuda');
          },
          onLogout: () {
            Navigator.pop(context);
            context.go('/login');
          },
        );
      },
    );
  }

  void _onTapNav(int i) {
    // 0..3 son tabs reales
    if (i <= 3) {
      setState(() {
        _index = i;
        _lastIndex = i;
      });
      return;
    }

    // 4 = “Más”
    setState(() => _index = _lastIndex); // se queda en el tab actual
    _openMoreSheet();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _PlaceholderTab(title: 'Inicio (placeholder)'),
      _PlaceholderTab(title: 'Servicios (placeholder)'),
      _PlaceholderTab(title: 'Citas (placeholder)'),
      _PlaceholderTab(title: 'Recibos (placeholder)'),
    ];

    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              nombre: 'Hola, Sagma 👋', // luego lo haces dinámico
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
