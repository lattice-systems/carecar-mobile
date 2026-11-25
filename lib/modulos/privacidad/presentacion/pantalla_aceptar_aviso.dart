import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/privacidad/estado_aviso.dart';
import '../../../nucleo/sesion/proveedores_sesion.dart';
import '../dominio/privacidad.dart';
import 'componentes_privacidad.dart';
import 'proveedores_privacidad.dart';

/// La puerta del aviso de privacidad (V2-M22.01): en el primer ingreso y cada
/// vez que la agencia publica una versión nueva, se lee y se acepta antes de
/// usar la app. La guardia del enrutador manda aquí; al aceptar, la misma
/// guardia devuelve a la persona a donde iba.
///
/// Quien no acepta no se queda atrapada: puede cerrar sesión.
class PantallaAceptarAviso extends ConsumerStatefulWidget {
  const PantallaAceptarAviso({super.key});

  @override
  ConsumerState<PantallaAceptarAviso> createState() =>
      _PantallaAceptarAvisoState();
}

class _PantallaAceptarAvisoState extends ConsumerState<PantallaAceptarAviso> {
  bool _aceptando = false;
  FalloPrivacidad? _fallo;

  @override
  void initState() {
    super.initState();
    // El verificador ya pidió el aviso; aquí solo se pone al día la puerta con
    // lo que el servidor dijo (y con lo que diga si se vuelve a pedir).
    ref.listenManual(
      avisoVigenteProvider,
      (_, siguiente) => siguiente.whenData(_conciliar),
      fireImmediately: true,
    );
  }

  /// Fuera del cuadro en curso: cambiar el estado avisa al enrutador, que no
  /// puede reconstruirse a media construcción.
  void _conciliar(AvisoDePrivacidad aviso) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final estado = ref.read(estadoAvisoProvider.notifier);
      if (aviso.aceptado) {
        estado.aceptado();
      } else if (ref.read(estadoAvisoProvider) == EstadoAviso.verificando) {
        estado.pendiente();
      }
    });
  }

  Future<void> _aceptar(AvisoDePrivacidad aviso) async {
    setState(() {
      _aceptando = true;
      _fallo = null;
    });
    try {
      await ref.read(repositorioPrivacidadProvider).aceptar(aviso.id);
      if (!mounted) return;
      ref.read(estadoAvisoProvider.notifier).aceptado();
      ref.invalidate(avisoVigenteProvider);
    } on AvisoNoVigente catch (fallo) {
      // Salió otra versión mientras se leía: se vuelve a pedir y se lee la
      // nueva; no se acepta a ciegas.
      ref.invalidate(avisoVigenteProvider);
      if (mounted) setState(() => _fallo = fallo);
    } on FalloPrivacidad catch (fallo) {
      if (mounted) setState(() => _fallo = fallo);
    } finally {
      if (mounted) setState(() => _aceptando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final aviso = ref.watch(avisoVigenteProvider);
    final datos = aviso.value;
    final puedeAceptar = datos != null && !aviso.isLoading && !_aceptando;

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        title: Text(textos.privacidadTitulo),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: aviso.when(
                skipLoadingOnReload: true,
                loading: () =>
                    _Contenido(hijo: const CargandoAviso(), encabezado: textos),
                error: (error, _) => EstadoError(
                  causa: error is PrivacidadSinConexion
                      ? CausaError.sinConexion
                      : CausaError.generico,
                  alReintentar: () => ref.invalidate(avisoVigenteProvider),
                ),
                data: (a) => _Contenido(
                  hijo: TextoDelAviso(aviso: a),
                  encabezado: textos,
                ),
              ),
            ),
            // La barra de abajo se separa del texto que se desplaza por detrás.
            DecoratedBox(
              decoration: BoxDecoration(
                color: c.fondo,
                border: Border(top: BorderSide(color: c.borde)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Espaciado.e4,
                  Espaciado.e3,
                  Espaciado.e4,
                  Espaciado.e4,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_fallo case final fallo?) ...[
                      Aviso(
                        mensaje: _textoDeFallo(textos, fallo),
                        tono: fallo is AvisoNoVigente
                            ? Tono.informacion
                            : fallo is PrivacidadSinConexion
                            ? Tono.advertencia
                            : Tono.peligro,
                      ),
                      const SizedBox(height: Espaciado.e3),
                    ],
                    BotonPildora(
                      texto: _aceptando
                          ? textos.privacidadGuardando
                          : textos.privacidadAceptar,
                      expandido: true,
                      alPresionar: puedeAceptar ? () => _aceptar(datos) : null,
                    ),
                    const SizedBox(height: Espaciado.e2),
                    BotonPildora(
                      texto: textos.privacidadNoAcepto,
                      variante: VarianteBotonPildora.vidrio,
                      expandido: true,
                      alPresionar: _aceptando
                          ? null
                          : () => ref
                                .read(controladorSesionProvider)
                                .cerrarSesion(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _textoDeFallo(AppLocalizations textos, FalloPrivacidad fallo) =>
      switch (fallo) {
        AvisoNoVigente() => textos.privacidadCambio,
        PrivacidadSinConexion() => textos.privacidadSinConexionAceptar,
        PrivacidadNoDisponible() => textos.privacidadErrorAceptar,
      };
}

/// El encabezado de la puerta y lo que va debajo, que se desplaza.
class _Contenido extends StatelessWidget {
  const _Contenido({required this.hijo, required this.encabezado});

  final Widget hijo;
  final AppLocalizations encabezado;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    return ListView(
      padding: const EdgeInsets.all(Espaciado.e4),
      children: [
        Semantics(
          header: true,
          child: Text(
            encabezado.privacidadAntesDeContinuar,
            style: tokens.tipografia.titulo2.copyWith(color: c.texto),
          ),
        ),
        const SizedBox(height: Espaciado.e2),
        Text(
          encabezado.privacidadIntro,
          style: tokens.tipografia.cuerpo.copyWith(color: c.textoSecundario),
        ),
        const SizedBox(height: Espaciado.e5),
        hijo,
      ],
    );
  }
}
