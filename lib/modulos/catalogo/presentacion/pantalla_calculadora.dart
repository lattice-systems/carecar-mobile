import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/selector.dart';
import '../../../nucleo/diseno/componentes/tarjeta_metrica.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/toma_a_cuenta.dart';
import 'proveedores_catalogo.dart';

/// Calculadora de toma a cuenta (V2-M03.04).
///
/// El cliente elige uno de sus vehiculos (con el kilometraje ya puesto) o
/// captura marca, modelo y anio, ajusta kilometraje y estado, y ve el rango
/// minimo a maximo. **La leyenda de estimacion no vinculante esta siempre
/// visible**, antes y despues del resultado. La formula vive en el backend: la
/// app solo pide y muestra.
///
/// Con `modeloId` la estimacion se hace contra ese modelo nuevo, que viaja al
/// backend y queda guardado con ella.
class PantallaCalculadora extends ConsumerStatefulWidget {
  const PantallaCalculadora({super.key, this.modeloId});

  final int? modeloId;

  @override
  ConsumerState<PantallaCalculadora> createState() =>
      _EstadoPantallaCalculadora();
}

/// Lo que se le dice al cliente cuando no hubo resultado.
enum _Falla { sinParametros, datos, sinConexion, noEncontrado, generico }

/// Valor del selector para "otro auto": ningun id de vehiculo es 0.
const _otroAuto = 0;

final _pesos = NumberFormat.currency(
  locale: 'es_MX',
  symbol: r'$',
  decimalDigits: 0,
);
final _miles = NumberFormat.decimalPattern('es_MX');

class _EstadoPantallaCalculadora extends ConsumerState<PantallaCalculadora> {
  final _marca = TextEditingController();
  final _modelo = TextEditingController();
  final _anio = TextEditingController();
  final _km = TextEditingController();
  final _scroll = ScrollController();

  int? _vehiculoId;
  EstadoAuto _estado = EstadoAuto.bueno;
  bool _intentado = false;
  bool _calculando = false;
  Estimacion? _estimacion;
  _Falla? _falla;

  int get _anioMaximo => DateTime.now().year + 1;

  @override
  void initState() {
    super.initState();
    // Con vehiculos en el garaje se parte del primero, ya con su kilometraje.
    ref.read(garajeProvider.future).then<void>((lista) {
      if (!mounted || _vehiculoId != null) return;
      _elegirVehiculo(lista.isEmpty ? _otroAuto : lista.first.id, lista);
    }, onError: (Object _) {});
  }

