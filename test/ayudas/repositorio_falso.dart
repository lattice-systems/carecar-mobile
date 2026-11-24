import 'package:carecar_mobile/nucleo/datos/fallo.dart';
import 'package:carecar_mobile/nucleo/datos/repositorio_base.dart';

/// Repositorio en memoria para pruebas · V2-T01.08, criterio 4.
///
/// Guarda un valor, puede tardar y puede fallar a pedido. Con eso se recorren
/// los cinco estados de [VistaAsincrona] sin levantar red ni servidor.
///
/// Usa [RepositorioBase], igual que los repositorios de verdad. Es a proposito:
/// si el fake no convirtiera los errores como ellos, una prueba podria pasar
/// con un error sin tipar que en produccion si vendria tipado.
///
/// Los modulos no lo implementan: lo **componen** dentro de su propio fake, que
/// es el que respeta su interfaz.
///
/// ```dart
/// class RepositorioCatalogoFalso implements RepositorioCatalogo {
///   RepositorioCatalogoFalso(List<ModeloVigente> modelos)
///     : _modelos = RepositorioFalso(modelos);
///
///   final RepositorioFalso<List<ModeloVigente>> _modelos;
///
///   /// Para que la prueba configure latencia y fallos.
///   RepositorioFalso<List<ModeloVigente>> get fuente => _modelos;
///
///   @override
///   Future<List<ModeloVigente>> modelos() => _modelos.leer();
/// }
/// ```
class RepositorioFalso<T> with RepositorioBase {
  RepositorioFalso(this.valor, {this.latencia = Duration.zero, this.falla});

  /// Lo que responde. Se puede cambiar entre llamadas para simular una
  /// recarga que trae algo distinto.
  T valor;

  /// Cuanto tarda en responder.
  ///
  /// Sirve para ver el esqueleto y para probar que una pantalla no parpadea al
  /// recargar. Con [Duration.zero] responde en el siguiente microtask.
  Duration latencia;

  /// Si no es nulo, cada lectura falla con esto.
  Fallo? falla;

  /// Cuantas veces se ha leido. Para comprobar que una pantalla no pide lo
  /// mismo de mas, o que «Reintentar» si volvio a pedir.
  int llamadas = 0;

  Fallo? _fallaUnaVez;
  Object? _reventarUnaVez;

  /// Falla **solo la proxima** lectura y despues vuelve a funcionar.
  ///
  /// Es el caso de «Reintentar»: la pantalla muestra el error, el usuario toca
  /// el boton y entra.
  void fallarUnaVez(Fallo fallo) => _fallaUnaVez = fallo;

  /// Lanza **solo la proxima** vez algo que no es un [Fallo], como lo haria un
  /// bug en el mapeo de un DTO.
  ///
  /// Sirve para comprobar que la pantalla no se rompe ni filtra detalle
  /// tecnico cuando pasa lo que nadie previo.
  void reventarUnaVez(Object error) => _reventarUnaVez = error;

  /// Lee el valor, aplicando latencia y fallos.
  Future<T> leer() => pedir(() async {
    llamadas++;
    if (latencia > Duration.zero) await Future<void>.delayed(latencia);

    final reventar = _reventarUnaVez;
    if (reventar != null) {
      _reventarUnaVez = null;
      throw reventar;
    }

    final unaVez = _fallaUnaVez;
    if (unaVez != null) {
      _fallaUnaVez = null;
      throw unaVez;
    }

    final siempre = falla;
    if (siempre != null) throw siempre;

    return valor;
  });
}
