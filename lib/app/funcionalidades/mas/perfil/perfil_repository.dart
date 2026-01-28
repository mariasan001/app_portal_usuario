
import 'package:portal_servicios_usuario/app/funcionalidades/mas/perfil/perfil_models.dart';

abstract class PerfilRepository {
  Future<PerfilServidorPublico> obtenerPerfil();

  /// Solo actualiza contacto (correo/telefono)
  Future<PerfilServidorPublico> actualizarContacto(ActualizarContactoPayload payload);
}
