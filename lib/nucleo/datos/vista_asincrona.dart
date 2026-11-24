import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../diseno/componentes/estado_error.dart';
import 'fallo.dart';

/// Pinta los cinco estados de una carga · V2-T01.08, criterio 3.
///
/// Toma un `AsyncValue` y resuelve igual en todos los modulos lo que antes
/// cada pantalla decidia por su cuenta: cuando va el esqueleto, cuando el
/// contenido, cuando el estado vacio y como se ve un error. En particular,
/// absorbe el ternario que estaba copiado en cada pantalla:
///
/// ```dart
/// error is SinConexion ? CausaError.sinConexion : CausaError.generico
/// ```
///
/// Uso tipico:
///
/// ```dart
/// VistaAsincrona<List<VehiculoGaraje>>(
///   estado: ref.watch(garajeProvider),
///   cargando: (_) => const Column(
///     children: [Esqueleto(alto: 120), Esqueleto(alto: 120)],
///   ),
///   datos: (_, vehiculos) => ListaDeVehiculos(vehiculos),
///   vacio: (_) => const EstadoVacio(titulo: 'Aun no tienes vehiculos'),
///   alReintentar: () => ref.invalidate(garajeProvider),
/// )
/// ```
///
/// **El esqueleto lo da el modulo**, no el nucleo: la guia de estilos pide que
/// tenga la forma del contenido que viene, y esa forma solo la conoce la
/// pantalla.
///
/// No se encarga de la sesion. Si el fallo es [CaraDelFallo.sesionTerminada],
/// la salida no es un boton de reintentar sino volver al acceso, y eso lo
/// resuelve el guardia de navegacion antes de que la vista se pinte.
class VistaAsincrona<T> extends StatelessWidget {
  const VistaAsincrona({
    required this.estado,
    required this.cargando,
    required this.datos,
    super.key,
    this.estaVacio,
    this.vacio,
    this.alReintentar,
  });

  /// Lo que se esta cargando, normalmente `ref.watch(unProvider)`.
  final AsyncValue<T> estado;

  /// El esqueleto con la forma del contenido que viene.
  final WidgetBuilder cargando;

  /// El contenido, cuando hay datos.
  final Widget Function(BuildContext context, T datos) datos;

  /// Cuando se considera vacio el resultado.
  ///
  /// Si no se da, una lista, un mapa o un texto vacios cuentan como vacio y
  /// cualquier otra cosa no.
  final bool Function(T datos)? estaVacio;

  /// Que pintar cuando esta vacio.
  ///
  /// Si no se da, un resultado vacio se pinta con [datos]. Es deliberado: hay
  /// pantallas donde la lista vacia **no** es un estado normal sino un error de
  /// datos —como el garaje, porque no puede haber un cliente sin vehiculo— y el
  /// nucleo no debe inventarles un estado que nadie pidio.
  final WidgetBuilder? vacio;

  /// Que hacer al tocar «Reintentar», normalmente `ref.invalidate(...)`.
  ///
  /// Si no se da, el boton se ve deshabilitado: [EstadoError] siempre lo
  /// dibuja.
  final VoidCallback? alReintentar;

  @override
  Widget build(BuildContext context) {
    // El orden es el mismo que usa `AsyncValue.when` de Riverpod con sus
    // valores por omision, para que nadie se lleve una sorpresa: primero el
    // error, luego el dato, y el esqueleto solo si todavia no hay ninguno.
    if (estado.hasError) {
      final fallo = falloDe(estado.error!);
      return EstadoError(
        alReintentar: alReintentar,
        causa: fallo.esSinConexion
            ? CausaError.sinConexion
            : CausaError.generico,
        // Sin conexion es una condicion del telefono, no una respuesta del
        // servidor: ahi manda el texto del sistema de diseno, que dice que
        // hacer («Revisa tu internet»). En los demas casos el texto viene del
        // contrato, que ya respeta RIC-14.
        mensaje: fallo.esSinConexion ? null : fallo.mensaje,
      );
    }

    if (estado.hasValue) {
      // Vale tambien mientras recarga con un dato previo: sin esto la lista
      // desapareceria y volveria en cada refresco.
      final valor = estado.requireValue;
      final pintarVacio = vacio;
      if (pintarVacio != null && _estaVacio(valor)) return pintarVacio(context);
      return datos(context, valor);
    }

    return cargando(context);
  }

  bool _estaVacio(T valor) {
    final propio = estaVacio;
    if (propio != null) return propio(valor);
    return switch (valor) {
      final Iterable<Object?> i => i.isEmpty,
      final Map<Object?, Object?> m => m.isEmpty,
      final String s => s.isEmpty,
      _ => false,
    };
  }
}
