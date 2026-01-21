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
    if (location.startsWith('/tramites')) return 2;
    if (location.startsWith('/recibos')) return 3;
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
        context.go('/tramites');
        break;
      case 3:
        context.go('/recibos');
        break;
    }
  }

  void _openMoreSheet(BuildContext context) {
    final base = Theme.of(context);

    // ✅ Mata el “tinte” Material3 SOLO en el bottom sheet
    final sheetTheme = base.copyWith(
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ColoresApp.blanco,
        modalBackgroundColor: ColoresApp.blanco,
        surfaceTintColor: Colors.transparent, // ✅ adiós rosita
        showDragHandle: true, // ✅ dejamos solo el del sistema (1 raya)
      ),
      colorScheme: base.colorScheme.copyWith(
        surface: ColoresApp.blanco,
        surfaceTint: Colors.transparent,
      ),
    );

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,

      // ✅ Dejamos el handle del sistema (1 raya) y quitamos el tuyo
      showDragHandle: true,

      // ✅ Scrim más oscuro = menos “mezcla rosita” con tu fondo crema
      barrierColor: Colors.black.withValues(alpha: 0.40),

      backgroundColor: ColoresApp.blanco,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),

      builder: (ctx) => Theme(
        data: sheetTheme,
        child: AppMoreSheet(
          showCustomHandle: false, // ✅ importante: no dibujar tu handle
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
            const AppTopBar(
              nombre: 'Sagma',
              hintSearch: 'Buscar en tu portal...',
            ),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (i) {
          if (i == 4) {
            _openMoreSheet(context);
            return;
          }
          _goByIndex(context, i);
        },
      ),
    );
  }
}
