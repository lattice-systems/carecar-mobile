import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../../../nucleo/camara/selector_foto.dart';
import '../../../nucleo/eventos/eventos_en_vivo.dart';
import '../../../nucleo/eventos/proveedores_eventos.dart';
import '../../citas/citas.dart';
import '../datos/repositorio_valuacion_api.dart';
import '../dominio/repositorio_valuacion.dart';
import '../dominio/valuacion.dart';

/// Repositorio del modulo. En pruebas:
/// `repositorioValuacionProvider.overrideWithValue(RepositorioValuacionFake())`.
final repositorioValuacionProvider = Provider<RepositorioValuacion>(
  (ref) => RepositorioValuacionApi(ref.watch(apiClienteProvider)),
  retry: (_, _) => null,
  name: 'repositorioValuacionProvider',
);

/// Toma o elige las fotos guiadas (V2-M26.02). En pruebas se reemplaza.
final selectorValuacionProvider = Provider<SelectorFoto>(
  (ref) => SelectorFotoDelSistema(),
  name: 'selectorValuacionProvider',
);

/// Imagen de una foto subida. La direccion que manda el servidor es relativa.
/// En pruebas se sustituye por una en memoria para no salir a la red.
final imagenValuacionProvider = Provider<ImageProvider Function(String)>((ref) {
  final base = ref.watch(apiClienteProvider).config.base;
  return (url) => NetworkImage(base.resolve(url).toString());
}, name: 'imagenValuacionProvider');

/// Aviso en vivo de una oferta capturada o renovada (V2-M26.04). No trae el
/// monto.
const eventoValuacionOferta = 'valuacion.oferta';

/// Cuantas valuaciones se piden por pagina.
final tamanoPaginaValuacionesProvider = Provider<int>(
  (ref) => 20,
  name: 'tamanoPaginaValuacionesProvider',
);

/// Lo que «Mis valuaciones» ya cargo.
class EstadoMisValuaciones {
  const EstadoMisValuaciones({
    required this.valuaciones,
    required this.pagina,
    required this.hayMas,
    this.cargandoMas = false,
    this.errorAlCargarMas = false,
  });

  final List<Valuacion> valuaciones;

  /// Ultima pagina cargada, empezando en 0.
  final int pagina;
  final bool hayMas;
  final bool cargandoMas;
  final bool errorAlCargarMas;

  EstadoMisValuaciones copiaCon({
    required bool cargandoMas,
    required bool errorAlCargarMas,
  }) => EstadoMisValuaciones(
    valuaciones: valuaciones,
    pagina: pagina,
    hayMas: hayMas,
    cargandoMas: cargandoMas,
    errorAlCargarMas: errorAlCargarMas,
  );
}

/// Mis valuaciones (V2-M26.01), de a una pagina. Una oferta nueva o la vuelta
/// del canal tras una caida las vuelven a pedir sin pasar por carga; si esa
/// recarga falla, se queda lo que se ve.
class MisValuacionesNotifier extends AsyncNotifier<EstadoMisValuaciones> {
  var _turno = 0;

  @override
  Future<EstadoMisValuaciones> build() async {
    ref.listen(eventosProvider, (_, evento) {
      if (evento case AsyncData(:final value)
          when value.nombre == eventoValuacionOferta ||
              value.nombre == eventoReconectado) {
        _recargar();
      }
    });
    final pagina = await ref
        .watch(repositorioValuacionProvider)
        .listar(tamano: ref.watch(tamanoPaginaValuacionesProvider));
    return EstadoMisValuaciones(
      valuaciones: pagina.valuaciones,
      pagina: pagina.pagina,
      hayMas: pagina.hayMas,
    );
  }

