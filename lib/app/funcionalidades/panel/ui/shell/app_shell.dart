import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/widgets/app_bottom_nav.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/widgets/app_more_sheet.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/widgets/app_top_bar.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/servicios/ui/widgets/servicios_search_sheet.dart';

// ✅ NUEVO: notificaciones
import 'package:portal_servicios_usuario/app/funcionalidades/notificaciones/ui/widgets/notificaciones_sheet.dart';

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

    final sheetTheme = base.copyWith(
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ColoresApp.blanco,
        modalBackgroundColor: ColoresApp.blanco,
        surfaceTintColor: Colors.transparent,
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
      showDragHandle: true,
      barrierColor: Colors.black.withOpacity(0.40),
      backgroundColor: ColoresApp.blanco,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Theme(
        data: sheetTheme,
        child: AppMoreSheet(
          showCustomHandle: false,

          // ✅ Perfil
          onPerfil: () {
            Navigator.pop(ctx);
            context.go('/perfil');
          },

          // ✅ Documentos
          onDocumentos: () {
            Navigator.pop(ctx);
            context.go('/documentos');
          },

          // ✅ Config (placeholder)
          onConfig: () {
            Navigator.pop(ctx);
            // context.go('/config');
          },

          // ✅ Ayuda (placeholder)
          onAyuda: () {
            Navigator.pop(ctx);
             context.go('/ayuda');
          },

          // ✅ Logout
          onLogout: () {
            Navigator.pop(ctx);
            context.go('/login');
          },
        ),
      ),
    );
  }

  // ✅ Abre buscador contextual SOLO para Servicios
  void _openServiciosSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.40),
      builder: (_) {
        return ServiciosSearchSheet(
          onOpen: (item) {
            Navigator.pop(context);

            final r = (item.route ?? '').trim();
            if (r.isNotEmpty) {
              context.go(r);
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Abrir: ${item.titulo}')),
            );
          },
        );
      },
    );
  }

  // ✅ FUTURO: aquí irá DocumentosSearchSheet (paso 2)
  void _openDocumentosSearch(BuildContext context) {
    // siguiente paso: showModalBottomSheet con DocumentosSearchSheet(...)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Buscador de documentos (pendiente)')),
    );
  }

  // ✅ Notificaciones PRO
  void _openNotificaciones(BuildContext context, List<NotificacionItem> items) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      barrierColor: Colors.black.withOpacity(0.40),
      backgroundColor: ColoresApp.blanco,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => NotificacionesSheet(
        items: items,
        onMarkAllRead: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Marcadas como leídas (demo)')),
          );
        },
        onOpen: (item) {
          Navigator.pop(context);

          final r = (item.route ?? '').trim();
          if (r.isNotEmpty) {
            context.go(r);
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Abrir: ${item.titulo}')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(loc);

    final inServicios = loc.startsWith('/servicios');
    final inDocs = loc.startsWith('/documentos');

    // ✅ Hint dinámico por sección
    final hintSearch = inServicios
        ? 'Buscar trámites y consultas…'
        : inDocs
            ? 'Buscar documentos y constancias…'
            : 'Buscar en tu portal…';

    // ✅ Trailing dinámico: en servicios mostramos “filtros”
    final trailing = inServicios
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIcons.slidersHorizontal(PhosphorIconsStyle.light),
                size: 18,
                color: ColoresApp.textoSuave.withOpacity(0.85),
              ),
              const SizedBox(width: 8),
              Icon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.light),
                size: 18,
                color: ColoresApp.textoSuave.withOpacity(0.6),
              ),
            ],
          )
        : null;

    final avatar = const AssetImage('assets/img/perfil.png');

    final demoNotifs = <NotificacionItem>[
      NotificacionItem(
        id: '1',
        titulo: 'Trámite en proceso',
        mensaje: 'Tu solicitud fue recibida y está siendo validada.',
        fecha: DateTime.now().subtract(const Duration(minutes: 18)),
        tipo: NotiTipo.tramite,
        estado: NotiEstado.enProceso,
        leida: false,
        route: '/tramites',
      ),
      NotificacionItem(
        id: '2',
        titulo: 'Cita próxima',
        mensaje: 'Mañana 10:30 am tienes una cita programada.',
        fecha: DateTime.now().subtract(const Duration(hours: 3)),
        tipo: NotiTipo.cita,
        estado: NotiEstado.proxima,
        leida: false,
        route: '/tramites',
      ),
      NotificacionItem(
        id: '3',
        titulo: 'Recibo disponible',
        mensaje: 'Tu recibo de esta quincena ya fue cargado.',
        fecha: DateTime.now().subtract(const Duration(days: 1)),
        tipo: NotiTipo.recibo,
        estado: NotiEstado.listo,
        leida: true,
        route: '/recibos',
      ),
    ];

    final notifsPendientes = demoNotifs.where((n) => !n.leida).length;

    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              nombre: 'Hola, Maria 👋',
              hintSearch: hintSearch,

              // 🔎 Buscar (adaptado por sección)
              onTapBuscar: inServicios
                  ? () => _openServiciosSearch(context)
                  : inDocs
                      ? () => _openDocumentosSearch(context)
                      : null,
              searchTrailing: trailing,

              // 👤 Perfil (topbar)
              avatarImage: avatar,
              onTapPerfil: () => context.go('/perfil'),

              // 🔔 Notificacionesiq
              notificacionesPendientes: notifsPendientes,
              showNotificationDotWhenZero: true,
              onTapNotificaciones: () => _openNotificaciones(context, demoNotifs),
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
