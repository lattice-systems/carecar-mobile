import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/privacidad/estado_aviso.dart';
import '../dominio/privacidad.dart';
import 'componentes_privacidad.dart';
import 'proveedores_privacidad.dart';

/// Leer el aviso de privacidad vigente, con cuándo se aceptó (V2-M22.01).
/// Se abre desde el perfil.
class PantallaAvisoPrivacidad extends ConsumerStatefulWidget {
  const PantallaAvisoPrivacidad({super.key});

  @override
  ConsumerState<PantallaAvisoPrivacidad> createState() =>
      _PantallaAvisoPrivacidadState();
}

class _PantallaAvisoPrivacidadState
    extends ConsumerState<PantallaAvisoPrivacidad> {
  @override
  void initState() {
    super.initState();
    // Siempre el texto de hoy: una versión nueva pudo publicarse desde que se
    // inició sesión.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.invalidate(avisoVigenteProvider);
    });
    ref.listenManual(
      avisoVigenteProvider,
      (_, siguiente) => siguiente.whenData(_conciliar),
      fireImmediately: true,
    );
  }

  /// Si el servidor dice que falta aceptar esta versión (porque no se pudo
  /// verificar al entrar, por ejemplo), la guardia lleva a la puerta.
  void _conciliar(AvisoDePrivacidad aviso) {
    if (aviso.aceptado) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(estadoAvisoProvider.notifier).pendiente();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final aviso = ref.watch(avisoVigenteProvider);

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(title: Text(textos.privacidadTitulo)),
      body: SafeArea(
        child: aviso.when(
          skipLoadingOnReload: true,
          loading: () => const Padding(
            padding: EdgeInsets.all(Espaciado.e4),
            child: CargandoAviso(),
          ),
          error: (error, _) => EstadoError(
            causa: error is PrivacidadSinConexion
                ? CausaError.sinConexion
                : CausaError.generico,
            alReintentar: () => ref.invalidate(avisoVigenteProvider),
          ),
          data: (a) => ListView(
            padding: const EdgeInsets.all(Espaciado.e4),
            children: [
              // Lo primero que se busca aquí es si ya se aceptó, no el final
              // de un texto largo.
              if (a.aceptadoEn case final cuando?) ...[
                Aviso(
                  mensaje: textos.privacidadAceptadoEl(
                    diaDelAviso(context, cuando),
                  ),
                  tono: Tono.exito,
                ),
                const SizedBox(height: Espaciado.e4),
              ],
              TextoDelAviso(aviso: a),
            ],
          ),
        ),
      ),
    );
  }
}
