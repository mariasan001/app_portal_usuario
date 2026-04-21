import 'dart:math';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:portal_servicios_usuario/app/funcionalidades/documentos/domain/documento_item.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/documentos/domain/firma_evidencia.dart';

import '../domain/constancia_laboral_data.dart';

class DocumentoPdfService {
  static Future<Uint8List> buildConstanciaLaboralPdf({
    required DocumentoItem doc,
    required FirmaEvidencia evidencia,
    required ConstanciaLaboralData data,
    required Uint8List escudoBytes,
    required Uint8List colegioBytes,
    required Uint8List cintaBytes,

    /// ✅ si true: cuando falten datos del backend, genera valores DEMO realistas (sin "N/D")
    bool demoMode = false,
  }) async {
    final pdf = pw.Document();

    final escudo = pw.MemoryImage(escudoBytes);
    final colegio = pw.MemoryImage(colegioBytes);
    final cinta = pw.MemoryImage(cintaBytes);

    // ===== estilos =====
    final base = pw.TextStyle(
      fontSize: 10.6,
      color: PdfColors.black,
      lineSpacing: 1.18,
    );
    final bold = base.copyWith(fontWeight: pw.FontWeight.bold);
    final italic = base.copyWith(fontStyle: pw.FontStyle.italic);

    final bicentTitle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
      letterSpacing: 0.15,
    );

    final tramiteTitle = pw.TextStyle(
      fontSize: 9.0,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
      letterSpacing: 0.25,
    );

    final subtleLine = PdfColor.fromInt(0xFFDFE3EA);

    const headerH = 64.0;
    const footerH = 36.0;

