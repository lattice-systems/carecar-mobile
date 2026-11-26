import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/control_binario.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/fila_acciones.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/resultado_pantalla.dart';
import '../../../nucleo/diseno/componentes/selector.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/datos_fiscales.dart';
import '../dominio/pagos.dart';
import '../dominio/tarjetas.dart';
import 'confirmar_con_el_banco.dart';
import 'esqueleto_pagos.dart';
import 'formato_pagos.dart';
import 'proveedores_datos_fiscales.dart';
import 'proveedores_pagos.dart';
import 'rutas_pagos.dart';

/// Pagar una orden desde la app (V2-M08.02 y V2-M08.04), con el procesador
/// simulado (ADR 0009): el desglose del ticket, con que se paga (una tarjeta
/// guardada o una de las tarjetas de prueba, que se revisa en el telefono y
/// solo sale como token), los datos fiscales para la factura y «Pagar». Si el
/// banco simulado pide confirmar, abre su pantalla. Termina en un resultado:
/// pagada, o no se pudo con su motivo y la opcion de intentar otra vez con una
/// llave nueva. Una orden ya pagada o que aun no se puede pagar lo dice.
class PantallaPagarOrden extends ConsumerWidget {
  const PantallaPagarOrden({required this.ordenId, super.key});

  final int ordenId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final titulo = textos.pagosPagarTitulo;
    Widget estado(Widget hijo) =>
        MarcoPantalla.estado(titulo: titulo, conRegreso: true, estado: hijo);

    return ref
        .watch(ordenPorPagarProvider(ordenId))
        .when(
          skipLoadingOnReload: true,
          loading: () => estado(
            EsqueletoPagos(
              altos: const [56, 220, 160],
              etiqueta: textos.pagosCargando,
            ),
          ),
          error: (error, _) => estado(
            EstadoError(
              causa: error is SinConexion
                  ? CausaError.sinConexion
                  : CausaError.generico,
              textoReintentar: textos.pagosReintentar,
              alReintentar: () =>
                  ref.invalidate(ordenPorPagarProvider(ordenId)),
            ),
          ),
          data: (orden) {
            final pagado = orden.pago;
            if (pagado != null && pagado.estado == EstadoPago.pagado) {
              return estado(
                EstadoVacio(
                  titulo: textos.pagosYaPagadaTitulo,
                  mensaje: textos.pagosYaPagadaMensaje(
                    textoMedio(textos, pagado),
                    fechaPago(context, pagado.pagadoEn ?? pagado.creadoEn),
                  ),
                  icono: LucideIcons300.circleCheckBig,
                  textoAccion: textos.pagosVerPago,
                  alAccion: () => context.pushReplacement(rutaPago(pagado.id)),
                ),
              );
            }
            if (!orden.pagable) {
              return estado(
                EstadoVacio(
                  titulo: textos.pagosNoPagableTitulo,
                  mensaje: textos.pagosNoPagableMensaje,
                  icono: LucideIcons300.clock,
                ),
              );
            }
            return FormularioPago(
              key: ValueKey(('pagar', orden.ordenId)),
              orden: orden,
            );
          },
        );
  }
}

/// Por que no se pudo seguir: lo que se explica en un aviso arriba.
enum _Aviso { revisa, sinConexion, error, rechazo }

/// Valor del selector para pagar con una tarjeta nueva.
const _otraTarjeta = -1;

/// Valor del selector de factura para no facturar.
const _sinFactura = 0;

/// El formulario con la orden ya cargada.
class FormularioPago extends ConsumerStatefulWidget {
  const FormularioPago({required this.orden, super.key});

  final OrdenPorPagar orden;

  static const botonPagar = Key('pagos_pagar');
  static const campoNumero = Key('pagos_numero');
  static const campoVencimiento = Key('pagos_vencimiento');
  static const campoCvv = Key('pagos_cvv');

  @override
  ConsumerState<FormularioPago> createState() => _EstadoFormularioPago();
}