  // Vuelve a pedir las paginas que ya estaban en pantalla.
  Future<void> _recargar() async {
    final turno = ++_turno;
    try {
      final repositorio = ref.read(repositorioValuacionProvider);
      final tamano = ref.read(tamanoPaginaValuacionesProvider);
      final hasta = state.value?.pagina ?? 0;
      final valuaciones = <Valuacion>[];
      var ultima = await repositorio.listar(tamano: tamano);
      valuaciones.addAll(ultima.valuaciones);
      while (ultima.pagina < hasta && ultima.hayMas) {
        ultima = await repositorio.listar(
          pagina: ultima.pagina + 1,
          tamano: tamano,
        );
        valuaciones.addAll(ultima.valuaciones);
      }
      if (!ref.mounted || turno != _turno) return;
      state = AsyncData(
        EstadoMisValuaciones(
          valuaciones: valuaciones,
          pagina: ultima.pagina,
          hayMas: ultima.hayMas,
        ),
      );
    } on Object {
      return;
    }
  }

  /// Pide la pagina siguiente. Si falla, conserva lo cargado y lo marca.
  Future<void> cargarMas() async {
    final actual = state.value;
    if (actual == null || !actual.hayMas || actual.cargandoMas) return;
    final turno = ++_turno;
    state = AsyncData(
      actual.copiaCon(cargandoMas: true, errorAlCargarMas: false),
    );
    try {
      final pagina = await ref
          .read(repositorioValuacionProvider)
          .listar(
            pagina: actual.pagina + 1,
            tamano: ref.read(tamanoPaginaValuacionesProvider),
          );
      if (!ref.mounted || turno != _turno) return;
      state = AsyncData(
        EstadoMisValuaciones(
          valuaciones: [...actual.valuaciones, ...pagina.valuaciones],
          pagina: pagina.pagina,
          hayMas: pagina.hayMas,
        ),
      );
    } on Object {
      if (!ref.mounted || turno != _turno) return;
      state = AsyncData(
        actual.copiaCon(cargandoMas: false, errorAlCargarMas: true),
      );
    }
  }
}

final misValuacionesProvider =
    AsyncNotifierProvider.autoDispose<
      MisValuacionesNotifier,
      EstadoMisValuaciones
    >(
      MisValuacionesNotifier.new,
      // El reintento es del usuario (boton de EstadoError), no automatico.
      retry: (_, _) => null,
      name: 'misValuacionesProvider',
    );

/// Una valuacion con sus fotos, cita y oferta. El aviso de oferta de esta
/// valuacion o la vuelta del canal la vuelven a pedir sin pasar por carga
/// (V2-M26.04); si esa recarga falla, se queda la que se ve.
class ValuacionNotifier extends AsyncNotifier<Valuacion> {
  ValuacionNotifier(this.valuacionId);

  final int valuacionId;
  var _turno = 0;

  @override
  Future<Valuacion> build() {
    ref.listen(eventosProvider, (_, evento) {
      if (evento case AsyncData(:final value)
          when value.nombre == eventoReconectado ||
              (value.nombre == eventoValuacionOferta &&
                  value.datos['valuacionId'] == valuacionId)) {
        recargar();
      }
    });
    return ref.watch(repositorioValuacionProvider).una(valuacionId);
  }

  /// Vuelve a pedirla sin pasar por carga.
  Future<void> recargar() async {
    final turno = ++_turno;
    try {
      final nueva = await ref
          .read(repositorioValuacionProvider)
          .una(valuacionId);
      if (ref.mounted && turno == _turno) state = AsyncData(nueva);
    } on Object {
      return;
    }
  }

  /// Suma la foto recien subida sin perder las que se subieron a la vez.
  void agregarFotos(Valuacion respuesta) {
    final actual = state.value;
    _turno++;
    state = AsyncData(
      actual == null ? respuesta : respuesta.conFotosDe(actual),
    );
    ref.invalidate(misValuacionesProvider);
  }

  /// Acepta o rechaza la oferta de [monto]. Si el servidor no la registra
  /// porque cambio o vencio, se vuelve a pedir y el rechazo sube a quien
  /// llamo.
  Future<void> responder({
    required bool aceptada,
    required double monto,
  }) async {
    try {
      final respondida = await ref
          .read(repositorioValuacionProvider)
          .responder(
            valuacionId: valuacionId,
            aceptada: aceptada,
            monto: monto,
          );
      if (!ref.mounted) return;
      _turno++;
      state = AsyncData(respondida);
      ref.invalidate(misValuacionesProvider);
    } on ValuacionRechazada {
      if (ref.mounted) await recargar();
      rethrow;
    }
  }
}

