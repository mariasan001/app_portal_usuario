import 'package:flutter/material.dart';

enum CitaTipo { tramite, consulta }
enum CitaCanal { presencial, digital }
enum CitaEstado { proxima, enProceso, finalizada, cancelada }

extension CitaEstadoX on CitaEstado {
  String get label {
    switch (this) {
      case CitaEstado.proxima:
        return 'Próxima';
      case CitaEstado.enProceso:
        return 'En proceso';
      case CitaEstado.finalizada:
        return 'Finalizada';
      case CitaEstado.cancelada:
        return 'Cancelada';
    }
  }
}

extension CitaCanalX on CitaCanal {
  String get label => this == CitaCanal.presencial ? 'Presencial' : 'En línea';
  IconData get icon => this == CitaCanal.presencial ? Icons.location_on_outlined : Icons.language_outlined;
}

class ConstanciaInfo {
  const ConstanciaInfo({
    required this.id,
    required this.emitidaAt,
    this.vigencia = const Duration(days: 180), // ~6 meses
  });

  final String id;
  final DateTime emitidaAt;
  final Duration vigencia;

  DateTime get venceAt => emitidaAt.add(vigencia);
  bool get vigente => DateTime.now().isBefore(venceAt);
}

class CitaResumen {
  const CitaResumen({
    required this.id,
    required this.servicioId,
    required this.titulo,
    required this.tipo,
    required this.canal,
    required this.estado,
    required this.folio,
    required this.creadaAt,
    this.citaAt,
    this.accent,
    this.ubicacionNombre,
  });

  final String id;
  final String servicioId;
  final String titulo;
  final CitaTipo tipo;
  final CitaCanal canal;
  final CitaEstado estado;

  final String folio;
  final DateTime creadaAt;

  /// Para presencial: fecha/hora de la cita
  final DateTime? citaAt;

  final Color? accent;
  final String? ubicacionNombre;

  bool get esPresencial => canal == CitaCanal.presencial;
  bool get esDigital => canal == CitaCanal.digital;

  bool get puedeCancelar => estado == CitaEstado.proxima || estado == CitaEstado.enProceso;
  bool get puedeReagendar => estado == CitaEstado.proxima && esPresencial;
}

enum PasoEstado { pendiente, actual, completo }

class CitaPaso {
  const CitaPaso({
    required this.titulo,
    this.descripcion,
    this.fecha,
    required this.estado,
  });

  final String titulo;
  final String? descripcion;
  final DateTime? fecha;
  final PasoEstado estado;
}

class CitaDetalle extends CitaResumen {
  const CitaDetalle({
    required super.id,
    required super.servicioId,
    required super.titulo,
    required super.tipo,
    required super.canal,
    required super.estado,
    required super.folio,
    required super.creadaAt,
    super.citaAt,
    super.accent,
    super.ubicacionNombre,
    this.direccion,
    this.telefonos = const [],
    this.correos = const [],
    this.recomendaciones = const [],
    this.pasos = const [],
    this.constancia,
  });

  final String? direccion;
  final List<String> telefonos;
  final List<String> correos;

  final List<String> recomendaciones;

  /// Timeline del trámite / cita
  final List<CitaPaso> pasos;

  /// Solo aplica a digital finalizada
  final ConstanciaInfo? constancia;

  bool get puedeDescargarConstancia {
    if (canal != CitaCanal.digital) return false;
    if (estado != CitaEstado.finalizada) return false;
    return constancia != null && constancia!.vigente;
  }

  bool get constanciaVencida {
    if (constancia == null) return false;
    return !constancia!.vigente;
  }
}
