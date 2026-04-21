import '../utils/localhost_resolver.dart';

enum ApiModule { iam }

abstract final class AppEnvironment {
  static const _iamBaseUrl = String.fromEnvironment(
    'IAM_BASE_URL',
    defaultValue: 'http://10.0.32.46:8081/iam',
  );

  static const iamAppCode = String.fromEnvironment(
    'IAM_APP_CODE',
    defaultValue: 'PLAT_SERV',
  );

  static String baseUrlFor(ApiModule module) {
    switch (module) {
      case ApiModule.iam:
        return resolveLocalhostUrl(_iamBaseUrl);
    }
  }
}
