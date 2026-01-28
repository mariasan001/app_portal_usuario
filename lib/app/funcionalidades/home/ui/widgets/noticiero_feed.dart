// lib/app/funcionalidades/home/ui/widget/noticiero_feed.dart

import 'package:flutter/material.dart';

import '../../domain/noticiero_post.dart';
import 'noticiero_post_card.dart';

class NoticieroFeed extends StatelessWidget {
  final List<NoticieroPost> posts;
  final void Function(String postId) onLike;
  final void Function(NoticieroPost post) onShare;

  /// ✅ nuevo: dirección del feed
  final Axis direction;

  /// ✅ nuevo: tamaño para modo horizontal
  final double height;
  final double itemWidth;

  /// ✅ padding configurable
  final EdgeInsets padding;

  const NoticieroFeed({
    super.key,
    required this.posts,
    required this.onLike,
    required this.onShare,
    this.direction = Axis.vertical,
    this.height = 530,
    this.itemWidth = 320,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 18),
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(child: Text('Sin publicaciones por ahora.'));
    }

    // ✅ Vertical (como lo tenías)
    if (direction == Axis.vertical) {
      return ListView.separated(
        padding: padding,
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final post = posts[i];
          return NoticieroPostCard(
            post: post,
            onLike: () => onLike(post.id),
            onShare: () => onShare(post),
          );
        },
      );
    }

    // ✅ Horizontal (lado a lado)
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: padding,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final post = posts[i];
          return SizedBox(
            width: itemWidth,
            child: NoticieroPostCard(
              post: post,
              onLike: () => onLike(post.id),
              onShare: () => onShare(post),
            ),
          );
        },
      ),
    );
  }
}
