import '../utils/localhost_resolver.dart';

enum ApiModule { iam }

enum AppFlavor { dev, qa, prod }

AppFlavor appFlavorFromName(String rawValue) {
  switch (rawValue.trim().toLowerCase()) {
    case 'qa':
      return AppFlavor.qa;
    case 'prod':
      return AppFlavor.prod;
    default:
      return AppFlavor.dev;
  }
}

String selectBaseUrlForFlavor({
  required AppFlavor flavor,
  required String overrideBaseUrl,
  required String devBaseUrl,
  required String qaBaseUrl,
  required String prodBaseUrl,
}) {
  final sanitizedOverride = overrideBaseUrl.trim();
  if (sanitizedOverride.isNotEmpty) {
    return sanitizedOverride;
  }

  switch (flavor) {
    case AppFlavor.dev:
      return devBaseUrl.trim();
    case AppFlavor.qa:
      return qaBaseUrl.trim();
    case AppFlavor.prod:
      return prodBaseUrl.trim();
  }
}

abstract final class AppEnvironment {
  static const _appFlavor = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: 'dev',
  );

  static const _iamBaseUrlOverride = String.fromEnvironment(
    'IAM_BASE_URL',
    defaultValue: '',
  );

  static const _iamBaseUrlDev = String.fromEnvironment(
    'IAM_BASE_URL_DEV',
    defaultValue: 'http://10.0.32.64:8081/iam',
  );

  static const _iamBaseUrlQa = String.fromEnvironment(
    'IAM_BASE_URL_QA',
    defaultValue: 'https://qa.portal-servicios.local/iam',
  );

  static const _iamBaseUrlProd = String.fromEnvironment(
    'IAM_BASE_URL_PROD',
    defaultValue: 'https://portal-servicios.example.com/iam',
  );

  static const iamAppCode = String.fromEnvironment(
    'IAM_APP_CODE',
    defaultValue: 'PLAT_SERV',
  );

  static AppFlavor get flavor => appFlavorFromName(_appFlavor);

  static String get flavorName => flavor.name;

  static bool get isDevelopment => flavor == AppFlavor.dev;

  static bool get isQa => flavor == AppFlavor.qa;

  static bool get isProduction => flavor == AppFlavor.prod;

  static String baseUrlFor(ApiModule module) {
    switch (module) {
      case ApiModule.iam:
        final baseUrl = selectBaseUrlForFlavor(
          flavor: flavor,
          overrideBaseUrl: _iamBaseUrlOverride,
          devBaseUrl: _iamBaseUrlDev,
          qaBaseUrl: _iamBaseUrlQa,
          prodBaseUrl: _iamBaseUrlProd,
        );

        return resolveLocalhostUrl(baseUrl);
    }
  }
}
