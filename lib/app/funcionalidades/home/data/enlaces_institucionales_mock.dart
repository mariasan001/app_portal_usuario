// lib/app/funcionalidades/home/data/enlaces_institucionales_mock.dart

import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import '../domain/enlace_institucional.dart';

final enlacesInstitucionalesMock = <EnlaceInstitucional>[
  EnlaceInstitucional(
    id: 'viajes',
    titulo: 'Viajes turísticos',
    subtitle: 'Convocatorias y paquetes',
    destino: 'https://example.com/viajes',
    icon: PhosphorIcons.airplane(PhosphorIconsStyle.light),
    accent: ColoresApp.dorado,
  ),
  EnlaceInstitucional(
    id: 'declaranet',
    titulo: 'DeclaraNET',
    subtitle: 'Declaración patrimonial',
    destino: 'https://example.com/declaranet',
    icon: PhosphorIcons.fileText(PhosphorIconsStyle.light),
    accent: ColoresApp.cafe,
  ),
  EnlaceInstitucional(
    id: 'deportes',
    titulo: 'Deportes',
    subtitle: 'Torneos y actividades',
    destino: 'https://example.com/deportes',
    icon: PhosphorIcons.basketball(PhosphorIconsStyle.light),
    accent: ColoresApp.vino,
  ),
  EnlaceInstitucional(
    id: 'escalafon',
    titulo: 'Escalafón',
    subtitle: 'Proceso y resultados',
    destino: 'https://example.com/escalafon',
    icon: PhosphorIcons.medal(PhosphorIconsStyle.light),
    accent: ColoresApp.cafe,
  ),
  EnlaceInstitucional(
    id: 'issemym',
    titulo: 'Prestaciones ISSEMYM',
    subtitle: 'Salud y beneficios',
    destino: 'https://example.com/issemym',
    icon: PhosphorIcons.heart(PhosphorIconsStyle.light),
    accent: ColoresApp.dorado,
  ),
  EnlaceInstitucional(
    id: 'cineclub',
    titulo: 'Cine club',
    subtitle: 'Cartelera y eventos',
    destino: 'https://example.com/cineclub',
    icon: PhosphorIcons.filmSlate(PhosphorIconsStyle.light),
    accent: ColoresApp.vino,
  ),
  EnlaceInstitucional(
    id: 'descuentos',
    titulo: 'Descuentos',
    subtitle: 'Convenios vigentes',
    destino: 'https://example.com/descuentos',
    icon: PhosphorIcons.tag(PhosphorIconsStyle.light),
    accent: ColoresApp.cafe,
  ),
  EnlaceInstitucional(
    id: 'boletos',
    titulo: 'Emisión de boletos',
    subtitle: 'Sistema de boletaje',
    destino: 'https://example.com/boletos',
    icon: PhosphorIcons.ticket(PhosphorIconsStyle.light),
    accent: ColoresApp.dorado,
  ),
];
