import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/documentos/ui/pages/DocumentoPdfPreview.dart';
import 'package:printing/printing.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import 'package:portal_servicios_usuario/app/funcionalidades/documentos/service/documento_pdf_service.dart';

import '../../data/documentos_mock.dart';
import '../../domain/documento_item.dart';
import '../../domain/firma_evidencia.dart';
import '../../domain/constancia_laboral_data.dart';

class DocumentoDetallePage extends StatefulWidget {
  final String documentoId;
  const DocumentoDetallePage({super.key, required this.documentoId});

  @override
  State<DocumentoDetallePage> createState() => _DocumentoDetallePageState();
}

class _DocumentoDetallePageState extends State<DocumentoDetallePage> {
  DocumentoItem? _doc;
  late FirmaEvidencia _ev;

  Future<Uint8List>? _pdfFuture; // ✅ cache del PDF

  // ✅ mientras no venga evidencia real del backend, dejamos demo encendido
  static const bool _demoModeEvidencia = true;

  DocumentoItem? _findDoc() {
    try {
      return documentosMock.firstWhere((d) => d.id == widget.documentoId);
    } catch (_) {
      return null;
    }
  }

  // ✅ demo de firma (cuando venga real, reemplazas)
  FirmaEvidencia _demoFirma(DocumentoItem doc) {
    final seed = _seedFrom('${doc.id}|SeguriSign|54151816');
    final rng = Random(seed);

    final serial = _hex(rng, bytes: 8).padLeft(20, '0'); // más “certificado”
    final datosEstamp = _hex(rng, bytes: 24).toUpperCase();
    final alg = 'SHA1/RSA_ENCRYPTION';

    // fecha demo (12 min atrás)
    final sello = DateTime.now().subtract(const Duration(minutes: 12));

    final ocsp = [
      'Nombre del respondedor: OCSP DEL GOBIERNO DEL ESTADO DE MÉXICO',
      'Emisor del respondedor: AUTORIDAD CERTIFICADORA DEL GOBIERNO DEL ESTADO DE MÉXICO',
      'Número de serie: $serial',
      'Fecha (UTC / Local): ${_formatUtcLocalLine(sello)}',
      'Algoritmo: $alg',
      'Revocación: No revocado',
    ].join('\n');

    final tsp = [
      'Nombre del respondedor: RESPONDEDOR TSP DEL GOBIERNO DEL ESTADO DE MÉXICO',
      'Emisor del respondedor: AUTORIDAD CERTIFICADORA DEL GOBIERNO DEL ESTADO DE MÉXICO',
      'Secuencia: ${22200000 + rng.nextInt(900000)}',
      'Fecha (UTC / Local): ${_formatUtcLocalLine(sello)}',
      'Datos estampillados: $datosEstamp',
      'Status: Válida',
    ].join('\n');

    // hash demo (sha256 = 64 hex)
    final hash = _hex(rng, bytes: 32).toLowerCase();

    return FirmaEvidencia(
      proveedor: 'SeguriSign',
      archivoFirmado: '${doc.id}.pdf',
      secuencia: '54151816',
      autoridadCertificadora: 'AUTORIDAD CERTIFICADORA DEL GOBIERNO DEL ESTADO DE MÉXICO',
      ocsp: ocsp,
      tsp: tsp,
      selloTiempo: sello,
      hashSha256: hash,
      urlVerificacion: 'https://segurisign.demo/verificar/${doc.id}',
    );
  }

  Future<Uint8List> _buildPdfBytes(DocumentoItem doc, FirmaEvidencia ev) async {
    final escudoBytes =
        (await rootBundle.load('assets/img/escudo.png')).buffer.asUint8List();

    final colegioBytes =
        (await rootBundle.load('assets/img/escudo_1.png')).buffer.asUint8List();

    final cintaBytes =
        (await rootBundle.load('assets/img/cinta.png')).buffer.asUint8List();

    final data = ConstanciaLaboralData(
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
    );

    return DocumentoPdfService.buildConstanciaLaboralPdf(
      doc: doc,
      evidencia: ev,
      data: data,
      escudoBytes: escudoBytes,
      colegioBytes: colegioBytes,
      cintaBytes: cintaBytes,
    );
  }

