import '../dominio/pagos.dart';
import '../dominio/tarjetas.dart';

/// La pasarela simulada (ADR 0009): revisa la tarjeta con las reglas del
/// telefono y la cambia por el token de su tarjeta de prueba. No toca la red.
class PasarelaSimulada implements PasarelaPago {
  const PasarelaSimulada();

  @override
  TarjetaNueva tokenizar(BorradorTarjeta borrador, DateTime hoy) {
    final errores = borrador.errores(hoy);
    final tarjeta = borrador.tarjeta;
    final fecha = ReglasTarjeta.vencimiento(borrador.vencimiento);
    if (errores.isNotEmpty || tarjeta == null || fecha == null) {
      throw TarjetaInvalida(errores);
    }
    return TarjetaNueva(
      token: tarjeta.token,
      mesVence: fecha.mes,
      anioVence: fecha.anio,
      guardar: borrador.guardar,
    );
  }
}
