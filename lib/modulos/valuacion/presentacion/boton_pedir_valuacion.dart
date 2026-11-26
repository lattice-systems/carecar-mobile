import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../dominio/repositorio_valuacion.dart';
import 'proveedores_valuacion.dart';
import 'rutas_valuacion.dart';

/// «Pedir valuación formal» desde una estimacion (V2-M26.01).
///
/// Pide la valuacion y abre su detalle; si el vehiculo ya tenia una abierta,
/// abre esa. Una estimacion capturada a mano se explica sin salir de la
/// pantalla.
class BotonPedirValuacion extends ConsumerStatefulWidget {
  const BotonPedirValuacion({
    required this.estimacionId,
    super.key,
    this.alAbrir,
  });

  final int estimacionId;

  /// Como abrir el detalle. Sin valor, se apila sobre la pantalla actual. Una
  /// hoja inferior lo pasa para cerrarse antes.
  final void Function(int valuacionId)? alAbrir;

  @override
  ConsumerState<BotonPedirValuacion> createState() =>
      _BotonPedirValuacionState();
}

class _BotonPedirValuacionState extends ConsumerState<BotonPedirValuacion> {
  bool _enviando = false;
  Object? _fallo;

  Future<void> _pedir() async {
    if (_enviando) return;
    setState(() {
      _enviando = true;
      _fallo = null;
    });
    try {
      final valuacion = await ref
          .read(repositorioValuacionProvider)
          .pedir(widget.estimacionId);
      if (!mounted) return;
      ref.invalidate(misValuacionesProvider);
      setState(() => _enviando = false);
      final abrir = widget.alAbrir;
      if (abrir != null) {
        abrir(valuacion.id);
      } else {
        context.push(rutaValuacion(valuacion.id));
      }
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _fallo = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final fallo = _fallo;
    final sinVehiculo =
        fallo is ValuacionRechazada &&
        fallo.motivo == MotivoRechazoValuacion.sinVehiculo;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BotonPildora(
          texto: t.valuacionPedir,
          icono: Icons.verified_outlined,
          expandido: true,
          cargando: _enviando,
          // Una estimacion a mano no va a poder: el aviso dice que hacer.
          alPresionar: sinVehiculo ? null : _pedir,
        ),
        if (fallo != null) ...[
          const SizedBox(height: Espaciado.e2),
          Aviso(
            tono: sinVehiculo ? Tono.advertencia : Tono.peligro,
            mensaje: switch (fallo) {
              _ when sinVehiculo => t.valuacionPedirSinVehiculo,
              SinConexion() => t.valuacionSinConexionAccion,
              NoEncontrado() => t.valuacionPedirNoEncontrada,
              _ => t.valuacionPedirError,
            },
          ),
        ],
      ],
    );
  }
}