  // ✅ PRO: evidencia para UI (con algoritmo/serie/cadena/datos estampillados)
  Map<String, String> _toMapEvidencia(
    FirmaEvidencia ev, {
    required DocumentoItem doc,
    bool demoMode = false,
  }) {
    String? clean(String? s) {
      if (s == null) return null;
      final t = s.trim();
      if (t.isEmpty) return null;
      final low = t.toLowerCase();
      if (low == 'n/d' || low == 'nd' || low == 'n/a' || low == 'na') return null;
      return t;
    }

    // parse kv from ocsp/tsp
    List<MapEntry<String, String>> parseKv(String raw) {
      final r = clean(raw) ?? '';
      if (r.isEmpty) return const [];
      final lines = r
          .replaceAll('\r', '\n')
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final out = <MapEntry<String, String>>[];
      for (final ln in lines) {
        final idx = ln.indexOf(':');
        if (idx > 0 && idx < ln.length - 1) {
          out.add(
            MapEntry(
              ln.substring(0, idx).trim(),
              ln.substring(idx + 1).trim(),
            ),
          );
        }
      }
      return out;
    }

    String? findKv(List<MapEntry<String, String>> kv, List<String> keys) {
      for (final it in kv) {
        final k = it.key.toLowerCase();
        for (final s in keys) {
          if (k.contains(s)) return clean(it.value);
        }
      }
      return null;
    }

    final ocspKv = parseKv(ev.ocsp ?? '');
    final tspKv = parseKv(ev.tsp ?? '');

    // seed determinístico por doc + secuencia
    final seed = _seedFrom('${doc.id}|${ev.secuencia}|${ev.proveedor}|${ev.archivoFirmado}');
    final rng = Random(seed);

    final serie = findKv(ocspKv, ['número de serie', 'numero de serie', '# serie', 'serie']) ??
        findKv(tspKv, ['número de serie', 'numero de serie', '# serie', 'serie']) ??
        (demoMode ? _hex(rng, bytes: 8).padLeft(20, '0') : null);

    final algoritmo = findKv(ocspKv, ['algoritmo']) ??
        findKv(tspKv, ['algoritmo']) ??
        (demoMode ? 'SHA1/RSA_ENCRYPTION' : null);

    // cadena de firma (si no viene, la inventamos demostrativa)
final raw = demoMode ? _hex(rng, bytes: 160).toUpperCase() : null;
final cadena = raw != null ? '0x$raw' : null;
    // datos estampillados
    final datosEstamp = findKv(tspKv, ['datos estampillados', 'datos', 'stamped', 'stamp']) ??
        (demoMode ? _hex(rng, bytes: 24).toUpperCase() : null);

    final sello = ev.selloTiempo;
    final selloStr = (sello != null) ? _formatUtcLocalLine(sello) : null;

    // “estados” tipo reporte
    final validezOk = clean(ev.hashSha256) != null;
    final revOk = clean(ev.ocsp) != null;
    final tspOk = clean(ev.tsp) != null;

    final map = <String, String>{
      'Proveedor': ev.proveedor,
      'Archivo firmado': ev.archivoFirmado,
      'Secuencia': ev.secuencia,
      'Autoridad Certificadora': ev.autoridadCertificadora,

      'Validez': validezOk ? 'OK — Vigente' : 'N/D',
      'Revocación': revOk ? 'OK — No revocado' : 'N/D',
      'Status': tspOk ? 'OK — Válida' : 'N/D',

      if (selloStr != null) 'Fecha (UTC / Local)': selloStr,
      if (serie != null) '# Serie': serie,
      if (algoritmo != null) 'Algoritmo': algoritmo,

      if (clean(ev.hashSha256) != null) 'Hash': 'SHA-256 · ${clean(ev.hashSha256)}',
      if (datosEstamp != null) 'Datos estampillados': datosEstamp,

      if (clean(ev.urlVerificacion) != null) 'Verificación': clean(ev.urlVerificacion)!,

      // deja OCSP/TSP al final (por largos)
      if (clean(ev.ocsp) != null) 'OCSP': clean(ev.ocsp)!,
      if (clean(ev.tsp) != null) 'TSP': clean(ev.tsp)!,
    };

    return map;
  }

  @override
  void initState() {
    super.initState();

    _doc = _findDoc();
    if (_doc != null) {
      _ev = _demoFirma(_doc!);
      _pdfFuture = _buildPdfBytes(_doc!, _ev); // ✅ cache
    }
  }

  Future<Uint8List> _getPdfBytes() async {
    final f = _pdfFuture;
    if (f != null) return await f;

    final doc = _doc;
    if (doc == null) throw Exception('Documento no encontrado');
    _ev = _demoFirma(doc);
    final newF = _buildPdfBytes(doc, _ev);
    _pdfFuture = newF;
    return await newF;
  }

