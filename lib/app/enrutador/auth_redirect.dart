import '../../features/auth/application/auth_state.dart';

const _publicAuthPaths = <String>{
  '/bienvenida',
  '/login',
  '/registro',
  '/recuperar',
  '/token',
  '/nueva-contrasena',
};

bool isPublicAuthPath(String location) {
  return _publicAuthPaths.contains(location);
}

String? redirectForAuth({
  required AuthState authState,
  required String location,
}) {
  final isPublicPath = isPublicAuthPath(location);

  if (authState.status == AuthStatus.unknown) {
    return isPublicPath ? null : '/bienvenida';
  }

  if (authState.isAuthenticated) {
    return isPublicPath ? '/home' : null;
  }

  return isPublicPath ? null : '/login';
}
