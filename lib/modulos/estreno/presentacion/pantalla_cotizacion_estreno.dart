import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/chip_pista.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/tarjeta_metrica.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../catalogo/catalogo.dart';
import '../dominio/estreno.dart';
import 'componentes_estreno.dart';
import 'proveedores_estreno.dart';
import 'rutas_estreno.dart';

/// Cotizacion (V2-M16.02): enganche y plazo; la mensualidad la calcula el
/// backend y se muestra con su leyenda no vinculante. Se puede adjuntar una
/// estimacion de toma a cuenta (V2-M16.03) y mandarla a un asesor.
class PantallaCotizacionEstreno extends ConsumerStatefulWidget {
  const PantallaCotizacionEstreno({required this.modeloId, super.key});

  final int modeloId;

  @override
  ConsumerState<PantallaCotizacionEstreno> createState() =>
      _PantallaCotizacionEstrenoState();
}

class _PantallaCotizacionEstrenoState
    extends ConsumerState<PantallaCotizacionEstreno> {
  static const _espera = Duration(milliseconds: 400);

  final _enganche = TextEditingController();
  int _plazo = 48;
  int? _estimacion;
  MensualidadEstimada? _calculo;
  FalloEstreno? _falloCalculo;
  bool _calculando = false;

  /// Numero del ultimo calculo pedido: solo su respuesta se muestra.
  int _pedido = 0;
  FalloEstreno? _falloEnvio;
  bool _enviando = false;
  SolicitudDeEstreno? _solicitud;
  Timer? _demora;
  bool _inicializado = false;

  @override
  void dispose() {
    _demora?.cancel();
    _enganche.dispose();
    super.dispose();
  }

  double? get _engancheCapturado =>
      double.tryParse(_enganche.text.replaceAll(RegExp(r'[^0-9.]'), ''));

  void _programarCalculo() {
    _demora?.cancel();
    // Lo que se mostraba deja de valer apenas cambia el enganche, y una
    // respuesta que ya venia en camino tampoco debe pintarse.
    _pedido++;
    setState(() {
      _calculo = null;
      _falloCalculo = null;
      _calculando = true;
    });
    _demora = Timer(_espera, _calcular);
  }

  Future<void> _calcular() async {
    if (!mounted) return;
    final enganche = _engancheCapturado;
    if (enganche == null) {
      setState(() => _calculando = false);
      return;
    }
    final pedido = ++_pedido;
    setState(() {
      _calculo = null;
      _falloCalculo = null;
      _calculando = true;
    });
    try {
      final c = await ref
          .read(repositorioEstrenoProvider)
          .calcular(
            modeloId: widget.modeloId,
            enganche: enganche,
            plazoMeses: _plazo,
          );
      // Una respuesta que llega tarde no pisa a la del ultimo cambio.
      if (!mounted || pedido != _pedido) return;
      setState(() {
        _calculo = c;
        _calculando = false;
      });
    } on FalloEstreno catch (fallo) {
      if (!mounted || pedido != _pedido) return;
      setState(() {
        _falloCalculo = fallo;
        _calculando = false;
      });
    }
  }

  Future<void> _enviar() async {
    final enganche = _engancheCapturado;
    if (enganche == null) return;
    setState(() {
      _enviando = true;
      _falloEnvio = null;
    });
    try {
      final solicitud = await ref
          .read(repositorioEstrenoProvider)
          .pedirCotizacion(
            modeloId: widget.modeloId,
            enganche: enganche,
            plazoMeses: _plazo,
            estimacionId: _estimacion,
          );
      ref.invalidate(misSolicitudesProvider);
      if (mounted) setState(() => _solicitud = solicitud);
    } on FalloEstreno catch (fallo) {
      if (mounted) setState(() => _falloEnvio = fallo);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final detalle = ref.watch(detalleModeloProvider(widget.modeloId));
    final precio = detalle.value?.modelo.precioDesde;
    if (!_inicializado && precio != null) {
      _inicializado = true;
      // Arranca con el enganche minimo sugerido y calcula de una vez.
      _enganche.text = (precio * engancheMinimoPct).ceil().toString();
      WidgetsBinding.instance.addPostFrameCallback((_) => _calcular());
    }

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(title: Text(textos.estrenoCotizacionTitulo)),
      body: SafeArea(
        child: detalle.when(
          skipLoadingOnReload: true,
          loading: () => Semantics(
            label: textos.catalogoDetalleCargando,
            liveRegion: true,
            child: const Padding(
              padding: EdgeInsets.all(Espaciado.e4),
              child: Column(
                children: [
                  Esqueleto(alto: 56),
                  SizedBox(height: Espaciado.e3),
                  Esqueleto(alto: 56),
                ],
              ),
            ),
          ),
          error: (error, _) => error is NoEncontrado
              ? EstadoVacio(
                  titulo: textos.catalogoNoEncontradoTitulo,
                  mensaje: textos.catalogoNoEncontradoMensaje,
                  icono: Icons.directions_car_outlined,
                )
              : EstadoError(
                  causa: error is SinConexion
                      ? CausaError.sinConexion
                      : CausaError.generico,
                  alReintentar: () =>
                      ref.invalidate(detalleModeloProvider(widget.modeloId)),
                ),
          data: (d) => _formulario(context, textos, d.modelo),
        ),
      ),
    );
  }

  Widget _formulario(
    BuildContext context,
    AppLocalizations textos,
    ModeloVigente modelo,
  ) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final precio = modelo.precioDesde;
    final calculo = _calculo;

    return ListView(
      padding: const EdgeInsets.all(Espaciado.e4),
      children: [
        Text(
          modelo.titulo,
          style: tokens.tipografia.titulo2.copyWith(color: c.texto),
        ),
        if (precio != null)
          Text(
            textos.estrenoPrecioDesde(pesosEstreno.format(precio)),
            style: tokens.tipografia.cuerpo.copyWith(color: c.textoSecundario),
          ),
        if (precio == null) ...[
          const SizedBox(height: Espaciado.e4),
          Aviso(mensaje: textos.estrenoSinPrecio, tono: Tono.informacion),
        ] else if (_solicitud case final solicitud?) ...[
          const SizedBox(height: Espaciado.e4),
          ConfirmacionEstreno(
            solicitud: solicitud,
            alVerSolicitudes: () =>
                context.pushReplacement(rutaMisSolicitudesEstreno),
          ),
        ] else ...[
          // Sin titulo de seccion: el campo ya se llama «Enganche».
          Padding(
            padding: const EdgeInsets.only(top: Espaciado.e5),
            child: CampoTexto(
              etiqueta: textos.estrenoEnganche,
              controlador: _enganche,
              teclado: TextInputType.number,
              formatos: [FilteringTextInputFormatter.digitsOnly],
              ayuda: textos.estrenoEngancheAyuda(
                pesosEstreno.format((precio * engancheMinimoPct).ceil()),
              ),
              alCambiar: (_) => _programarCalculo(),
            ),
          ),
          SeccionEstreno(
            titulo: textos.estrenoPlazo,
            hijo: Wrap(
              spacing: Espaciado.e2,
              runSpacing: Espaciado.e1,
              children: [
                for (final meses in plazosPermitidos)
                  ChipPista(
                    texto: textos.estrenoMeses(meses),
                    seleccionado: _plazo == meses,
                    alCambiar: (_) {
                      setState(() => _plazo = meses);
                      _calcular();
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: Espaciado.e5),
          if (calculo != null) ...[
            TarjetaMetrica(
              cifra: pesosEstreno.format(calculo.mensualidad),
              etiqueta: textos.estrenoMensualidad,
              detalle: textos.estrenoMeses(calculo.plazoMeses),
            ),
            const SizedBox(height: Espaciado.e2),
            Aviso(mensaje: calculo.leyenda, tono: Tono.informacion),
          ] else if (_calculando)
            Semantics(
              liveRegion: true,
              child: Column(
                children: [
                  const Esqueleto(alto: 96),
                  const SizedBox(height: Espaciado.e2),
                  Text(
                    textos.estrenoCalculando,
                    style: tokens.tipografia.cuerpo.copyWith(
                      color: c.textoSecundario,
                    ),
                  ),
                ],
              ),
            )
          else if (_falloCalculo != null)
            Aviso(
              mensaje: textoDeFalloEstreno(textos, _falloCalculo!),
              tono: Tono.advertencia,
            ),
          SelectorEstimacion(
            elegida: _estimacion,
            alElegir: (id) => setState(() => _estimacion = id),
          ),
          if (_falloEnvio != null) ...[
            const SizedBox(height: Espaciado.e4),
            Aviso(
              mensaje: textoDeFalloEstreno(textos, _falloEnvio!),
              tono: _falloEnvio is EstrenoDuplicada
                  ? Tono.informacion
                  : Tono.peligro,
            ),
          ],
          const SizedBox(height: Espaciado.e5),
          BotonPildora(
            texto: _enviando
                ? textos.estrenoEnviando
                : textos.estrenoEnviarCotizacion,
            expandido: true,
            alPresionar: _enviando || calculo == null ? null : _enviar,
          ),
          AccesoMisSolicitudes(
            alToque: () => context.push(rutaMisSolicitudesEstreno),
          ),
        ],
      ],
    );
  }
}
