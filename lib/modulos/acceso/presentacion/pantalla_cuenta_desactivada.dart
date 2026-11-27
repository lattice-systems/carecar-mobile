import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../config/agencia.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/centrado_desplazable.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/navegacion/rutas.dart';
import '../../../nucleo/sesion/proveedores_sesion.dart';
import 'proveedores_acceso.dart';

/// Por que no puedo entrar: la agencia desactivo la cuenta · V2-M01.08.
///
/// Es un **callejon a proposito**. No lleva campos ni «intentar de nuevo»:
/// escribir otra vez la contrasena no arregla nada, y ofrecerlo haria que la
/// persona lo intentara hasta rendirse sin saber por que. Lo unico accionable
/// es hablar con la agencia, asi que eso es lo que ofrece.
///
/// La sesion local ya se borro antes de llegar: lo hace
/// `ControladorSesion.terminarPorCuentaDesactivada`, al que llama el 403 desde
/// `ClienteApi` -la cuenta se puede desactivar con la persona dentro- y el
/// login cuando el servidor contesta 403 al entrar.
class PantallaCuentaDesactivada extends ConsumerStatefulWidget {
  const PantallaCuentaDesactivada({super.key});

  static const botonLlamar = Key('desactivada_llamar');
  static const botonCorreo = Key('desactivada_correo');
  static const botonVolver = Key('desactivada_volver');

  @override
  ConsumerState<PantallaCuentaDesactivada> createState() =>
      _EstadoPantallaCuentaDesactivada();
}

class _EstadoPantallaCuentaDesactivada
    extends ConsumerState<PantallaCuentaDesactivada> {
  Future<void> _abrir(Uri enlace) async {
    final textos = AppLocalizations.of(context);
    final mensajero = ScaffoldMessenger.of(context);
    var abierto = false;
    try {
      abierto = await ref.read(abrirEnlaceProvider)(enlace);
    } on Object {
      // Un celular sin app de telefono o de correo no es un error de la app.
      abierto = false;
    }
    if (!abierto) {
      mensajero.showSnackBar(
        SnackBar(content: Text(textos.accesoDesactivadaNoSePudo)),
      );
    }
  }

  /// Vuelve al login. Hace falta reconocer el aviso: si no, la guardia
  /// regresaria aqui en cuanto se intente salir.
  void _volver() {
    ref.read(controladorSesionProvider).reconocerCuentaDesactivada();
    GoRouter.of(context).go(Rutas.acceso);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);

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
                  // El icono acompana al texto; no lleva la informacion solo.
                  Icon(
                    LucideIcons300.userX,
                    size: 40,
                    color: tokens.colores.peligro,
                  ),
                  const SizedBox(height: Espaciado.e4),
                  Text(
                    textos.accesoDesactivadaTitulo,
                    style: tokens.tipografia.titulo2,
                  ),
                  const SizedBox(height: Espaciado.e2),
                  Text(
                    textos.accesoDesactivadaExplicacion,
                    style: tokens.tipografia.cuerpo.copyWith(
                      color: tokens.colores.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: Espaciado.e6),
                  Boton(
                    key: PantallaCuentaDesactivada.botonLlamar,
                    texto: textos.accesoDesactivadaLlamar,
                    alPresionar: () => _abrir(
                      Uri(
                        scheme: 'tel',
                        path: Agencia.telefono.replaceAll(' ', ''),
                      ),
                    ),
                    anchoCompleto: true,
                  ),
                  const SizedBox(height: Espaciado.e2),
                  Boton(
                    key: PantallaCuentaDesactivada.botonCorreo,
                    texto: textos.accesoDesactivadaEscribir,
                    variante: VarianteBoton.secundario,
                    alPresionar: () =>
                        _abrir(Uri(scheme: 'mailto', path: Agencia.correo)),
                    anchoCompleto: true,
                  ),
                  const SizedBox(height: Espaciado.e2),
                  Boton(
                    key: PantallaCuentaDesactivada.botonVolver,
                    texto: textos.accesoDesactivadaVolver,
                    variante: VarianteBoton.terciario,
                    alPresionar: _volver,
                    anchoCompleto: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
