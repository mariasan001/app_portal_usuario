import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException({required this.message, this.statusCode, this.identifier});

  final String message;
  final int? statusCode;
  final String? identifier;

  factory ApiException.fromDioException(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final message = switch (error.type) {
      DioExceptionType.connectionTimeout => 'La conexión tardó demasiado.',
      DioExceptionType.sendTimeout =>
        'No se pudo enviar la información a tiempo.',
      DioExceptionType.receiveTimeout =>
        'El servidor tardó demasiado en responder.',
      DioExceptionType.connectionError =>
        'No fue posible conectar con el servidor.',
      DioExceptionType.cancel => 'La solicitud fue cancelada.',
      DioExceptionType.badCertificate =>
        'El certificado del servidor no es válido.',
      DioExceptionType.badResponse => _extractMessage(
        response?.data,
        statusCode,
      ),
      DioExceptionType.unknown =>
        'Ocurrió un error inesperado al comunicar con la API.',
    };

    return ApiException(
      message: message,
      statusCode: statusCode,
      identifier: error.requestOptions.path,
    );
  }

  static String _extractMessage(Object? data, int? statusCode) {
    if (data is Map<String, dynamic>) {
      final nestedMessage = data['message'] ?? data['error'] ?? data['detail'];
      if (nestedMessage is String && nestedMessage.trim().isNotEmpty) {
        return nestedMessage.trim();
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    if (statusCode == 401) {
      return 'Tus credenciales no son válidas o tu sesión expiró.';
    }

    if (statusCode == 403) {
      return 'No tienes permisos para realizar esta acción.';
    }

    if (statusCode == 404) {
      return 'No se encontró el recurso solicitado.';
    }

    if (statusCode != null && statusCode >= 500) {
      return 'El servidor presentó un problema. Intenta más tarde.';
    }

    return 'No fue posible completar la solicitud.';
  }

  @override
  String toString() => 'ApiException($statusCode, $identifier): $message';
}
