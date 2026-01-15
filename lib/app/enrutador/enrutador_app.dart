
import 'package:go_router/go_router.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/login/login_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/registro/registro_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/autenticacion/ui/token_page.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/introduccion/ui/bienvenida_page.dart';

class EnrutadorApp {
  static final GoRouter router = GoRouter(
    initialLocation: '/bienvenida',
    routes: [
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
        path: '/token',
        builder: (context, state) => const TokenPage(),
),
    ],
  );
}
