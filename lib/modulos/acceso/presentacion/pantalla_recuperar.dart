import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';
import 'package:go_router/go_router.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/datos/fallo.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/navegacion/rutas.dart';
import '../dominio/correo.dart';
import 'proveedores_acceso.dart';

/// Pide el codigo de recuperacion · V2-M01.04 y V2-T02.27.
///
/// El correo trae un codigo de 6 digitos (y un enlace que todavia no abre la
/// app). Al enviarlo lleva al paso del codigo con el correo ya puesto.
///
/// **Responde igual exista o no el correo.** El contrato contesta 202 en los
/// dos casos para no revelar que cuentas hay registradas, y esta pantalla no
/// debe deshacerlo con un mensaje distinto: siempre lleva al mismo aviso.
///
/// Por eso el aviso dice «**si** ese correo tiene una cuenta»: quien se
/// equivoco al escribirlo tiene que entender que puede no llegarle nada, en
/// vez de quedarse esperando un correo que nunca va a existir.
class PantallaRecuperar extends ConsumerStatefulWidget {
  const PantallaRecuperar({this.correoInicial, super.key});

  /// Lo que el cliente ya escribio en el acceso, para no pedirselo otra vez.
  final String? correoInicial;

  static const campoCorreo = Key('recuperar_correo');
  static const botonEnviar = Key('recuperar_enviar');
  static const avisoEnviado = Key('recuperar_aviso_enviado');
  static const avisoDeError = Key('recuperar_aviso_error');

  @override
  ConsumerState<PantallaRecuperar> createState() => _EstadoPantallaRecuperar();
}

class _EstadoPantallaRecuperar extends ConsumerState<PantallaRecuperar> {
  late final _correo = TextEditingController(text: widget.correoInicial ?? '');

  bool _enviando = false;
  bool _enviado = false;
  Fallo? _fallo;
  String? _errorCorreo;

  @override
  void dispose() {
    _correo.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_enviando) return;
    final textos = AppLocalizations.of(context);
    final correo = _correo.text.trim();

    final error = correo.isEmpty
        ? textos.accesoCorreoVacio
        : (pareceCorreo(correo) ? null : textos.accesoCorreoInvalido);
    setState(() => _errorCorreo = error);
    if (error != null) return;

    setState(() {
      _enviando = true;
      _fallo = null;
      _enviado = false;
    });

    try {
      await ref
          .read(repositorioAccesoProvider)
          .pedirEnlaceDeRecuperacion(correo);
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _enviado = true;
      });
      await context.push(Rutas.localizacionRestablecer(correo: correo));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _fallo = falloDe(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final fallo = _fallo;

    return MarcoPantalla(
      titulo: textos.accesoRecuperarTitulo,
      subtitulo: textos.accesoRecuperarExplicacion,
      conRegreso: true,
      icono: LucideIcons300.keyRound,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            Espaciado.margenTelefono,
            Espaciado.e4,
            Espaciado.margenTelefono,
            Espaciado.e8,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_enviado) ...[
                  Aviso(
                    key: PantallaRecuperar.avisoEnviado,
                    tono: Tono.informacion,
                    titulo: textos.accesoRecuperarEnviado,
                    mensaje: textos.accesoRecuperarEnviadoMensaje,
                  ),
                  const SizedBox(height: Espaciado.e4),
                ],
                if (fallo != null) ...[
                  Aviso(
                    key: PantallaRecuperar.avisoDeError,
                    // Sin conexion y el bloqueo por intentos son esperas, no
                    // algo que la persona pueda corregir aqui.
                    tono: fallo.esSinConexion || fallo is DemasiadosIntentos
                        ? Tono.advertencia
                        : Tono.peligro,
                    titulo: switch (fallo) {
                      _ when fallo.esSinConexion =>
                        textos.accesoSinConexionTitulo,
                      DemasiadosIntentos() => textos.accesoBloqueoTitulo,
                      _ => textos.accesoRecuperarFalloTitulo,
                    },
                    mensaje: fallo.mensaje,
                  ),
                  const SizedBox(height: Espaciado.e4),
                ],
                CampoTexto(
                  key: PantallaRecuperar.campoCorreo,
                  etiqueta: textos.accesoCorreoEtiqueta,
                  controlador: _correo,
                  error: _errorCorreo,
                  habilitado: !_enviando,
                  teclado: TextInputType.emailAddress,
                  pistasAutocompletar: const [AutofillHints.email],
                  accionTeclado: TextInputAction.done,
                  alEnviar: _enviando ? null : (_) => _enviar(),
                ),
                const SizedBox(height: Espaciado.e6),
                Boton(
                  key: PantallaRecuperar.botonEnviar,
                  texto: _enviando
                      ? textos.accesoRecuperarEnviando
                      : textos.accesoRecuperarEnviar,
                  alPresionar: _enviando ? null : _enviar,
                  cargando: _enviando,
                  anchoCompleto: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
