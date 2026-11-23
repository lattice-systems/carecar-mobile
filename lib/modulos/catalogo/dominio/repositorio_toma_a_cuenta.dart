import 'toma_a_cuenta.dart';

/// Contrato que la presentacion usa para estimar la toma a cuenta.
/// Una pagina de estimaciones guardadas, de la mas reciente a la mas antigua.
class PaginaDeEstimaciones {
  const PaginaDeEstimaciones({
    required this.estimaciones,
    required this.pagina,
    required this.hayMas,
  });

  final List<Estimacion> estimaciones;

  /// Indice de esta pagina, empezando en 0.
  final int pagina;

  /// Si quedan paginas por pedir despues de esta.
  final bool hayMas;
}

abstract interface class RepositorioTomaACuenta {
  /// Calcula el rango y lo guarda como estimacion del cliente.
  ///
  /// Lanza `NoEncontrado` si el vehiculo no es del cliente o el modelo ya no
  /// esta vigente, y `SinParametrosDeValuacion` si la agencia aun no valua ese
  /// auto.
  Future<Estimacion> estimar(SolicitudEstimacion solicitud);

  /// Las estimaciones guardadas del cliente (V2-M03.07), de a [tamano].
  Future<PaginaDeEstimaciones> guardadas({int pagina = 0, int tamano = 20});
}
