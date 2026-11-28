import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tema_pista.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../datos/repositorio_encuestas.dart';
import '../dominio/encuesta.dart';

const _rutaEncuestas = '/encuestas';

final rutasEncuestas = <RouteBase>[
  GoRoute(
    path: _rutaEncuestas,
    builder: (context, state) => _tema(context, const _ListaEncuestas()),
    routes: [
      GoRoute(
        path: ':id',
        builder: (context, state) => _tema(
          context,
          _FormularioEncuesta(
            ordenId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
          ),
        ),
      ),
    ],
  ),
];

Widget _tema(BuildContext context, Widget child) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: child,
);

class EncuestasInicio extends ConsumerWidget {
  const EncuestasInicio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendientes = ref.watch(encuestasPendientesProvider).asData?.value;
    if (pendientes == null || pendientes.isEmpty) {
      return const SizedBox.shrink();
    }
    final textos = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Espaciado.e4),
      child: GrupoLista(
        filas: [
          FilaGrupo(
            titulo: textos.m15Titulo,
            subtitulo: textos.m15Pendientes,
            icono: LucideIcons300.clipboardList,
            alToque: () => context.push(_rutaEncuestas),
          ),
        ],
      ),
    );
  }
}

class _ListaEncuestas extends ConsumerWidget {
  const _ListaEncuestas();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final formato = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    );
    return ref
        .watch(encuestasPendientesProvider)
        .when(
          loading: () => MarcoPantalla.estado(
            titulo: textos.m15Titulo,
            conRegreso: true,
            estado: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => MarcoPantalla.estado(
            titulo: textos.m15Titulo,
            conRegreso: true,
            estado: EstadoError(
              causa: error is SinConexion
                  ? CausaError.sinConexion
                  : CausaError.generico,
              alReintentar: () => ref.invalidate(encuestasPendientesProvider),
            ),
          ),
          data: (lista) => lista.isEmpty
              ? MarcoPantalla.estado(
                  titulo: textos.m15Titulo,
                  conRegreso: true,
                  estado: EstadoVacio(titulo: textos.m15Vacio),
                )
              : MarcoPantalla(
                  titulo: textos.m15Titulo,
                  conRegreso: true,
                  alRefrescar: () =>
                      ref.refresh(encuestasPendientesProvider.future),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(Espaciado.e4),
                      sliver: SliverToBoxAdapter(
                        child: GrupoLista(
                          filas: [
                            for (final encuesta in lista)
                              FilaGrupo(
                                titulo: encuesta.modelo,
                                subtitulo: formato.format(
                                  encuesta.cerradaEn.toLocal(),
                                ),
                                icono: LucideIcons300.wrench,
                                alToque: () => context.push(
                                  '$_rutaEncuestas/${encuesta.ordenId}',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
  }
}

class _FormularioEncuesta extends ConsumerStatefulWidget {
  const _FormularioEncuesta({required this.ordenId});
  final int ordenId;

  @override
  ConsumerState<_FormularioEncuesta> createState() => _FormularioEstado();
}

class _FormularioEstado extends ConsumerState<_FormularioEncuesta> {
  final _notas = <CalificacionEncuesta, int>{};
  final _comentario = TextEditingController();
  bool _enviando = false;
  bool _respondida = false;
  bool _contacto = false;
  bool _error = false;
  bool _noDisponible = false;

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  Future<void> _accion(
    Future<void> Function() enviar,
    VoidCallback exito,
  ) async {
    if (_enviando) return;
    setState(() {
      _enviando = true;
      _error = false;
    });
    try {
      await enviar();
      if (mounted) exito();
    } on ExcepcionApi catch (error) {
      if (!mounted) return;
      if (error is Conflicto || error is NoEncontrado) {
        ref.invalidate(encuestasPendientesProvider);
        setState(() => _noDisponible = true);
      } else {
        setState(() => _error = true);
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final repo = ref.read(repositorioEncuestasProvider);
    final etiquetas = {
      CalificacionEncuesta.nps: textos.m15Recomendar,
      CalificacionEncuesta.tiempo: textos.m15Tiempo,
      CalificacionEncuesta.trato: textos.m15Trato,
      CalificacionEncuesta.limpieza: textos.m15Limpieza,
      CalificacionEncuesta.asesor: textos.m15Asesor,
    };
    if (_noDisponible || widget.ordenId < 1) {
      return MarcoPantalla.estado(
        titulo: textos.m15Titulo,
        conRegreso: true,
        estado: EstadoVacio(titulo: textos.m15NoDisponible),
      );
    }
    return MarcoPantalla(
      titulo: textos.m15Titulo,
      conRegreso: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(Espaciado.e4),
          sliver: SliverList.list(
            children: [
              if (_error) Aviso(mensaje: textos.m15Error, tono: Tono.peligro),
              if (_respondida) ...[
                Semantics(header: true, child: Text(textos.m15Gracias)),
                if (_contacto)
                  Aviso(mensaje: textos.m15ContactoListo, tono: Tono.exito)
                else if (_notas[CalificacionEncuesta.nps]! <= 6)
                  Boton(
                    texto: textos.m15Contacto,
                    cargando: _enviando,
                    alPresionar: () => _accion(
                      () => repo.contacto(widget.ordenId),
                      () => setState(() => _contacto = true),
                    ),
                  ),
              ] else ...[
                Text(textos.m15Escala),
                for (final pregunta in CalificacionEncuesta.values)
                  _Escala(
                    titulo: etiquetas[pregunta]!,
                    esNps: pregunta == CalificacionEncuesta.nps,
                    seleccion: _notas[pregunta],
                    alElegir: _enviando
                        ? null
                        : (nota) => setState(() => _notas[pregunta] = nota),
                  ),
                CampoTexto(
                  etiqueta: textos.m15Comentario,
                  controlador: _comentario,
                  lineas: 3,
                  formatos: [LengthLimitingTextInputFormatter(1000)],
                  habilitado: !_enviando,
                ),
                const SizedBox(height: Espaciado.e4),
                Boton(
                  texto: textos.m15Enviar,
                  cargando: _enviando,
                  alPresionar:
                      _notas.length != CalificacionEncuesta.values.length
                      ? null
                      : () => _accion(
                          () => repo.responder(
                            widget.ordenId,
                            _notas,
                            _comentario.text.trim(),
                          ),
                          () {
                            ref.invalidate(encuestasPendientesProvider);
                            setState(() => _respondida = true);
                          },
                        ),
                ),
                Boton(
                  texto: textos.m15Posponer,
                  variante: VarianteBoton.secundario,
                  alPresionar: _enviando
                      ? null
                      : () => _accion(() => repo.posponer(widget.ordenId), () {
                          ref.invalidate(encuestasPendientesProvider);
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(_rutaEncuestas);
                          }
                        }),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Escala extends StatelessWidget {
  const _Escala({
    required this.titulo,
    required this.esNps,
    required this.seleccion,
    required this.alElegir,
  });
  final String titulo;
  final bool esNps;
  final int? seleccion;
  final ValueChanged<int>? alElegir;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Espaciado.e3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: Text(titulo)),
        Wrap(
          spacing: Espaciado.e1,
          children: [
            for (var nota = esNps ? 0 : 1; nota <= (esNps ? 10 : 5); nota++)
              Semantics(
                selected: seleccion == nota,
                child: Boton(
                  texto: nota.toString(),
                  tamano: TamanoBoton.chico,
                  variante: seleccion == nota
                      ? VarianteBoton.principal
                      : VarianteBoton.secundario,
                  alPresionar: alElegir == null ? null : () => alElegir!(nota),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}
