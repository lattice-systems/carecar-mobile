import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
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
    final aviso = ref.watch(avisoVigenteProvider);
    final datos = aviso.value;
    final puedeAceptar = datos != null && !aviso.isLoading && !_aceptando;

    final slivers = aviso.when(
      skipLoadingOnReload: true,
      loading: () => [
        _Contenido(hijo: const CargandoAviso(), intro: textos.privacidadIntro),
      ],
      error: (error, _) => [
        SliverFillRemaining(
          child: EstadoError(
            causa: error is PrivacidadSinConexion
                ? CausaError.sinConexion
                : CausaError.generico,
            alReintentar: () => ref.invalidate(avisoVigenteProvider),
          ),
        ),
      ],
      data: (a) => [
        _Contenido(
          hijo: TextoDelAviso(aviso: a),
          intro: textos.privacidadIntro,
        ),
      ],
    );

    // Sin regreso ni cierre: la puerta se cruza aceptando o cerrando sesión.
    return MarcoPantalla(
      icono: LucideIcons300.shieldCheck,
      titulo: textos.privacidadAntesDeContinuar,
      subtitulo: textos.privacidadTitulo,
      acciones: const [],
      slivers: slivers,
      barraInferior: BarraInferior(
        hijos: [
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
                : () => ref.read(controladorSesionProvider).cerrarSesion(),
          ),
        ],
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

/// La introducción de la puerta y lo que va debajo (el texto del aviso), como
/// un solo sliver que se desplaza.
class _Contenido extends StatelessWidget {
  const _Contenido({required this.hijo, required this.intro});

  final Widget hijo;
  final String intro;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    return SliverPadding(
      padding: const EdgeInsets.all(Espaciado.e4),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              intro,
              style: tokens.tipografia.cuerpo.copyWith(
                color: c.textoSecundario,
              ),
            ),
            const SizedBox(height: Espaciado.e5),
            hijo,
          ],
        ),
      ),
    );
  }
}
