// lib/app/funcionalidades/home/domain/enlace_institucional.dart

import 'package:flutter/material.dart';

class EnlaceInstitucional {
  final String id;
  final String titulo;
  final String? subtitle;

  /// Puede ser una URL externa o una ruta interna (GoRouter).
  final String destino;

  /// Icono (Phosphor o Material).
  final IconData icon;

  /// Acento visual (línea delgadita / bubble).
  final Color accent;

  const EnlaceInstitucional({
    required this.id,
    required this.titulo,
    required this.destino,
    required this.icon,
    required this.accent,
    this.subtitle,
  });

  bool get esUrlExterna => destino.startsWith('http://') || destino.startsWith('https://');
}
