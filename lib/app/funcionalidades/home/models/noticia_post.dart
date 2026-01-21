// lib/app/funcionalidades/home/models/noticia_post.dart

import '../domain/noticiero_post.dart';

class NoticiaPostDto {
  final String id;
  final String autorNombre;
  final String? autorAvatarUrl;
  final String etiqueta;

  final String titulo;
  final String? descripcion;
  final String imagenUrl;

  /// ISO date string (ej: "2026-01-21T10:30:00Z")
  final String fechaIso;

  final int likes;
  final bool isLiked;

  const NoticiaPostDto({
    required this.id,
    required this.autorNombre,
    required this.autorAvatarUrl,
    required this.etiqueta,
    required this.titulo,
    required this.descripcion,
    required this.imagenUrl,
    required this.fechaIso,
    required this.likes,
    required this.isLiked,
  });

  factory NoticiaPostDto.fromJson(Map<String, dynamic> json) {
    final rawLikes = json['likes'];

    return NoticiaPostDto(
      id: (json['id'] ?? '').toString(),
      autorNombre: (json['autorNombre'] ?? '').toString(),
      autorAvatarUrl: json['autorAvatarUrl']?.toString(),
      etiqueta: (json['etiqueta'] ?? 'Aviso').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      descripcion: json['descripcion']?.toString(),
      imagenUrl: (json['imagenUrl'] ?? '').toString(),

      // ✅ tu backend manda "fecha" -> lo guardamos en fechaIso
      fechaIso: (json['fecha'] ?? '').toString(),

      likes: rawLikes is int ? rawLikes : int.tryParse('$rawLikes') ?? 0,
      isLiked: (json['isLiked'] ?? false) == true,
    );
  }

  NoticieroPost toDomain() {
    final dt = DateTime.tryParse(fechaIso) ?? DateTime.now();

    return NoticieroPost(
      id: id,
      autorNombre: autorNombre,
      autorAvatarUrl: autorAvatarUrl,
      etiqueta: NoticieroEtiquetaX.fromString(etiqueta),
      titulo: titulo,
      descripcion: descripcion,
      imagenUrl: imagenUrl,
      fecha: dt,
      likes: likes,
      isLiked: isLiked,
    );
  }
}
