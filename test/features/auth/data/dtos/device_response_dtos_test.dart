import 'package:flutter_test/flutter_test.dart';
import 'package:portal_servicios_usuario/features/auth/data/dtos/device/device_check_response_dto.dart';
import 'package:portal_servicios_usuario/features/auth/data/dtos/device/device_enrollment_request_response_dto.dart';
import 'package:portal_servicios_usuario/features/auth/domain/entities/device/device_check_result.dart';

void main() {
  group('DeviceCheckResponseDto', () {
    test('convierte DEVICE_NOT_ENROLLED a resultado de dominio', () {
      final dto = DeviceCheckResponseDto.fromJson({
        'code': 'DEVICE_NOT_ENROLLED',
        'message': 'Dispositivo no enrolado',
        'deviceIdHash': 'hash-123',
      });

      final result = dto.toDomain();

      expect(result.code, DeviceCheckCode.deviceNotEnrolled);
      expect(result.rawCode, 'DEVICE_NOT_ENROLLED');
      expect(result.requiresEnrollment, isTrue);
      expect(result.isAuthorized, isFalse);
      expect(result.deviceIdHash, 'hash-123');
    });

    test('convierte OK a resultado autorizado', () {
      final dto = DeviceCheckResponseDto.fromJson({
        'code': 'OK',
        'message': 'Dispositivo reconocido',
      });

      final result = dto.toDomain();

      expect(result.code, DeviceCheckCode.ok);
      expect(result.isAuthorized, isTrue);
      expect(result.requiresEnrollment, isFalse);
    });
  });

  group('DeviceEnrollmentRequestResponseDto', () {
    test('acepta enrollmentId directo', () {
      final dto = DeviceEnrollmentRequestResponseDto.fromJson({
        'code': 'OTP_SENT',
        'message': 'Codigo enviado',
        'enrollmentId': 'enroll-001',
      });

      final result = dto.toDomain();

      expect(result.enrollmentId, 'enroll-001');
      expect(result.code, 'OTP_SENT');
    });

    test('acepta requestId como respaldo para enrollmentId', () {
      final dto = DeviceEnrollmentRequestResponseDto.fromJson({
        'code': 'OTP_SENT',
        'message': 'Codigo enviado',
        'requestId': 'req-009',
      });

      final result = dto.toDomain();

      expect(result.enrollmentId, 'req-009');
    });
  });
}