  void _openPreviewPage() {
    final doc = _doc;
    if (doc == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentoPdfPreviewPage(
          title: doc.titulo,
          buildBytes: () => _getPdfBytes(),
        ),
      ),
    );
  }

  Future<void> _download() async {
    try {
      final bytes = await _getPdfBytes();
      await Printing.layoutPdf(
        name: '${_doc!.id}.pdf',
        onLayout: (_) async => bytes,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir/descargar 😅 ($e)')),
      );
    }
  }

  Future<void> _share() async {
    try {
      final bytes = await _getPdfBytes();
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${_doc!.id}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo compartir 😅 ($e)')),
      );
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
                fontWeight: FontWeight.w800,
                color: ColoresApp.textoSuave,
              ),
            ),
          ),
        ),
      );
    }

    // ✅ aquí cambia: ahora pasamos doc + demoMode
    final evidencia = _toMapEvidencia(
      _ev,
      doc: doc,
      demoMode: _demoModeEvidencia,
    );

    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      doc.titulo,
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

              const SizedBox(height: 8),

              InkWell(
                onTap: _openPreviewPage,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIcons.eye(PhosphorIconsStyle.light),
                        size: 16,
                        color: ColoresApp.cafe.withOpacity(0.9),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ver vista previa',
                        style: t.bodySmall?.copyWith(
                          fontSize: 12.2,
                          fontWeight: FontWeight.w900,
                          color: ColoresApp.cafe.withOpacity(0.95),
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        PhosphorIcons.caretRight(PhosphorIconsStyle.light),
                        size: 14,
                        color: ColoresApp.textoSuave,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: _openPreviewPage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: ColoresApp.inputBg.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: ColoresApp.bordeSuave),
                    ),
                    child: Stack(
                      children: [
                        FutureBuilder<Uint8List>(
                          future: _pdfFuture,
                          builder: (context, snap) {
                            if (!snap.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final bytes = snap.data!;
                            return StreamBuilder<PdfRaster>(
                              stream: Printing.raster(bytes, pages: const [0], dpi: 120),
                              builder: (context, rs) {
                                if (!rs.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                final page = rs.data!;
                                return FutureBuilder<Uint8List>(
                                  future: page.toPng(),
                                  builder: (context, pngSnap) {
                                    if (!pngSnap.hasData) {
                                      return const Center(child: CircularProgressIndicator());
                                    }

                                    return Image.memory(
                                      pngSnap.data!,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),

                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: ColoresApp.bordeSuave),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIcons.filePdf(PhosphorIconsStyle.light),
                                  size: 16,
                                  color: ColoresApp.texto,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Vista previa',
                                  style: t.labelMedium?.copyWith(
                                    fontSize: 11.4,
                                    fontWeight: FontWeight.w900,
                                    color: ColoresApp.texto,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.94),
                              border: Border(top: BorderSide(color: ColoresApp.bordeSuave)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Toca para abrir en pantalla completa',
                                    style: t.bodySmall?.copyWith(
                                      fontSize: 11.4,
                                      fontWeight: FontWeight.w800,
                                      color: ColoresApp.textoSuave,
                                    ),
                                  ),
                                ),
                                Icon(
                                  PhosphorIcons.arrowsOut(PhosphorIconsStyle.light),
                                  size: 16,
                                  color: ColoresApp.textoSuave,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _Action(
                    icon: PhosphorIcons.downloadSimple(PhosphorIconsStyle.light),
                    label: 'Descargar',
                    onTap: _download,
                  ),
                  const SizedBox(width: 10),
                  _Action(
                    icon: PhosphorIcons.shareNetwork(PhosphorIconsStyle.light),
                    label: 'Compartir',
                    onTap: _share,
                  ),
                ],
              ),

              const SizedBox(height: 14),

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

                      final isTech = _isTechField(k, v);

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
                                fontSize: isTech ? 10.4 : 11.2,
                                fontWeight: FontWeight.w700,
                                color: ColoresApp.textoSuave,
                                height: 1.25,
                                fontFamily: isTech ? 'monospace' : null,
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

/* =========================
  Helpers (UI evidence)
========================= */

bool _isTechField(String k, String v) {
  final kk = k.toLowerCase();
  return kk.contains('hash') ||
      kk.contains('cadena') ||
      kk.contains('serie') ||
      kk.contains('datos') ||
      kk.contains('url') ||
      v.contains('SHA-256') ||
      v.length > 60;
}

// FNV-1a simple hash -> seed
int _seedFrom(String s) {
  int hash = 0x811C9DC5;
  for (final c in s.codeUnits) {
    hash ^= c;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}

// random hex
String _hex(Random rng, {required int bytes}) {
  const hex = '0123456789abcdef';
  final sb = StringBuffer();
  for (int i = 0; i < bytes; i++) {
    final b = rng.nextInt(256);
    sb.write(hex[(b >> 4) & 0xF]);
    sb.write(hex[b & 0xF]);
  }
  return sb.toString();
}

String _formatUtcLocalLine(DateTime d) {
  final utc = d.toUtc();
  final local = d.toLocal();

  String isoNoMillis(DateTime x) {
    final s = x.toIso8601String();
    return s.contains('.') ? s.split('.').first : s;
  }

  String offset(DateTime x) {
    final o = x.timeZoneOffset;
    final sign = o.isNegative ? '-' : '+';
    final hh = o.inHours.abs().toString().padLeft(2, '0');
    final mm = (o.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return '$sign$hh:$mm';
  }

  return '${isoNoMillis(utc)}Z / ${isoNoMillis(local)}${offset(local)}';
}

// hex block (espaciado y con saltos)
String _formatHexBlock(String input, {int group = 2, int groupsPerLine = 28}) {
  final raw = input.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
  if (raw.isEmpty) return input.trim();

  final sb = StringBuffer();
  var g = 0;

  for (int i = 0; i < raw.length; i += group) {
    final end = (i + group <= raw.length) ? i + group : raw.length;
    sb.write(raw.substring(i, end));
    g++;

    if (end < raw.length) sb.write(' ');
    if (g >= groupsPerLine) {
      sb.write('\n');
      g = 0;
    }
  }

  return sb.toString().trim();
}
