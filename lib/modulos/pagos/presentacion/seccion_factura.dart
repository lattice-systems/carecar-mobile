import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/selector.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/datos_fiscales.dart';
import '../dominio/pagos.dart';
import 'esqueleto_pagos.dart';
import 'formato_pagos.dart';
import 'proveedores_datos_fiscales.dart';
import 'proveedores_pagos.dart';
import 'rutas_pagos.dart';

/// La factura simulada de un pago (V2-M08.06, ADR 0009). Si ya esta timbrada
/// muestra folio, folio fiscal y receptor, y comparte el PDF o el XML. Si el
/// pago se puede facturar, elige los datos fiscales y la timbra; si el
/// timbrado rechaza el perfil dice que corregir y lleva a editarlo. Un pago en
/// caja se factura en la agencia. En cualquier otro caso no ocupa lugar.
class SeccionFactura extends ConsumerStatefulWidget {
  const SeccionFactura({required this.pago, super.key});

  final Pago pago;

  static const botonFacturar = Key('pagos_facturar');
  static const botonPdf = Key('pagos_factura_pdf');
  static const botonXml = Key('pagos_factura_xml');
  static const botonCorregir = Key('pagos_factura_corregir');
  static const botonAgregarPerfil = Key('pagos_factura_agregar_perfil');

  @override
  ConsumerState<SeccionFactura> createState() => _EstadoSeccionFactura();
}

class _EstadoSeccionFactura extends ConsumerState<SeccionFactura> {
  int? _perfilId;
  bool _facturando = false;
  FormatoFactura? _descargando;
  String? _error;
  String? _errorDescarga;
  TimbradoRechazado? _rechazo;
  int? _perfilRechazado;

  /// El perfil que se toco, el que se eligio al pagar, el predeterminado o el
  /// primero.
  int? _perfilElegido(List<PerfilFiscal> perfiles) {
    final ids = {for (final perfil in perfiles) perfil.id};
    for (final candidato in [_perfilId, widget.pago.perfilFiscalId]) {
      if (candidato != null && ids.contains(candidato)) return candidato;
    }
    for (final perfil in perfiles) {
      if (perfil.predeterminado) return perfil.id;
    }
    return perfiles.isEmpty ? null : perfiles.first.id;
  }

  Future<void> _facturar(int perfilId) async {
    final textos = AppLocalizations.of(context);
    final pagoId = widget.pago.id;
    setState(() {
      _facturando = true;
      _error = null;
      _rechazo = null;
    });
    try {
      await ref
          .read(pagoProvider(pagoId).notifier)
          .facturar(perfilFiscalId: perfilId);
      ref.invalidate(pagosProvider);
    } on TimbradoRechazado catch (rechazo) {
      if (!mounted) return;
      setState(() {
        _rechazo = rechazo;
        _perfilRechazado = perfilId;
      });
    } on FacturaRechazada catch (rechazo) {
      if (!mounted) return;
      setState(() => _error = textoRechazoFactura(textos, rechazo.motivo));
      ref.invalidate(pagoProvider(pagoId));
    } on SinConexion {
      if (!mounted) return;
      setState(() => _error = textos.pagosFacturaSinConexion);
    } on Object {
      if (!mounted) return;
      setState(() => _error = textos.pagosFacturaErrorFacturar);
    } finally {
      if (mounted) setState(() => _facturando = false);
    }
  }

