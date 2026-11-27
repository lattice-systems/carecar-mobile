import 'package:flutter/material.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';

/// El esqueleto del modulo, con la forma del contenido que viene.
class EsqueletoValuacion extends StatelessWidget {
  const EsqueletoValuacion({required this.altos, super.key});

  final List<double> altos;

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).valuacionCargando,
    liveRegion: true,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(Espaciado.e4),
      child: Column(
        children: [
          for (final alto in altos) ...[
            Esqueleto(alto: alto),
            const SizedBox(height: Espaciado.e3),
          ],
        ],
      ),
    ),
  );
}

/// El error de carga del modulo: sin conexion o generico, con reintento.
class ErrorValuacion extends StatelessWidget {
  const ErrorValuacion({
    required this.error,
    required this.alReintentar,
    super.key,
  });

  final Object error;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final sinConexion = error is SinConexion;
    return EstadoError(
      causa: sinConexion ? CausaError.sinConexion : CausaError.generico,
      titulo: sinConexion
          ? t.valuacionSinConexionTitulo
          : t.valuacionErrorTitulo,
      mensaje: sinConexion
          ? t.valuacionSinConexionMensaje
          : t.valuacionErrorMensaje,
      textoReintentar: t.valuacionReintentar,
      alReintentar: alReintentar,
    );
  }
}

/// Una tarjeta del modulo para contenido propio (el calendario, una toma).
class SuperficieValuacion extends StatelessWidget {
  const SuperficieValuacion({
    required this.hijo,
    super.key,
    this.relleno = Espaciado.e4,
  });

  final Widget hijo;
  final double relleno;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.colores.superficie,
        borderRadius: Radios.bordeTarjeta,
        boxShadow: tokens.sombras,
      ),
      child: Padding(padding: EdgeInsets.all(relleno), child: hijo),
    );
  }
}
