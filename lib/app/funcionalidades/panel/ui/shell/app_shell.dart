import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/widgets/app_bottom_nav.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/widgets/app_more_sheet.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/widgets/app_top_bar.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';


class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _indexFromLocation(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/servicios')) return 1;
    if (location.startsWith('/citas')) return 2;
    if (location.startsWith('/recibos')) return 3;
    // “Más” no es ruta
    return 0;
  }

  void _goByIndex(BuildContext context, int i) {
    switch (i) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/servicios');
        break;
      case 2:
        context.go('/citas');
        break;
      case 3:
        context.go('/recibos');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(loc);

    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Top bar estilo “app moderna”
            const AppTopBar(
              nombre: 'Sagma', // luego lo haces dinámico
              hintSearch: 'Buscar en tu portal...',
            ),

            // ✅ Contenido
            Expanded(child: child),
          ],
        ),
      ),

      // ✅ Bottom nav fijo
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (i) {
          if (i == 4) {
            // Más
            showModalBottomSheet(
              context: context,
              useSafeArea: true,
              showDragHandle: true,
              backgroundColor: ColoresApp.blanco,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              builder: (_) => AppMoreSheet(
                onPerfil: () {
                  Navigator.pop(context);
                  // context.go('/perfil');
                },
                onConfig: () {
                  Navigator.pop(context);
                  // context.go('/config');
                },
                onAyuda: () {
                  Navigator.pop(context);
                  // context.go('/ayuda');
                },
                onLogout: () {
                  Navigator.pop(context);
                  context.go('/login'); // luego aquí limpias sesión real
                },
              ),
            );
            return;
          }

          _goByIndex(context, i);
        },
      ),
    );
  }
}
