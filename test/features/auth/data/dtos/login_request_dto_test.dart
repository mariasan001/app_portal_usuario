import 'package:flutter_test/flutter_test.dart';
import 'package:portal_servicios_usuario/core/config/app_environment.dart';
import 'package:portal_servicios_usuario/features/auth/data/dtos/session/login_request_dto.dart';

void main() {
  group('LoginRequestDto', () {
    test('arma el payload con username, password y appCode fijo', () {
      final dto = LoginRequestDto.fromCredentials(
        username: '210049376',
        password: 'Secreto123',
      );

      expect(dto.toJson(), {
        'username': '210049376',
        'password': 'Secreto123',
        'appCode': AppEnvironment.iamAppCode,
      });
    });
  });
}
