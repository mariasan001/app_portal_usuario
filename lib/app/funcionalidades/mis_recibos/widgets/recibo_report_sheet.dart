import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import 'mis_recibos_ui.dart';

class ReciboReportSheet {
  static Future<_ReporteResult?> open(BuildContext context) {
    return showModalBottomSheet<_ReporteResult?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: ColoresApp.blanco,
      barrierColor: Colors.black.withOpacity(0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const _ReciboReportBody(),
      ),
    );
  }
}

class _ReporteResult {
  const _ReporteResult({required this.motivo, this.detalle});
  final String motivo;
  final String? detalle;
}

class _ReciboReportBody extends StatefulWidget {
  const _ReciboReportBody();

  @override
  State<_ReciboReportBody> createState() => _ReciboReportBodyState();
}

class _ReciboReportBodyState extends State<_ReciboReportBody> {
  String _motivo = _motivos.first;
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: ColoresApp.bordeSuave,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Reportar problema',
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w900, color: ColoresApp.texto),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: ColoresApp.inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ColoresApp.bordeSuave),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _motivo,
                isExpanded: true,
                dropdownColor: ColoresApp.blanco,
                items: _motivos
                    .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                    .toList(),
                onChanged: (v) => setState(() => _motivo = v ?? _motivos.first),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: ColoresApp.blanco,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ColoresApp.bordeSuave),
            ),
            child: TextField(
              controller: _ctrl,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Describe el problema (opcional)…',
                hintStyle: t.bodySmall?.copyWith(color: ColoresApp.textoSuave, fontWeight: FontWeight.w800),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: UiSecondaryButton(
                  text: 'Cancelar',
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: UiPrimaryButton(
                  text: 'Enviar',
                  accent: ColoresApp.cafe,
                  onTap: () {
                    Navigator.pop(
                      context,
                      _ReporteResult(
                        motivo: _motivo,
                        detalle: _ctrl.text.trim().isEmpty ? null : _ctrl.text.trim(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const List<String> _motivos = [
  'Saldo incorrecto',
  'Descuentos no reconocidos',
  'Percepciones incompletas',
  'Datos personales incorrectos',
  'Otro',
];
