import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/hoja_inferior.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/orden_taller.dart';
import '../dominio/repositorio_taller.dart';
import 'formato_taller.dart';
import 'proveedores_taller.dart';
import 'provisional/lienzo_firma_provisional.dart';

/// Trabajos adicionales de la orden (V2-M04.05): la cotizacion de cada uno por
/// concepto (mano de obra, refacciones y total), aprobar o rechazar uno por uno
/// con la firma en pantalla y los totales, que se recalculan con la respuesta
/// del backend. Resuelve esqueleto, datos, vacio, error y sin conexion.
class PantallaAdicionales extends ConsumerStatefulWidget {
  const PantallaAdicionales({required this.ordenId, super.key});

  final int ordenId;

  @override
  ConsumerState<PantallaAdicionales> createState() => _EstadoAdicionales();
}

class _EstadoAdicionales extends ConsumerState<PantallaAdicionales> {
  int? _enviando;
  ({String mensaje, Tono tono})? _aviso;

  Future<void> _responder(TrabajoAdicional adicional, bool aprobado) async {
    final textos = AppLocalizations.of(context);
    final total = monedaTaller(context, adicional.total);
    final firma = await mostrarHojaInferior<_FirmaCapturada>(
      context,
      titulo: aprobado
          ? textos.tallerFirmaAprobarTitulo
          : textos.tallerFirmaRechazarTitulo,
      builder: (_) => _HojaFirma(
        concepto: adicional.concepto,
        total: total,
        aprobado: aprobado,
      ),
    );
    if (firma == null || !mounted) return;
    setState(() {
      _enviando = adicional.id;
      _aviso = null;
    });
    final exportar = ref.read(exportarFirmaProvider);
    final notifier = ref.read(ordenTallerProvider(widget.ordenId).notifier);
    ({String mensaje, Tono tono}) aviso;
    try {
      final Uint8List png = await exportar(firma.trazos, firma.tamano);
      await notifier.responder(
        adicionalId: adicional.id,
        aprobado: aprobado,
        firmaPng: png,
      );
      aviso = aprobado
          ? (
              mensaje: textos.tallerRespuestaAprobada(adicional.concepto),
              tono: Tono.exito,
            )
          : (
              mensaje: textos.tallerRespuestaRechazada(adicional.concepto),
              tono: Tono.informacion,
            );
    } on AdicionalYaRespondido {
      aviso = (
        mensaje: textos.tallerRespuestaYaRespondida,
        tono: Tono.advertencia,
      );
    } on OrdenCerrada {
      aviso = (
        mensaje: textos.tallerRespuestaOrdenCerrada,
        tono: Tono.advertencia,
      );
    } on SinConexion {
      aviso = (mensaje: textos.tallerRespuestaSinConexion, tono: Tono.peligro);
    } on Object {
      aviso = (mensaje: textos.tallerRespuestaError, tono: Tono.peligro);
    }
    if (!mounted) return;
    setState(() {
      _enviando = null;
      _aviso = aviso;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final orden = ref.watch(ordenTallerProvider(widget.ordenId));

    final Widget contenido = orden.when(
      skipLoadingOnReload: true,
      loading: () => const SliverToBoxAdapter(child: _Cargando()),
      error: (error, _) => SliverFillRemaining(
        child: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          textoReintentar: textos.tallerReintentar,
          alReintentar: () =>
              ref.invalidate(ordenTallerProvider(widget.ordenId)),
        ),
      ),
      data: (o) => o.adicionales.isEmpty
          ? SliverFillRemaining(
              child: EstadoVacio(
                titulo: textos.tallerAdicionalesVacio,
                mensaje: textos.tallerAdicionalesVacioMensaje,
                icono: LucideIcons300.hammer,
              ),
            )
          : SliverToBoxAdapter(
              child: _Adicionales(
                orden: o,
                aviso: _aviso,
                enviando: _enviando,
                alResponder: _responder,
              ),
            ),
    );

    return MarcoPantalla(
      icono: LucideIcons300.listPlus,
      titulo: textos.tallerAdicionalesTitulo,
      subtitulo: orden.value?.vehiculo,
      conRegreso: true,
      alRefrescar: () =>
          ref.refresh(ordenTallerProvider(widget.ordenId).future),
      slivers: [contenido],
    );
  }
}

class _Adicionales extends StatelessWidget {
  const _Adicionales({
    required this.orden,
    required this.aviso,
    required this.enviando,
    required this.alResponder,
  });

  final OrdenEnVivo orden;
  final ({String mensaje, Tono tono})? aviso;
  final int? enviando;
  final Future<void> Function(TrabajoAdicional, bool) alResponder;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final t = TokensPista.de(context).tipografia;
    String dinero(double valor) => monedaTaller(context, valor);

