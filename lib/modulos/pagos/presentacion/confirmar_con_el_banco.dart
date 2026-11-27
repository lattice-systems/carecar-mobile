import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/dialogo.dart';

/// La pantalla simulada del banco para el 3-D Secure (ADR 0009). Regresa si la
/// persona confirmo; cerrarla cuenta como cancelar.
Future<bool> confirmarConElBanco(
  BuildContext context, {
  required String monto,
  required String tarjeta,
}) async {
  final textos = AppLocalizations.of(context);
  final confirmada = await mostrarDialogo<bool>(
    context,
    cerrarAlTocarFuera: false,
    builder: (contexto) => Dialogo(
      titulo: textos.pagosBancoTitulo,
      mensaje: textos.pagosBancoMensaje(monto, tarjeta),
      textoPrincipal: textos.pagosBancoConfirmar,
      alPrincipal: () => Navigator.of(contexto).pop(true),
      textoSecundario: textos.pagosBancoCancelar,
      alSecundario: () => Navigator.of(contexto).pop(false),
      llavePrincipal: llaveConfirmarBanco,
      llaveSecundario: llaveCancelarBanco,
    ),
  );
  return confirmada ?? false;
}

const llaveConfirmarBanco = Key('pagos_banco_confirmar');
const llaveCancelarBanco = Key('pagos_banco_cancelar');
