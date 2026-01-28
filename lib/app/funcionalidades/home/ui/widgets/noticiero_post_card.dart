// lib/app/funcionalidades/home/ui/widget/noticiero_post_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import '../../domain/noticiero_post.dart';

class NoticieroPostCard extends StatelessWidget {
  final NoticieroPost post;
  final VoidCallback onLike;
  final VoidCallback onShare;

  /// Ratio cuando el card NO tiene altura limitada (feed vertical).
  /// Más bajo => imagen más alta (más “larga”).
  final double imageAspectRatio;

  const NoticieroPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onShare,
    this.imageAspectRatio = 11 / 14, // 👈 aquí lo ajustas si quieres
  });

  Color _accent(NoticieroEtiqueta e) {
    switch (e) {
      case NoticieroEtiqueta.oficial:
        return ColoresApp.dorado;
      case NoticieroEtiqueta.aviso:
        return ColoresApp.cafe;
      case NoticieroEtiqueta.reporte:
        return ColoresApp.vino;
    }
  }

  bool get _hasAvatar => (post.autorAvatarUrl ?? '').trim().isNotEmpty;
  bool get _hasImage => post.imagenUrl.trim().isNotEmpty;

  String get _authorInitial {
    final name = post.autorNombre.trim();
    if (name.isEmpty) return 'P';
    return name[0].toUpperCase();
  }

  String _formatFecha(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    final h = two(dt.hour);
    final m = two(dt.minute);

    final now = DateTime.now();
    final isToday = now.year == dt.year && now.month == dt.month && now.day == dt.day;
    if (isToday) return 'Hoy · $h:$m';

    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final mes = meses[dt.month - 1];
    return '${dt.day} $mes · $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent(post.etiqueta);

    return LayoutBuilder(
      builder: (context, constraints) {
        // ✅ En horizontal, el item viene con altura limitada => aquí ocurre el overflow si no controlamos.
        final boundedHeight = constraints.hasBoundedHeight;

        // ✅ Solo usamos flex si hay altura limitada Y hay imagen.
        final useFlexImage = boundedHeight && _hasImage;

        return Material(
          color: ColoresApp.blanco,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: ColoresApp.bordeSuave),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              mainAxisSize: useFlexImage ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  autorNombre: post.autorNombre,
                  fechaPublicacion: post.fechaPublicacion,
                  hasAvatar: _hasAvatar,
                  autorAvatarUrl: post.autorAvatarUrl,
                  authorInitial: _authorInitial,
                  etiqueta: post.etiqueta.texto,
                  accent: accent,
                  formatFecha: _formatFecha,
                ),

                // ✅ Imagen SOLO si existe (sin huecos)
                if (_hasImage) ...[
                  if (useFlexImage)
                    Expanded(
                      child: _LikeableImage(
                        imageUrl: post.imagenUrl,
                        useAspectRatio: false, // 👈 en horizontal se ajusta al espacio
                        aspectRatio: imageAspectRatio,
                        onDoubleTapLike: () {
                          HapticFeedback.selectionClick();
                          onLike();
                        },
                      ),
                    )
                  else
                    _LikeableImage(
                      imageUrl: post.imagenUrl,
                      useAspectRatio: true, // 👈 en vertical respeta ratio
                      aspectRatio: imageAspectRatio,
                      onDoubleTapLike: () {
                        HapticFeedback.selectionClick();
                        onLike();
                      },
                    ),
                ],

                // ✅ Si NO hay imagen: separador sutil (0 blancos)
                if (!_hasImage)
                  Container(
                    height: 1,
                    color: ColoresApp.bordeSuave.withOpacity(0.7),
                  ),

                _ActionsRow(
                  isLiked: post.isLiked,
                  likes: post.likes,
                  onLike: () {
                    HapticFeedback.selectionClick();
                    onLike();
                  },
                  onShare: () {
                    HapticFeedback.selectionClick();
                    onShare();
                  },
                ),

                _Caption(
                  titulo: post.titulo,
                  descripcion: post.descripcion,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* =======================================================================
  HEADER
======================================================================= */

class _Header extends StatelessWidget {
  final String autorNombre;
  final DateTime fechaPublicacion;
  final bool hasAvatar;
  final String? autorAvatarUrl;
  final String authorInitial;
  final String etiqueta;
  final Color accent;
  final String Function(DateTime) formatFecha;

  const _Header({
    required this.autorNombre,
    required this.fechaPublicacion,
    required this.hasAvatar,
    required this.autorAvatarUrl,
    required this.authorInitial,
    required this.etiqueta,
    required this.accent,
    required this.formatFecha,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: ColoresApp.inputBg,
              shape: BoxShape.circle,
              border: Border.all(color: ColoresApp.bordeSuave),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: ColoresApp.inputBg,
              backgroundImage: hasAvatar ? NetworkImage(autorAvatarUrl!) : null,
              child: !hasAvatar
                  ? Text(
                      authorInitial,
                      style: t.labelMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: ColoresApp.texto,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  autorNombre.trim().isEmpty ? 'Dirección General' : autorNombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodyMedium?.copyWith(
                    fontSize: 11.2,
                    fontWeight: FontWeight.w900,
                    color: ColoresApp.texto,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatFecha(fechaPublicacion),
                  style: t.bodySmall?.copyWith(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                    color: ColoresApp.textoSuave,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),

          _TagChip(text: etiqueta, accent: accent),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;
  final Color accent;

  const _TagChip({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withOpacity(0.18)),
      ),
      child: Text(
        text,
        style: t.labelSmall?.copyWith(
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          color: accent,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/* =======================================================================
  IMAGE (asset/network) + HEART POP
======================================================================= */

class _LikeableImage extends StatefulWidget {
  final String imageUrl;
  final VoidCallback onDoubleTapLike;

  /// Si true: usa AspectRatio (vertical feed).
  /// Si false: se adapta al espacio (horizontal feed con altura fija).
  final bool useAspectRatio;
  final double aspectRatio;

  const _LikeableImage({
    required this.imageUrl,
    required this.onDoubleTapLike,
    required this.useAspectRatio,
    required this.aspectRatio,
  });

  @override
  State<_LikeableImage> createState() => _LikeableImageState();
}

class _LikeableImageState extends State<_LikeableImage> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _scale = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _popHeart() => _c.forward(from: 0);

  bool _isAsset(String v) => v.trim().startsWith('assets/');
  bool _isNetwork(String v) {
    final s = v.trim();
    return s.startsWith('http://') || s.startsWith('https://');
  }

  Widget _placeholder() {
    return Container(
      color: ColoresApp.inputBg,
      alignment: Alignment.center,
      child: Icon(
        PhosphorIcons.image(PhosphorIconsStyle.light),
        color: ColoresApp.textoSuave,
        size: 28,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final src = widget.imageUrl.trim();

    Widget image;
    if (_isAsset(src)) {
      image = Image.asset(
        src,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else if (_isNetwork(src)) {
      image = Image.network(
        src,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(color: ColoresApp.inputBg);
        },
      );
    } else {
      image = _placeholder();
    }

    final content = GestureDetector(
      onDoubleTap: () {
        widget.onDoubleTapLike();
        _popHeart();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Icon(
                  PhosphorIcons.heart(PhosphorIconsStyle.fill),
                  size: 78,
                  color: ColoresApp.blanco.withOpacity(0.92),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // ✅ Vertical: ratio controlado / Horizontal: se adapta (sin overflow)
    if (widget.useAspectRatio) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: content,
      );
    }

    return SizedBox.expand(child: content);
  }
}

/* =======================================================================
  ACTIONS
======================================================================= */

class _ActionsRow extends StatelessWidget {
  final bool isLiked;
  final int likes;
  final VoidCallback onLike;
  final VoidCallback onShare;

  const _ActionsRow({
    required this.isLiked,
    required this.likes,
    required this.onLike,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          _ActionPill(
            onTap: onLike,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 160),
                  scale: isLiked ? 1.08 : 1.0,
                  child: Icon(
                    isLiked
                        ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                        : PhosphorIcons.heart(PhosphorIconsStyle.light),
                    size: 19,
                    color: isLiked ? ColoresApp.vino : ColoresApp.texto,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$likes',
                  style: t.labelMedium?.copyWith(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w900,
                    color: ColoresApp.textoSuave,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _ActionPill(
            onTap: onShare,
            child: Icon(
              PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.light),
              size: 19,
              color: ColoresApp.texto,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ActionPill({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColoresApp.inputBg.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: child,
        ),
      ),
    );
  }
}

/* =======================================================================
  CAPTION
======================================================================= */

class _Caption extends StatelessWidget {
  final String titulo;
  final String? descripcion;

  const _Caption({required this.titulo, required this.descripcion});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final desc = (descripcion ?? '').trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.bodyMedium?.copyWith(
              fontSize: 12.2,
              fontWeight: FontWeight.w900,
              color: ColoresApp.texto,
              letterSpacing: 0.1,
            ),
          ),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: t.bodySmall?.copyWith(
                fontSize: 11.4,
                height: 1.25,
                fontWeight: FontWeight.w600,
                color: ColoresApp.textoSuave,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
