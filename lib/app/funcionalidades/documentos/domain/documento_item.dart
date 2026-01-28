import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum DocumentoCategoria { constancias, vigencia, informacion }
enum DocumentoEstado { vigente, pendiente, vencido }

extension DocumentoCategoriaX on DocumentoCategoria {
  String get label {
    switch (this) {
      case DocumentoCategoria.constancias:
        return 'Constancias';
      case DocumentoCategoria.vigencia:
        return 'Vigencia';
      case DocumentoCategoria.informacion:
        return 'Información';
    }
  }
}

extension DocumentoEstadoX on DocumentoEstado {
  String get label {
    switch (this) {
      case DocumentoEstado.vigente:
        return 'Vigente';
      case DocumentoEstado.pendiente:
        return 'Pendiente';
      case DocumentoEstado.vencido:
        return 'Vencido';
    }
  }

  IconData get icon {
    switch (this) {
      case DocumentoEstado.vigente:
        return PhosphorIcons.sealCheck(PhosphorIconsStyle.light);
      case DocumentoEstado.pendiente:
        return PhosphorIcons.clock(PhosphorIconsStyle.light);
      case DocumentoEstado.vencido:
        return PhosphorIcons.warningCircle(PhosphorIconsStyle.light);
    }
  }
}

class DocumentoItem {
  final String id;
  final String titulo;
  final String? descripcion;
  final DocumentoCategoria categoria;
  final DocumentoEstado estado;
  final DateTime? actualizado;
  final String? route; // ✅ si existe: navega a /servicios/:tipo/:id
  final IconData icon;

  const DocumentoItem({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.categoria,
    required this.estado,
    this.actualizado,
    this.route,
    required this.icon,
  });
}
