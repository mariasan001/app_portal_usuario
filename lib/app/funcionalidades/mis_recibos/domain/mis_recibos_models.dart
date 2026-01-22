import 'package:flutter/material.dart';

enum ReciboEstado { pendiente, disponible }

extension ReciboEstadoX on ReciboEstado {
  String get label => this == ReciboEstado.disponible ? 'Disponible' : 'Pendiente';
}

class ProximaNominaInfo {
  const ProximaNominaInfo({
    required this.anio,
    required this.quincena,
    required this.disponibleAt,
  });

  final int anio;
  final int quincena;
  final DateTime disponibleAt;

  bool get disponible => DateTime.now().isAfter(disponibleAt) || DateTime.now().isAtSameMomentAs(disponibleAt);

  int get faltanDias {
    final now = DateTime.now();
    final d0 = DateUtils.dateOnly(now);
    final d1 = DateUtils.dateOnly(disponibleAt);
    final diff = d1.difference(d0).inDays;
    return diff < 0 ? 0 : diff;
  }

  String get countdownLabel {
    if (disponible) return 'Ya puedes descargarla';
    final d = faltanDias;
    if (d == 0) return 'Se libera hoy';
    if (d == 1) return 'Falta 1 día';
    return 'Faltan $d días';
  }
}

class ReciboResumen {
  const ReciboResumen({
    required this.id,
    required this.anio,
    required this.quincena,
    required this.periodoLabel,
    required this.disponibleAt,
    required this.neto,
    required this.estado,
    this.tieneReporte = false,
  });

  final String id;
  final int anio;
  final int quincena;

  /// Ej: "Qna 02 · 2026"
  final String periodoLabel;

  final DateTime disponibleAt;
  final double neto;
  final ReciboEstado estado;

  /// Si ya levantó reporte (mock)
  final bool tieneReporte;

  bool get disponible => estado == ReciboEstado.disponible;
}

class ReciboDetalle {
  const ReciboDetalle({
    required this.resumen,
    required this.percepciones,
    required this.deducciones,
    required this.totalPercepciones,
    required this.totalDeducciones,
  });

  final ReciboResumen resumen;

  /// Ej: {"Sueldo base": 12000, "Compensación": 1500}
  final Map<String, double> percepciones;
  final Map<String, double> deducciones;

  final double totalPercepciones;
  final double totalDeducciones;
}

class ReporteNominaPayload {
  const ReporteNominaPayload({
    required this.reciboId,
    required this.motivo,
    this.detalle,
  });

  final String reciboId;
  final String motivo;
  final String? detalle;
}
