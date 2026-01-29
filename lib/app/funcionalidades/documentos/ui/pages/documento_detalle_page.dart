import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/documentos/domain/constancia_laboral_data.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/documentos/service/documento_pdf_service.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';
import 'package:printing/printing.dart';

import '../../data/documentos_mock.dart';
import '../../domain/documento_item.dart';
import '../../domain/firma_evidencia.dart';

class DocumentoDetallePage extends StatefulWidget {
  final String documentoId;
  const DocumentoDetallePage({super.key, required this.documentoId});

  @override
  State<DocumentoDetallePage> createState() => _DocumentoDetallePageState();
}

class _DocumentoDetallePageState extends State<DocumentoDetallePage> {
  DocumentoItem? _doc;
  late FirmaEvidencia _ev;

  late Future<Uint8List> _pdfFuture;
  late Future<Uint8List> _thumbFuture;
  late Future<_PdfMeta> _metaFuture;

  DocumentoItem? _findDoc() {
    try {
      return documentosMock.firstWhere((d) => d.id == widget.documentoId);
    } catch (_) {
      return null;
    }
  }

  FirmaEvidencia _demoFirma(DocumentoItem doc) {
    return FirmaEvidencia(
      proveedor: 'SeguriSign',
      archivoFirmado: '${doc.id}.pdf',
      secuencia: '54151816',
      autoridadCertificadora: 'AUTORIDAD CERTIFICADORA DEL GOBIERNO DEL ESTADO DE MÉXICO',
      ocsp: 'GOOD · Respuesta válida',
      tsp: 'Timestamp aplicado',
      selloTiempo: DateTime.now().subtract(const Duration(minutes: 12)),
      urlVerificacion: 'https://segurisign.demo/verificar/${doc.id}',
    );
  }

  Map<String, String> _toMapEvidencia(DocumentoItem doc, FirmaEvidencia ev) {
    return {
      'Evidencia criptográfica': 'Transacción ${ev.proveedor}',
      'Archivo firmado': ev.archivoFirmado,
      'Secuencia': ev.secuencia,
      'Autoridad certificadora': ev.autoridadCertificadora,
      if (ev.ocsp != null) 'OCSP': ev.ocsp!,
      if (ev.tsp != null) 'TSP': ev.tsp!,
      if (ev.hashSha256 != null) 'Hash': 'SHA-256 · ${ev.hashSha256}',
      if (ev.urlVerificacion != null) 'Verificación': ev.urlVerificacion!,
    };
  }

  Future<Uint8List> _buildPdfBytes(DocumentoItem doc, FirmaEvidencia ev) {
return DocumentoPdfService.buildConstanciaLaboralPdf(
  doc: doc,
  evidencia: ev,
  data: ConstanciaLaboralData(
    folio: 'CNL-${doc.id.toUpperCase()}',
    lugar: 'Toluca, Estado de México',
    fechaEmision: DateTime.now(),
    nombre: 'MARIA FERNANDA SAGM',
    numeroServidor: '123456',
    curp: 'SAGM001101MDFRXXX0',
    dependencia: 'Gobierno del Estado de México',
    area: 'Dirección General de Personal',
    puesto: 'Analista de Sistemas',
    tipoNombramiento: 'Confianza',
    fechaIngreso: DateTime(2022, 3, 1),
    estatusLaboral: 'Activo/a',
    rfc: 'SAGM001101XXX',
    nivel: 'N-12',
    percepcionBrutaMensual: '\$32,450.00 MXN',
  ),
);
  }

  Future<Uint8List> _buildThumbFromPdf(Uint8List pdfBytes) async {
    await for (final page in Printing.raster(pdfBytes, pages: [0], dpi: 150)) {
      final png = await page.toPng();
      return png;
    }
    throw Exception('No se pudo rasterizar la página 1');
  }

  Future<_PdfMeta> _buildMetaFromPdf(Uint8List pdfBytes) async {
    return _PdfMeta(
      bytes: pdfBytes.length,
      // si luego quieres: páginas, formato, etc (depende de lib)
      createdAt: DateTime.now(),
    );
  }

