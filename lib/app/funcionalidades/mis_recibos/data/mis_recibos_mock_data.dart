import 'dart:math';

import 'package:flutter/material.dart';

import '../domain/mis_recibos_models.dart';

class MisRecibosMockData {
  static final _rnd = Random(11);

  // ⬇️ pega esto dentro de MisRecibosMockData, reemplazando buildRecibos()

static List<ReciboResumen> buildRecibos({int total = 80}) {
  final now = DateTime.now();
  final prox = buildProximaNomina();

  // empezamos “antes” de la próxima
  int anio = prox.anio;
  int qna = prox.quincena;

  final out = <ReciboResumen>[];

  for (int i = 0; i < total; i++) {
    // prev periodo
    if (qna > 1) {
      qna -= 1;
    } else {
      anio -= 1;
      qna = 24;
    }

    final id = '$anio-${qna.toString().padLeft(2, '0')}';
    final label = _periodoLabel(anio, qna);

    final disponibleAt = _disponibleAt(anio, qna);

    // Si tu enum se llama distinto, ajusta aquí:
    final estado = now.isAfter(disponibleAt)
        ? ReciboEstado.disponible
        : ReciboEstado.pendiente;

    out.add(
      ReciboResumen(
        id: id,
        anio: anio,
        quincena: qna,
        periodoLabel: label,
        disponibleAt: disponibleAt,
        neto: _netoMock(anio, qna),
        estado: estado,
        tieneReporte: false,
      ),
    );
  }

  // orden desc por seguridad
  out.sort((a, b) => ((b.anio * 100) + b.quincena).compareTo((a.anio * 100) + a.quincena));
  return out;
}

// ---------- helpers privados (si ya existen en tu archivo, NO dupliques) ----------
static double _netoMock(int anio, int qna) {
  // mock estable por periodo (no random loco cada hot reload)
  final key = (anio * 100) + qna;
  final base = 11800.0 + (qna * 73.25);
  final wiggle = (key % 17) * 19.3;
  return base + wiggle;
}

static int _mesDesdeQuincena(int qna) => ((qna - 1) ~/ 2) + 1;

static DateTime _disponibleAt(int anio, int qna) {
  final mes = _mesDesdeQuincena(qna);
  if (qna.isOdd) {
    // 1ra quincena -> 16 del mes
    return DateTime(anio, mes, 16, 9, 0);
  } else {
    // 2da quincena -> último día del mes
    final lastDay = DateTime(anio, mes + 1, 0).day;
    return DateTime(anio, mes, lastDay, 9, 0);
  }
}

static String _periodoLabel(int anio, int qna) {
  const m = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
  final mes = _mesDesdeQuincena(qna).clamp(1, 12);
  return '${m[mes - 1]} $anio · Qna ${qna.toString().padLeft(2, '0')}';
}


  static ReciboDetalle buildDetalle(ReciboResumen r) {
    // Mock de conceptos
    final percepciones = <String, double>{
      'Sueldo base': (r.neto * 1.25),
      'Compensación': (r.neto * 0.18),
      'Apoyo': (r.neto * 0.07),
    };

    final deducciones = <String, double>{
      'ISR': (r.neto * 0.22),
      'Seguridad social': (r.neto * 0.10),
      'Otros': (r.neto * 0.03),
    };

    double sum(Map<String, double> m) => m.values.fold(0, (a, b) => a + b);

    return ReciboDetalle(
      resumen: r,
      percepciones: percepciones,
      deducciones: deducciones,
      totalPercepciones: sum(percepciones),
      totalDeducciones: sum(deducciones),
    );
  }

  static ProximaNominaInfo buildProximaNomina() {
    final now = DateTime.now();
    // próxima quincena mock: si estamos cerca de una disponible, mueve al futuro inmediato
    final disponibleAt = DateTime(now.year, now.month, min(now.day + 4, 28), 10, 30);
    final q = ((now.month - 1) * 2) + (now.day <= 15 ? 1 : 2);

    return ProximaNominaInfo(
      anio: now.year,
      quincena: q.clamp(1, 24),
      disponibleAt: disponibleAt,
    );
  }
}
