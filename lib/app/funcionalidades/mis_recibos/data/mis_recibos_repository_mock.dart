import 'dart:async';

import '../domain/mis_recibos_models.dart';
import 'mis_recibos_mock_data.dart';
import 'mis_recibos_repository.dart';

class MisRecibosRepositoryMock implements MisRecibosRepository {
  MisRecibosRepositoryMock._();

  static final MisRecibosRepositoryMock instance = MisRecibosRepositoryMock._();

  final List<ReciboResumen> _all = MisRecibosMockData.buildRecibos();
  final Set<String> _reportados = <String>{};

  Future<T> _delay<T>(T v, [int ms = 220]) async {
    await Future.delayed(Duration(milliseconds: ms));
    return v;
  }

  @override
  Future<ProximaNominaInfo> proximaNomina() async {
    return _delay(MisRecibosMockData.buildProximaNomina(), 180);
  }

  @override
  Future<List<ReciboResumen>> ultimas({int limit = 5}) async {
    final x = _all.take(limit).map(_applyReportFlag).toList();
    return _delay(x, 200);
  }

  @override
  Future<List<ReciboResumen>> listar({int? anio, int? quincena}) async {
    Iterable<ReciboResumen> q = _all;

    if (anio != null) q = q.where((r) => r.anio == anio);
    if (quincena != null) q = q.where((r) => r.quincena == quincena);

    // si no filtra nada, muestra un set “bonito”
    final out = q.take(20).map(_applyReportFlag).toList();
    return _delay(out, 220);
  }

  @override
  Future<ReciboDetalle> obtenerDetalle(String reciboId) async {
    final r = _all.firstWhere((x) => x.id == reciboId);
    final rr = _applyReportFlag(r);
    return _delay(MisRecibosMockData.buildDetalle(rr), 220);
  }

  @override
  Future<String> descargar(String reciboId) async {
    // mock path
    return _delay('mock:///downloads/$reciboId.pdf', 250);
  }

  @override
  Future<List<String>> descargarLote(List<String> reciboIds) async {
    final files = reciboIds.map((id) => 'mock:///downloads/$id.pdf').toList();
    return _delay(files, 420);
  }

  @override
  Future<void> reportar(ReporteNominaPayload payload) async {
    _reportados.add(payload.reciboId);
    await _delay(null, 260);
  }

  ReciboResumen _applyReportFlag(ReciboResumen r) {
    if (!_reportados.contains(r.id)) return r;
    return ReciboResumen(
      id: r.id,
      anio: r.anio,
      quincena: r.quincena,
      periodoLabel: r.periodoLabel,
      disponibleAt: r.disponibleAt,
      neto: r.neto,
      estado: r.estado,
      tieneReporte: true,
    );
  }
}
