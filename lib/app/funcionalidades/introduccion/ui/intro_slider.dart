
library introduccion_intro_slider;

import 'dart:async';
import 'package:flutter/material.dart';

import '../../../tema/colores.dart';
import '../modelos/slide_intro.dart';

part 'intro_slider_parts/skip_chip.dart';
part 'intro_slider_parts/swipe_hint.dart';
part 'intro_slider_parts/bottom_card.dart';
part 'intro_slider_parts/circle_action.dart';
part 'intro_slider_parts/auto_next_button.dart';
part 'intro_slider_parts/indicador_dots.dart';
class IntroSlider extends StatefulWidget {
  final SlideIntro slide;
  final int index; // index global del pageview (1..3)
  final int totalIntros; // 3
  final bool esUltimo;

  final VoidCallback onSaltar;
  final VoidCallback onAtras;
  final VoidCallback onSiguiente;

  const IntroSlider({
    super.key,
    required this.slide,
    required this.index,
    required this.totalIntros,
    required this.esUltimo,
    required this.onSaltar,
    required this.onAtras,
    required this.onSiguiente,
  });

  @override
  State<IntroSlider> createState() => _IntroSliderState();
}

class _IntroSliderState extends State<IntroSlider> with TickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final AnimationController _autoCtrl;
  late final AnimationController _hintCtrl;

  Timer? _resumeTimer;

  static const _enterDur = Duration(milliseconds: 380);
  static const _autoDur = Duration(seconds: 6);
  static const _resumeAfter = Duration(seconds: 3);

  bool _autoPausedByUser = false;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(vsync: this, duration: _enterDur)..forward();

    _autoCtrl = AnimationController(vsync: this, duration: _autoDur);
    _autoCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        if (!mounted) return;
        if (!widget.esUltimo && !_autoPausedByUser) {
          widget.onSiguiente();
        }
      }
    });

    _hintCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    _startAutoIfNeeded();
  }

  @override
  void didUpdateWidget(covariant IntroSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.index != widget.index || oldWidget.slide.imagen != widget.slide.imagen) {
      _enterCtrl.forward(from: 0);
      _autoPausedByUser = false;
      _startAutoIfNeeded(restart: true);
    }

    if (!oldWidget.esUltimo && widget.esUltimo) {
      _stopAuto();
    }
  }

  @override
  void dispose() {
    _resumeTimer?.cancel();
    _enterCtrl.dispose();
    _autoCtrl.dispose();
    _hintCtrl.dispose();
    super.dispose();
  }

  void _startAutoIfNeeded({bool restart = false}) {
    if (widget.esUltimo) return;
    if (_autoPausedByUser) return;

    if (restart) {
      _autoCtrl.forward(from: 0);
      return;
    }

    if (!_autoCtrl.isAnimating) {
      _autoCtrl.forward(from: 0);
    }
  }

  void _stopAuto() {
    _resumeTimer?.cancel();
    _autoCtrl.stop();
  }

  void _pauseAutoAndResumeLater() {
    if (widget.esUltimo) return;

    _autoPausedByUser = true;
    _stopAuto();

    _resumeTimer?.cancel();
    _resumeTimer = Timer(_resumeAfter, () {
      if (!mounted) return;
      _autoPausedByUser = false;
      _startAutoIfNeeded(restart: true);
    });
  }

  void _onUserIntent() => _pauseAutoAndResumeLater();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final indexIntro = widget.index - 1;

    final fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic);
    final cardSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
    final imgScale = Tween<double>(begin: 0.985, end: 1.0)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onUserIntent(), // pausa auto sin bloquear swipe del PageView
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: _SkipChip(
                onTap: () {
                  _onUserIntent();
                  widget.onSaltar();
                },
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Center(
                child: FadeTransition(
                  opacity: fade,
                  child: ScaleTransition(
                    scale: imgScale,
                    child: Image.asset(widget.slide.imagen, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            if (widget.index == 1) ...[
              _SwipeHint(ctrl: _hintCtrl),
              const SizedBox(height: 10),
            ],

            FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: cardSlide,
                child: _BottomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Text(
                          widget.slide.titulo,
                          key: ValueKey('titulo-${widget.index}'),
                          textAlign: TextAlign.center,
                          style: t.titleMedium?.copyWith(
                            color: ColoresApp.texto,
                            fontWeight: FontWeight.w800,
                            height: 1.12,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Text(
                          widget.slide.descripcion,
                          key: ValueKey('desc-${widget.index}'),
                          textAlign: TextAlign.center,
                          style: t.bodySmall?.copyWith(
                            color: ColoresApp.textoSuave,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _CircleAction(
                            onTap: () {
                              _onUserIntent();
                              widget.onAtras();
                            },
                            enabled: widget.index > 1,
                            icon: Icons.arrow_back,
                            variant: _CircleVariant.filled,
                          ),

                          _IndicadorDots(actual: indexIntro, total: widget.totalIntros),

                          _AutoNextButton(
                            progress: _autoCtrl,
                            showProgress: !widget.esUltimo && !_autoPausedByUser,
                            icon: widget.esUltimo ? Icons.check : Icons.arrow_forward,
                            onTap: () {
                              _onUserIntent();
                              widget.onSiguiente();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
