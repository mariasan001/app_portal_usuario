import '../domain/mis_recibos_models.dart';

abstract class MisRecibosRepository {
  Future<ProximaNominaInfo> proximaNomina();

  Future<List<ReciboResumen>> ultimas({int limit = 5});

  /// Lista por año / quincena. Si no pasas nada, regresa un set “razonable”.
  Future<List<ReciboResumen>> listar({int? anio, int? quincena});

  Future<ReciboDetalle> obtenerDetalle(String reciboId);

  Future<String> descargar(String reciboId);

  Future<List<String>> descargarLote(List<String> reciboIds);

  Future<void> reportar(ReporteNominaPayload payload);
}