    FilaGrupo monto(String etiqueta, double valor, {bool fuerte = false}) =>
        FilaGrupo(
          titulo: etiqueta,
          fin: Text(dinero(valor), style: fuerte ? t.titulo3 : t.cuerpo),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Espaciado.margenTelefono),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (aviso case final aviso?) ...[
            Aviso(mensaje: aviso.mensaje, tono: aviso.tono),
            const SizedBox(height: Espaciado.e4),
          ],
          for (final adicional in orden.adicionales) ...[
            GrupoLista(
              encabezado: adicional.concepto,
              filas: [
                monto(textos.tallerAdicionalManoDeObra, adicional.manoDeObra),
                monto(textos.tallerAdicionalRefacciones, adicional.refacciones),
                monto(
                  textos.tallerAdicionalTotal,
                  adicional.total,
                  fuerte: true,
                ),
              ],
            ),
            const SizedBox(height: Espaciado.e3),
            _Respuesta(
              adicional: adicional,
              enviando: enviando == adicional.id,
              bloqueado: enviando != null,
              alResponder: (aprobado) => alResponder(adicional, aprobado),
            ),
            const SizedBox(height: Espaciado.e6),
          ],
          GrupoLista(
            encabezado: textos.tallerTotales,
            filas: [
              monto(textos.tallerTotalOrden, orden.totalOrden),
              monto(
                textos.tallerTotalAprobados,
                orden.totalAdicionalesAprobados,
              ),
              monto(
                textos.tallerTotalPendientes,
                orden.totalAdicionalesPendientes,
              ),
              monto(
                textos.tallerTotalEstimado,
                orden.totalEstimado,
                fuerte: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Respuesta extends StatelessWidget {
  const _Respuesta({
    required this.adicional,
    required this.enviando,
    required this.bloqueado,
    required this.alResponder,
  });

  final TrabajoAdicional adicional;
  final bool enviando;
  final bool bloqueado;
  final ValueChanged<bool> alResponder;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);

    if (!adicional.pendiente) {
      final aprobado = adicional.estado == EstadoAdicional.aprobado;
      final respondido = adicional.respondidoEn;
      return Wrap(
        spacing: Espaciado.e3,
        runSpacing: Espaciado.e2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Insignia(
            texto: aprobado
                ? textos.tallerAdicionalAprobado
                : textos.tallerAdicionalRechazado,
            tono: aprobado ? Tono.exito : Tono.neutro,
            conIcono: true,
          ),
          if (respondido != null)
            Text(
              textos.tallerAdicionalRespondidoEl(
                horaTaller(context, respondido),
              ),
              style: tokens.tipografia.etiqueta.copyWith(
                color: tokens.colores.textoSecundario,
              ),
            ),
        ],
      );
    }

    return Wrap(
      spacing: Espaciado.e3,
      runSpacing: Espaciado.e2,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Insignia(
          texto: textos.tallerAdicionalPendiente,
          tono: Tono.advertencia,
          conIcono: true,
        ),
        Boton(
          texto: textos.tallerAdicionalRechazar,
          variante: VarianteBoton.secundario,
          alPresionar: bloqueado ? null : () => alResponder(false),
        ),
        Boton(
          texto: textos.tallerAdicionalAprobar,
          cargando: enviando,
          alPresionar: bloqueado ? null : () => alResponder(true),
        ),
      ],
    );
  }
}

class _FirmaCapturada {
  const _FirmaCapturada(this.trazos, this.tamano);

  final List<List<Offset>> trazos;
  final Size tamano;
}

class _HojaFirma extends StatefulWidget {
  const _HojaFirma({
    required this.concepto,
    required this.total,
    required this.aprobado,
  });

  final String concepto;
  final String total;
  final bool aprobado;

  @override
  State<_HojaFirma> createState() => _EstadoHojaFirma();
}

class _EstadoHojaFirma extends State<_HojaFirma> {
  static const _alto = 180.0;

  final _firma = ControladorFirma();
  double _ancho = 0;

  @override
  void dispose() {
    _firma.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          textos.tallerFirmaInstruccion(widget.concepto, widget.total),
          style: tokens.tipografia.cuerpo.copyWith(
            color: tokens.colores.textoSecundario,
          ),
        ),
        const SizedBox(height: Espaciado.e4),
        LayoutBuilder(
          builder: (context, limites) {
            _ancho = limites.maxWidth;
            return LienzoFirmaProvisional(controlador: _firma, alto: _alto);
          },
        ),
        const SizedBox(height: Espaciado.e3),
        ListenableBuilder(
          listenable: _firma,
          builder: (context, _) => Wrap(
            spacing: Espaciado.e3,
            runSpacing: Espaciado.e2,
            alignment: WrapAlignment.end,
            children: [
              Boton(
                texto: textos.tallerFirmaBorrar,
                variante: VarianteBoton.terciario,
                alPresionar: _firma.vacia ? null : _firma.limpiar,
              ),
              Boton(
                texto: widget.aprobado
                    ? textos.tallerFirmaConfirmarAprobar
                    : textos.tallerFirmaConfirmarRechazar,
                variante: widget.aprobado
                    ? VarianteBoton.principal
                    : VarianteBoton.peligro,
                alPresionar: _firma.vacia
                    ? null
                    : () => Navigator.of(context).pop(
                        _FirmaCapturada(_firma.trazos, Size(_ancho, _alto)),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: Espaciado.margenTelefono),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Esqueleto(alto: 180),
        SizedBox(height: Espaciado.e4),
        Esqueleto(alto: 180),
      ],
    ),
  );
}
