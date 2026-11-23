import '../../../config/ficha_tecnica.dart' as v1;
import '../dominio/ficha_tecnica_vehiculo.dart';
import '../dominio/vehiculo_garaje.dart';

/// Respaldo de la ficha tecnica con lo que ya trae la app (codigo v1).
///
/// Sirve mientras el backend no tenga `ficha_tecnica_modelo` o no haya red.
/// Titulos y claves van como codigos (la pantalla los traduce); los valores
/// vienen del codigo v1, en espanol.
abstract final class FichaTecnicaLocal {
  /// `null` si el modelo no es uno de los que la app conoce.
  static FichaTecnicaVehiculo? de(VehiculoGaraje vehiculo) {
    final f = v1.fichaDeModelo(
      vehiculo.modelo,
      anio: vehiculo.anio,
      version: vehiculo.version,
    );
    if (f == null) return null;
    return FichaTecnicaVehiculo(
      delRespaldo: true,
      secciones: [
        SeccionFicha(
          codigo: 'general',
          especificaciones: [
            EspecificacionFicha(codigo: 'carroceria', valor: f.carroceria),
            EspecificacionFicha(codigo: 'pasajeros', valor: f.pasajeros),
          ],
        ),
        SeccionFicha(
          codigo: 'motor',
          especificaciones: [
            EspecificacionFicha(codigo: 'propulsion', valor: f.propulsion),
            EspecificacionFicha(codigo: 'motor', valor: f.motor),
            EspecificacionFicha(codigo: 'potencia', valor: f.potencia),
          ],
        ),
        SeccionFicha(
          codigo: 'transmision',
          especificaciones: [
            EspecificacionFicha(codigo: 'transmision', valor: f.transmision),
            EspecificacionFicha(codigo: 'traccion', valor: f.traccion),
          ],
        ),
      ],
    );
  }
}
