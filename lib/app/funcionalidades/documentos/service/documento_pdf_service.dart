import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:portal_servicios_usuario/app/funcionalidades/documentos/domain/documento_item.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/documentos/domain/firma_evidencia.dart';

import '../domain/constancia_laboral_data.dart'; // ajusta

class DocumentoPdfService {
  /// ✅ 2 páginas:
  /// - Página 1: Constancia laboral completa (SIEMPRE 1 hoja)
  /// - Página 2: SOLO evidencia criptográfica (NUNCA SE QUITA)
  static Future<Uint8List> buildConstanciaLaboralPdf({
    required DocumentoItem doc,
    required FirmaEvidencia evidencia,
    required ConstanciaLaboralData data,
  }) async {
    final pdf = pw.Document();

    // ===== Estilos (oficio real, limpio) =====
    final base = pw.TextStyle(
      fontSize: 10.9,
      color: PdfColors.black,
      lineSpacing: 1.2,
    );

    final bold = base.copyWith(fontWeight: pw.FontWeight.bold);
    final italic = base.copyWith(fontStyle: pw.FontStyle.italic);

    final title = pw.TextStyle(
      fontSize: 17.5,
      fontWeight: pw.FontWeight.bold,
      letterSpacing: 0.7,
      color: PdfColors.black,
    );

    final bicentTitle = pw.TextStyle(
      fontSize: 11.2,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
      letterSpacing: 0.2,
    );

    final subtleLine = PdfColor.fromInt(0xFFDFE3EA);

    // =========================
    // PAGE 1 — CONSTANCIA (1 hoja)
    // =========================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.fromLTRB(52, 44, 52, 44),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ===== HEADER SUPERIOR (centrado) =====
              pw.Text(
                '2025. Bicentenario de la vida municipal en el Estado de México',
                style: bicentTitle,
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 10),

              pw.Text(
                'CONSTANCIA LABORAL',
                style: title,
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 5),

              // ✅ “Documento emitido…” cursiva
              pw.Text(
                'Documento emitido electrónicamente. No requiere firma autógrafa.',
                style: italic.copyWith(color: PdfColors.grey700, fontSize: 10.2),
                textAlign: pw.TextAlign.center,
              ),

              pw.SizedBox(height: 12),

              // ===== BLOQUE FOLIO/LUGAR/FECHA (derecha, tipo oficio) =====
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: _metaOficioBox(
                  folio: data.folio,
                  lugar: data.lugar,
                  fecha: _formatDateEs(data.fechaEmision),
                  base: base,
                  bold: bold,
                  subtleLine: subtleLine,
                ),
              ),

              pw.SizedBox(height: 12),
              pw.Divider(color: subtleLine, thickness: 1),
              pw.SizedBox(height: 10),

              // ===== DESTINATARIO =====
              pw.Text('A QUIEN CORRESPONDA:', style: bold.copyWith(fontSize: 11.1)),
              pw.SizedBox(height: 8),

              // ===== TEXTO FORMAL (compacto para que siempre quepa 1 hoja) =====
              pw.Text(
                'Por medio de la presente se hace constar que ${data.nombre.toUpperCase()}, '
                'con número de servidor público ${data.numeroServidor}, labora en ${data.dependencia}, '
                'adscrita/o a ${data.area}, desempeñando el puesto de ${data.puesto}. '
                'Cuenta con nombramiento de tipo ${data.tipoNombramiento} y se encuentra en estatus '
                '${data.estatusLaboral}. La fecha de ingreso registrada es el ${_formatDateEs(data.fechaIngreso)}.',
                style: base,
                textAlign: pw.TextAlign.justify,
              ),

              pw.SizedBox(height: 10),

