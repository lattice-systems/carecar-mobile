import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../dominio/documento_vehiculo.dart';

/// Fecha corta: `27 dic 2026`.
String fechaDocumento(BuildContext context, DateTime fecha) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(fecha);

String textoTipo(AppLocalizations textos, TipoDocumento tipo) => switch (tipo) {
  TipoDocumento.poliza => textos.documentosTipoPoliza,
  TipoDocumento.tarjetaCirculacion => textos.documentosTipoTarjetaCirculacion,
  TipoDocumento.verificacion => textos.documentosTipoVerificacion,
  TipoDocumento.tenencia => textos.documentosTipoTenencia,
  TipoDocumento.licencia => textos.documentosTipoLicencia,
  TipoDocumento.garantia => textos.documentosTipoGarantia,
  TipoDocumento.factura => textos.documentosTipoFactura,
  TipoDocumento.otro => textos.documentosTipoOtro,
};

/// El nombre que se ve: el tipo, o el titulo propio de un documento «otro».
String nombreDocumento(AppLocalizations textos, DocumentoVehiculo documento) {
  final titulo = documento.titulo?.trim();
  if (documento.tipo == TipoDocumento.otro &&
      titulo != null &&
      titulo.isNotEmpty) {
    return titulo;
  }
  return textoTipo(textos, documento.tipo);
}

IconData iconoTipo(TipoDocumento tipo) => switch (tipo) {
  TipoDocumento.poliza => LucideIcons300.shield,
  TipoDocumento.tarjetaCirculacion => LucideIcons300.idCard,
  TipoDocumento.verificacion => LucideIcons300.leaf,
  TipoDocumento.tenencia => LucideIcons300.receipt,
  TipoDocumento.licencia => LucideIcons300.badgeCheck,
  TipoDocumento.garantia => LucideIcons300.shieldCheck,
  TipoDocumento.factura => LucideIcons300.fileText,
  TipoDocumento.otro => LucideIcons300.file,
};

String textoEstado(AppLocalizations textos, EstadoDocumento estado) =>
    switch (estado) {
      EstadoDocumento.vigente => textos.documentosEstadoVigente,
      EstadoDocumento.porVencer => textos.documentosEstadoPorVencer,
      EstadoDocumento.vencido => textos.documentosEstadoVencido,
      EstadoDocumento.sinFecha => textos.documentosEstadoSinFecha,
    };

/// El color de cada estado; nunca va solo: la insignia lleva icono y texto.
Tono tonoEstado(EstadoDocumento estado) => switch (estado) {
  EstadoDocumento.vigente => Tono.exito,
  EstadoDocumento.porVencer => Tono.advertencia,
  EstadoDocumento.vencido => Tono.peligro,
  EstadoDocumento.sinFecha => Tono.neutro,
};

/// Cuando vence o vencio, en palabras: «hoy», «en 12 días», «hace 35 días».
/// Nulo si el servidor no mando los dias.
String? cuandoVence(AppLocalizations textos, DocumentoVehiculo documento) {
  final dias = documento.diasRestantes;
  if (dias == null) return null;
  return dias < 0
      ? textos.documentosHaceDias(-dias)
      : textos.documentosEnDias(dias);
}

/// Lo que va bajo el nombre: la fecha con los dias que faltan y, en otra
/// linea, el numero, la aseguradora y quien lo cargo. Nulo si no hay nada.
String? subtituloDocumento(BuildContext context, DocumentoVehiculo documento) {
  final textos = AppLocalizations.of(context);
  final lineas = <String>[];

  final vence = documento.venceEn;
  if (vence != null) {
    final fecha = fechaDocumento(context, vence);
    final cuando = cuandoVence(textos, documento);
    final vencido = documento.estado == EstadoDocumento.vencido;
    lineas.add(
      [
        vencido
            ? textos.documentosVencioEl(fecha)
            : textos.documentosVenceEl(fecha),
        ?cuando,
      ].join(' · '),
    );
  }

  final numero = documento.numero?.trim();
  final aseguradora = documento.aseguradora?.trim();
  final detalle = [
    if (numero != null && numero.isNotEmpty) textos.documentosNumero(numero),
    if (aseguradora != null && aseguradora.isNotEmpty) aseguradora,
    if (documento.origen == OrigenDocumento.agencia)
      textos.documentosCargadoPorAgencia,
  ].join(' · ');
  if (detalle.isNotEmpty) lineas.add(detalle);

  return lineas.isEmpty ? null : lineas.join('\n');
}
