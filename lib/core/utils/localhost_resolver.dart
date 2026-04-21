import 'package:flutter/foundation.dart';

String resolveLocalhostUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host != 'localhost') {
    return url;
  }

  if (kIsWeb) {
    return url;
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return uri.replace(host: '10.0.2.2').toString();
  }

  return uri.replace(host: '127.0.0.1').toString();
}