              // ===== TABLA FORMAL (sin rellenos, solo líneas suaves) =====
              pw.Container(
                padding: const pw.EdgeInsets.fromLTRB(12, 10, 12, 8),
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: subtleLine, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Text('Datos del servidor público', style: bold.copyWith(fontSize: 11.0)),
                    pw.SizedBox(height: 8),
                    pw.Table(
                      columnWidths: const {
                        0: pw.FlexColumnWidth(1.05),
                        1: pw.FlexColumnWidth(1.95),
                      },
                      border: pw.TableBorder(
                        horizontalInside: pw.BorderSide(color: subtleLine, width: 1),
                      ),
                      children: [
                        _row('Nombre', data.nombre, base, bold),
                        _row('No. Servidor', data.numeroServidor, base, bold),
                        _row('CURP', data.curp, base, bold, monospaceValue: true),
                        if (data.rfc != null) _row('RFC', data.rfc!, base, bold, monospaceValue: true),
                        _row('Dependencia', data.dependencia, base, bold),
                        _row('Área', data.area, base, bold),
                        _row('Puesto', data.puesto, base, bold),
                        if (data.nivel != null) _row('Nivel', data.nivel!, base, bold),
                        _row('Tipo de nombramiento', data.tipoNombramiento, base, bold),
                        _row('Fecha de ingreso', _formatDateEs(data.fechaIngreso), base, bold),
                        _row('Estatus', data.estatusLaboral, base, bold),
                        if (data.percepcionBrutaMensual != null)
                          _row('Percepción bruta mensual', data.percepcionBrutaMensual!, base, bold),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // ===== CIERRE FORMAL =====
              pw.Text(
                'Se expide la presente constancia para los fines legales y administrativos que la interesada/o estime convenientes.',
                style: base,
                textAlign: pw.TextAlign.justify,
              ),

              pw.SizedBox(height: 14),

              pw.Text('ATENTAMENTE', style: bold, textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 26),

              // ===== FIRMA (placeholder) =====
              pw.Column(
                children: [
                  pw.Container(height: 1, width: 260, color: subtleLine),
                  pw.SizedBox(height: 6),
                  pw.Text('Nombre y cargo de quien emite', style: base.copyWith(fontSize: 10.3)),
                  pw.Text('Dirección responsable', style: base.copyWith(fontSize: 10.1, color: PdfColors.grey700)),
                ],
              ),

              pw.Spacer(),

              // ===== PIE (mínimo, porque el “Bicentenario” ya va arriba) =====
              pw.Text(
                'Página 1 de 2',
                style: italic.copyWith(fontSize: 9.8, color: PdfColors.grey700),
                textAlign: pw.TextAlign.right,
              ),
            ],
          );
        },
      ),
    );

    // =========================
    // PAGE 2 — SOLO EVIDENCIA
    // =========================
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.fromLTRB(52, 44, 52, 44),
        build: (_) => [
          pw.Text(
            '2025. Bicentenario de la vida municipal en el Estado de México',
            style: bicentTitle,
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 12),

          pw.Text(
            'EVIDENCIA CRIPTOGRÁFICA DE FIRMA',
            style: title.copyWith(fontSize: 15.8),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 6),

          pw.Text(
            'La siguiente información permite validar la integridad y autenticidad del documento.',
            style: italic.copyWith(fontSize: 10.2, color: PdfColors.grey700),
            textAlign: pw.TextAlign.center,
          ),

          pw.SizedBox(height: 14),

          _evidenceOnlyPage(
            evidencia: evidencia,
            base: base,
            bold: bold,
            italic: italic,
            subtleLine: subtleLine,
          ),

          pw.SizedBox(height: 14),

          pw.Text(
            'Página 2 de 2',
            style: italic.copyWith(fontSize: 9.8, color: PdfColors.grey700),
            textAlign: pw.TextAlign.right,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /* =========================
    Bloque Folio/Lugar/Fecha (oficio real)
  ========================= */

  static pw.Widget _metaOficioBox({
    required String folio,
    required String lugar,
    required String fecha,
    required pw.TextStyle base,
    required pw.TextStyle bold,
    required PdfColor subtleLine,
  }) {
    // Caja compacta y elegante, derecha
    return pw.Container(
      width: 280,
      padding: const pw.EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: subtleLine, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _kvLineOficio('Folio', folio, base, bold),
          pw.SizedBox(height: 4),
          _kvLineOficio('Lugar', lugar, base, bold),
          pw.SizedBox(height: 4),
          _kvLineOficio('Fecha', fecha, base, bold),
        ],
      ),
    );
  }

  static pw.Widget _kvLineOficio(String k, String v, pw.TextStyle base, pw.TextStyle bold) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 54,
          child: pw.Text('$k:', style: bold.copyWith(fontSize: 10.6)),
        ),
        pw.Expanded(
          child: pw.Text(v, style: base.copyWith(fontSize: 10.6)),
        ),
      ],
    );
  }

  /* =========================
    Página 2: SOLO evidencia
  ========================= */

  static pw.Widget _evidenceOnlyPage({
    required FirmaEvidencia evidencia,
    required pw.TextStyle base,
    required pw.TextStyle bold,
    required pw.TextStyle italic,
    required PdfColor subtleLine,
  }) {
    final items = <MapEntry<String, String>>[
      MapEntry('Proveedor', evidencia.proveedor),
      MapEntry('Archivo firmado', evidencia.archivoFirmado),
      MapEntry('Secuencia', evidencia.secuencia),
      MapEntry('Autoridad certificadora', evidencia.autoridadCertificadora),
      if (evidencia.ocsp != null) MapEntry('OCSP', evidencia.ocsp!),
      if (evidencia.tsp != null) MapEntry('TSP', evidencia.tsp!),
      if (evidencia.selloTiempo != null) MapEntry('Sello de tiempo', _formatDateTimeEs(evidencia.selloTiempo!)),
      if (evidencia.hashSha256 != null) MapEntry('Hash', 'SHA-256 · ${evidencia.hashSha256}'),
      if (evidencia.urlVerificacion != null) MapEntry('URL de verificación', evidencia.urlVerificacion!),
    ];

    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: subtleLine, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Table(
            columnWidths: const {
              0: pw.FlexColumnWidth(1.05),
              1: pw.FlexColumnWidth(1.95),
            },
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: subtleLine, width: 1),
            ),
            children: [
              for (final it in items) _evidenceRow(it.key, it.value, base, bold),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Este documento fue emitido electrónicamente y su validez puede verificarse mediante los datos anteriores.',
            style: italic.copyWith(fontSize: 10.0, color: PdfColors.grey700),
            textAlign: pw.TextAlign.justify,
          ),
        ],
      ),
    );
  }

  static pw.TableRow _evidenceRow(String k, String v, pw.TextStyle base, pw.TextStyle bold) {
    final lower = k.toLowerCase();
    final isTech = lower.contains('hash') ||
        lower.contains('secuencia') ||
        lower.contains('url') ||
        v.contains('SHA-256');

    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 7),
          child: pw.Text(k, style: bold.copyWith(fontSize: 10.7)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 7),
          child: pw.Text(
            v,
            style: base.copyWith(
              fontSize: 10.7,
              color: PdfColors.grey800,
              fontFallback: isTech ? [pw.Font.courier()] : null,
            ),
          ),
        ),
      ],
    );
  }

  /* =========================
    Helpers tabla
  ========================= */

  static pw.TableRow _row(
    String k,
    String v,
    pw.TextStyle base,
    pw.TextStyle bold, {
    bool monospaceValue = false,
  }) {
    final valStyle = base.copyWith(
      fontSize: 10.8,
      color: PdfColors.grey800,
      fontFallback: monospaceValue ? [pw.Font.courier()] : null,
    );

    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 7),
          child: pw.Text(k, style: bold.copyWith(fontSize: 10.8)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 7),
          child: pw.Text(v, style: valStyle),
        ),
      ],
    );
  }

  /* =========================
    Fechas (sin intl)
  ========================= */

  static String _formatDateEs(DateTime d) {
    const months = [
      'enero','febrero','marzo','abril','mayo','junio',
      'julio','agosto','septiembre','octubre','noviembre','diciembre'
    ];
    final dd = d.day.toString().padLeft(2, '0');
    final mm = months[d.month - 1];
    return '$dd de $mm de ${d.year}';
  }

  static String _formatDateTimeEs(DateTime d) {
    const months = [
      'enero','febrero','marzo','abril','mayo','junio',
      'julio','agosto','septiembre','octubre','noviembre','diciembre'
    ];
    final dd = d.day.toString().padLeft(2, '0');
    final mm = months[d.month - 1];
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd de $mm de ${d.year} · $hh:$mi h';
  }
}
