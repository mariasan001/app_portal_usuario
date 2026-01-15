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
  int _index = 0; // ahora 0..2 (solo intros)

  Timer? _autoTimer;
  bool _mostrarSplash = true;

  final String _logoPath = 'assets/img/logo.png';

  final _intros = const <SlideIntro>[
    SlideIntro(
      imagen: 'assets/img/intro_1.png',
      titulo: 'CONSULTA TUS DOCUMENTOS LABORALES',
      descripcion:
          'accede a tus recibos de nómina, finiquitos, anualizados y comprobantes fiscales, vinculados a tu perfil.Todo en un solo lugar, seguro y personalizado.',
    ),
    SlideIntro(
      imagen: 'assets/img/intro_2.png',
      titulo: 'INICIA O DA SEGUIMIENTO A TRÁMITES',
      descripcion:
          'solicita movimientos, licencias o cualquier trámite oficial con transparencia, historial y control desde tu sesión.Sin filas, sin vueltas: todo desde el espacio.',
    ),
    SlideIntro(
      imagen: 'assets/img/intro_3.png',
      titulo: 'INFORMACIÓN OFICIAL Y ACTUALIZADA',
      descripcion:
          'consulta lineamientos, acuerdos y disposiciones oficiales que aplican según tu rol y situación laboral.Siempre vigentes, claros y en un solo lugar.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // ✅ Splash solo al arranque
    _autoTimer = Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      setState(() => _mostrarSplash = false);
    });
  }

  void _irLogin() => context.go('/login');

  void _siguiente() {
    final ultimo = _index == _intros.length - 1;
    if (ultimo) return _irLogin();

    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _atras() {
    if (_index <= 0) return;

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
    // ✅ 1) Splash fuera del PageView: NO hay forma de volver con swipe.
    if (_mostrarSplash) {
      return Scaffold(
        backgroundColor: ColoresApp.fondoCrema,
        body: SafeArea(
          child: SplashLogo(
            imagen: _logoPath,
            mostrarLoader: true,
          ),
        ),
      );
    }

    // ✅ 2) Ya solo quedan los 3 intros (0..2)
    final totalIntros = _intros.length;

    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageCtrl,
          onPageChanged: (i) => setState(() => _index = i),
          itemCount: _intros.length,
          itemBuilder: (context, i) {
            final s = _intros[i];
            final esUltimo = i == _intros.length - 1;

            return IntroSlider(
              slide: s,
              index: i + 1, 
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
