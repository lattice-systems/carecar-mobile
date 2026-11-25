import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/centrado_desplazable.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/sesion/proveedores_sesion.dart';
import '../../../sesion/controlador_sesion.dart';
import '../dominio/bloqueo_por_intentos.dart';
import 'aviso_bloqueo.dart';
import 'espera_servidor.dart';
import 'proveedores_acceso.dart';

/// Pantalla de acceso · V2-M01.01.
///
/// El criterio de aceptacion es explicito: **no hay registro publico**. La
/// cuenta la entrega la agencia al entregar la unidad, asi que aqui no existe
/// ningun flujo de «crear cuenta», y una nota lo explica para que nadie la
/// busque.
///
/// **No navega.** Cuando la sesion queda autenticada, el guardia del enrutador
/// saca al usuario de `/acceso` hacia donde iba, o al inicio
/// (`nucleo/navegacion/guardia_sesion.dart`). Por eso esta pantalla no recibe
/// callbacks de exito ni llama a `go`: solo pide la sesion y muestra lo que
/// pasa.
class PantallaAcceso extends ConsumerStatefulWidget {
  const PantallaAcceso({super.key});

  static const campoCorreo = Key('acceso_correo');
  static const campoContrasena = Key('acceso_contrasena');
  static const botonEntrar = Key('acceso_entrar');
  static const botonOlvide = Key('acceso_olvide');
  static const avisoDeError = Key('acceso_aviso_error');

  @override
  ConsumerState<PantallaAcceso> createState() => _EstadoPantallaAcceso();
}

class _EstadoPantallaAcceso extends ConsumerState<PantallaAcceso> {
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();

  /// Los errores de campo los guarda la pantalla.
  ///
  /// Los componentes del sistema v2 reciben `error` como texto y no traen
  /// validador, asi que no hay `Form` ni `FormState` que los junte.
  String? _errorCorreo;
  String? _errorContrasena;

  /// Hasta cuando dura el bloqueo por intentos, si hay uno.
  ///
  /// Se guarda en vez de calcularse en cada `build`: el `Retry-After` dice
  /// cuantos segundos faltan **desde que fallo**, asi que recalcularlo
  /// reiniciaria la cuenta cada vez que la pantalla se reconstruye -escribir
  /// en un campo basta- y el usuario nunca la veria bajar.
  BloqueoPorIntentos? _bloqueo;

  /// Arranca al empezar la peticion y avisa si el servidor tarda (V2-M01.12).
  Timer? _esperaDelServidor;
  bool _servidorTarda = false;

  /// Vigila si el servidor tarda en contestar.
  ///
  /// El aviso se va en cuanto responde, con exito o con error: dejarlo haria
  /// que el cliente leyera «despertando» junto a un mensaje de credenciales.
  void _vigilarLaEspera(EstadoSesion actual) {
    if (actual is Autenticando) {
      _esperaDelServidor ??= Timer(umbralEsperaServidor, () {
        if (mounted) setState(() => _servidorTarda = true);
      });
      return;
    }
    _esperaDelServidor?.cancel();
    _esperaDelServidor = null;
    if (_servidorTarda) setState(() => _servidorTarda = false);
  }

  /// Recuerda el bloqueo cuando aparece, y lo olvida al salir del fallo.
  void _alCambiarLaSesion(EstadoSesion? _, EstadoSesion actual) {
    _vigilarLaEspera(actual);
    if (actual is FalloDeSesion && actual.esBloqueoTemporal) {
      final segundos = actual.esperaSegundos;
      final nuevo = BloqueoPorIntentos.desde(
        ahora: ref.read(relojAccesoProvider)(),
        espera: segundos == null ? null : Duration(seconds: segundos),
      );
      if (nuevo != null) setState(() => _bloqueo = nuevo);
      return;
    }
    if (actual is! FalloDeSesion && _bloqueo != null) {
      setState(() => _bloqueo = null);
    }
  }

