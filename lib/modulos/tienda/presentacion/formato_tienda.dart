import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../citas/citas.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/repositorio_tienda.dart';
import '../dominio/tienda.dart';

// Los precios son en pesos mexicanos y se escriben igual en cualquier idioma.
final _pesos = NumberFormat.currency(locale: 'es_MX', symbol: r'$');

String pesosTienda(double monto) => _pesos.format(monto);

String _idioma(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();

String _hora(BuildContext context, DateTime fecha) =>
    DateFormat.Hm(_idioma(context)).format(fecha);

/// "vie 28 nov, 14:30", en la hora del teléfono.
String momentoTienda(BuildContext context, DateTime momento) {
  final local = momento.toLocal();
  return '${DateFormat.MMMEd(_idioma(context)).format(local)}, '
      '${_hora(context, local)}';
}

/// "vie 28 nov, 09:00".
String diaYHoraTienda(BuildContext context, DateTime fecha, String hora) =>
    '${DateFormat.MMMEd(_idioma(context)).format(fecha)}, '
    '${hora.length >= 5 ? hora.substring(0, 5) : hora}';

/// El nombre de un auto del garaje, o el que mandó la cita.
String? nombreDeAuto(
  List<VehiculoGaraje> garaje,
  int vehiculoId, [
  String? deLaCita,
]) {
  for (final v in garaje) {
    if (v.id == vehiculoId) return v.titulo;
  }
  return deLaCita;
}

String textoCita(
  BuildContext context,
  CitaCliente cita,
  List<VehiculoGaraje> garaje,
) => [
  diaYHoraTienda(context, cita.fecha, cita.horaInicio),
  ?nombreDeAuto(garaje, cita.vehiculoId, cita.vehiculoNombre),
].join(', ');

String textoCategoria(AppLocalizations t, CategoriaProducto? categoria) =>
    switch (categoria) {
      null => t.tiendaCategoriaTodas,
      CategoriaProducto.accesorio => t.tiendaCategoriaAccesorio,
      CategoriaProducto.refaccion => t.tiendaCategoriaRefaccion,
      CategoriaProducto.cuidado => t.tiendaCategoriaCuidado,
    };

IconData iconoCategoria(CategoriaProducto? categoria) => switch (categoria) {
  CategoriaProducto.accesorio => LucideIcons300.sparkles,
  CategoriaProducto.refaccion => LucideIcons300.wrench,
  CategoriaProducto.cuidado => LucideIcons300.droplet,
  null => LucideIcons300.shoppingBag,
};

String textoExistencia(AppLocalizations t, Producto producto) =>
    producto.agotado
    ? t.tiendaAgotado
    : t.tiendaExistencia(producto.existencia);

String textoEstadoPedido(AppLocalizations t, EstadoPedido estado) =>
    switch (estado) {
      EstadoPedido.apartado => t.tiendaEstadoApartado,
      EstadoPedido.listo => t.tiendaEstadoListo,
      EstadoPedido.entregado => t.tiendaEstadoEntregado,
      EstadoPedido.cancelado => t.tiendaEstadoCancelado,
    };

Tono tonoEstadoPedido(EstadoPedido estado) => switch (estado) {
  EstadoPedido.apartado => Tono.informacion,
  EstadoPedido.listo => Tono.exito,
  EstadoPedido.entregado => Tono.neutro,
  EstadoPedido.cancelado => Tono.advertencia,
};

String textoMotivoCancelacion(AppLocalizations t, MotivoCancelacion motivo) =>
    switch (motivo) {
      MotivoCancelacion.cliente => t.tiendaMotivoCliente,
      MotivoCancelacion.vencido => t.tiendaMotivoVencido,
      MotivoCancelacion.agencia => t.tiendaMotivoAgencia,
    };

String textoRechazo(AppLocalizations t, MotivoRechazoPedido motivo) =>
    switch (motivo) {
      MotivoRechazoPedido.sinExistencia => t.tiendaRechazoSinExistencia,
      MotivoRechazoPedido.citaNoDisponible => t.tiendaRechazoCitaNoDisponible,
      MotivoRechazoPedido.limiteApartados => t.tiendaRechazoLimite,
      MotivoRechazoPedido.noCancelable => t.tiendaRechazoNoCancelable,
      MotivoRechazoPedido.noModificable => t.tiendaRechazoNoModificable,
      MotivoRechazoPedido.productoIncompatible => t.tiendaRechazoIncompatible,
    };

/// Lo que se le dice a la persona cuando una acción falla. [sinConexion] es el
/// texto propio de cada acción para cuando no hay red.
String textoFallo(
  AppLocalizations t,
  Object error, {
  required String sinConexion,
}) => switch (error) {
  PedidoRechazado(:final motivo) => textoRechazo(t, motivo),
  SinConexion() => sinConexion,
  _ => t.tiendaAccionError,
};
