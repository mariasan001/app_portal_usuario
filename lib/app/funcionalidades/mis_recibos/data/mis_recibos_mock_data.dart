import 'dart:math';

import 'package:flutter/material.dart';

import '../domain/mis_recibos_models.dart';

class MisRecibosMockData {
  static final _rnd = Random(11);

  static List<ReciboResumen> buildRecibos() {
    final now = DateTime.now();
    final years = [now.year, now.year - 1, now.year - 2];

    final list = <ReciboResumen>[];

    for (final y in years) {
      // 24 quincenas (mock típico)
      for (int q = 1; q <= 24; q++) {
        // fecha “publicación” aproximada: cada 15 días
        final base = DateTime(y, 1, 1).add(Duration(days: (q - 1) * 15));
        final disponibleAt = DateTime(base.year, base.month, min(base.day + 10, 28), 10, 30);

        final neto = 8000 + _rnd.nextInt(9000) + _rnd.nextDouble();
        final estado = DateTime.now().isAfter(disponibleAt) ? ReciboEstado.disponible : ReciboEstado.pendiente;

        list.add(
          ReciboResumen(
            id: 'recibo_${y}_q${q.toString().padLeft(2, '0')}',
            anio: y,
            quincena: q,
            periodoLabel: 'Qna ${q.toString().padLeft(2, '0')} · $y',
            disponibleAt: disponibleAt,
            neto: neto,
            estado: estado,
          ),
        );
      }
    }

    // Ordena más recientes primero
    list.sort((a, b) => b.disponibleAt.compareTo(a.disponibleAt));
    return list;
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
