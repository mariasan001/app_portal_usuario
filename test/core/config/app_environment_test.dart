import 'package:flutter_test/flutter_test.dart';
import 'package:portal_servicios_usuario/core/config/app_environment.dart';
import 'package:portal_servicios_usuario/core/utils/localhost_resolver.dart';

void main() {
  group('appFlavorFromName', () {
    test('dev es el valor por defecto para nombres vacios o desconocidos', () {
      expect(appFlavorFromName(''), AppFlavor.dev);
      expect(appFlavorFromName('desconocido'), AppFlavor.dev);
    });

    test('qa y prod se interpretan correctamente', () {
      expect(appFlavorFromName('qa'), AppFlavor.qa);
      expect(appFlavorFromName('QA'), AppFlavor.qa);
      expect(appFlavorFromName('prod'), AppFlavor.prod);
      expect(appFlavorFromName('PROD'), AppFlavor.prod);
    });
  });

  group('selectBaseUrlForFlavor', () {
    test('usa el override cuando existe', () {
      final baseUrl = selectBaseUrlForFlavor(
        flavor: AppFlavor.dev,
        overrideBaseUrl: 'https://override.local/iam',
        devBaseUrl: 'http://dev.local/iam',
        qaBaseUrl: 'https://qa.local/iam',
        prodBaseUrl: 'https://prod.local/iam',
      );

      expect(baseUrl, 'https://override.local/iam');
    });

    test('usa la URL correspondiente al flavor cuando no hay override', () {
      expect(
        selectBaseUrlForFlavor(
          flavor: AppFlavor.dev,
          overrideBaseUrl: '',
          devBaseUrl: 'http://dev.local/iam',
          qaBaseUrl: 'https://qa.local/iam',
          prodBaseUrl: 'https://prod.local/iam',
        ),
        'http://dev.local/iam',
      );

      expect(
        selectBaseUrlForFlavor(
          flavor: AppFlavor.qa,
          overrideBaseUrl: '',
          devBaseUrl: 'http://dev.local/iam',
          qaBaseUrl: 'https://qa.local/iam',
          prodBaseUrl: 'https://prod.local/iam',
        ),
        'https://qa.local/iam',
      );

      expect(
        selectBaseUrlForFlavor(
          flavor: AppFlavor.prod,
          overrideBaseUrl: '',
          devBaseUrl: 'http://dev.local/iam',
          qaBaseUrl: 'https://qa.local/iam',
          prodBaseUrl: 'https://prod.local/iam',
        ),
        'https://prod.local/iam',
      );
    });
  });

  group('resolveLocalhostUrl', () {
    test('no modifica una IP real de red para pruebas en celular fisico', () {
      expect(
        resolveLocalhostUrl('http://10.0.32.64:8081/iam'),
        'http://10.0.32.64:8081/iam',
      );
    });

    test('no modifica un dominio remoto', () {
      expect(
        resolveLocalhostUrl('https://qa.portal-servicios.local/iam'),
        'https://qa.portal-servicios.local/iam',
      );
    });
  });
}
