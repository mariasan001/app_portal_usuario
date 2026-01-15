import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../tema/colores.dart';
import '../modelos/slide_intro.dart';
import 'intro_slider.dart';
import 'splash_logo.dart';

class BienvenidaPage extends StatefulWidget {
  const BienvenidaPage({super.key});

  @override
  State<BienvenidaPage> createState() => _BienvenidaPageState();
}

class _BienvenidaPageState extends State<BienvenidaPage> {
  final _pageCtrl = PageController();
  int _index = 0;

  Timer? _autoTimer;

  bool get _enSplash => _index == 0;

  final _slides = const <SlideIntro>[
    SlideIntro(imagen: 'assets/img/logo.png', titulo: '', descripcion: ''), // splash
    SlideIntro(
      imagen: 'assets/img/intro_1.png',
      titulo: 'CONSULTA TUS DOCUMENTOS\nLABORALES',
      descripcion:
          'accede a tus recibos de nómina, finiquitos, anualizados y\ncomprobantes fiscales, vinculados a tu perfil.\n\nTodo en un solo lugar, seguro y personalizado.',
    ),
    SlideIntro(
      imagen: 'assets/img/intro_2.png',
      titulo: 'INICIA O DA SEGUIMIENTO A\nTRÁMITES',
      descripcion:
          'solicita movimientos, licencias o cualquier trámite oficial\ncon transparencia, historial y control desde tu sesión.\n\nSin filas, sin vueltas: todo desde el espacio.',
    ),
    SlideIntro(
      imagen: 'assets/img/intro_3.png',
      titulo: 'INFORMACIÓN OFICIAL Y\nACTUALIZADA',
      descripcion:
          'consulta lineamientos, acuerdos y disposiciones oficiales\nque aplican según tu rol y situación laboral.\n\nSiempre vigentes, claros y en un solo lugar.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Splash auto-avanza después de un ratito (preloader real)
    _autoTimer = Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      if (_index == 0) _siguiente();
    });
  }

  void _irLogin() => context.go('/login');

  void _siguiente() {
    final ultimo = _index == _slides.length - 1;
    if (ultimo) return _irLogin();

    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _atras() {
    if (_index <= 1) return;

    _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalIntros = _slides.length - 1;

    return Scaffold(
      backgroundColor: _enSplash ? ColoresApp.fondoCrema : ColoresApp.blanco,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageCtrl,
          onPageChanged: (i) {
            setState(() => _index = i);

            // Si ya salió del splash, cancelamos el auto-avance para que no “empuje”
            if (i != 0) _autoTimer?.cancel();
          },
          itemCount: _slides.length,
          itemBuilder: (context, i) {
            final s = _slides[i];

            // 0) Splash
            if (i == 0) {
              return SplashLogo(
                imagen: s.imagen,
                mostrarLoader: true,
              );
            }

            // 1..3) Intro
            final esUltimo = i == _slides.length - 1;

            return IntroSlider(
              slide: s,
              index: i,
              totalIntros: totalIntros,
              esUltimo: esUltimo,
              onSaltar: _irLogin,
              onAtras: _atras,
              onSiguiente: _siguiente,
            );
          },
        ),
      ),
    );
  }
}
