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
      DioExceptionType.connectionTimeout => 'La conexion tardo demasiado.',
      DioExceptionType.sendTimeout =>
        'No se pudo enviar la informacion a tiempo.',
      DioExceptionType.receiveTimeout =>
        'El servidor tardo demasiado en responder.',
      DioExceptionType.connectionError =>
        'No fue posible conectar con el servidor. Revisa tu red o la URL configurada.',
      DioExceptionType.cancel => 'La solicitud fue cancelada.',
      DioExceptionType.badCertificate =>
        'El certificado del servidor no es valido.',
      DioExceptionType.badResponse => _extractMessage(
        response?.data,
        statusCode,
      ),
      DioExceptionType.unknown =>
        'Ocurrio un error inesperado al comunicar con la API.',
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

    if (statusCode == 400) {
      return 'Los datos enviados no son validos.';
    }

    if (statusCode == 401) {
      return 'Tus credenciales no son validas o tu sesion expiro.';
    }

    if (statusCode == 403) {
      return 'No tienes permisos para realizar esta accion.';
    }

    if (statusCode == 404) {
      return 'No se encontro el recurso solicitado.';
    }

    if (statusCode == 408) {
      return 'La solicitud tardo demasiado. Intenta nuevamente.';
    }

    if (statusCode == 409) {
      return 'El recurso ya existe o entro en conflicto con el estado actual.';
    }

    if (statusCode == 422) {
      return 'Los datos enviados no pasaron la validacion del servidor.';
    }

    if (statusCode != null && statusCode >= 500) {
      return 'El servidor presento un problema. Intenta mas tarde.';
    }

    return 'No fue posible completar la solicitud.';
  }

  @override
  String toString() => 'ApiException($statusCode, $identifier): $message';
}