  Future<void> _descargar(Factura factura, FormatoFactura formato) async {
    final textos = AppLocalizations.of(context);
    setState(() {
      _descargando = formato;
      _errorDescarga = null;
    });
    try {
      final archivo = await ref
          .read(repositorioPagosProvider)
          .descargarFactura(factura, formato);
      await ref.read(compartirFacturaProvider)(archivo);
    } on SinConexion {
      if (!mounted) return;
      setState(() => _errorDescarga = textos.pagosFacturaSinConexion);
    } on Object {
      if (!mounted) return;
      setState(() => _errorDescarga = textos.pagosFacturaErrorDescargar);
    } finally {
      if (mounted) setState(() => _descargando = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final pago = widget.pago;
    final factura = pago.factura;
    final Widget? hijo;
    if (factura != null) {
      hijo = _timbrada(context, factura);
    } else if (pago.facturable) {
      hijo = _porFacturar(context);
    } else if (pago.medio == MedioPago.caja &&
        pago.estado == EstadoPago.pagado) {
      hijo = Aviso(
        mensaje: textos.pagosFacturaEnLaAgencia,
        tono: Tono.informacion,
      );
    } else {
      hijo = _error == null
          ? null
          : Aviso(mensaje: _error!, tono: Tono.peligro);
    }
    if (hijo == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: Espaciado.e4),
      child: SeccionPantalla(titulo: textos.pagosFactura, hijo: hijo),
    );
  }

  Widget _timbrada(BuildContext context, Factura factura) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final errorDescarga = _errorDescarga;
    final descargando = _descargando;

    Widget descarga(FormatoFactura formato) => BotonPildora(
      key: formato == FormatoFactura.pdf
          ? SeccionFactura.botonPdf
          : SeccionFactura.botonXml,
      texto: formato == FormatoFactura.pdf
          ? textos.pagosFacturaPdf
          : textos.pagosFacturaXml,
      icono: formato == FormatoFactura.pdf
          ? LucideIcons300.fileText
          : LucideIcons300.download,
      variante: VarianteBotonPildora.tonal,
      expandido: true,
      cargando: descargando == formato,
      alPresionar: descargando == null
          ? () => _descargar(factura, formato)
          : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Insignia(
            texto: textos.pagosFacturaTimbrada,
            tono: Tono.exito,
            conIcono: true,
          ),
        ),
        const SizedBox(height: Espaciado.e3),
        GrupoLista(
          filas: [
            FilaGrupo(
              titulo: textos.pagosFacturaFolio(factura.folio),
              subtitulo: fechaPago(context, factura.timbradaEn),
              icono: LucideIcons300.receiptText,
              colorIcono: c.acento,
            ),
            FilaGrupo(
              titulo: factura.uuid,
              subtitulo: textos.pagosFacturaFolioFiscal,
              icono: LucideIcons300.hash,
              colorIcono: c.textoSecundario,
            ),
            FilaGrupo(
              titulo: textos.pagosPerfilFiscal(
                factura.rfcReceptor,
                factura.razonSocialReceptor,
              ),
              subtitulo: textos.pagosFacturaReceptor(factura.usoCfdi),
              icono: LucideIcons300.badgeCheck,
              colorIcono: c.marca,
            ),
          ],
        ),
        const SizedBox(height: Espaciado.e3),
        Aviso(mensaje: textos.pagosFacturaSimulada, tono: Tono.informacion),
        if (errorDescarga != null) ...[
          const SizedBox(height: Espaciado.e3),
          Aviso(mensaje: errorDescarga, tono: Tono.peligro),
        ],
        const SizedBox(height: Espaciado.e4),
        descarga(FormatoFactura.pdf),
        const SizedBox(height: Espaciado.e3),
        descarga(FormatoFactura.xml),
      ],
    );
  }

  Widget _porFacturar(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return ref
        .watch(perfilesFiscalesProvider)
        .when(
          skipLoadingOnReload: true,
          loading: () => EsqueletoPagos(
            altos: const [56, 48],
            etiqueta: textos.pagosCargando,
          ),
          error: (error, _) => Aviso(
            mensaje: error is SinConexion
                ? textos.pagosFacturaSinConexion
                : textos.pagosFacturaErrorFacturar,
            tono: Tono.peligro,
          ),
          data: (perfiles) => perfiles.isEmpty
              ? _sinPerfiles(context)
              : _elegirPerfil(context, perfiles),
        );
  }

  Widget _sinPerfiles(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Aviso(mensaje: textos.pagosFacturaSinPerfiles, tono: Tono.informacion),
        const SizedBox(height: Espaciado.e4),
        BotonPildora(
          key: SeccionFactura.botonAgregarPerfil,
          texto: textos.pagosAgregarDatosFiscales,
          icono: LucideIcons300.plus,
          variante: VarianteBotonPildora.tonal,
          expandido: true,
          alPresionar: () => context.push(rutaPerfilFiscalNuevo),
        ),
      ],
    );
  }

  Widget _elegirPerfil(BuildContext context, List<PerfilFiscal> perfiles) {
    final textos = AppLocalizations.of(context);
    final elegido = _perfilElegido(perfiles);
    final rechazo = _rechazo;
    final perfilRechazado = _perfilRechazado;
    final error = _error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Selector<int>(
          key: ValueKey(('factura-perfil', elegido)),
          etiqueta: textos.pagosDatosFiscales,
          ayuda: textos.pagosFacturarAyuda,
          opciones: [
            for (final perfil in perfiles)
              OpcionSelector(
                valor: perfil.id,
                texto: textos.pagosPerfilFiscal(perfil.rfc, perfil.razonSocial),
              ),
          ],
          valor: elegido,
          alCambiar: _facturando
              ? null
              : (valor) => setState(() {
                  _perfilId = valor;
                  _rechazo = null;
                  _error = null;
                }),
        ),
        if (rechazo != null) ...[
          const SizedBox(height: Espaciado.e3),
          Aviso(
            titulo: textos.pagosTimbradoRechazado,
            mensaje: textosTimbradoRechazado(textos, rechazo.campos).join('\n'),
            tono: Tono.peligro,
          ),
          if (perfilRechazado != null) ...[
            const SizedBox(height: Espaciado.e3),
            BotonPildora(
              key: SeccionFactura.botonCorregir,
              texto: textos.pagosCorregirDatosFiscales,
              icono: LucideIcons300.pencil,
              variante: VarianteBotonPildora.tonal,
              expandido: true,
              alPresionar: () =>
                  context.push(rutaPerfilFiscal(perfilRechazado)),
            ),
          ],
        ],
        if (error != null) ...[
          const SizedBox(height: Espaciado.e3),
          Aviso(mensaje: error, tono: Tono.peligro),
        ],
        const SizedBox(height: Espaciado.e4),
        BotonPildora(
          key: SeccionFactura.botonFacturar,
          texto: textos.pagosFacturar,
          icono: LucideIcons300.receiptText,
          expandido: true,
          cargando: _facturando,
          alPresionar: elegido == null || _facturando
              ? null
              : () => _facturar(elegido),
        ),
      ],
    );
  }
}
