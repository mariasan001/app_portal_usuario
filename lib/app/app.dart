import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'enrutador/enrutador_app.dart';
import 'tema/tema_app.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(EnrutadorApp.routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Portal Servicios',
      routerConfig: router,
      theme: TemaApp.construir(),
    );
  }
}
