import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../modulos/asistencia/asistencia.dart';
import '../../modulos/asistente/asistente.dart';
import '../../modulos/catalogo/catalogo.dart';
import '../../modulos/citas/citas.dart';
import '../../modulos/ejemplo/ejemplo.dart';
import '../../modulos/galeria/galeria.dart';
import '../../modulos/historial/historial.dart';
import '../../modulos/mantenimiento/mantenimiento.dart';
import '../../modulos/recoleccion/recoleccion.dart';
import '../../modulos/taller/taller.dart';
import '../../modulos/vehiculos/vehiculos.dart';
import '../migracion/interruptor_modulos.dart';
import 'rutas_del_nucleo.dart';

/// UNICO lugar donde se juntan las rutas de todos los modulos (V2-T01.03).
///
/// Es un archivo caliente a proposito pequeno: cada modulo publica su lista de
/// `RouteBase` en su `<modulo>.dart` y aqui solo se agrega UNA linea por
/// modulo. Las rutas de los modulos exigen sesion por defecto (ver
/// `Rutas.publicas`). Guia: `lib/modulos/README.md`.
///
/// Es el unico archivo de `nucleo/` que importa modulos, y solo su contrato
/// publico (`<modulo>.dart`).
///
/// Los modulos que existen en v1 y en v2 pasan por el interruptor
/// (V2-T01.05): sus rutas v2 solo se registran si el modulo esta en v2. Un
/// modulo nuevo agrega su valor a `ModuloMigrable` y su renglon aqui.
List<RouteBase> rutasDeLaApp(InterruptorModulos interruptor) => [
  ...rutasDelNucleo(interruptor: interruptor, destinosV2: destinosDeMenuV2),
  // --- Un renglon por modulo, en orden alfabetico ---
  ...interruptor.rutas(ModuloMigrable.asistencia, rutasAsistencia),
  // El asistente (M24) es nuevo en v2: no pasa por el interruptor.
  ...rutasAsistente,
  ...interruptor.rutas(ModuloMigrable.catalogo, rutasCatalogo),
  ...interruptor.rutas(ModuloMigrable.citas, rutasCitas),
  // El ejemplo es solo para desarrollo; se elimina en V2-T01.07.
  if (kDebugMode) ...rutasEjemplo,
  // La galeria del sistema de diseno es solo para desarrollo (V2-T02.06).
  // Cuando exista el flavor `desarrollo` (V2-T01.04) se condiciona a el.
  if (kDebugMode) ...rutasGaleria,
  // El historial v2 (M02.05) se abre desde el detalle v2 del vehiculo.
  ...rutasHistorial,
  // El mantenimiento (M05) es nuevo en v2: no pasa por el interruptor.
  ...rutasMantenimiento,
  // La recoleccion (M17) es nueva en v2: no pasa por el interruptor.
  ...rutasRecoleccion,
  ...rutasTaller,
  ...interruptor.rutas(ModuloMigrable.vehiculos, rutasVehiculos),
];

/// A que ruta v2 lleva cada tarjeta del menu v1 cuando su modulo esta en v2.
/// Un modulo sin tarjeta en el menu (asistencia) no aparece aqui.
const destinosDeMenuV2 = <ModuloMigrable, String>{
  ModuloMigrable.catalogo: rutaCatalogo,
  ModuloMigrable.citas: rutaMisCitas,
  ModuloMigrable.vehiculos: rutaGaraje,
};