class _EstadoFormularioPago extends ConsumerState<FormularioPago> {
  final _numero = TextEditingController();
  final _vencimiento = TextEditingController();
  final _cvv = TextEditingController();
  String _llave = _llaveNueva();
  int? _elegida;
  int? _perfilFiscalId;
  bool _eligioFactura = false;
  bool _guardar = false;
  bool _intentado = false;
  bool _pagando = false;
  _Aviso? _aviso;
  MotivoRechazoPago? _rechazo;
  Pago? _resultado;

  @override
  void dispose() {
    for (final c in [_numero, _vencimiento, _cvv]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _llaveNueva() {
    final azar = Random.secure();
    const letras = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return [for (var i = 0; i < 24; i++) letras[azar.nextInt(letras.length)]]
        .join();
  }

  BorradorTarjeta get _borrador => BorradorTarjeta(
    numero: _numero.text,
    vencimiento: _vencimiento.text,
    cvv: _cvv.text,
    guardar: _guardar,
  );

  /// La tarjeta elegida: la que se toco, la predeterminada vigente o una
  /// nueva.
  int _tarjetaElegida(List<MetodoPago> metodos) {
    final elegida = _elegida;
    if (elegida != null) return elegida;
    for (final metodo in metodos) {
      if (metodo.predeterminado && !metodo.vencida) return metodo.id;
    }
    return _otraTarjeta;
  }

  /// Los datos fiscales elegidos: los que se tocaron o el predeterminado.
  int _facturaElegida(List<PerfilFiscal> perfiles) {
    if (_eligioFactura) return _perfilFiscalId ?? _sinFactura;
    for (final perfil in perfiles) {
      if (perfil.predeterminado) return perfil.id;
    }
    return _sinFactura;
  }

  Future<void> _pagar(
    List<MetodoPago> metodos,
    List<PerfilFiscal> perfiles,
  ) async {
    final textos = AppLocalizations.of(context);
    setState(() => _intentado = true);
    final elegida = _tarjetaElegida(metodos);
    final MedioElegido medio;
    String tarjeta;
    if (elegida == _otraTarjeta) {
      try {
        final nueva = ref
            .read(pasarelaPagoProvider)
            .tokenizar(_borrador, ref.read(hoyPagosProvider)());
        medio = nueva;
        final deprueba = _borrador.tarjeta!;
        tarjeta = textos.pagosMedioTarjeta(
          textoMarca(deprueba.marca),
          deprueba.ultimos4,
        );
      } on TarjetaInvalida {
        setState(() => _aviso = _Aviso.revisa);
        return;
      }
    } else {
      medio = TarjetaGuardada(elegida);
      tarjeta = textoTarjetaGuardada(
        textos,
        metodos.firstWhere((m) => m.id == elegida),
      );
    }
    final factura = _facturaElegida(perfiles);
    setState(() {
      _pagando = true;
      _aviso = null;
      _rechazo = null;
    });
    final repositorio = ref.read(repositorioPagosProvider);
    final orden = widget.orden;
    try {
      var pago = await repositorio.pagar(
        orden.ordenId,
        llave: _llave,
        medio: medio,
        perfilFiscalId: factura == _sinFactura ? null : factura,
      );
      if (pago.requiereAutenticacion) {
        if (!mounted) return;
        final confirmada = await confirmarConElBanco(
          context,
          monto: pesos(context, orden.total),
          tarjeta: tarjeta,
        );
        if (!mounted) return;
        pago = await repositorio.autenticar(pago.id, confirmada: confirmada);
      }
      if (!mounted) return;
      if (pago.estado == EstadoPago.pagado) {
        ref.invalidate(metodosPagoProvider);
      }
      setState(() => _resultado = pago);
    } on PagoRechazado catch (rechazo) {
      if (!mounted) return;
      setState(() {
        _aviso = _Aviso.rechazo;
        _rechazo = rechazo.motivo;
      });
    } on SinConexion {
      if (!mounted) return;
      setState(() => _aviso = _Aviso.sinConexion);
    } on Object {
      if (!mounted) return;
      setState(() => _aviso = _Aviso.error);
    } finally {
      if (mounted) setState(() => _pagando = false);
    }
  }

  void _otraVez() {
    setState(() {
      _resultado = null;
      _llave = _llaveNueva();
      _cvv.clear();
      _intentado = false;
    });
  }

  void _usarTarjetaDePrueba(TarjetaDePrueba tarjeta) {
    setState(() {
      _numero.text = ReglasTarjeta.agrupar(tarjeta.numero);
      _aviso = null;
    });
  }

  String? _avisoTexto(AppLocalizations textos) => switch (_aviso) {
    _Aviso.revisa => textos.pagosRevisaTarjeta,
    _Aviso.sinConexion => textos.pagosSinConexion,
    _Aviso.error => textos.pagosErrorPagar,
    _Aviso.rechazo => textoRechazo(
      textos,
      _rechazo ?? MotivoRechazoPago.ordenNoPagable,
    ),
    null => null,
  };

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final resultado = _resultado;
    if (resultado != null) return _cierre(context, resultado);

    final orden = widget.orden;
    final metodos =
        ref.watch(metodosPagoProvider).value ?? const <MetodoPago>[];
    final perfiles =
        ref.watch(perfilesFiscalesProvider).value ?? const <PerfilFiscal>[];
    final elegida = _tarjetaElegida(metodos);
    final factura = _facturaElegida(perfiles);
    final errores = _intentado
        ? _borrador.errores(ref.read(hoyPagosProvider)())
        : const <CampoTarjeta, MotivoTarjeta>{};
    String? error(CampoTarjeta campo) {
      final motivo = errores[campo];
      return motivo == null ? null : textoMotivoTarjeta(textos, motivo);
    }

    final aviso = _avisoTexto(textos);

    return MarcoPantalla(
      titulo: textos.pagosPagarTitulo,
      subtitulo: textos.pagosOrden('${orden.ordenId}'),
      conRegreso: true,
      barraInferior: BarraInferior(
        hijos: [
          Boton(
            key: FormularioPago.botonPagar,
            texto: textos.pagosPagar(pesos(context, orden.total)),
            anchoCompleto: true,
            cargando: _pagando,
            alPresionar: _pagando ? null : () => _pagar(metodos, perfiles),
          ),
        ],
      ),
      slivers: [
        SliverToBoxAdapter(
          child: AbsorbPointer(
            absorbing: _pagando,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Espaciado.e4,
                    Espaciado.e2,
                    Espaciado.e4,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Aviso(
                        mensaje: textos.pagosSimuladoAviso,
                        tono: Tono.informacion,
                      ),
                      if (aviso != null) ...[
                        const SizedBox(height: Espaciado.e3),
                        Aviso(
                          mensaje: aviso,
                          tono: _aviso == _Aviso.revisa
                              ? Tono.advertencia
                              : Tono.peligro,
                        ),
                      ],
                      const SizedBox(height: Espaciado.e4),
                      _Desglose(orden: orden),
                    ],
                  ),
                ),
                SeccionPantalla(
                  titulo: textos.pagosConQue,
                  hijo: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (metodos.isNotEmpty) ...[
                        Selector<int>(
                          key: ValueKey(('tarjeta', elegida)),
                          etiqueta: textos.pagosTarjeta,
                          opciones: [
                            for (final metodo in metodos)
                              OpcionSelector(
                                valor: metodo.id,
                                texto: metodo.vencida
                                    ? textos.pagosTarjetaVencida(
                                        textoTarjetaGuardada(textos, metodo),
                                      )
                                    : textoTarjetaGuardada(textos, metodo),
                              ),
                            OpcionSelector(
                              valor: _otraTarjeta,
                              texto: textos.pagosOtraTarjeta,
                            ),
                          ],
                          valor: elegida,
                          alCambiar: (valor) => setState(() {
                            _elegida = valor ?? _otraTarjeta;
                            _aviso = null;
                          }),
                        ),
                        const SizedBox(height: Espaciado.e3),
                      ],
                      if (elegida == _otraTarjeta) ...[
                        CampoTexto(
                          key: FormularioPago.campoNumero,
                          etiqueta: textos.pagosNumero,
                          sugerencia: textos.pagosNumeroSugerencia,
                          controlador: _numero,
                          teclado: TextInputType.number,
                          accionTeclado: TextInputAction.next,
                          formatos: const [_FormatoNumero()],
                          pistasAutocompletar: const [
                            AutofillHints.creditCardNumber,
                          ],
                          error: error(CampoTarjeta.numero),
                          alCambiar: (_) => setState(() => _aviso = null),
                        ),
                        const SizedBox(height: Espaciado.e3),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CampoTexto(
                                key: FormularioPago.campoVencimiento,
                                etiqueta: textos.pagosVencimiento,
                                sugerencia: textos.pagosVencimientoSugerencia,
                                controlador: _vencimiento,
                                teclado: TextInputType.number,
                                accionTeclado: TextInputAction.next,
                                formatos: const [_FormatoVencimiento()],
                                pistasAutocompletar: const [
                                  AutofillHints.creditCardExpirationDate,
                                ],
                                error: error(CampoTarjeta.vencimiento),
                                alCambiar: (_) => setState(() => _aviso = null),
                              ),
                            ),
                            const SizedBox(width: Espaciado.e3),
                            Expanded(
                              child: CampoTexto(
                                key: FormularioPago.campoCvv,
                                etiqueta: textos.pagosCvv,
                                controlador: _cvv,
                                teclado: TextInputType.number,
                                accionTeclado: TextInputAction.done,
                                ocultarTexto: true,
                                formatos: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(
                                    ReglasTarjeta.largoCvv,
                                  ),
                                ],
                                pistasAutocompletar: const [
                                  AutofillHints.creditCardSecurityCode,
                                ],
                                error: error(CampoTarjeta.cvv),
                                alCambiar: (_) => setState(() => _aviso = null),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Espaciado.e2),
                        Text(
                          textos.pagosCvvAyuda,
                          style: TokensPista.de(context).tipografia.cuerpoChico
                              .copyWith(
                                color: TokensPista.de(context)
                                    .colores
                                    .textoSecundario,
                              ),
                        ),
                        const SizedBox(height: Espaciado.e3),
                        Casilla(
                          etiqueta: textos.pagosGuardarTarjeta,
                          descripcion: textos.pagosGuardarTarjetaAyuda,
                          valor: _guardar,
                          alCambiar: (valor) =>
                              setState(() => _guardar = valor),
                        ),
                      ],
                    ],
                  ),
                ),
                if (elegida == _otraTarjeta)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Espaciado.e4,
                    ),
                    child: GrupoLista(
                      encabezado: textos.pagosTarjetasDePrueba,
                      pie: textos.pagosTarjetasDePruebaPie,
                      filas: [
                        for (final tarjeta in tarjetasDePrueba)
                          FilaGrupo(
                            llave: ValueKey('prueba-${tarjeta.token}'),
                            titulo: ReglasTarjeta.agrupar(tarjeta.numero),
                            subtitulo: textos.pagosTarjetaDePruebaDetalle(
                              textoMarca(tarjeta.marca),
                              textoEscenario(textos, tarjeta.escenario),
                            ),
                            icono: LucideIcons300.creditCard,
                            alToque: () => _usarTarjetaDePrueba(tarjeta),
                          ),
                      ],
                    ),
                  ),
                if (perfiles.isNotEmpty)
                  SeccionPantalla(
                    titulo: textos.pagosFactura,
                    hijo: Selector<int>(
                      key: ValueKey(('factura', factura)),
                      etiqueta: textos.pagosDatosFiscales,
                      ayuda: textos.pagosFacturaAyuda,
                      opciones: [
                        OpcionSelector(
                          valor: _sinFactura,
                          texto: textos.pagosSinFactura,
                        ),
                        for (final perfil in perfiles)
                          OpcionSelector(
                            valor: perfil.id,
                            texto: textos.pagosPerfilFiscal(
                              perfil.rfc,
                              perfil.razonSocial,
                            ),
                          ),
                      ],
                      valor: factura,
                      alCambiar: (valor) => setState(() {
                        _eligioFactura = true;
                        _perfilFiscalId = valor == _sinFactura ? null : valor;
                      }),
                    ),
                  ),
                const SizedBox(height: Espaciado.e4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cierre(BuildContext context, Pago pago) {
    final textos = AppLocalizations.of(context);
    if (pago.estado == EstadoPago.pagado) {
      return ResultadoPantalla(
        titulo: textos.pagosPagadoTitulo,
        mensaje: textos.pagosPagadoMensaje(
          pesos(context, pago.monto),
          pago.referencia,
        ),
        principal: AccionPantalla(
          texto: textos.pagosListo,
          alPresionar: () => context.pop(),
        ),
        secundaria: AccionPantalla(
          texto: textos.pagosVerMisPagos,
          alPresionar: () => context.pushReplacement(rutaMisPagos),
        ),
      );
    }
    return ResultadoPantalla(
      titulo: textos.pagosFalloTitulo,
      mensaje: textoMotivoFallo(textos, pago.motivoFallo),
      tono: Tono.peligro,
      icono: LucideIcons300.circleX,
      principal: AccionPantalla(
        texto: textos.pagosIntentarOtraVez,
        alPresionar: _otraVez,
      ),
      secundaria: AccionPantalla(
        texto: textos.pagosVolver,
        alPresionar: () => context.pop(),
      ),
    );
  }
}

