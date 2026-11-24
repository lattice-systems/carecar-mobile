import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../../../nucleo/camara/selector_foto.dart';
import '../datos/repositorio_asistente_api.dart';
import '../dominio/repositorio_asistente.dart';

/// Repositorio del modulo. En pruebas:
/// `repositorioAsistenteProvider.overrideWithValue(...)`.
final repositorioAsistenteProvider = Provider<RepositorioAsistente>(
  (ref) => RepositorioAsistenteApi(ref.watch(carecarApiProvider)),
  name: 'repositorioAsistenteProvider',
);

/// Toma o elige la foto de un testigo (V2-M24.05). En pruebas se reemplaza.
final selectorFotoProvider = Provider<SelectorFoto>(
  (ref) => SelectorFotoDelSistema(),
  name: 'selectorFotoProvider',
);

/// Quien escribio un mensaje de la conversacion.
enum AutorConversacion { cliente, asistente }

/// Estado de envio de una pregunta del cliente.
enum EnvioPregunta { enviando, enviada, fallida }

/// Un mensaje de la conversacion con el asistente.
class MensajeConversacion {
  const MensajeConversacion({
    required this.autor,
    this.texto = '',
    this.fuentes = const [],
    this.envio = EnvioPregunta.enviada,
    this.fallo,
    this.consultaId,
    this.util,
    this.foto,
    this.testigo,
  });

  final AutorConversacion autor;

  /// Texto del mensaje. En una respuesta con [fallo] viene vacio: la pantalla
  /// pone el texto traducido del fallo.
  final String texto;
  final List<CitaDelManual> fuentes;
  final EnvioPregunta envio;
  final FalloAsistente? fallo;

  /// Id de la respuesta para calificarla; nulo en preguntas y fallos.
  final int? consultaId;

  /// Calificacion del cliente (V2-M24.07): `true` 👍, `false` 👎, nula sin
  /// calificar.
  final bool? util;

  /// Foto de un testigo que mando el cliente (V2-M24.05). Solo en memoria,
  /// para poder reintentar; no se guarda.
  final FotoElegida? foto;

  /// Lo que dijo el asistente de esa foto.
  final TestigoDelTablero? testigo;

  MensajeConversacion conEnvio(EnvioPregunta nuevo) => _copia(envio: nuevo);

  MensajeConversacion conUtil(bool? nuevo) =>
      _copia(envio: envio, util: () => nuevo);

  MensajeConversacion _copia({
    required EnvioPregunta envio,
    bool? Function()? util,
  }) => MensajeConversacion(
    autor: autor,
    texto: texto,
    fuentes: fuentes,
    envio: envio,
    fallo: fallo,
    consultaId: consultaId,
    util: util == null ? this.util : util(),
    foto: foto,
    testigo: testigo,
  );
}

/// Conversacion con el asistente sobre un vehiculo. Vive mientras la pantalla
/// esta abierta: no se guarda en el telefono.
class ConversacionAsistente extends Notifier<List<MensajeConversacion>> {
  ConversacionAsistente(this.vehiculoId);

  final int vehiculoId;

  @override
  List<MensajeConversacion> build() => const [];

  /// `true` mientras espera una respuesta: no se manda otra pregunta encima.
  bool get esperando => state.any((m) => m.envio == EnvioPregunta.enviando);

  Future<void> preguntar(String pregunta) async {
    if (esperando) return;
    state = [
      ...state,
      MensajeConversacion(
        autor: AutorConversacion.cliente,
        texto: pregunta,
        envio: EnvioPregunta.enviando,
      ),
    ];
    await _resolver(state.length - 1);
  }

  /// Manda la foto de un testigo del tablero (V2-M24.05).
  Future<void> identificar(FotoElegida foto) async {
    if (esperando) return;
    state = [
      ...state,
      MensajeConversacion(
        autor: AutorConversacion.cliente,
        envio: EnvioPregunta.enviando,
        foto: foto,
      ),
    ];
    await _resolver(state.length - 1);
  }

  /// Vuelve a mandar una pregunta que fallo.
  Future<void> reintentar(int indice) async {
    if (esperando) return;
    final mensajes = [...state];
    // Quita la explicacion del fallo que venia justo despues.
    if (indice + 1 < mensajes.length && mensajes[indice + 1].fallo != null) {
      mensajes.removeAt(indice + 1);
    }
    mensajes[indice] = mensajes[indice].conEnvio(EnvioPregunta.enviando);
    state = mensajes;
    await _resolver(indice);
  }

  /// Califica la respuesta en [indice] (V2-M24.07). Se marca al momento; si
  /// no se pudo guardar, vuelve a como estaba.
  Future<void> calificar(int indice, bool util) async {
    final mensaje = state[indice];
    final consultaId = mensaje.consultaId;
    if (consultaId == null || mensaje.util == util) return;
    final anterior = mensaje.util;
    _ponerUtil(indice, util);
    try {
      await ref
          .read(repositorioAsistenteProvider)
          .calificar(consultaId: consultaId, util: util);
    } on FalloAsistente {
      if (ref.mounted) _ponerUtil(indice, anterior);
    }
  }

  void _ponerUtil(int indice, bool? util) {
    final mensajes = [...state];
    mensajes[indice] = mensajes[indice].conUtil(util);
    state = mensajes;
  }

  Future<void> _resolver(int indice) async {
    final pregunta = state[indice].texto;
    final foto = state[indice].foto;
    MensajeConversacion respuesta;
    var envio = EnvioPregunta.enviada;
    try {
      if (foto != null) {
        final t = await ref
            .read(repositorioAsistenteProvider)
            .identificarTestigo(
              vehiculoId: vehiculoId,
              imagen: foto.bytes,
              tipo: foto.tipo,
            );
        respuesta = MensajeConversacion(
          autor: AutorConversacion.asistente,
          texto: t.queHacer ?? '',
          fuentes: t.reconocido ? t.fuentes : const [],
          consultaId: t.reconocido ? t.consultaId : null,
          testigo: t,
        );
        if (!ref.mounted) return;
        final mensajes = [...state];
        mensajes[indice] = mensajes[indice].conEnvio(envio);
        mensajes.insert(indice + 1, respuesta);
        state = mensajes;
        return;
      }
      final r = await ref
          .read(repositorioAsistenteProvider)
          .preguntar(vehiculoId: vehiculoId, pregunta: pregunta);
      respuesta = MensajeConversacion(
        autor: AutorConversacion.asistente,
        texto: r.texto,
        fuentes: r.encontrado ? r.fuentes : const [],
        consultaId: r.consultaId,
      );
    } on FalloAsistente catch (fallo) {
      if (fallo.sePuedeReintentar) envio = EnvioPregunta.fallida;
      respuesta = MensajeConversacion(
        autor: AutorConversacion.asistente,
        fallo: fallo,
      );
    }
    if (!ref.mounted) return;
    final mensajes = [...state];
    mensajes[indice] = mensajes[indice].conEnvio(envio);
    mensajes.insert(indice + 1, respuesta);
    state = mensajes;
  }
}

/// Conversacion por vehiculo; se descarta al cerrar la pantalla.
final conversacionAsistenteProvider = NotifierProvider.autoDispose
    .family<ConversacionAsistente, List<MensajeConversacion>, int>(
      ConversacionAsistente.new,
      name: 'conversacionAsistenteProvider',
    );