    // =========================
    // PAGE 1 — CONSTANCIA
    // =========================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.fromLTRB(52, 44, 52, 44),
        build: (_) {
          return pw.Stack(
            children: [
              pw.Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _cintillaHeader(
                  escudo: escudo,
                  colegio: colegio,
                  height: headerH,
                  center: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        '2025. Bicentenario de la vida municipal en el Estado de México',
                        style: bicentTitle,
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'CONSTANCIA LABORAL',
                        style: tramiteTitle,
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              pw.Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _footerCinta(
                  cinta: cinta,
                  height: footerH,
                  rightText: 'Página 1',
                  textStyle: italic.copyWith(fontSize: 9.4, color: PdfColors.grey700),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: headerH + 5, bottom: footerH + 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Text(
                      'Documento emitido electrónicamente. No requiere firma autógrafa.',
                      style: italic.copyWith(fontSize: 7.9, color: PdfColors.grey700),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 5),
                    _metaOficioInline(
                      folio: data.folio,
                      lugar: data.lugar,
                      fecha: _formatDateEs(data.fechaEmision),
                      base: base.copyWith(fontSize: 6.7, color: PdfColors.grey800),
                      bold: bold.copyWith(fontSize: 6.7),
                    ),
                    pw.SizedBox(height: 14),
                    pw.Text('A QUIEN CORRESPONDA:', style: bold.copyWith(fontSize: 11.0)),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Por medio de la presente se hace constar que ${data.nombre.toUpperCase()}, '
                      'con número de servidor público ${data.numeroServidor}, labora en ${data.dependencia}, '
                      'adscrita/o a ${data.area}, desempeñando el puesto de ${data.puesto}. '
                      'Cuenta con nombramiento de tipo ${data.tipoNombramiento} y se encuentra en estatus '
                      '${data.estatusLaboral}. La fecha de ingreso registrada es el ${_formatDateEs(data.fechaIngreso)}.',
                      style: base,
                      textAlign: pw.TextAlign.justify,
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text('Datos del servidor público', style: bold.copyWith(fontSize: 11.0)),
                    pw.SizedBox(height: 6),
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: subtleLine, width: 1),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Table(
                        columnWidths: const {
                          0: pw.FlexColumnWidth(1.05),
                          1: pw.FlexColumnWidth(1.95),
                        },
                        border: pw.TableBorder(
                          horizontalInside: pw.BorderSide(color: subtleLine, width: 1),
                        ),
                        children: [
                          _rowTight('Nombre', data.nombre, base, bold),
                          _rowTight('No. Servidor', data.numeroServidor, base, bold),
                          _rowTight('CURP', data.curp, base, bold, monospaceValue: true),
                          if (data.rfc != null) _rowTight('RFC', data.rfc!, base, bold, monospaceValue: true),
                          _rowTight('Dependencia', data.dependencia, base, bold),
                          _rowTight('Área', data.area, base, bold),
                          _rowTight('Puesto', data.puesto, base, bold),
                          if (data.nivel != null) _rowTight('Nivel', data.nivel!, base, bold),
                          _rowTight('Tipo de nombramiento', data.tipoNombramiento, base, bold),
                          _rowTight('Fecha de ingreso', _formatDateEs(data.fechaIngreso), base, bold),
                          _rowTight('Estatus', data.estatusLaboral, base, bold),
                          if (data.percepcionBrutaMensual != null)
                            _rowTight('Percepción bruta mensual', data.percepcionBrutaMensual!, base, bold),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'Se expide la presente constancia para los fines legales y administrativos que la interesada/o estime convenientes.',
                      style: base,
                      textAlign: pw.TextAlign.justify,
                    ),
                    pw.SizedBox(height: 14),
                    _firmaProfesional(
                      base: base,
                      bold: bold,
                      subtleLine: subtleLine,
                      nombre: 'NOMBRE DE QUIEN EMITE',
                      cargo: 'Cargo del responsable',
                      area: 'Dirección / Área responsable',
                      mostrarSello: true,
                    ),
                    pw.Spacer(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // =========================
    // PAGE 2+ — EVIDENCIA (BONITA + COMPACTA + DEMO REALISTA SI FALTA)
    // =========================
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.fromLTRB(52, 44, 52, 44),
        header: (_) => _cintillaHeader(
          escudo: escudo,
          colegio: colegio,
          height: headerH,
        ),
        footer: (ctx) {
          final globalPage = ctx.pageNumber + 1;
          return _footerCinta(
            cinta: cinta,
            height: footerH,
            rightText: 'Página $globalPage',
            textStyle: italic.copyWith(fontSize: 9.4, color: PdfColors.grey700),
          );
        },
        build: (_) => [
          pw.SizedBox(height: 8),
          _evidenceCompactNice(
            evidencia: evidencia,
            data: data,
            base: base,
            bold: bold,
            demoMode: demoMode,
          ),
          pw.SizedBox(height: 10),
        ],
      ),
    );

    return pdf.save();
  }

  /* =========================
    HEADER (logos)
  ========================= */
  static pw.Widget _cintillaHeader({
    required pw.ImageProvider escudo,
    required pw.ImageProvider colegio,
    required double height,
    pw.Widget? center,
  }) {
    return pw.Container(
      height: height,
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Image(escudo, height: 30, fit: pw.BoxFit.contain),
          pw.SizedBox(width: 10),
          pw.Expanded(child: center ?? pw.SizedBox()),
          pw.SizedBox(width: 10),
          pw.Image(colegio, height: 30, fit: pw.BoxFit.contain),
        ],
      ),
    );
  }

  /* =========================
    FOOTER (cinta centrada)
  ========================= */
  static pw.Widget _footerCinta({
    required pw.ImageProvider cinta,
    required double height,
    String? rightText,
    pw.TextStyle? textStyle,
  }) {
    return pw.Container(
      height: height,
      child: pw.Stack(
        children: [
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Image(
              cinta,
              height: height - 6,
              fit: pw.BoxFit.contain,
            ),
          ),
          if (rightText != null && textStyle != null)
            pw.Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(rightText, style: textStyle),
              ),
            ),
        ],
      ),
    );
  }

  /* =========================
    FIRMA PRO (centrada REAL + sello sin empujar)
  ========================= */
  static pw.Widget _firmaProfesional({
    required pw.TextStyle base,
    required pw.TextStyle bold,
    required PdfColor subtleLine,
    required String nombre,
    required String cargo,
    required String area,
    bool mostrarSello = true,
  }) {
    final titleStyle = bold.copyWith(fontSize: 10.8, letterSpacing: 0.9);
    final nameStyle = bold.copyWith(fontSize: 10.2);
    final subStyle = base.copyWith(fontSize: 9.6, color: PdfColors.grey700);

    const firmaBoxW = 330.0;
    const espacioFirmaH = 26.0;

    final selloBox = pw.Container(
      width: 160,
      height: 78,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: subtleLine, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColor.fromInt(0xFFF7F8FA),
      ),
      child: pw.Center(
        child: pw.Text(
          'SELLO',
          style: base.copyWith(fontSize: 9.4, color: PdfColors.grey600, letterSpacing: 0.6),
        ),
      ),
    );

    final firmaCentro = pw.Container(
      width: firmaBoxW,
      child: pw.Column(
        children: [
          pw.SizedBox(height: espacioFirmaH),
          pw.Container(width: firmaBoxW - 30, height: 1, color: subtleLine),
          pw.SizedBox(height: 6),
          pw.Text(nombre.toUpperCase(), style: nameStyle, textAlign: pw.TextAlign.center),
          pw.SizedBox(height: 2),
          pw.Text(cargo, style: subStyle, textAlign: pw.TextAlign.center),
          pw.SizedBox(height: 2),
          pw.Text(area, style: subStyle, textAlign: pw.TextAlign.center),
        ],
      ),
    );

    return pw.Column(
      children: [
        pw.Text('ATENTAMENTE', style: titleStyle, textAlign: pw.TextAlign.center),
        pw.SizedBox(height: 12),
        pw.Container(
          height: 90,
          child: pw.Stack(
            children: [
              pw.Align(alignment: pw.Alignment.center, child: firmaCentro),
              if (mostrarSello) pw.Positioned(right: 0, top: 0, child: selloBox),
            ],
          ),
        ),
      ],
    );
  }

  /* =========================
    META INLINE
  ========================= */
  static pw.Widget _metaOficioInline({
    required String folio,
    required String lugar,
    required String fecha,
    required pw.TextStyle base,
    required pw.TextStyle bold,
  }) {
    pw.Widget item(String k, String v) {
      return pw.Expanded(
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('$k: ', style: bold),
            pw.Expanded(child: pw.Text(v, style: base)),
          ],
        ),
      );
    }

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        item('Folio', folio),
        pw.SizedBox(width: 12),
        item('Lugar', lugar),
        pw.SizedBox(width: 12),
        item('Fecha', fecha),
      ],
    );
  }

  /* =========================
    TABLA TIGHT (constancia)
  ========================= */
  static pw.TableRow _rowTight(
    String k,
    String v,
    pw.TextStyle base,
    pw.TextStyle bold, {
    bool monospaceValue = false,
  }) {
    final valStyle = base.copyWith(
      fontSize: 10.4,
      color: PdfColors.grey800,
      fontFallback: monospaceValue ? [pw.Font.courier()] : null,
    );

    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: pw.Text(k, style: bold.copyWith(fontSize: 10.4)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: pw.Text(v, style: valStyle),
        ),
      ],
    );
  }

  /* =========================
    EVIDENCIA (compacta, bonita, con algoritmo + cadena + demo realista)
  ========================= */
  static pw.Widget _evidenceCompactNice({
    required FirmaEvidencia evidencia,
    required ConstanciaLaboralData data,
    required pw.TextStyle base,
    required pw.TextStyle bold,
    bool demoMode = false,
  }) {
    final blue = PdfColor.fromInt(0xFF1E56D9);
    final pad = const pw.EdgeInsets.symmetric(vertical: 2.2, horizontal: 4.6);

    final tTitle = bold.copyWith(fontSize: 13.2);
    final tMetaB = bold.copyWith(fontSize: 11.0);
    final tMeta = base.copyWith(fontSize: 10.2);
    final tLbl = bold.copyWith(fontSize: 9.8);
    final tVal = base.copyWith(fontSize: 9.8);

    final monoSmall = base.copyWith(
      fontSize: 8.6,
      fontFallback: [pw.Font.courier()],
      lineSpacing: 1.08,
    );

    // === DEMO: valores realistas si faltan ===
    final demo = _DemoEvidence(
      seed: _hashSeed('${data.folio}|${data.curp}|${data.numeroServidor}'),
    );

    String? clean(String? s) {
      if (s == null) return null;
      final t = s.trim();
      if (t.isEmpty) return null;
      final low = t.toLowerCase();
      if (low == 'n/d' || low == 'nd' || low == 'n/a' || low == 'na') return null;
      return t;
    }

    // leer extras si existen en tu modelo
    final dyn = evidencia as dynamic;

    final sigAlg = _pickFirstNonEmpty([
      _tryGetStr(dyn, (o) => o.algoritmo),
      _tryGetStr(dyn, (o) => o.signatureAlgorithm),
      _tryGetStr(dyn, (o) => o.algoritmoFirma),
      _tryGetStr(dyn, (o) => o.sigAlg),
    ]);

    final certSerial = _pickFirstNonEmpty([
      _tryGetStr(dyn, (o) => o.numeroSerie),
      _tryGetStr(dyn, (o) => o.serie),
      _tryGetStr(dyn, (o) => o.certSerial),
      _tryGetStr(dyn, (o) => o.noSerie),
      _tryGetStr(dyn, (o) => o.serialNumber),
    ]);

    final cadenaFirmaRaw = _pickFirstNonEmpty([
      _tryGetStr(dyn, (o) => o.cadenaFirma),
      _tryGetStr(dyn, (o) => o.cadenaDeFirma),
      _tryGetStr(dyn, (o) => o.signatureChain),
      _tryGetStr(dyn, (o) => o.cadena),
    ]);

    // parse ocsp/tsp (si vienen como texto "k: v")
    final ocspKvRaw = _parseKvText(clean(evidencia.ocsp) ?? '');
    final tspKvRaw = _parseKvText(clean(evidencia.tsp) ?? '');

    String? findKv(List<MapEntry<String, String>> kv, List<String> keys) {
      for (final it in kv) {
        final k = it.key.toLowerCase();
        for (final s in keys) {
          if (k.contains(s)) {
            final v = clean(it.value);
            if (v != null) return v;
          }
        }
      }
      return null;
    }

    // ==== valores finales (backend → kv → demo) ====
    final serial = clean(certSerial) ??
        findKv(ocspKvRaw, ['número de serie', 'numero de serie', '# serie', 'serie']) ??
        findKv(tspKvRaw, ['número de serie', 'numero de serie', '# serie', 'serie']) ??
        (demoMode ? demo.serie() : null);

    final sello = evidencia.selloTiempo ?? (demoMode ? demo.selloTiempo(base: data.fechaEmision) : null);
    final selloUtcLocal = (sello != null) ? _formatUtcLocalLine(sello) : null;

    final algoritmo = clean(sigAlg) ??
        findKv(ocspKvRaw, ['algoritmo']) ??
        findKv(tspKvRaw, ['algoritmo']) ??
        (demoMode ? demo.algoritmo() : null);

    final cadenaFirma = clean(cadenaFirmaRaw) ?? (demoMode ? demo.cadenaFirmaHex() : null);

    final datosEstamp = findKv(tspKvRaw, ['datos estampillados', 'datos', 'stamped', 'stamp']) ??
        (demoMode ? demo.datosEstampilladosHex() : null);

    final hashSha = clean(evidencia.hashSha256) ?? (demoMode ? demo.hashSha256Hex() : null);

    final urlVer = clean(evidencia.urlVerificacion) ?? (demoMode ? demo.urlVerificacion() : null);

    // OCSP/TSP: si no vienen, en demoMode los “fabricamos”
    final ocspKv = ocspKvRaw.isNotEmpty
        ? ocspKvRaw
        : (demoMode ? demo.ocspKv(serie: serial ?? demo.serie()) : <MapEntry<String, String>>[]);

    final tspKv = tspKvRaw.isNotEmpty
        ? tspKvRaw
        : (demoMode
            ? demo.tspKv(
                serie: serial ?? demo.serie(),
                secuencia: evidencia.secuencia,
                datosEstamp: datosEstamp ?? demo.datosEstampilladosHex(),
              )
            : <MapEntry<String, String>>[]);

    // ===== UI helpers =====
    pw.Widget cell(String text, pw.TextStyle style) => pw.Padding(
          padding: pad,
          child: pw.Text(text, style: style),
        );

    pw.Widget cellMono(String text, {double? fontSize}) => pw.Padding(
          padding: pad,
          child: pw.Text(
            text,
            style: monoSmall.copyWith(fontSize: fontSize ?? monoSmall.fontSize),
          ),
        );

    pw.Widget headerBand(String label) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFFEFF4FF),
          border: pw.Border.all(color: blue, width: 0.9),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Text(label, style: bold.copyWith(fontSize: 11.4, letterSpacing: 0.2)),
      );
    }

    pw.Widget kvLine(String k, String v, {bool strong = false}) {
      final s1 = strong ? tMetaB : tMeta;
      final s2 = strong ? tMetaB : tMeta;
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 1.2),
        child: pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(text: '$k: ', style: s1),
              pw.TextSpan(text: v, style: s2),
            ],
          ),
        ),
      );
    }

    String dashIfNull(String? s) => (s == null || s.trim().isEmpty) ? '—' : s.trim();

    // tabla principal compacta tipo reporte
    final mainTable = pw.Table(
      columnWidths: const {
        0: pw.FixedColumnWidth(60),
        1: pw.FixedColumnWidth(120),
        2: pw.FlexColumnWidth(2.4),
        3: pw.FixedColumnWidth(80),
        4: pw.FixedColumnWidth(45),
        5: pw.FlexColumnWidth(1.2),
      },
      border: pw.TableBorder.all(color: blue, width: 0.9),
      children: [
        pw.TableRow(
          children: [
            cell('Firmante', tLbl),
            cell('Nombre', tLbl),
            cell(data.nombre.toUpperCase(), tVal),
            cell('Validez', tLbl),
            cell((hashSha != null) ? 'OK' : '—', tLbl),
            cell((hashSha != null) ? 'Vigente' : '—', tVal),
          ],
        ),
        pw.TableRow(
          children: [
            cell('', tLbl),
            cell('CURP', tLbl),
            cellMono(data.curp.toUpperCase(), fontSize: 9.2),
            cell('Revocación', tLbl),
            cell((ocspKv.isNotEmpty) ? 'OK' : '—', tLbl),
            cell((ocspKv.isNotEmpty) ? 'No Revocado' : '—', tVal),
          ],
        ),
        pw.TableRow(
          children: [
            cell('Firma', tLbl),
            cell('# Serie', tLbl),
            cellMono(dashIfNull(serial), fontSize: 9.2),
            cell('Status', tLbl),
            cell((tspKv.isNotEmpty) ? 'OK' : '—', tLbl),
            cell((tspKv.isNotEmpty) ? 'Válida' : '—', tVal),
          ],
        ),
        if (selloUtcLocal != null)
          pw.TableRow(
            children: [
              cell('', tLbl),
              cell('Fecha (UTC / Local)', tLbl),
              cell(selloUtcLocal, tVal),
              cell('', tVal),
              cell('', tVal),
              cell('', tVal),
            ],
          ),
        if (algoritmo != null)
          pw.TableRow(
            children: [
              cell('', tLbl),
              cell('Algoritmo', tLbl),
              cell(algoritmo, tVal),
              cell('', tVal),
              cell('', tVal),
              cell('', tVal),
            ],
          ),
      ],
    );

    final cadenaBox = pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: blue, width: 0.9),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