  @override
  void dispose() {
    _esperaDelServidor?.cancel();
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  /// Validacion minima: que tenga algo, una arroba y un punto despues.
  ///
  /// No se usa una expresion regular estricta a proposito: rechazar un correo
  /// valido es peor que dejar pasar uno raro, porque el backend valida igual e
  /// ignora mayusculas y espacios (RIC-8).
  String? _revisarCorreo(AppLocalizations textos, String correo) {
    if (correo.isEmpty) return textos.accesoCorreoVacio;
    final arroba = correo.indexOf('@');
    if (arroba <= 0 || !correo.contains('.', arroba)) {
      return textos.accesoCorreoInvalido;
    }
    return null;
  }

  Future<void> _entrar() async {
    final textos = AppLocalizations.of(context);
    final correo = _correo.text.trim();
    final contrasena = _contrasena.text;

    final errorCorreo = _revisarCorreo(textos, correo);
    final errorContrasena = contrasena.isEmpty
        ? textos.accesoContrasenaVacia
        : null;

    setState(() {
      _errorCorreo = errorCorreo;
      _errorContrasena = errorContrasena;
    });

    // No tiene sentido una peticion de red para descubrir que el campo venia
    // vacio, y un 429 se gasta igual con datos invalidos.
    if (errorCorreo != null || errorContrasena != null) return;

    await ref
        .read(controladorSesionProvider)
        .iniciarSesion(correo: correo, contrasena: contrasena);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    ref.listen(estadoSesionProvider, _alCambiarLaSesion);
    final estado = ref.watch(estadoSesionProvider);
    final entrando = estado is Autenticando;
    final fallo = estado is FalloDeSesion ? estado : null;

    // Con la sesion ya iniciada en esta pantalla no queda nada por hacer: el
    // guardia esta a punto de sacar al usuario. No se depende de que llegue
    // primero, porque un segundo toque pediria otra sesion al servidor.
    final puedeEntrar = !entrando && estado is! Autenticada;

    return Scaffold(
      body: SafeArea(
        child: CentradoDesplazable(
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e5),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Encabezado(
                    marca: textos.accesoMarca,
                    subtitulo: textos.accesoSubtitulo,
                  ),
                  const SizedBox(height: Espaciado.e6),
                  if (_servidorTarda) ...[
                    const AvisoEsperaServidor(),
                    const SizedBox(height: Espaciado.e4),
                  ],
                  if (_bloqueo != null) ...[
                    AvisoBloqueo(
                      bloqueo: _bloqueo!,
                      reloj: ref.watch(relojAccesoProvider),
                    ),
                    const SizedBox(height: Espaciado.e4),
                  ] else if (fallo != null) ...[
                    Aviso(
                      key: PantallaAcceso.avisoDeError,
                      // Ni «sin conexion» ni «demasiados intentos» son errores
                      // de quien entra: son esperas, y no hay nada que
                      // corregir en el formulario. Van en ambar, no en rojo.
                      tono: fallo.esFalloDeRed || fallo.esBloqueoTemporal
                          ? Tono.advertencia
                          : Tono.peligro,
                      titulo: switch (fallo) {
                        _ when fallo.esFalloDeRed =>
                          textos.accesoSinConexionTitulo,
                        _ when fallo.esBloqueoTemporal =>
                          textos.accesoBloqueoTitulo,
                        _ => textos.accesoFalloTitulo,
                      },
                      mensaje: fallo.mensaje,
                    ),
                    const SizedBox(height: Espaciado.e4),
                  ],
                  CampoTexto(
                    key: PantallaAcceso.campoCorreo,
                    etiqueta: textos.accesoCorreoEtiqueta,
                    ayuda: textos.accesoCorreoAyuda,
                    controlador: _correo,
                    error: _errorCorreo,
                    habilitado: puedeEntrar,
                    // Teclado de correo, como pidio RIC-8.
                    teclado: TextInputType.emailAddress,
                    pistasAutocompletar: const [AutofillHints.email],
                    accionTeclado: TextInputAction.next,
                  ),
                  const SizedBox(height: Espaciado.e4),
                  CampoContrasena(
                    key: PantallaAcceso.campoContrasena,
                    etiqueta: textos.accesoContrasenaEtiqueta,
                    controlador: _contrasena,
                    error: _errorContrasena,
                    habilitado: puedeEntrar,
                    accionTeclado: TextInputAction.done,
                    alEnviar: puedeEntrar ? (_) => _entrar() : null,
                  ),
                  const SizedBox(height: Espaciado.e6),
                  Boton(
                    key: PantallaAcceso.botonEntrar,
                    texto: entrando
                        ? textos.accesoEntrando
                        : textos.accesoEntrar,
                    // Deshabilitado mientras entra: evita el doble toque, que
                    // con cinco intentos y bloqueo de 15 minutos sale caro.
                    alPresionar: puedeEntrar ? _entrar : null,
                    cargando: entrando,
                    anchoCompleto: true,
                  ),
                  const SizedBox(height: Espaciado.e2),
                  Boton(
                    key: PantallaAcceso.botonOlvide,
                    texto: textos.accesoOlvide,
                    variante: VarianteBoton.terciario,
                    alPresionar: puedeEntrar ? _olvide : null,
                  ),
                  const SizedBox(height: Espaciado.e5),
                  _NotaSinRegistro(texto: textos.accesoSinRegistro),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// La recuperacion es V2-M01.04 y todavia no existe en v2.
  ///
  /// Se deja el enlace visible porque el criterio de la historia no lo quita y
  /// esconderlo seria una regresion de lo que el cliente ya tiene en la v1. El
  /// destino se cablea con las rutas, no desde aqui.
  void _olvide() {}
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.marca, required this.subtitulo});

  final String marca;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    return Column(
      children: [
        Text(marca, style: tokens.tipografia.titulo1),
        const SizedBox(height: Espaciado.e1),
        Text(
          subtitulo,
          textAlign: TextAlign.center,
          style: tokens.tipografia.cuerpo.copyWith(
            color: tokens.colores.textoSecundario,
          ),
        ),
      ],
    );
  }
}

/// Nota que explica por que no hay registro.
///
/// No es un enlace ni un boton: el criterio prohibe cualquier flujo de
/// registro, asi que es solo texto.
class _NotaSinRegistro extends StatelessWidget {
  const _NotaSinRegistro({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Icon(
            Icons.info_outline,
            size: 16,
            color: tokens.colores.textoSecundario,
          ),
        ),
        const SizedBox(width: Espaciado.e2),
        Expanded(
          child: Text(
            texto,
            style: tokens.tipografia.cuerpoChico.copyWith(
              color: tokens.colores.textoSecundario,
            ),
          ),
        ),
      ],
    );
  }
}
