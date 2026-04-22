import '../domain/entities/device/device_check_result.dart';
import '../ui/auth_copy.dart';

String defaultDeviceMessage(DeviceCheckResult result) {
  return AuthCopy.deviceCheckMessage(result);
}
