import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class AppMoreSheet extends StatelessWidget {
  final VoidCallback onPerfil;
  final VoidCallback onConfig;
  final VoidCallback onAyuda;
  final VoidCallback onLogout;

  const AppMoreSheet({
    super.key,
    required this.onPerfil,
    required this.onConfig,
    required this.onAyuda,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget item(IconData icon, String text, VoidCallback onTap, {Color? color}) {
      return ListTile(
        leading: Icon(icon, color: color ?? ColoresApp.vino),
        title: Text(text, style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        onTap: onTap,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          item(Icons.person_rounded, 'Editar perfil', onPerfil),
          item(Icons.settings_rounded, 'Configuración', onConfig),
          item(Icons.support_agent_rounded, 'Ayuda y soporte', onAyuda),
          const Divider(),
          item(Icons.logout_rounded, 'Cerrar sesión', onLogout, color: Colors.redAccent),
        ],
      ),
    );
  }
}
