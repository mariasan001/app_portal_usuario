import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../device_metadata_collector.dart';

final deviceInfoPluginProvider = Provider<DeviceInfoPlugin>((ref) {
  return DeviceInfoPlugin();
});

final deviceMetadataCollectorProvider = Provider<DeviceMetadataCollector>((
  ref,
) {
  return DeviceMetadataCollectorImpl(ref.watch(deviceInfoPluginProvider));
});
