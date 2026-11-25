/// Raíz de las rutas de la bitácora (V2-M18).
const rutaBitacora = '/bitacora';

/// Bitácora de un vehículo: `/bitacora/7`. [nombre] es el del vehículo y viaja
/// como parámetro para el subtítulo y el nombre del archivo exportado.
String rutaBitacoraVehiculo(int vehiculoId, {String? nombre}) => Uri(
  path: '$rutaBitacora/$vehiculoId',
  queryParameters: nombre == null ? null : {'nombre': nombre},
).toString();

/// Estadísticas de un vehículo: `/bitacora/7/estadisticas`.
String rutaEstadisticasBitacora(int vehiculoId) =>
    '$rutaBitacora/$vehiculoId/estadisticas';

/// Exportación de un vehículo: `/bitacora/7/exportar`.
String rutaExportarBitacora(int vehiculoId, {String? nombre}) => Uri(
  path: '$rutaBitacora/$vehiculoId/exportar',
  queryParameters: nombre == null ? null : {'nombre': nombre},
).toString();
