class ConstanciaLaboralData {
  final String folio;
  final String lugar;
  final DateTime fechaEmision;

  final String nombre;
  final String numeroServidor;
  final String curp;

  final String dependencia;
  final String area;
  final String puesto;
  final String tipoNombramiento; // Base/Confianza/Honorarios
  final DateTime fechaIngreso;
  final String estatusLaboral; // Activo/a, etc.

  // Opcionales (para que se vea más pro y completo)
  final String? rfc;
  final String? nivel;
  final String? percepcionBrutaMensual;

  const ConstanciaLaboralData({
    required this.folio,
    required this.lugar,
    required this.fechaEmision,
    required this.nombre,
    required this.numeroServidor,
    required this.curp,
    required this.dependencia,
    required this.area,
    required this.puesto,
    required this.tipoNombramiento,
    required this.fechaIngreso,
    required this.estatusLaboral,
    this.rfc,
    this.nivel,
    this.percepcionBrutaMensual,
  });
}