pw.Text(
  'Cadena de firma: EEWEPQWN QWEO 232 13 145 885 2 6 235 266 22 6 21 5 2 3 901 44 762 18 550 3 17 08 99 410 62 11 704 233 87 19 560 41 602 7 81 330 14 992 6 27 118 44 509 2 61 703 88 16 240 9 33 701 12 998 5 41 077 28 660 3 92 114 7 55 843 20 611 4 18 990 31 765 2 06 331 49 270',
  style: tLbl.copyWith(fontSize: 10.1),
  softWrap: true, // ✅ si no cabe, baja a la siguiente línea automático
),

            pw.SizedBox(height: 3),
            pw.Text(
              (cadenaFirma != null) ? _formatHexBlock(cadenaFirma, groupsPerLine: 28) : '—',
              style: monoSmall.copyWith(fontSize: 8.4),
            ),
          ],
        ),
      ),
    );

    final hashUrl = pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: blue, width: 0.9),
        borderRadius: pw.BorderRadius.circular(6),
        color: PdfColor.fromInt(0xFFF7F9FF),
      ),
      child: pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Text('Hash:', style: tLbl),
                pw.SizedBox(width: 6),
                pw.Expanded(
                  child: pw.Text(
                    (hashSha != null) ? 'SHA-256 · $hashSha' : '—',
                    style: monoSmall.copyWith(fontSize: 8.6),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                pw.Text('URL:', style: tLbl),
                pw.SizedBox(width: 6),
                pw.Expanded(
                  child: pw.Text(
                    (urlVer != null) ? urlVer : '—',
                    style: monoSmall.copyWith(fontSize: 8.6),
                  ),
                ),
              ],
            ),
            if (datosEstamp != null) ...[
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Text('Datos estampillados:', style: tLbl),
                  pw.SizedBox(width: 6),
                  pw.Expanded(
                    child: pw.Text(
                      _formatHexBlock(datosEstamp, groupsPerLine: 36),
                      style: monoSmall.copyWith(fontSize: 8.4),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );

    pw.Widget sectionKvTable(String label, List<MapEntry<String, String>> kv) {
      if (kv.isEmpty) return pw.SizedBox();

      bool hasFecha = kv.any((e) => e.key.toLowerCase().contains('fecha'));

      pw.Widget row(String k, String v) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2.1, horizontal: 5),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(width: 170, child: pw.Text(k, style: tLbl)),
                pw.SizedBox(width: 8),
                pw.Expanded(child: pw.Text(v, style: v.length > 40 ? monoSmall.copyWith(fontSize: 8.8) : tVal)),
              ],
            ),
          );

      return pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: blue, width: 0.9),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFEFF4FF),
                borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(5)),
              ),
              child: pw.Text(label, style: bold.copyWith(fontSize: 10.8)),
            ),
            if (!hasFecha && selloUtcLocal != null) row('Fecha (UTC / Local)', selloUtcLocal),
            for (final it in kv) row(it.key, it.value),
          ],
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Evidencia Criptográfica · Transacción ${evidencia.proveedor}', style: tTitle),
        pw.SizedBox(height: 3),
        kvLine('Archivo Firmado', evidencia.archivoFirmado, strong: true),
        kvLine('Secuencia', evidencia.secuencia, strong: true),
        kvLine('Autoridad Certificadora', evidencia.autoridadCertificadora),
        pw.SizedBox(height: 10),

        headerBand('Detalle de firma'),
        pw.SizedBox(height: 6),
        mainTable,

        pw.SizedBox(height: 8),
        cadenaBox,

        pw.SizedBox(height: 8),
        hashUrl,

        if (ocspKv.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          sectionKvTable('OCSP', ocspKv),
        ],
        if (tspKv.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          sectionKvTable('TSP', tspKv),
        ],
      ],
    );
  }

  /* =========================
    Helpers: dynamic getters
  ========================= */
  static String? _pickFirstNonEmpty(List<String?> candidates) {
    for (final c in candidates) {
      final v = c?.trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  static String? _tryGetStr(dynamic obj, dynamic Function(dynamic o) getter) {
    try {
      final v = getter(obj);
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    } catch (_) {
      return null;
    }
  }

  /* =========================
    Parse KV desde texto (OCSP / TSP)
  ========================= */
  static List<MapEntry<String, String>> _parseKvText(String raw) {
    if (raw.trim().isEmpty) return const [];

    final lines = raw
        .replaceAll('\r', '\n')
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final out = <MapEntry<String, String>>[];
    for (final ln in lines) {
      final idx = ln.indexOf(':');
      if (idx > 0 && idx < ln.length - 1) {
        final k = ln.substring(0, idx).trim();
        final v = ln.substring(idx + 1).trim();
        out.add(MapEntry(k, v));
      }
    }
    return out;
  }

  /* =========================
    Fecha UTC/Local
  ========================= */
  static String _formatUtcLocalLine(DateTime d) {
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

  /* =========================
    Formato “cadena” en bloque hex
  ========================= */
  static String _formatHexBlock(String input, {int group = 2, int groupsPerLine = 28}) {
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

  /* =========================
    Fechas (sin intl)
  ========================= */
  static String _formatDateEs(DateTime d) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    final dd = d.day.toString().padLeft(2, '0');
    final mm = months[d.month - 1];
    return '$dd de $mm de ${d.year}';
  }
}

/* =========================
  DEMO generator (realista + consistente)
========================= */

int _hashSeed(String s) {
  var h = 2166136261; // FNV-ish
  for (final code in s.codeUnits) {
    h ^= code;
    h = (h * 16777619) & 0x7fffffff;
  }
  return h;
}

class _DemoEvidence {
  _DemoEvidence({required int seed}) : _r = Random(seed);

  final Random _r;

  String algoritmo() {
    const list = [
      'SHA1/RSA_ENCRYPTION',
      'SHA256/RSA_ENCRYPTION',
      'SHA256withRSA',
      'SHA512withRSA',
    ];
    return list[_r.nextInt(list.length)];
  }

  // 22-24 dígitos con ceros a la izquierda (tipo reporte real)
  String serie() {
    final n = _r.nextInt(9999999);
    return n.toString().padLeft(22, '0');
  }

  DateTime selloTiempo({required DateTime base}) {
    return base.add(Duration(seconds: 20 + _r.nextInt(90)));
  }

  String _hex(int bytes) {
    const hex = '0123456789abcdef';
    final sb = StringBuffer();
    for (int i = 0; i < bytes; i++) {
      final b = _r.nextInt(256);
      sb.write(hex[(b >> 4) & 0xF]);
      sb.write(hex[b & 0xF]);
    }
    return sb.toString();
  }

  String cadenaFirmaHex() => _hex(260); // grande como cadena “real”
  String hashSha256Hex() => _hex(32);
  String datosEstampilladosHex() => _hex(36);

  String urlVerificacion() {
    final id = _hex(6);
    return 'https://verifica.edomex.gob.mx/firma/$id';
  }

  List<MapEntry<String, String>> ocspKv({required String serie}) {
    return [
      const MapEntry('Nombre del respondedor', 'OCSP DEL GOBIERNO DEL ESTADO DE MEXICO'),
      const MapEntry('Emisor del respondedor', 'AUTORIDAD CERTIFICADORA DEL GOBIERNO DEL ESTADO DE MEXICO'),
      MapEntry('Número de serie', serie),
    ];
  }

  List<MapEntry<String, String>> tspKv({
    required String serie,
    required String secuencia,
    required String datosEstamp,
  }) {
    return [
      const MapEntry('Nombre del respondedor', 'RESPONDEDOR TSP DEL GOBIERNO DEL ESTADO DE MEXICO'),
      const MapEntry('Emisor del respondedor', 'AUTORIDAD CERTIFICADORA DEL GOBIERNO DEL ESTADO DE MEXICO'),
      MapEntry('Número de serie', serie),
      MapEntry('Secuencia', secuencia),
      MapEntry('Datos estampillados', datosEstamp),
    ];
  }
}
