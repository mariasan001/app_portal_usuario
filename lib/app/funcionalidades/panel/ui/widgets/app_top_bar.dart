import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class AppTopBar extends StatelessWidget {
  final String nombre;
  final String hintSearch;

  const AppTopBar({
    super.key,
    required this.nombre,
    required this.hintSearch,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFEFEFEF),
                child: Icon(Icons.person, color: Color(0xFF777777)),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  nombre,
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ColoresApp.texto,
                  ),
                ),
              ),

              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Search
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: ColoresApp.blanco.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x12000000)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 20, color: Color(0xFF777777)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hintSearch,
                    style: t.bodySmall?.copyWith(
                      color: ColoresApp.textoSuave,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                  color: ColoresApp.vino,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
