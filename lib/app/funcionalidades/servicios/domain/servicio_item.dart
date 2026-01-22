import 'package:flutter/material.dart';

enum ServicioTipo { consulta, tramite }

extension ServicioTipoX on ServicioTipo {
  String get texto {
    switch (this) {
      case ServicioTipo.consulta:
        return 'Consultas';
      case ServicioTipo.tramite:
        return 'Trámites';
    }
  }
}

enum ServicioCategoria {
  todas,
  controlPagos,
  prestacionesSocioeconomicas,
  remuneraciones,
  consultas,
}

extension ServicioCategoriaX on ServicioCategoria {
  String get texto {
    switch (this) {
      case ServicioCategoria.todas:
        return 'Todas';
      case ServicioCategoria.controlPagos:
        return 'Control de pagos';
      case ServicioCategoria.prestacionesSocioeconomicas:
        return 'Prestaciones';
      case ServicioCategoria.remuneraciones:
        return 'Remuneraciones';
      case ServicioCategoria.consultas:
        return 'Consultas';
    }
  }
}

class ServicioItem {
  final String id;
  final ServicioTipo tipo;
  final ServicioCategoria categoria;

  final String titulo;
  final String? subtitle;

  final IconData icon;
  final Color accent;

  /// Ruta opcional para navegación (GoRouter), ej:
  /// /servicios/tramite/t_quinquenio
  /// /servicios/consulta/c_fump
  final String? route;

  const ServicioItem({
    required this.id,
    required this.tipo,
    required this.categoria,
    required this.titulo,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.route,
  });
}
