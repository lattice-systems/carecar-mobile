import '../../../config/ficha_tecnica.dart' as v1;
import '../dominio/ficha_tecnica_vehiculo.dart';
import '../dominio/vehiculo_garaje.dart';

/// Respaldo de la ficha tecnica con lo que ya trae la app (codigo v1).
///
/// Sirve mientras el backend no tenga `ficha_tecnica_modelo` o no haya red. Los
/// titulos y claves viajan en espanol, igual que los datos que manda la
/// agencia.
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
          titulo: 'General',
          especificaciones: [
            EspecificacionFicha(clave: 'Carrocería', valor: f.carroceria),
            EspecificacionFicha(clave: 'Pasajeros', valor: f.pasajeros),
          ],
        ),
        SeccionFicha(
          titulo: 'Motor',
          especificaciones: [
            EspecificacionFicha(clave: 'Propulsión', valor: f.propulsion),
            EspecificacionFicha(clave: 'Motor', valor: f.motor),
            EspecificacionFicha(clave: 'Potencia', valor: f.potencia),
          ],
        ),
        SeccionFicha(
          titulo: 'Transmisión',
          especificaciones: [
            EspecificacionFicha(clave: 'Transmisión', valor: f.transmision),
            EspecificacionFicha(clave: 'Tracción', valor: f.traccion),
          ],
        ),
      ],
    );
  }
}
