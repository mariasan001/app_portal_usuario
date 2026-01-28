import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../domain/documento_item.dart';

final documentosMock = <DocumentoItem>[
  DocumentoItem(
    id: 'constancia-laboral',
    titulo: 'Constancia laboral',
    descripcion: 'Descarga tu constancia laboral en PDF.',
    categoria: DocumentoCategoria.constancias,
    estado: DocumentoEstado.vigente,
    actualizado: DateTime.now().subtract(const Duration(hours: 3)),
    route: '/servicios/tramite/constancia_laboral',
    icon: PhosphorIcons.fileText(PhosphorIconsStyle.light),
  ),
  DocumentoItem(
    id: 'no-adeudo',
    titulo: 'Constancia de no adeudo',
    descripcion: 'Solicita y descarga tu constancia de no adeudo.',
    categoria: DocumentoCategoria.constancias,
    estado: DocumentoEstado.pendiente,
    actualizado: DateTime.now().subtract(const Duration(days: 1)),
    route: '/servicios/tramite/constancia_no_adeudo',
    icon: PhosphorIcons.file(PhosphorIconsStyle.light),
  ),
  DocumentoItem(
    id: 'vigencia-derechos',
    titulo: 'Vigencia de derechos',
    descripcion: 'Consulta tu vigencia de derechos actual.',
    categoria: DocumentoCategoria.vigencia,
    estado: DocumentoEstado.vigente,
    actualizado: DateTime.now().subtract(const Duration(days: 2)),
    route: '/servicios/consulta/vigencia_derechos',
    icon: PhosphorIcons.shieldCheck(PhosphorIconsStyle.light),
  ),
  DocumentoItem(
    id: 'fump',
    titulo: 'FUMP (Formato Único)',
    descripcion: 'Consulta tu información FUMP y datos registrados.',
    categoria: DocumentoCategoria.informacion,
    estado: DocumentoEstado.vigente,
    actualizado: DateTime.now().subtract(const Duration(days: 4)),
    route: '/servicios/consulta/fump',
    icon: PhosphorIcons.identificationCard(PhosphorIconsStyle.light),
  ),
  DocumentoItem(
    id: 'datos-generales',
    titulo: 'Datos generales',
    descripcion: 'Información registrada en el sistema.',
    categoria: DocumentoCategoria.informacion,
    estado: DocumentoEstado.vigente,
    actualizado: DateTime.now().subtract(const Duration(days: 7)),
    route: null, // demo: no navega, solo muestra snackbar
    icon: PhosphorIcons.userCircle(PhosphorIconsStyle.light),
  ),
];
