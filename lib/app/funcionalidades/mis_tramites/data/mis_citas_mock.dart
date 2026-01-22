import 'dart:math';

import 'package:flutter/material.dart';
import '../domain/mis_citas_models.dart';

Color _accent(int seed) {
  final r = Random(seed);
  final base = Colors.primaries[r.nextInt(Colors.primaries.length)];
  return base.shade700;
}

DateTime _at({required int daysFromNow, int hour = 10, int minute = 0}) {
  final now = DateTime.now();
  final d = now.add(Duration(days: daysFromNow));
  return DateTime(d.year, d.month, d.day, hour, minute);
}

final List<CitaDetalle> misCitasMock = [
  // Próxima presencial (en 2 días)
  CitaDetalle(
    id: 'cita_001',
    servicioId: 't_no_adeudo',
    titulo: 'Constancia de no adeudo',
    tipo: CitaTipo.tramite,
    canal: CitaCanal.presencial,
    estado: CitaEstado.proxima,
    folio: 'CITA-20260201-AB12CD',
    creadaAt: _at(daysFromNow: -1, hour: 9),
    citaAt: _at(daysFromNow: 2, hour: 11, minute: 30),
    accent: _accent(1),
    ubicacionNombre: 'Módulo Centro (Mock)',
    direccion: 'Av. Principal 123, Centro, Toluca, Méx.',
    telefonos: const ['722 123 4567'],
    correos: const ['citas@ejemplo.gob.mx'],
    recomendaciones: const [
      'Llega 10 minutos antes.',
      'Lleva identificación oficial.',
      'Si vas con copias, tu yo del futuro te lo agradecerá.',
    ],
    pasos: const [
      CitaPaso(titulo: 'Cita creada', estado: PasoEstado.completo),
      CitaPaso(titulo: 'Confirmación de asistencia', estado: PasoEstado.actual),
      CitaPaso(titulo: 'Atención en módulo', estado: PasoEstado.pendiente),
      CitaPaso(titulo: 'Entrega de documento', estado: PasoEstado.pendiente),
    ],
  ),

  // En proceso digital
  CitaDetalle(
    id: 'cita_002',
    servicioId: 't_historico_laboral',
    titulo: 'Histórico laboral',
    tipo: CitaTipo.consulta,
    canal: CitaCanal.digital,
    estado: CitaEstado.enProceso,
    folio: 'CON-20260201-K9M2PX',
    creadaAt: _at(daysFromNow: -2, hour: 12, minute: 10),
    accent: _accent(2),
    recomendaciones: const [
      'Evita recargar la pantalla como si fuera cajero un viernes 😄',
    ],
    pasos: const [
      CitaPaso(titulo: 'Solicitud recibida', estado: PasoEstado.completo),
      CitaPaso(titulo: 'Validación de datos', estado: PasoEstado.actual),
      CitaPaso(titulo: 'Generación del resultado', estado: PasoEstado.pendiente),
      CitaPaso(titulo: 'Listo para descargar', estado: PasoEstado.pendiente),
    ],
  ),

  // Finalizada digital con constancia vigente (emitida hace 60 días aprox)
  CitaDetalle(
    id: 'cita_003',
    servicioId: 't_finiquito',
    titulo: 'Constancia de finiquito',
    tipo: CitaTipo.tramite,
    canal: CitaCanal.digital,
    estado: CitaEstado.finalizada,
    folio: 'TRM-20251120-ZX7Q2W',
    creadaAt: DateTime.now().subtract(const Duration(days: 75)),
    accent: _accent(3),
    constancia: ConstanciaInfo(
      id: 'const_003',
      emitidaAt: DateTime.now().subtract(const Duration(days: 60)),
      vigencia: const Duration(days: 180),
    ),
    pasos: const [
      CitaPaso(titulo: 'Solicitud recibida', estado: PasoEstado.completo),
      CitaPaso(titulo: 'Documentos validados', estado: PasoEstado.completo),
      CitaPaso(titulo: 'Resultado emitido', estado: PasoEstado.completo),
      CitaPaso(titulo: 'Constancia disponible', estado: PasoEstado.completo),
    ],
  ),

  // Finalizada digital con constancia vencida (emitida hace 220 días)
  CitaDetalle(
    id: 'cita_004',
    servicioId: 't_reexpedicion_pagos',
    titulo: 'Reexpedición de pagos',
    tipo: CitaTipo.tramite,
    canal: CitaCanal.digital,
    estado: CitaEstado.finalizada,
    folio: 'TRM-20250515-PL8N4T',
    creadaAt: DateTime.now().subtract(const Duration(days: 240)),
    accent: _accent(4),
    constancia: ConstanciaInfo(
      id: 'const_004',
      emitidaAt: DateTime.now().subtract(const Duration(days: 220)),
      vigencia: const Duration(days: 180),
    ),
    pasos: const [
      CitaPaso(titulo: 'Solicitud recibida', estado: PasoEstado.completo),
      CitaPaso(titulo: 'Documentos validados', estado: PasoEstado.completo),
      CitaPaso(titulo: 'Resultado emitido', estado: PasoEstado.completo),
      CitaPaso(titulo: 'Constancia disponible', estado: PasoEstado.completo),
    ],
  ),

  // Cancelada
  CitaDetalle(
    id: 'cita_005',
    servicioId: 't_no_adeudo',
    titulo: 'Constancia de no adeudo',
    tipo: CitaTipo.tramite,
    canal: CitaCanal.presencial,
    estado: CitaEstado.cancelada,
    folio: 'CITA-20260110-RT55AA',
    creadaAt: DateTime.now().subtract(const Duration(days: 20)),
    citaAt: DateTime.now().subtract(const Duration(days: 10)),
    accent: _accent(5),
    ubicacionNombre: 'Módulo Norte (Mock)',
    pasos: const [
      CitaPaso(titulo: 'Cita creada', estado: PasoEstado.completo),
      CitaPaso(titulo: 'Cancelada por el usuario', estado: PasoEstado.completo),
    ],
  ),
];

List<CitaResumen> buildResumenFromMock() {
  return misCitasMock
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
}