  @override
  void dispose() {
    _marca.dispose();
    _modelo.dispose();
    _anio.dispose();
    _km.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _elegirVehiculo(int id, List<VehiculoGaraje> garaje) {
    setState(() {
      _vehiculoId = id;
      _estimacion = null;
      _falla = null;
      final km = garaje.where((v) => v.id == id).firstOrNull?.kilometraje;
      if (km != null) _km.text = _miles.format(km);
    });
  }

  String? _errorMarca(AppLocalizations t) =>
      _intentado && _marca.text.trim().isEmpty ? t.calculadoraErrorMarca : null;

  String? _errorModelo(AppLocalizations t) =>
      _intentado && _modelo.text.trim().isEmpty
      ? t.calculadoraErrorModelo
      : null;

  String? _errorAnio(AppLocalizations t) =>
      _intentado && leerAnio(_anio.text, maximo: _anioMaximo) == null
      ? t.calculadoraErrorAnio(_anioMaximo)
      : null;

  String? _errorKm(AppLocalizations t) =>
      _intentado && leerKilometraje(_km.text) == null
      ? t.calculadoraErrorKm
      : null;

  Future<void> _calcular() async {
    setState(() => _intentado = true);
    final km = leerKilometraje(_km.text);
    final id = _vehiculoId;
    if (km == null || id == null) return;

    final SolicitudEstimacion solicitud;
    if (id == _otroAuto) {
      final anio = leerAnio(_anio.text, maximo: _anioMaximo);
      if (_marca.text.trim().isEmpty ||
          _modelo.text.trim().isEmpty ||
          anio == null) {
        return;
      }
      solicitud = SolicitudCapturada(
        marca: _marca.text,
        modelo: _modelo.text,
        anio: anio,
        km: km,
        estado: _estado,
        modeloDestinoId: widget.modeloId,
      );
    } else {
      solicitud = SolicitudDeVehiculo(
        vehiculoId: id,
        km: km,
        estado: _estado,
        modeloDestinoId: widget.modeloId,
      );
    }

    setState(() {
      _calculando = true;
      _falla = null;
    });
    try {
      final resultado = await ref
          .read(repositorioTomaACuentaProvider)
          .estimar(solicitud);
      if (!mounted) return;
      setState(() {
        _estimacion = resultado;
        _calculando = false;
      });
      // El resultado va arriba: se regresa para que se vea sin buscarlo.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.jumpTo(0);
      });
    } on ExcepcionApi catch (e) {
      if (!mounted) return;
      setState(() {
        _calculando = false;
        _estimacion = null;
        _falla = switch (e) {
          SinParametrosDeValuacion() => _Falla.sinParametros,
          DatosInvalidos() => _Falla.datos,
          SinConexion() => _Falla.sinConexion,
          NoEncontrado() => _Falla.noEncontrado,
          _ => _Falla.generico,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final garaje = ref.watch(garajeProvider);
    final destino = widget.modeloId == null
        ? null
        : ref
              .watch(detalleModeloProvider(widget.modeloId!))
              .asData
              ?.value
              .modelo
              .titulo;
    final tokens = TokensPista.de(context);
    // `value` conserva la lista anterior mientras se recarga, asi el selector
    // no pierde el auto elegido.
    final vehiculos = garaje.value ?? const <VehiculoGaraje>[];
    final elegido =
        _vehiculoId == _otroAuto || vehiculos.any((v) => v.id == _vehiculoId)
        ? _vehiculoId!
        : _otroAuto;
    final cargandoAutos = garaje.isLoading && _vehiculoId == null;
    final capturando = _vehiculoId == _otroAuto;

    return Scaffold(
      appBar: AppBar(title: Text(t.calculadoraTitulo)),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.all(Espaciado.e4),
        children: [
          // Siempre visible: antes, durante y despues del resultado.
          Aviso(mensaje: t.calculadoraLeyenda),
          if (_estimacion != null) ...[
            const SizedBox(height: Espaciado.e4),
            _Resultado(estimacion: _estimacion!),
          ],
          if (_falla != null) ...[
            const SizedBox(height: Espaciado.e4),
            _AvisoDeFalla(falla: _falla!),
          ],
          if (destino != null) ...[
            const SizedBox(height: Espaciado.e4),
            Text(
              t.calculadoraContra(destino),
              style: tokens.tipografia.cuerpoFuerte.copyWith(
                color: tokens.colores.texto,
              ),
            ),
          ],
          const SizedBox(height: Espaciado.e4),
          if (cargandoAutos)
            Semantics(
              label: t.calculadoraCargandoAutos,
              liveRegion: true,
              child: const Esqueleto(alto: 56),
            )
          else
            Selector<int>(
              etiqueta: t.calculadoraAuto,
              valor: _vehiculoId == null ? _otroAuto : elegido,
              opciones: [
                for (final v in vehiculos)
                  OpcionSelector(valor: v.id, texto: v.titulo),
                OpcionSelector(valor: _otroAuto, texto: t.calculadoraOtroAuto),
              ],
              alCambiar: _calculando
                  ? null
                  : (id) => _elegirVehiculo(id ?? _otroAuto, vehiculos),
            ),
          if (capturando) ...[
            const SizedBox(height: Espaciado.e3),
            CampoTexto(
              etiqueta: t.calculadoraMarca,
              controlador: _marca,
              error: _errorMarca(t),
              alCambiar: (_) => setState(() {}),
              accionTeclado: TextInputAction.next,
              habilitado: !_calculando,
            ),
            const SizedBox(height: Espaciado.e3),
            CampoTexto(
              etiqueta: t.calculadoraModelo,
              controlador: _modelo,
              error: _errorModelo(t),
              alCambiar: (_) => setState(() {}),
              accionTeclado: TextInputAction.next,
              habilitado: !_calculando,
            ),
            const SizedBox(height: Espaciado.e3),
            CampoTexto(
              etiqueta: t.calculadoraAnio,
              controlador: _anio,
              error: _errorAnio(t),
              alCambiar: (_) => setState(() {}),
              teclado: TextInputType.number,
              accionTeclado: TextInputAction.next,
              formatos: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              habilitado: !_calculando,
            ),
          ],
          const SizedBox(height: Espaciado.e3),
          CampoTexto(
            etiqueta: t.calculadoraKm,
            controlador: _km,
            ayuda: t.calculadoraKmAyuda,
            error: _errorKm(t),
            alCambiar: (_) => setState(() {}),
            teclado: TextInputType.number,
            formatos: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,. ]'))],
            habilitado: !_calculando,
          ),
          const SizedBox(height: Espaciado.e3),
          Selector<EstadoAuto>(
            etiqueta: t.calculadoraEstado,
            valor: _estado,
            opciones: [
              for (final e in EstadoAuto.values)
                OpcionSelector(valor: e, texto: _textoDeEstado(t, e)),
            ],
            alCambiar: _calculando
                ? null
                : (e) => setState(() {
                    _estado = e ?? _estado;
                    _estimacion = null;
                  }),
          ),
          const SizedBox(height: Espaciado.e5),
          Boton(
            texto: t.calculadoraCalcular,
            anchoCompleto: true,
            cargando: _calculando,
            alPresionar: cargandoAutos || _vehiculoId == null
                ? null
                : _calcular,
          ),
        ],
      ),
    );
  }
}

String _textoDeEstado(AppLocalizations t, EstadoAuto e) => switch (e) {
  EstadoAuto.excelente => t.calculadoraEstadoExcelente,
  EstadoAuto.bueno => t.calculadoraEstadoBueno,
  EstadoAuto.regular => t.calculadoraEstadoRegular,
  EstadoAuto.malo => t.calculadoraEstadoMalo,
};

class _Resultado extends StatelessWidget {
  const _Resultado({required this.estimacion});

