import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'models/app_device_info.dart';

abstract interface class DeviceMetadataCollector {
  Future<AppDeviceInfo> collect();
}

class DeviceMetadataCollectorImpl implements DeviceMetadataCollector {
  DeviceMetadataCollectorImpl(this._deviceInfoPlugin);

  final DeviceInfoPlugin _deviceInfoPlugin;

  @override
  Future<AppDeviceInfo> collect() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = _normalizeAppVersion(packageInfo);

    if (kIsWeb) {
      final info = await _deviceInfoPlugin.webBrowserInfo;
      final platform = _safeValue(info.platform);
      final fingerprint =
          [
                info.vendor,
                info.userAgent,
                info.hardwareConcurrency?.toString(),
                platform,
              ]
              .where(
                (item) => item != null && item.toString().trim().isNotEmpty,
              )
              .join('|');

      return AppDeviceInfo(
        deviceIdFinal: _hashDeviceId(fingerprint),
        fingerprintId: _safeValue(fingerprint),
        brand: _safeValue(info.vendor),
        model: _safeValue(info.browserName.name),
        platform: 'WEB',
        osVersion: platform,
        arch: _safeValue(info.hardwareConcurrency?.toString()),
        appVersion: appVersion,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final info = await _deviceInfoPlugin.androidInfo;
        final fingerprint = _safeValue(
          info.fingerprint.isNotEmpty
              ? info.fingerprint
              : '${info.brand}|${info.model}|${info.id}',
        );
        final arch = _firstNonEmpty([
          ...info.supported64BitAbis,
          ...info.supported32BitAbis,
          ...info.supportedAbis,
        ]);

        return AppDeviceInfo(
          deviceIdFinal: _hashDeviceId(fingerprint),
          fingerprintId: fingerprint,
          brand: _safeValue(info.brand),
          model: _safeValue(info.model),
          platform: 'ANDROID',
          osVersion: _safeValue(info.version.release),
          arch: arch,
          appVersion: appVersion,
        );
      case TargetPlatform.iOS:
        final info = await _deviceInfoPlugin.iosInfo;
        final fingerprint = _safeValue(
          info.identifierForVendor ??
              '${info.utsname.machine}|${info.model}|${info.systemVersion}',
        );

        return AppDeviceInfo(
          deviceIdFinal: _hashDeviceId(fingerprint),
          fingerprintId: fingerprint,
          brand: 'Apple',
          model: _safeValue(info.model),
          platform: 'IOS',
          osVersion: _safeValue(info.systemVersion),
          arch: _safeValue(info.utsname.machine),
          appVersion: appVersion,
        );
      case TargetPlatform.windows:
        final info = await _deviceInfoPlugin.windowsInfo;
        final fingerprint = _safeValue(
          '${info.computerName}|${info.numberOfCores}|${info.systemMemoryInMegabytes}',
        );

        return AppDeviceInfo(
          deviceIdFinal: _hashDeviceId(fingerprint),
          fingerprintId: fingerprint,
          brand: 'Microsoft',
          model: _safeValue(info.computerName),
          platform: 'WINDOWS',
          osVersion: _safeValue(info.displayVersion),
          arch: _safeValue(info.numberOfCores.toString()),
          appVersion: appVersion,
        );
      case TargetPlatform.macOS:
        final info = await _deviceInfoPlugin.macOsInfo;
        final fingerprint = _safeValue(
          '${info.model}|${info.kernelVersion}|${info.systemGUID}',
        );

        return AppDeviceInfo(
          deviceIdFinal: _hashDeviceId(fingerprint),
          fingerprintId: fingerprint,
          brand: 'Apple',
          model: _safeValue(info.model),
          platform: 'MACOS',
          osVersion: _safeValue(info.osRelease),
          arch: _safeValue(info.arch),
          appVersion: appVersion,
        );
      case TargetPlatform.linux:
        final info = await _deviceInfoPlugin.linuxInfo;
        final fingerprint = _safeValue(
          '${info.machineId}|${info.id}|${info.prettyName}',
        );

        return AppDeviceInfo(
          deviceIdFinal: _hashDeviceId(fingerprint),
          fingerprintId: fingerprint,
          brand: _safeValue(info.name),
          model: _safeValue(info.prettyName),
          platform: 'LINUX',
          osVersion: _safeValue(info.version),
          arch: _safeValue(info.variant),
          appVersion: appVersion,
        );
      case TargetPlatform.fuchsia:
        return AppDeviceInfo(
          deviceIdFinal: _hashDeviceId('fuchsia|$appVersion'),
          fingerprintId: 'fuchsia',
          brand: 'Fuchsia',
          model: 'Fuchsia',
          platform: 'FUCHSIA',
          osVersion: 'unknown',
          arch: 'unknown',
          appVersion: appVersion,
        );
    }
  }

  String _normalizeAppVersion(PackageInfo info) {
    final build = info.buildNumber.trim();
    if (build.isEmpty || build == '0') {
      return info.version.trim();
    }
    return '${info.version.trim()}+$build';
  }

  String _hashDeviceId(String raw) {
    final normalized = _safeValue(raw);
    return sha256.convert(utf8.encode(normalized)).toString();
  }

  String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      final candidate = value.trim();
      if (candidate.isNotEmpty) {
        return candidate;
      }
    }
    return 'unknown';
  }

  String _safeValue(Object? value) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? 'unknown' : result;
  }
}
