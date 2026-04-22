import '../../../../core/device/models/app_device_info.dart';
import '../entities/device_check_result.dart';
import '../repositories/auth_repository.dart';

class CheckDeviceUseCase {
  const CheckDeviceUseCase(this._repository);

  final AuthRepository _repository;

  Future<DeviceCheckResult> call({
    required String username,
    required AppDeviceInfo device,
  }) {
    return _repository.checkDevice(username: username, device: device);
  }
}