  final Estimacion estimacion;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final e = estimacion;
    final minimo = _pesos.format(e.minimo);
    final maximo = _pesos.format(e.maximo);

    return Semantics(
      container: true,
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TarjetaMetrica(
            etiqueta: t.calculadoraResultadoTitulo,
            cifra: t.calculadoraRango(minimo, maximo),
            tono: Tono.informacion,
            detalle: e.titulo,
          ),
          const SizedBox(height: Espaciado.e2),
          Text(
            t.calculadoraSupuestos(
              e.edadAnios,
              _miles.format(e.kmEsperado),
              e.margenPorcentaje,
            ),
            style: tokens.tipografia.cuerpoChico.copyWith(
              color: tokens.colores.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvisoDeFalla extends StatelessWidget {
  const _AvisoDeFalla({required this.falla});

  final _Falla falla;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return switch (falla) {
      _Falla.sinParametros => Aviso(
        titulo: t.calculadoraSinParametrosTitulo,
        mensaje: t.calculadoraSinParametrosMensaje,
        tono: Tono.advertencia,
      ),
      _Falla.datos => Aviso(
        mensaje: t.calculadoraErrorDatos,
        tono: Tono.peligro,
      ),
      _Falla.sinConexion => Aviso(
        mensaje: t.calculadoraErrorSinConexion,
        tono: Tono.peligro,
      ),
      _Falla.noEncontrado => Aviso(
        mensaje: t.calculadoraErrorNoEncontrado,
        tono: Tono.peligro,
      ),
      _Falla.generico => Aviso(
        mensaje: t.calculadoraErrorGenerico,
        tono: Tono.peligro,
      ),
    };
  }
}
