import '../../../../core/device/models/app_device_info.dart';
import '../entities/device_enrollment_request_result.dart';
import '../repositories/auth_repository.dart';

class RequestDeviceEnrollmentUseCase {
  const RequestDeviceEnrollmentUseCase(this._repository);

  final AuthRepository _repository;

  Future<DeviceEnrollmentRequestResult> call({
    required String username,
    required AppDeviceInfo device,
  }) {
    return _repository.requestDeviceEnrollment(
      username: username,
      device: device,
    );
  }
}
