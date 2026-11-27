import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../dominio/pagos.dart';
import '../dominio/tarjetas.dart';

String _idioma(BuildContext context) =>
    Localizations.localeOf(context).toString();

/// Pesos con centavos, como en el ticket.
String pesos(BuildContext context, double valor) => NumberFormat.currency(
  locale: _idioma(context).startsWith('es') ? 'es_MX' : 'en_US',
  symbol: r'$',
  decimalDigits: 2,
).format(valor);

String fechaPago(BuildContext context, DateTime momento) =>
    DateFormat.yMMMd(_idioma(context)).add_Hm().format(momento.toLocal());

String textoEstadoPago(AppLocalizations textos, EstadoPago estado) =>
    switch (estado) {
      EstadoPago.pendiente => textos.pagosEstadoPendiente,
      EstadoPago.pagado => textos.pagosEstadoPagado,
      EstadoPago.fallido => textos.pagosEstadoFallido,
      EstadoPago.reembolsado => textos.pagosEstadoReembolsado,
    };

Tono tonoEstadoPago(EstadoPago estado) => switch (estado) {
  EstadoPago.pendiente => Tono.advertencia,
  EstadoPago.pagado => Tono.exito,
  EstadoPago.fallido => Tono.peligro,
  EstadoPago.reembolsado => Tono.informacion,
};

/// La marca como se escribe: «Visa», «Mastercard».
String textoMarca(String marca) => switch (marca) {
  'VISA' => 'Visa',
  'MASTERCARD' => 'Mastercard',
  _ => marca,
};

/// «Visa •••• 4242», «En caja» o la billetera simulada.
String textoMedio(AppLocalizations textos, Pago pago) => switch (pago.medio) {
  MedioPago.caja => textos.pagosMedioCaja,
  MedioPago.applePay => textos.pagosMedioApplePay,
  MedioPago.googlePay => textos.pagosMedioGooglePay,
  MedioPago.tarjeta => textos.pagosMedioTarjeta(
    textoMarca(pago.marca ?? ''),
    pago.ultimos4 ?? '',
  ),
};

String textoTarjetaGuardada(AppLocalizations textos, MetodoPago metodo) =>
    textos.pagosMedioTarjeta(textoMarca(metodo.marca), metodo.ultimos4);

/// «12/28».
String textoVencimiento(int mes, int anio) =>
    '${mes.toString().padLeft(2, '0')}/${(anio % 100).toString().padLeft(2, '0')}';

String textoMotivoFallo(AppLocalizations textos, MotivoFalloPago? motivo) =>
    switch (motivo) {
      MotivoFalloPago.fondosInsuficientes => textos.pagosMotivoFondos,
      MotivoFalloPago.autenticacionFallida => textos.pagosMotivoAutenticacion,
      MotivoFalloPago.autenticacionVencida => textos.pagosMotivoVencida,
      MotivoFalloPago.pagadaEnCaja => textos.pagosMotivoCaja,
      MotivoFalloPago.otro || null => textos.pagosMotivoOtro,
    };

String textoMotivoTarjeta(AppLocalizations textos, MotivoTarjeta motivo) =>
    switch (motivo) {
      MotivoTarjeta.numeroVacio => textos.pagosErrorNumeroVacio,
      MotivoTarjeta.numeroIncompleto => textos.pagosErrorNumeroIncompleto,
      MotivoTarjeta.numeroInvalido => textos.pagosErrorNumeroInvalido,
      MotivoTarjeta.noEsDePrueba => textos.pagosErrorNoEsDePrueba,
      MotivoTarjeta.vencimientoVacio => textos.pagosErrorVencimientoVacio,
      MotivoTarjeta.vencimientoInvalido => textos.pagosErrorVencimientoInvalido,
      MotivoTarjeta.vencida => textos.pagosErrorVencida,
      MotivoTarjeta.cvvInvalido => textos.pagosErrorCvv,
    };

String textoEscenario(AppLocalizations textos, EscenarioTarjeta escenario) =>
    switch (escenario) {
      EscenarioTarjeta.aprobada => textos.pagosEscenarioAprobada,
      EscenarioTarjeta.fondosInsuficientes => textos.pagosEscenarioFondos,
      EscenarioTarjeta.pideConfirmar => textos.pagosEscenarioConfirmar,
      EscenarioTarjeta.confirmacionFalla =>
        textos.pagosEscenarioConfirmacionFalla,
    };

/// Con [pedido] el intento en curso se explica como de un pedido de la tienda.
String textoRechazo(
  AppLocalizations textos,
  MotivoRechazoPago motivo, {
  bool pedido = false,
}) => switch (motivo) {
  MotivoRechazoPago.ordenNoPagable => textos.pagosOrdenNoPagable,
  MotivoRechazoPago.pagoEnCurso =>
    pedido ? textos.pagosPedidoPagoEnCurso : textos.pagosPagoEnCurso,
  MotivoRechazoPago.pagoNoPendiente => textos.pagosPagoNoPendiente,
  MotivoRechazoPago.pedidoNoPagable => textos.pagosPedidoNoPagable,
};

/// «Orden 41» o «Pedido 7»: lo que se pago.
String textoObjetivoPago(AppLocalizations textos, Pago pago) {
  final pedidoId = pago.pedidoId;
  return pedidoId != null
      ? textos.pagosPedido('$pedidoId')
      : textos.pagosOrden('${pago.ordenId ?? ''}');
}