  void _openPreviewInApp(String title, String filename) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _DocumentoPdfPreviewPage(
          title: title,
          filename: filename,
          buildBytes: () => _pdfFuture,
        ),
      ),
    );
  }

  Future<void> _openSystemLayout(DocumentoItem doc) async {
    try {
      HapticFeedback.lightImpact();
      final bytes = await _pdfFuture;
      await Printing.layoutPdf(
        name: '${doc.id}.pdf',
        onLayout: (_) async => bytes,
      );
    } catch (e) {
      if (!mounted) return;
      _snack('No se pudo abrir el PDF 😅 ($e)');
    }
  }

  Future<void> _sharePdf(DocumentoItem doc) async {
    try {
      HapticFeedback.lightImpact();
      final bytes = await _pdfFuture;
      await Printing.sharePdf(bytes: bytes, filename: '${doc.id}.pdf');
    } catch (e) {
      if (!mounted) return;
      _snack('No se pudo compartir 😅 ($e)');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ColoresApp.texto.withOpacity(0.92),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _doc = _findDoc();
    if (_doc != null) {
      _ev = _demoFirma(_doc!);

      _pdfFuture = _buildPdfBytes(_doc!, _ev);
      _thumbFuture = _pdfFuture.then(_buildThumbFromPdf);
      _metaFuture = _pdfFuture.then(_buildMetaFromPdf);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final doc = _doc;
    if (doc == null) {
      return Scaffold(
        backgroundColor: ColoresApp.blanco,
        body: SafeArea(
          child: Center(
            child: Text(
              'Documento no encontrado 😅',
              style: t.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: ColoresApp.textoSuave,
              ),
            ),
          ),
        ),
      );
    }

    final evidencia = _toMapEvidencia(doc, _ev).entries.toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FB),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: ColoresApp.texto),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doc.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ColoresApp.texto,
                fontWeight: FontWeight.w900,
                fontSize: 15.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Folio: CNA-${doc.id.toUpperCase()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ColoresApp.textoSuave,
                fontWeight: FontWeight.w800,
                fontSize: 11.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Compartir',
            onPressed: () => _sharePdf(doc),
            icon: Icon(
              PhosphorIcons.shareNetwork(PhosphorIconsStyle.light),
              color: ColoresApp.texto,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),

      // ✅ barra inferior fija: se siente “app real”
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: ColoresApp.bordeSuave)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _ActionButton(
                  kind: _ActionKind.primary,
                  icon: PhosphorIcons.filePdf(PhosphorIconsStyle.light),
                  label: 'Abrir PDF',
                  onTap: () => _openSystemLayout(doc),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  kind: _ActionKind.ghost,
                  icon: PhosphorIcons.shareNetwork(PhosphorIconsStyle.light),
                  label: 'Compartir',
                  onTap: () => _sharePdf(doc),
                ),
              ),
            ],
          ),
        ),
      ),

      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ tarjeta de preview tipo “papel”
                  _PdfPaperPreview(
                    thumbFuture: _thumbFuture,
                    metaFuture: _metaFuture,
                    onTap: () => _openPreviewInApp(doc.titulo, '${doc.id}.pdf'),
                  ),
                  const SizedBox(height: 12),

                  // microcopy elegante (sin rogar)
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.magnifyingGlassPlus(PhosphorIconsStyle.light),
                        size: 16,
                        color: ColoresApp.textoSuave,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Toca la vista previa para abrir en pantalla completa',
                        style: t.bodySmall?.copyWith(
                          fontSize: 11.2,
                          fontWeight: FontWeight.w700,
                          color: ColoresApp.textoSuave,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Evidencia de firma',
                style: t.bodyMedium?.copyWith(
                  fontSize: 13.2,
                  fontWeight: FontWeight.w900,
                  color: ColoresApp.texto,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90), // deja espacio al bottom bar
            sliver: SliverList.separated(
              itemCount: evidencia.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final e = evidencia[i];
                return _EvidenceTile(
                  title: e.key,
                  value: e.value,
                  onCopy: () async {
                    await Clipboard.setData(ClipboardData(text: e.value));
                    HapticFeedback.selectionClick();
                    _snack('Copiado ✅');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================
  Preview “papel” + shimmer
========================= */

class _PdfPaperPreview extends StatelessWidget {
  final Future<Uint8List> thumbFuture;
  final Future<_PdfMeta> metaFuture;
  final VoidCallback onTap;

  const _PdfPaperPreview({
    required this.thumbFuture,
    required this.metaFuture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: ColoresApp.bordeSuave),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // header mini
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: ColoresApp.cafe.withOpacity(0.92),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Documento PDF · Firmado',
                    style: t.bodySmall?.copyWith(
                      fontSize: 11.2,
                      fontWeight: FontWeight.w900,
                      color: ColoresApp.texto,
                    ),
                  ),
                  const Spacer(),
                  FutureBuilder<_PdfMeta>(
                    future: metaFuture,
                    builder: (_, snap) {
                      if (!snap.hasData) {
                        return Text(
                          '…',
                          style: t.bodySmall?.copyWith(
                            fontSize: 10.8,
                            fontWeight: FontWeight.w800,
                            color: ColoresApp.textoSuave,
                          ),
                        );
                      }
                      return Text(
                        _formatBytes(snap.data!.bytes),
                        style: t.bodySmall?.copyWith(
                          fontSize: 10.8,
                          fontWeight: FontWeight.w800,
                          color: ColoresApp.textoSuave,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // “hoja”
              AspectRatio(
                aspectRatio: 16 / 11, // se ve “papel” sin ser tan alto
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F2EE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ColoresApp.bordeSuave.withOpacity(0.9)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      FutureBuilder<Uint8List>(
                        future: thumbFuture,
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const _Shimmer();
                          }
                          if (snap.hasError || !snap.hasData) {
                            return Center(
                              child: Icon(
                                PhosphorIcons.filePdf(PhosphorIconsStyle.light),
                                size: 46,
                                color: ColoresApp.textoSuave,
                              ),
                            );
                          }

                          return Image.memory(
                            snap.data!,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          );
                        },
                      ),

                      // overlay top-right
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                PhosphorIcons.sealCheck(PhosphorIconsStyle.light),
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Válido',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // sombra inferior como “hoja sobre mesa”
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.16),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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

/* =========================
  Evidencia tile (copiar)
========================= */

class _EvidenceTile extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onCopy;

  const _EvidenceTile({
    required this.title,
    required this.value,
    required this.onCopy,
  });

  bool get _looksLikeUrl => value.startsWith('http://') || value.startsWith('https://');
  bool get _looksLikeHash => value.toLowerCase().contains('sha-256') || value.length >= 40;

  IconData get _icon {
    final k = title.toLowerCase();
    if (k.contains('hash')) return PhosphorIcons.fingerprintSimple(PhosphorIconsStyle.light);
    if (k.contains('ocsp') || k.contains('tsp')) return PhosphorIcons.shieldCheck(PhosphorIconsStyle.light);
    if (k.contains('autoridad')) return PhosphorIcons.buildings(PhosphorIconsStyle.light);
    if (k.contains('archivo')) return PhosphorIcons.filePdf(PhosphorIconsStyle.light);
    if (k.contains('secuencia')) return PhosphorIcons.hash(PhosphorIconsStyle.light);
    if (k.contains('verificación')) return PhosphorIcons.link(PhosphorIconsStyle.light);
    return PhosphorIcons.seal(PhosphorIconsStyle.light);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onCopy,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ColoresApp.bordeSuave),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: ColoresApp.inputBg.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColoresApp.bordeSuave),
                ),
                child: Icon(_icon, size: 18, color: ColoresApp.texto),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: t.bodySmall?.copyWith(
                        fontSize: 11.4,
                        fontWeight: FontWeight.w900,
                        color: ColoresApp.texto,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: t.bodySmall?.copyWith(
                        fontSize: 11.4,
                        fontWeight: FontWeight.w800,
                        color: _looksLikeUrl ? ColoresApp.cafe.withOpacity(0.95) : ColoresApp.textoSuave,
                        height: 1.25,
                        fontFamily: _looksLikeHash ? 'monospace' : null,
                        decoration: _looksLikeUrl ? TextDecoration.underline : null,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(
                PhosphorIcons.copySimple(PhosphorIconsStyle.light),
                size: 18,
                color: ColoresApp.textoSuave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* =========================
  Action buttons bottom
========================= */

enum _ActionKind { primary, ghost }

class _ActionButton extends StatelessWidget {
  final _ActionKind kind;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.kind,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final isPrimary = kind == _ActionKind.primary;

    return Material(
      color: isPrimary ? ColoresApp.cafe.withOpacity(0.92) : ColoresApp.inputBg.withOpacity(0.85),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPrimary ? Colors.transparent : ColoresApp.bordeSuave,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isPrimary ? Colors.white : ColoresApp.texto),
              const SizedBox(width: 8),
              Text(
                label,
                style: t.labelMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isPrimary ? Colors.white : ColoresApp.texto,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* =========================
  Shimmer (sin paquetes)
========================= */

class _Shimmer extends StatefulWidget {
  const _Shimmer();

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1150))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final v = _c.value; // 0..1
        return ShaderMask(
          shaderCallback: (r) {
            return LinearGradient(
              begin: Alignment(-1.0 + 2.0 * v, 0),
              end: Alignment(-0.2 + 2.0 * v, 0),
              colors: [
                const Color(0xFFE9EAF0),
                const Color(0xFFF7F8FB),
                const Color(0xFFE9EAF0),
              ],
            ).createShader(r);
          },
          blendMode: BlendMode.srcATop,
          child: Container(
            color: const Color(0xFFE9EAF0),
            child: Center(
              child: Icon(
                PhosphorIcons.filePdf(PhosphorIconsStyle.light),
                size: 40,
                color: ColoresApp.textoSuave.withOpacity(0.55),
              ),
            ),
          ),
        );
      },
    );
  }
}

/* =========================
  Preview completo (in-app)
========================= */

class _DocumentoPdfPreviewPage extends StatelessWidget {
  final String title;
  final String filename;
  final Future<Uint8List> Function() buildBytes;

  const _DocumentoPdfPreviewPage({
    required this.title,
    required this.filename,
    required this.buildBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      appBar: AppBar(
        backgroundColor: ColoresApp.blanco,
        elevation: 0,
        iconTheme: IconThemeData(color: ColoresApp.texto),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: ColoresApp.texto,
            fontWeight: FontWeight.w900,
            fontSize: 14.5,
          ),
        ),
      ),
      body: PdfPreview(
        build: (_) => buildBytes(),
        pdfFileName: filename,
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
      ),
    );
  }
}

/* =========================
  Helpers
========================= */

class _PdfMeta {
  final int bytes;
  final DateTime createdAt;
  const _PdfMeta({required this.bytes, required this.createdAt});
}

String _formatBytes(int bytes) {
  // formato simple, sin intl
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(2)} MB';
}
