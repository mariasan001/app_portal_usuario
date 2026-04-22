Map<String, dynamic> buildDeviceEnrollmentRouteData({
  required String username,
  required String enrollmentId,
}) {
  return {
    'flow': 'device-enroll',
    'username': username,
    'enrollmentId': enrollmentId,
    'backRoute': '/login',
    'nextRoute': '/login',
  };
}

Map<String, dynamic> buildPasswordResetTokenRouteData({required String email}) {
  return {
    'flow': 'password-reset',
    'email': email,
    'backRoute': '/recuperar',
    'nextRoute': '/nueva-contrasena',
  };
}

Map<String, dynamic> buildPasswordResetFormRouteData({
  required String email,
  required String token,
}) {
  return {'email': email, 'token': token, 'backRoute': '/token'};
}
