import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/dialogo.dart';
import '../dominio/pagos.dart';
import 'formato_pagos.dart';

/// La hoja simulada de Apple Pay o Google Pay (V2-M08.03, ADR 0009). Regresa
/// si la persona confirmo; cerrarla cuenta como cancelar.
Future<bool> confirmarConLaBilletera(
  BuildContext context, {
  required String monto,
  required MedioPago billetera,
}) async {
  final textos = AppLocalizations.of(context);
  final nombre = textoBilletera(textos, billetera);
  final confirmada = await mostrarDialogo<bool>(
    context,
    builder: (contexto) => Dialogo(
      titulo: nombre,
      mensaje: textos.pagosBilleteraMensaje(monto, nombre),
      textoPrincipal: textos.pagosBilleteraConfirmar,
      alPrincipal: () => Navigator.of(contexto).pop(true),
      textoSecundario: textos.pagosBilleteraCancelar,
      alSecundario: () => Navigator.of(contexto).pop(false),
      llavePrincipal: llaveConfirmarBilletera,
      llaveSecundario: llaveCancelarBilletera,
    ),
  );
  return confirmada ?? false;
}

const llaveConfirmarBilletera = Key('pagos_billetera_confirmar');
const llaveCancelarBilletera = Key('pagos_billetera_cancelar');
