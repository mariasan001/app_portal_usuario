import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/ayuda/ayuda_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/documentos/ui/pages/documento_detalle_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/documentos/ui/pages/documentos_page.dart';

import 'package:portal_servicios_usuario/app/funcionalidades/introduccion/ui/bienvenida_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/login/login_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/registro/registro_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/token/token_page.dart';

// ⚠️ Recomendación: renombra carpeta a cambio_contrasena para evitar %C3%B1
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/cambio_contrase%C3%B1a/RecuperarPasswordPage.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/cambio_contrase%C3%B1a/nueva_contrasena_page.dart';

// ✅ Contenido de tabs
import 'package:portal_servicios_usuario/app/funcionalidades/home/ui/inicio_tab.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/pages/citas_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/pages/recibos_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/pages/servicios_page.dart';

// ✅ Flujo de trámite/consulta
import 'package:portal_servicios_usuario/app/funcionalidades/servicios/ui/widgets/servicio_proceso_page.dart';

// ✅ Shell
import 'package:portal_servicios_usuario/app/funcionalidades/panel/ui/shell/app_shell.dart';

// ✅ NUEVAS PAGES (dentro de la app)
// Ajusta estos imports según tu estructura real:
import 'package:portal_servicios_usuario/app/funcionalidades/perfil/ui/perfil_page.dart';

class EnrutadorApp {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/bienvenida',
    debugLogDiagnostics: true,

    // ✅ Si alguien navega a una ruta inexistente
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Text(
            'Ruta no encontrada: ${state.uri}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      );
    },

    routes: [
      // ===================================================================
      // 1) INTRO / AUTH (SIN AppShell)
      //    Aquí NO se muestra topbar/bottomnav.
      // ===================================================================
      GoRoute(
        path: '/bienvenida',
        builder: (context, state) => const BienvenidaPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/registro',
        builder: (context, state) => const RegistroPage(),
      ),
      GoRoute(
        path: '/recuperar',
        builder: (context, state) => const RecuperarPasswordPage(),
      ),
      GoRoute(
        path: '/token',
        builder: (context, state) {
          // ✅ Usamos extras para pasar datos al TokenPage
          final extra = (state.extra as Map?) ?? {};

          final backRoute = (extra['backRoute'] ?? '/login') as String;
          final nextRoute = (extra['nextRoute'] ?? '/home') as String;
          final email = (extra['email'] ?? '') as String;

          return TokenPage(
            backRoute: backRoute,
            nextRoute: nextRoute,
            email: email,
          );
        },
      ),
      GoRoute(
        path: '/nueva-contrasena',
        builder: (context, state) {
          final extra = (state.extra as Map?) ?? {};
          final email = (extra['email'] ?? '') as String;
          final token = (extra['token'] ?? '') as String;

          return NuevaContrasenaPage(email: email, token: token);
        },
      ),

      // ===================================================================
      // 2) APP (CON AppShell SIEMPRE)
      //    Todo lo que sea "dentro del portal" va aquí.
      // ===================================================================
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // ------------------ Tabs principales ------------------
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InicioTab()),
          ),
          GoRoute(
            path: '/servicios',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ServiciosPage()),
          ),
          GoRoute(
            path: '/tramites',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TramitesPage()),
          ),
          GoRoute(
            path: '/recibos',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: RecibosPage()),
          ),

          // ------------------ Flujo dinámico de servicio ------------------
          // ✅ NUEVA RUTA DINÁMICA: confirmar y continuar
          // Ej: /servicios/tramite/t_no_adeudo
          // Ej: /servicios/consulta/c_fump
          GoRoute(
            path: '/servicios/:tipo/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              // final tipo = state.pathParameters['tipo']; // si luego validas consulta/tramite
              return ServicioProcesoPage(servicioId: id);
            },
          ),

          // ------------------ NUEVAS SECCIONES "Más opciones" ------------------
          // ✅ Perfil (desde avatar o desde el AppMoreSheet)
          GoRoute(
            path: '/perfil',
            builder: (context, state) => const PerfilPage(),
          ),

          GoRoute(
            path: '/documentos',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DocumentosPage()),
          ),
          GoRoute(
            path: '/documentos/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return DocumentoDetallePage(documentoId: id);
            },
          ),

          GoRoute(
          path: '/ayuda',
          pageBuilder: (context, state) =>
          const NoTransitionPage(child: AyudaSoportePage()),
         ),
        ],
      ),
    ],
  );
}
