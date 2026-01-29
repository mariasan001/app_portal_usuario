class FirmaEvidencia {
  final String proveedor; // SeguriSign
  final String archivoFirmado; // uuid.pdf
  final String secuencia; // 54151816
  final String autoridadCertificadora;

  // extras “cool”
  final String? ocsp;
  final String? tsp;
  final DateTime? selloTiempo;
  final String? hashSha256;
  final String? urlVerificacion;

  const FirmaEvidencia({
    required this.proveedor,
    required this.archivoFirmado,
    required this.secuencia,
    required this.autoridadCertificadora,
    this.ocsp,
    this.tsp,
    this.selloTiempo,
    this.hashSha256,
    this.urlVerificacion,
  });
}
