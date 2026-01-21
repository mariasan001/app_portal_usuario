// lib/app/funcionalidades/home/data/noticiero_mock.dart

import '../domain/noticiero_post.dart';

final noticieroMockPosts = <NoticieroPost>[
  NoticieroPost(
    id: '1',
    autorNombre: 'Dirección General',
    autorAvatarUrl: null,
    etiqueta: NoticieroEtiqueta.oficial,
    titulo: 'Actualización de servicios',
    descripcion: 'Ya puedes consultar tus recibos y trámites desde el portal.',
    imagenUrl: 'https://images.unsplash.com/photo-1521791136064-7986c2920216?w=1200&q=80',
    fecha: DateTime.now().subtract(const Duration(hours: 2)),
    likes: 128,
    isLiked: false,
  ),
  NoticieroPost(
    id: '2',
    autorNombre: 'Mesa de Ayuda',
    autorAvatarUrl: null,
    etiqueta: NoticieroEtiqueta.aviso,
    titulo: 'Mantenimiento programado',
    descripcion: 'El portal estará en mantenimiento hoy a las 11:30 pm.',
    imagenUrl: 'https://images.unsplash.com/photo-1553877522-43269d4ea984?w=1200&q=80',
    fecha: DateTime.now().subtract(const Duration(days: 1)),
    likes: 56,
    isLiked: true,
  ),
  NoticieroPost(
    id: '3',
    autorNombre: 'Gestión Administrativa',
    autorAvatarUrl: null,
    etiqueta: NoticieroEtiqueta.reporte,
    titulo: 'Nuevo trámite disponible',
    descripcion: 'Se habilitó la solicitud de constancias en línea.',
    imagenUrl: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=1200&q=80',
    fecha: DateTime.now().subtract(const Duration(days: 3)),
    likes: 77,
    isLiked: false,
  ),
];
