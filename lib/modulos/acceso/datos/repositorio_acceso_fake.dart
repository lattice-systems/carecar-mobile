import '../../../nucleo/datos/fallo.dart';
import '../../../nucleo/datos/repositorio_base.dart';
import '../dominio/repositorio_acceso.dart';

/// Repositorio de acceso en memoria, para pruebas y desarrollo · M01.
///
/// Recuerda lo que se le mando y falla a pedido con [falla]. Usa la misma
/// [RepositorioBase] que el de verdad, asi que una prueba no puede ver un
/// error sin tipar que en produccion si vendria tipado.
class RepositorioAccesoFake with RepositorioBase implements RepositorioAcceso {
  RepositorioAccesoFake({this.falla});

  /// Si no es nulo, cada llamada falla con esto.
  Fallo? falla;

  int llamadas = 0;
  String? ultimaActual;
  String? ultimaNueva;

  @override
  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  }) => pedir(() async {
    llamadas++;
    ultimaActual = actual;
    ultimaNueva = nueva;
    final f = falla;
    if (f != null) throw f;
  });
}
