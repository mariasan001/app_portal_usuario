enum ServicioCanal { digital, presencial }

class ServicioDetalle {
  final String descripcion;
  final List<String> requisitos;
  final List<String> pasos;

  final ServicioCanal canal;

  // Presencial
  final String? horario;
  final String? ubicacionNombre;
  final String? ubicacionDireccion;
  final List<String> telefonos;
  final List<String> correos;

  // Digital (opcional)
  final String? accionLabel; // si quieres cambiar el texto del botón

  const ServicioDetalle({
    required this.descripcion,
    required this.requisitos,
    required this.pasos,
    required this.canal,
    this.horario,
    this.ubicacionNombre,
    this.ubicacionDireccion,
    this.telefonos = const [],
    this.correos = const [],
    this.accionLabel,
  });
}