final valuacionProvider = AsyncNotifierProvider.autoDispose
    .family<ValuacionNotifier, Valuacion, int>(
      ValuacionNotifier.new,
      retry: (_, _) => null,
      name: 'valuacionProvider',
    );

/// Agenda la inspeccion (V2-M26.03). La cita nueva debe verse en «Mis citas»,
/// el horario ocupado sale de la disponibilidad y la valuacion cambia.
final agendarInspeccionProvider =
    Provider<
      Future<InspeccionValuacion> Function(int valuacionId, FranjaDisponible)
    >((ref) {
      return (valuacionId, franja) async {
        final cita = await ref
            .read(repositorioValuacionProvider)
            .agendar(
              valuacionId: valuacionId,
              franjaId: franja.franjaId,
              fecha: franja.fecha,
            );
        ref
          ..invalidate(misCitasProvider)
          ..invalidate(disponibilidadProvider)
          ..invalidate(valuacionProvider(valuacionId))
          ..invalidate(misValuacionesProvider);
        return cita;
      };
    }, name: 'agendarInspeccionProvider');

/// El valor estimado por mes de un vehiculo en los ultimos 12 meses
/// (V2-M26.05).
final valorEstimadoProvider = FutureProvider.autoDispose
    .family<List<PuntoValorEstimado>, int>(
      (ref, vehiculoId) =>
          ref.watch(repositorioValuacionProvider).valorEstimado(vehiculoId),
      retry: (_, _) => null,
      name: 'valorEstimadoProvider',
    );

/// Una foto que se esta subiendo o que fallo. Vive solo en memoria.
class SubidaPendiente {
  const SubidaPendiente(this.foto, {this.fallo});

  final FotoElegida foto;

  /// Por que fallo; nulo mientras se esta subiendo.
  final Object? fallo;

  bool get subiendo => fallo == null;
}

/// Las subidas en curso o fallidas de una valuacion. Cada toma se sube sola y
/// un fallo no toca las demas: la foto se conserva para reintentar. Nada se
/// guarda en el telefono.
class SubidasNotifier extends Notifier<Map<TomaValuacion, SubidaPendiente>> {
  SubidasNotifier(this.valuacionId);

  final int valuacionId;

  @override
  Map<TomaValuacion, SubidaPendiente> build() => const {};

  /// Sube [foto] como [toma]. Devuelve `false` si el servidor ya no admite
  /// fotos: la valuacion se vuelve a pedir y la pantalla lo explica.
  Future<bool> subir(TomaValuacion toma, FotoElegida foto) async {
    if (state[toma]?.subiendo ?? false) return true;
    state = {...state, toma: SubidaPendiente(foto)};
    // Si la persona sale de la pantalla a media subida, la respuesta todavia
    // debe llegar a la valuacion.
    final enlace = ref.keepAlive();
    final valuacion = ref.read(valuacionProvider(valuacionId).notifier);
    try {
      final respuesta = await ref
          .read(repositorioValuacionProvider)
          .subirFoto(
            valuacionId: valuacionId,
            toma: toma,
            bytes: foto.bytes,
            tipo: foto.tipo,
          );
      if (!ref.mounted) return true;
      valuacion.agregarFotos(respuesta);
      state = {...state}..remove(toma);
    } on ValuacionRechazada {
      if (!ref.mounted) return false;
      state = {...state}..remove(toma);
      await valuacion.recargar();
      return false;
    } on Object catch (error) {
      if (!ref.mounted) return true;
      state = {...state, toma: SubidaPendiente(foto, fallo: error)};
    } finally {
      enlace.close();
    }
    return true;
  }

  Future<bool> reintentar(TomaValuacion toma) async {
    final pendiente = state[toma];
    if (pendiente == null) return true;
    return subir(toma, pendiente.foto);
  }
}

final subidasValuacionProvider = NotifierProvider.autoDispose
    .family<SubidasNotifier, Map<TomaValuacion, SubidaPendiente>, int>(
      SubidasNotifier.new,
      name: 'subidasValuacionProvider',
    );
