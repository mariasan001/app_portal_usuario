import '../domain/mis_citas_models.dart';
import 'mis_citas_mock.dart';

class MisCitasRepositoryMock {
  MisCitasRepositoryMock._();
  static final instance = MisCitasRepositoryMock._();

  final List<CitaDetalle> _store = List.of(misCitasMock);

  // ✅ CACHE SINCRÓNICO (para UI instantánea)
  List<CitaResumen> get cache => _buildSortedResumen();

  // ✅ Ahora listar ya no tarda NADA
  Future<List<CitaResumen>> listar() async {
    return cache;
  }

  List<CitaResumen> _buildSortedResumen() {
    final list = _store
        .map(
          (d) => CitaResumen(
            id: d.id,
            servicioId: d.servicioId,
            titulo: d.titulo,
            tipo: d.tipo,
            canal: d.canal,
            estado: d.estado,
            folio: d.folio,
            creadaAt: d.creadaAt,
            citaAt: d.citaAt,
            accent: d.accent,
            ubicacionNombre: d.ubicacionNombre,
          ),
        )
        .toList();

    // Orden: próximas -> proceso -> finalizadas -> canceladas
    list.sort((a, b) {
      int rank(CitaEstado e) {
        switch (e) {
          case CitaEstado.proxima:
            return 0;
          case CitaEstado.enProceso:
            return 1;
          case CitaEstado.finalizada:
            return 2;
          case CitaEstado.cancelada:
            return 3;
        }
      }

      final ra = rank(a.estado);
      final rb = rank(b.estado);
      if (ra != rb) return ra.compareTo(rb);

      final da = a.citaAt ?? a.creadaAt;
      final db = b.citaAt ?? b.creadaAt;
      return da.compareTo(db);
    });

    return list;
  }

  // 👇 Estos puedes dejarlos async si quieres, pero SIN delays para que “no se sienta”
  Future<CitaDetalle> obtenerDetalle(String id) async {
    return _store.firstWhere((x) => x.id == id);
  }

  Future<CitaDetalle> cancelar(String id) async {
    final idx = _store.indexWhere((x) => x.id == id);
    if (idx < 0) throw StateError('Cita no encontrada');

    final cur = _store[idx];
    final updated = CitaDetalle(
      id: cur.id,
      servicioId: cur.servicioId,
      titulo: cur.titulo,
      tipo: cur.tipo,
      canal: cur.canal,
      estado: CitaEstado.cancelada,
      folio: cur.folio,
      creadaAt: cur.creadaAt,
      citaAt: cur.citaAt,
      accent: cur.accent,
      ubicacionNombre: cur.ubicacionNombre,
      direccion: cur.direccion,
      telefonos: cur.telefonos,
      correos: cur.correos,
      recomendaciones: cur.recomendaciones,
      pasos: [
        ...cur.pasos,
        const CitaPaso(titulo: 'Cancelada por el usuario', estado: PasoEstado.completo),
      ],
      constancia: cur.constancia,
    );

    _store[idx] = updated;
    return updated;
  }

  Future<CitaDetalle> reagendar({
    required String id,
    required DateTime nuevaFechaHora,
  }) async {
    final idx = _store.indexWhere((x) => x.id == id);
    if (idx < 0) throw StateError('Cita no encontrada');

    final cur = _store[idx];
    if (cur.canal != CitaCanal.presencial) {
      throw StateError('Solo se puede reagendar una cita presencial');
    }
    if (cur.estado != CitaEstado.proxima) {
      throw StateError('Solo se puede reagendar una cita próxima');
    }

    final updated = CitaDetalle(
      id: cur.id,
      servicioId: cur.servicioId,
      titulo: cur.titulo,
      tipo: cur.tipo,
      canal: cur.canal,
      estado: cur.estado,
      folio: cur.folio,
      creadaAt: cur.creadaAt,
      citaAt: nuevaFechaHora,
      accent: cur.accent,
      ubicacionNombre: cur.ubicacionNombre,
      direccion: cur.direccion,
      telefonos: cur.telefonos,
      correos: cur.correos,
      recomendaciones: cur.recomendaciones,
      pasos: [
        const CitaPaso(titulo: 'Reagendada', estado: PasoEstado.completo),
        ...cur.pasos,
      ],
      constancia: cur.constancia,
    );

    _store[idx] = updated;
    return updated;
  }

  Future<String> descargarConstancia(String citaId) async {
    final d = _store.firstWhere((x) => x.id == citaId);
    if (!d.puedeDescargarConstancia) {
      throw StateError('Constancia no disponible o vencida');
    }
    return 'constancia_${d.constancia!.id}.pdf';
  }
}
