import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_circular.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/hoja_inferior.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../valuacion/valuacion.dart';
import '../dominio/toma_a_cuenta.dart';
import 'proveedores_catalogo.dart';
import 'rutas_catalogo.dart';
import 'tarjetas_estimacion.dart';

/// Estimaciones de toma a cuenta que el cliente ya calculo (V2-M03.07).
///
/// Cada una sale guardada del servidor al calcularla, de la mas reciente a la
/// mas antigua, con su fecha y su rango. Tocar una abre el detalle tal como se
/// vio: el rango, los supuestos y la diferencia contra el modelo, sin
/// recalcular, porque la formula vive en el backend y un cambio de parametros
/// no debe reescribir lo que ya se mostro. Resuelve los cinco estados y pide
/// las paginas de a una.
class PantallaMisEstimaciones extends ConsumerStatefulWidget {
  const PantallaMisEstimaciones({super.key});

  @override
  ConsumerState<PantallaMisEstimaciones> createState() =>
      _EstadoPantallaMisEstimaciones();
}

class _EstadoPantallaMisEstimaciones
    extends ConsumerState<PantallaMisEstimaciones> {
  final _estimaciones = <Estimacion>[];
  int _pagina = 0;
  bool _hayMas = false;
  bool _cargandoInicial = true;
  bool _cargandoMas = false;
  bool _falloMas = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  Future<void> _recargar() async {
    setState(() {
      _error = null;
      // Con datos ya en pantalla se recarga sin esqueleto.
      _cargandoInicial = _estimaciones.isEmpty;
    });
    try {
      final pagina = await ref.read(repositorioTomaACuentaProvider).guardadas();
      if (!mounted) return;
      setState(() {
        _estimaciones
          ..clear()
          ..addAll(pagina.estimaciones);
        _pagina = pagina.pagina;
        _hayMas = pagina.hayMas;
        _falloMas = false;
        _cargandoInicial = false;
      });
    } on ExcepcionApi catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _cargandoInicial = false;
      });
    }
  }

  Future<void> _verMas() async {
    setState(() {
      _cargandoMas = true;
      _falloMas = false;
    });
    try {
      final pagina = await ref
          .read(repositorioTomaACuentaProvider)
          .guardadas(pagina: _pagina + 1);
      if (!mounted) return;
      setState(() {
        _estimaciones.addAll(pagina.estimaciones);
        _pagina = pagina.pagina;
        _hayMas = pagina.hayMas;
        _cargandoMas = false;
      });
    } on ExcepcionApi {
      if (!mounted) return;
      setState(() {
        _cargandoMas = false;
        _falloMas = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final acciones = [
      BotonCircular(
        etiqueta: t.valuacionMisTitulo,
        icono: Icons.verified_outlined,
        colorIcono: TokensPista.de(context).colores.texto,
        alPresionar: () => context.push(rutaValuaciones),
      ),
    ];

    Widget estado(Widget hijo) => MarcoPantalla.estado(
      titulo: t.misEstimacionesTitulo,
      conRegreso: true,
      acciones: acciones,
      estado: hijo,
    );

    if (_cargandoInicial) return estado(const _Cargando());
    if (_error != null && _estimaciones.isEmpty) {
      return estado(
        EstadoError(
          causa: _error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: _recargar,
        ),
      );
    }
    if (_estimaciones.isEmpty) {
      return estado(
        EstadoVacio(
          titulo: t.misEstimacionesVacioTitulo,
          mensaje: t.misEstimacionesVacioMensaje,
          icono: Icons.calculate_outlined,
          textoAccion: t.misEstimacionesVacioAccion,
          alAccion: () => context.pushReplacement(rutaCalculadora),
        ),
      );
    }
    return MarcoPantalla(
      titulo: t.misEstimacionesTitulo,
      conRegreso: true,
      acciones: acciones,
      alRefrescar: _recargar,
      slivers: [
        _Lista(
          estimaciones: _estimaciones,
          hayMas: _hayMas,
          cargandoMas: _cargandoMas,
          falloMas: _falloMas,
          alVerMas: _verMas,
        ),
      ],
    );
  }
}

/// Las estimaciones en una lista agrupada, como el resto de las listas de la
/// app, con «Ver más» al final cuando faltan páginas.
class _Lista extends StatelessWidget {
  const _Lista({
    required this.estimaciones,
    required this.hayMas,
    required this.cargandoMas,
    required this.falloMas,
    required this.alVerMas,
  });

  final List<Estimacion> estimaciones;
  final bool hayMas;
  final bool cargandoMas;
  final bool falloMas;
  final VoidCallback alVerMas;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Espaciado.margenTelefono,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GrupoLista(
              filas: [
                for (final e in estimaciones)
                  FilaGrupo(
                    titulo: e.titulo,
                    subtitulo: [
                      t.misEstimacionesFila(
                        e.creadaEn.toLocal(),
                        t.calculadoraRango(
                          formatoPesos.format(e.minimo),
                          formatoPesos.format(e.maximo),
                        ),
                      ),
                      if (e.modeloDestino != null)
                        t.calculadoraContra(e.modeloDestino!),
                    ].join(' · '),
                    icono: Icons.calculate_outlined,
                    colorIcono: c.acento,
                    alToque: () => _abrirDetalle(context, e),
                  ),
              ],
            ),
            if (falloMas) ...[
              const SizedBox(height: Espaciado.e3),
              Aviso(mensaje: t.misEstimacionesErrorMas, tono: Tono.peligro),
            ],
            if (hayMas) ...[
              const SizedBox(height: Espaciado.e3),
              BotonPildora(
                texto: t.misEstimacionesVerMas,
                variante: VarianteBotonPildora.vidrio,
                expandido: true,
                cargando: cargandoMas,
                alPresionar: alVerMas,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void _abrirDetalle(BuildContext context, Estimacion e) {
  final t = AppLocalizations.of(context);
  // Se cierra la hoja y se navega desde la pantalla de abajo.
  void irA(BuildContext hoja, String ruta) {
    Navigator.of(hoja).pop();
    context.push(ruta);
  }

  mostrarHojaInferior<void>(
    context,
    titulo: e.titulo,
    builder: (hoja) {
      final diferencia = diferenciaAPagar(e);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // La leyenda no vinculante tambien acompana a lo guardado.
          Aviso(mensaje: t.calculadoraLeyenda),
          const SizedBox(height: Espaciado.e4),
          ResultadoEstimacion(estimacion: e),
          if (diferencia != null) ...[
            const SizedBox(height: Espaciado.e3),
            DiferenciaEstimacion(
              modelo: e.modeloDestino,
              precio: e.precioDestino!,
              diferencia: diferencia,
            ),
          ],
          const SizedBox(height: Espaciado.e4),
          BotonPedirValuacion(
            estimacionId: e.id,
            alAbrir: (id) => irA(hoja, rutaValuacion(id)),
          ),
          if (e.vehiculoId case final vehiculoId?) ...[
            const SizedBox(height: Espaciado.e2),
            BotonPildora(
              texto: t.valuacionVerValor,
              icono: Icons.show_chart_rounded,
              variante: VarianteBotonPildora.tonal,
              expandido: true,
              alPresionar: () => irA(hoja, rutaValorVehiculo(vehiculoId)),
            ),
          ],
        ],
      );
    },
  );
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).misEstimacionesCargando,
      liveRegion: true,
      child: const Padding(
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 56),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 56),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 56),
          ],
        ),
      ),
    );
  }
}