/// Mano de obra, refacciones, subtotal, IVA y total, como en el ticket.
class _Desglose extends StatelessWidget {
  const _Desglose({required this.orden});

  final OrdenPorPagar orden;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final t = TokensPista.de(context).tipografia;
    FilaGrupo fila(String etiqueta, double valor, {bool fuerte = false}) =>
        FilaGrupo(
          titulo: etiqueta,
          fin: Text(
            pesos(context, valor),
            style: fuerte ? t.titulo3 : t.cuerpo,
          ),
          etiquetaFin: pesos(context, valor),
        );
    return GrupoLista(
      encabezado: textos.pagosDesglose,
      pie: textos.pagosPreciosConIva,
      filas: [
        fila(textos.pagosManoDeObra, orden.totalManoDeObra),
        fila(textos.pagosRefacciones, orden.totalRefacciones),
        fila(textos.pagosSubtotal, orden.subtotal),
        fila(textos.pagosIva, orden.iva),
        fila(textos.pagosTotal, orden.total, fuerte: true),
      ],
    );
  }
}

/// Solo digitos, hasta 16, en grupos de cuatro.
class _FormatoNumero extends TextInputFormatter {
  const _FormatoNumero();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue nuevo,
  ) {
    var digitos = ReglasTarjeta.soloDigitos(nuevo.text);
    if (digitos.length > ReglasTarjeta.largoNumero) {
      digitos = digitos.substring(0, ReglasTarjeta.largoNumero);
    }
    final texto = ReglasTarjeta.agrupar(digitos);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

/// `MM/AA`: solo digitos y la diagonal despues del mes.
class _FormatoVencimiento extends TextInputFormatter {
  const _FormatoVencimiento();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue nuevo,
  ) {
    var digitos = ReglasTarjeta.soloDigitos(nuevo.text);
    if (digitos.length > 4) digitos = digitos.substring(0, 4);
    final borrando = nuevo.text.length < anterior.text.length;
    final texto = digitos.length > 2 || (digitos.length == 2 && !borrando)
        ? '${digitos.substring(0, 2)}/${digitos.substring(2)}'
        : digitos;
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
