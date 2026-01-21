// lib/app/funcionalidades/home/ui/inicio_tab.dart

import 'package:flutter/material.dart';

import 'package:portal_servicios_usuario/app/funcionalidades/home/ui/widgets/noticiero_feed.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/home/ui/widgets/section_header.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/home/ui/widgets/enlaces_institucionales_section.dart';

import '../data/noticiero_mock.dart';
import '../domain/noticiero_post.dart';

// ✅ enlaces institucionales (domain + mock)
import '../domain/enlace_institucional.dart';
import '../data/enlaces_institucionales_mock.dart';

class InicioTab extends StatefulWidget {
  const InicioTab({super.key});

  @override
  State<InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends State<InicioTab> {
  late List<NoticieroPost> _posts;

  @override
  void initState() {
    super.initState();
    _posts = List.of(noticieroMockPosts);
  }

  void _toggleLike(String postId) {
    setState(() {
      _posts = _posts.map((p) {
        if (p.id != postId) return p;
        final nextLiked = !p.isLiked;
        final nextLikes = nextLiked ? p.likes + 1 : (p.likes > 0 ? p.likes - 1 : 0);
        return p.copyWith(isLiked: nextLiked, likes: nextLikes);
      }).toList();
    });
  }

  void _share(NoticieroPost post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Compartir: ${post.titulo}')),
    );
  }

  void _openEnlace(EnlaceInstitucional it) {
    // ✅ placeholder: aquí luego metes url_launcher o webview
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrir: ${it.titulo}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ tu lista de enlaces (mock)
    final List<EnlaceInstitucional> enlaces = enlacesInstitucionalesMock;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 8),

        // =========================
        // NOTICIERO
        // =========================
        const SectionHeaderChip(
          title: 'Noticiero',
          chipText: 'Actualizado',
        ),

        NoticieroFeed(
          posts: _posts,
          onLike: _toggleLike,
          onShare: _share,
          direction: Axis.horizontal,
          height: 430,
          itemWidth: 320,
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
        ),

        const SizedBox(height: 6),

        // =========================
        // ENLACES INSTITUCIONALES
        // =========================
        EnlacesInstitucionalesSection(
          items: enlaces,
          onTap: _openEnlace,
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}
