import '../domain/noticiero_post.dart';

final noticieroMockPosts = <NoticieroPost>[
  NoticieroPost(
    id: '3',
    autorNombre: 'Dirección General',
    autorAvatarUrl: null,
    etiqueta: NoticieroEtiqueta.reporte,
    titulo: 'Seguridad digital',
    descripcion: 'Cuidar tus datos personales es cuidar tu identidad.',
    imagenUrl: 'assets/img/post/post_3.png', // ✅ asset
    fecha: DateTime.now().subtract(const Duration(hours: 2)),
    likes: 128,
    isLiked: false,
  ),
  NoticieroPost(
    id: '2',
    autorNombre: 'Mesa de Ayuda',
    autorAvatarUrl: null,
    etiqueta: NoticieroEtiqueta.aviso,
    titulo: 'Constancia por sector',
    descripcion: 'Consulta la ruta correcta según tu perfil y QR.',
    imagenUrl: 'assets/img/post/post_1.png', // ✅ asset
    fecha: DateTime.now().subtract(const Duration(days: 1)),
    likes: 56,
    isLiked: true,
  ),
  NoticieroPost(
    id: '1',
    autorNombre: 'Gestión Administrativa',
    autorAvatarUrl: null,
    etiqueta: NoticieroEtiqueta.oficial,
    titulo: 'Que no te pase',
    descripcion: 'Si tus datos fiscales no están actualizados, tu pago podría llegar en cheque… .',
    imagenUrl: 'assets/img/post/post_2.png', // ✅ asset
    fecha: DateTime.now().subtract(const Duration(days: 3)),
    likes: 77,
    isLiked: false,
  ),

  // ✅ Ejemplo SIN imagen (se verá igual de pro, sin hueco blanco)

];
