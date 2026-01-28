import 'package:flutter/material.dart';

enum FaqTema { todos, portal, tramites, documentos, cuenta, seguridad, soporte }

extension FaqTemaX on FaqTema {
  String get label {
    switch (this) {
      case FaqTema.todos:
        return 'Todos';
      case FaqTema.portal:
        return 'Portal';
      case FaqTema.tramites:
        return 'Trámites';
      case FaqTema.documentos:
        return 'Documentos';
      case FaqTema.cuenta:
        return 'Cuenta';
      case FaqTema.seguridad:
        return 'Seguridad';
      case FaqTema.soporte:
        return 'Soporte';
    }
  }
}

class FaqItem {
  final String id;
  final String pregunta;
  final String respuesta;
  final FaqTema tema;
  final IconData icon;

  const FaqItem({
    required this.id,
    required this.pregunta,
    required this.respuesta,
    required this.tema,
    required this.icon,
  });
}
