import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class DocumentoDetallePage extends StatelessWidget {
  final String documentoId;
  const DocumentoDetallePage({super.key, required this.documentoId});

  Map<String, String> _demoEvidencia(String id) {
    // ✅ demo “de locos”
    return {
      'Evidencia Criptográfica': 'Transacción SeguriSign',
      'Archivo firmado': '$id.pdf',
      'Secuencia': '54151816',
      'Autoridad Certificadora':
          'AUTORIDAD CERTIFICADORA DEL GOBIERNO DEL ESTADO DE MÉXICO',
      'OCSP': 'GOOD · Respuesta válida',
      'TSP': 'Timestamp aplicado',
      'Hash': 'SHA-256 · b4cb80ee…efcb',
      'UUID': 'b4cb80ee-440c-45e4-81f8-e8ac52f1efcb',
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final evidencia = _demoEvidencia(documentoId);

    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Título con línea café (sin icono)
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 22,
                    decoration: BoxDecoration(
                      color: ColoresApp.cafe.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Documento',
                      style: t.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: ColoresApp.texto,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ✅ Preview (placeholder)
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: ColoresApp.inputBg.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: ColoresApp.bordeSuave),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIcons.filePdf(PhosphorIconsStyle.light),
                        size: 34,
                        color: ColoresApp.textoSuave,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vista previa del PDF (demo)',
                        style: t.bodyMedium?.copyWith(
                          fontSize: 12.4,
                          fontWeight: FontWeight.w800,
                          color: ColoresApp.textoSuave,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ✅ Acciones (sin botón negro)
              Row(
                children: [
                  _Action(
                    icon: PhosphorIcons.downloadSimple(PhosphorIconsStyle.light),
                    label: 'Descargar',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Descargando (demo)')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _Action(
                    icon: PhosphorIcons.shareNetwork(PhosphorIconsStyle.light),
                    label: 'Compartir',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Compartiendo (demo)')),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ✅ Evidencia criptográfica (lo pro)
              Text(
                'Evidencia de firma',
                style: t.bodyMedium?.copyWith(
                  fontSize: 13.2,
                  fontWeight: FontWeight.w900,
                  color: ColoresApp.texto,
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ColoresApp.blanco,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: ColoresApp.bordeSuave),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    itemCount: evidencia.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 14,
                      thickness: 1,
                      color: ColoresApp.bordeSuave.withOpacity(0.7),
                    ),
                    itemBuilder: (context, i) {
                      final k = evidencia.keys.elementAt(i);
                      final v = evidencia[k]!;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              k,
                              style: t.bodySmall?.copyWith(
                                fontSize: 11.4,
                                fontWeight: FontWeight.w800,
                                color: ColoresApp.texto,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 6,
                            child: Text(
                              v,
                              style: t.bodySmall?.copyWith(
                                fontSize: 11.2,
                                fontWeight: FontWeight.w700,
                                color: ColoresApp.textoSuave,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Expanded(
      child: Material(
        color: ColoresApp.inputBg.withOpacity(0.75),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColoresApp.bordeSuave),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: ColoresApp.texto),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: t.labelMedium?.copyWith(
                    fontSize: 11.6,
                    fontWeight: FontWeight.w900,
                    color: ColoresApp.texto,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
