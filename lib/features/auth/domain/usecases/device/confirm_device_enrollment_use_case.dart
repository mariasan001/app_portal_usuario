import '../../entities/device/device_enrollment_confirm_result.dart';
import '../../repositories/auth_repository.dart';

class ConfirmDeviceEnrollmentUseCase {
  const ConfirmDeviceEnrollmentUseCase(this._repository);

  final AuthRepository _repository;

  Future<DeviceEnrollmentConfirmResult> call({
    required String enrollmentId,
    required String otp,
    required String username,
  }) {
    return _repository.confirmDeviceEnrollment(
      enrollmentId: enrollmentId,
      otp: otp,
      username: username,
    );
  }
}
