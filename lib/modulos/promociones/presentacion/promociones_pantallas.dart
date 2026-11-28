import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../config/flavor.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/analitica/proveedores_analitica.dart';
import '../../../nucleo/api/proveedores_api.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/fila_lista.dart';
import '../../../nucleo/diseno/tema_pista.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../citas/citas.dart';
import '../datos/proveedores_publicaciones.dart';
import '../dominio/publicacion.dart';

bool get catalogoSimuladoHabilitado => Flavor.actual == Flavor.desarrollo;

class PromocionesInicio extends ConsumerWidget {
  const PromocionesInicio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final ofertas = ref.watch(promocionesProvider).asData?.value ?? const [];
    return _tema(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilaLista(
            titulo: textos.m13Novedades,
            inicio: const Icon(LucideIcons300.newspaper),
            alToque: () => context.push('/novedades'),
          ),
          if (ofertas.isNotEmpty) ...[
            Semantics(header: true, child: Text(textos.m13ParaTi)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final promocion in ofertas)
                    SizedBox(
                      width: 240,
                      child: FilaLista(
                        titulo: promocion.titulo,
                        conDivisor: false,
                        inicio: const Icon(LucideIcons300.tag),
                        alToque: () =>
                            context.push('/promociones/${promocion.id}'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

final rutasPromociones = <RouteBase>[
  GoRoute(
    path: '/promociones/agendar/:id',
    builder: (context, state) => _tema(
      context,
      _AgendarConPromocion(id: int.tryParse(state.pathParameters['id'] ?? '')),
    ),
  ),
  GoRoute(
    path: '/novedades',
    builder: (context, state) => _tema(context, const _Novedades()),
    routes: [
      GoRoute(
        path: ':id',
        builder: (context, state) => _tema(
          context,
          _Detalle(
            id: int.tryParse(state.pathParameters['id'] ?? ''),
            promocion: false,
          ),
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/promociones/:id',
    builder: (context, state) => _tema(
      context,
      _Detalle(
        id: int.tryParse(state.pathParameters['id'] ?? ''),
        promocion: true,
      ),
    ),
  ),
];

Widget _tema(BuildContext context, Widget pantalla) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: pantalla,
);

class _AgendarConPromocion extends ConsumerWidget {
  const _AgendarConPromocion({required this.id});

  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final publicaciones = ref.watch(promocionesProvider);
    Widget estado(Widget contenido) => MarcoPantalla.estado(
      titulo: textos.m13Agendar,
      conRegreso: true,
      estado: contenido,
    );
    return publicaciones.when(
      loading: () => estado(const Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          estado(_error(error, () => ref.invalidate(promocionesProvider))),
      data: (lista) {
        final promocion = lista.where((p) => p.id == id).firstOrNull;
        if (promocion == null ||
            promocion.cupon == null ||
            promocion.cta != 'agendar' ||
            promocion.vehiculos.isEmpty) {
          return estado(EstadoVacio(titulo: textos.m13NoDisponible));
        }
        return PantallaAgendarCita(
          vehiculoInicial: promocion.vehiculos.first,
          promocionId: promocion.id,
          vehiculosConPromocion: promocion.vehiculos.toSet(),
        );
      },
    );
  }
}

class _Novedades extends ConsumerWidget {
  const _Novedades();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titulo = AppLocalizations.of(context).m13Novedades;
    Widget estado(Widget contenido) => MarcoPantalla.estado(
      titulo: titulo,
      conRegreso: true,
      estado: contenido,
    );
    return ref
        .watch(novedadesProvider)
        .when(
          loading: () =>
              estado(const Center(child: CircularProgressIndicator())),
          error: (error, _) =>
              estado(_error(error, () => ref.invalidate(novedadesProvider))),
          data: (lista) => lista.isEmpty
              ? estado(
                  EstadoVacio(
                    titulo: AppLocalizations.of(context).m13SinNovedades,
                  ),
                )
              : MarcoPantalla(
                  titulo: titulo,
                  conRegreso: true,
                  slivers: [
                    SliverList.list(
                      children: [
                        for (final novedad in lista)
                          FilaLista(
                            titulo: novedad.titulo,
                            inicio: SizedBox(
                              width: 80,
                              child: _Foto(url: novedad.imagen),
                            ),
                            alToque: () =>
                                context.push('/novedades/${novedad.id}'),
                          ),
                      ],
                    ),
                  ],
                ),
        );
  }
}

Widget _error(Object error, VoidCallback reintentar) => EstadoError(
  causa: error is SinConexion ? CausaError.sinConexion : CausaError.generico,
  alReintentar: reintentar,
);

class _Detalle extends ConsumerWidget {
  const _Detalle({required this.id, required this.promocion});

  final int? id;
  final bool promocion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final proveedor = promocion ? promocionesProvider : novedadesProvider;
    final titulo = promocion ? textos.m13ParaTi : textos.m13Novedades;
    Widget estado(Widget contenido) => MarcoPantalla.estado(
      titulo: titulo,
      conRegreso: true,
      estado: contenido,
    );
    return ref
        .watch(proveedor)
        .when(
          loading: () =>
              estado(const Center(child: CircularProgressIndicator())),
          error: (error, _) =>
              estado(_error(error, () => ref.invalidate(proveedor))),
          data: (lista) {
            final item = lista
                .where((publicacion) => publicacion.id == id)
                .firstOrNull;
            if (item == null) {
              return estado(EstadoVacio(titulo: textos.m13NoDisponible));
            }
            return _Contenido(
              key: ValueKey(item.id),
              item: item,
              promocion: promocion,
            );
          },
        );
  }
}

class _Contenido extends ConsumerStatefulWidget {
  const _Contenido({required this.item, required this.promocion, super.key});
  final Publicacion item;
  final bool promocion;

  @override
  ConsumerState<_Contenido> createState() => _ContenidoState();
}

class _ContenidoState extends ConsumerState<_Contenido> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted ||
          !widget.promocion ||
          !ref.read(consentimientoAnaliticaProvider).activa) {
        return;
      }
      try {
        await ref
            .read(apiClienteProvider)
            .enviarSinRespuesta('/promociones/${widget.item.id}/vista');
      } on Exception {
        // La vista no bloquea la lectura de la promoción.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final textos = AppLocalizations.of(context);
    final formato = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    );
    final hasta = item.hasta;
    return MarcoPantalla(
      titulo: widget.promocion ? textos.m13ParaTi : textos.m13Novedades,
      conRegreso: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(Espaciado.e4),
          sliver: SliverList.list(
            children: [
              if (!widget.promocion || item.imagen != null)
                _Foto(url: item.imagen),
              Semantics(
                header: true,
                child: Text(
                  item.titulo,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Text(
                hasta == null
                    ? formato.format(item.fecha.toLocal())
                    : '${formato.format(item.fecha.toLocal())} – ${formato.format(hasta.toLocal())}',
              ),
              const SizedBox(height: Espaciado.e3),
              Text(item.cuerpo),
              if (item.cupon case final cupon?)
                FilaLista(
                  titulo: textos.m13Cupon,
                  subtitulo: cupon,
                  conChevron: false,
                ),
              if (item.cta == 'agendar' &&
                  (item.cupon?.isNotEmpty ?? false) &&
                  item.vehiculos.isNotEmpty)
                Boton(
                  texto: textos.m13Agendar,
                  alPresionar: () =>
                      context.push('/promociones/agendar/${item.id}'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Foto extends StatelessWidget {
  const _Foto({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url ?? '');
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: uri != null && uri.scheme == 'https' && uri.host.isNotEmpty
          ? Image.network(
              uri.toString(),
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => const Icon(LucideIcons300.imageOff),
            )
          : Image.asset(
              'assets/autos/march.jpg',
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
    );
  }
}
