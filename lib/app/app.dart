import 'package:flutter/material.dart';
import 'enrutador/enrutador_app.dart';
import 'tema/tema_app.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Portal Servicios',
      routerConfig: EnrutadorApp.router,
      theme: TemaApp.construir(), // ✅ AQUÍ
    );
  }
}
