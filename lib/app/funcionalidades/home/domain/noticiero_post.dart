// lib/app/funcionalidades/home/domain/noticiero_post.dart

enum NoticieroEtiqueta { oficial, aviso, reporte }

extension NoticieroEtiquetaX on NoticieroEtiqueta {
  String get texto {
    switch (this) {
      case NoticieroEtiqueta.oficial:
        return 'Oficial';
      case NoticieroEtiqueta.aviso:
        return 'Aviso';
      case NoticieroEtiqueta.reporte:
        return 'Reporte';
    }
  }

  static NoticieroEtiqueta fromString(String? v) {
    final s = (v ?? '').trim().toLowerCase();
    if (s == 'oficial') return NoticieroEtiqueta.oficial;
    if (s == 'aviso') return NoticieroEtiqueta.aviso;
    if (s == 'reporte') return NoticieroEtiqueta.reporte;
    return NoticieroEtiqueta.aviso;
  }
}

class NoticieroPost {
  final String id;
  final String autorNombre;
  final String? autorAvatarUrl;

  final NoticieroEtiqueta etiqueta;

  final String titulo;
  final String? descripcion;
  final String imagenUrl;

  /// ✅ valor real (lo que tienes hoy)
  final DateTime fecha;

  final int likes;
  final bool isLiked;

  const NoticieroPost({
    required this.id,
    required this.autorNombre,
    required this.autorAvatarUrl,
    required this.etiqueta,
    required this.titulo,
    required this.descripcion,
    required this.imagenUrl,
    required this.fecha,
    required this.likes,
    required this.isLiked,
  });

  /// ✅ alias para UI (para que el card use "fechaPublicacion")
  DateTime get fechaPublicacion => fecha;

  NoticieroPost copyWith({
    String? id,
    String? autorNombre,
    String? autorAvatarUrl,
    NoticieroEtiqueta? etiqueta,
    String? titulo,
    String? descripcion,
    String? imagenUrl,
    DateTime? fecha,
    int? likes,
    bool? isLiked,
  }) {
    return NoticieroPost(
      id: id ?? this.id,
      autorNombre: autorNombre ?? this.autorNombre,
      autorAvatarUrl: autorAvatarUrl ?? this.autorAvatarUrl,
      etiqueta: etiqueta ?? this.etiqueta,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      fecha: fecha ?? this.fecha,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
