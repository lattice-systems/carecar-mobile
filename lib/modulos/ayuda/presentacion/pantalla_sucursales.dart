import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/fila_acciones.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/mapa.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/mapas/mapas.dart';
import '../dominio/enlaces_sucursal.dart';
import '../dominio/sucursal.dart';
import '../dominio/tramos_de_dias.dart';
import 'proveedores_ayuda.dart';

/// Sucursales de la agencia con mapa, horarios por departamento, llamar y
/// cómo llegar (V2-M27.02).
///
/// Resuelve los cinco estados: cargando con esqueleto, datos, vacío, error con
/// reintento y sin conexión. «Abierto ahora» viene calculado por el servidor
/// con la hora de la agencia; por eso se pide de nuevo cada vez que se abre la
/// pantalla o se jala para recargar.
class PantallaSucursales extends ConsumerStatefulWidget {
  const PantallaSucursales({super.key});

  @override
  ConsumerState<PantallaSucursales> createState() =>
      _EstadoPantallaSucursales();
}

class _EstadoPantallaSucursales extends ConsumerState<PantallaSucursales> {
  /// La sucursal que se ve en el mapa; nula es la principal.
  int? _elegida;

  /// Lo que no se pudo abrir (el marcador o la app de mapas).
  String? _aviso;

  Future<void> _abrir(Uri enlace, String siFalla) async {
    var abierto = false;
    try {
      abierto = await ref.read(abrirEnlaceDeSucursalProvider)(enlace);
    } on Object {
      // Sin app que lo atienda, o la plataforma lo rechazó: se avisa abajo.
    }
    if (!mounted) return;
    setState(() => _aviso = abierto ? null : siFalla);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final sucursales = ref.watch(sucursalesProvider);
    final titulo = textos.sucursalesTitulo;

    return sucursales.when(
      skipLoadingOnReload: true,
      loading: () => MarcoPantalla.estado(
        titulo: titulo,
        conRegreso: true,
        estado: const _Cargando(),
      ),
      error: (error, _) => MarcoPantalla.estado(
        titulo: titulo,
        conRegreso: true,
        estado: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(sucursalesProvider),
        ),
      ),
      data: (lista) {
        if (lista.isEmpty) {
          return MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: EstadoVacio(
              titulo: textos.sucursalesVacioTitulo,
              mensaje: textos.sucursalesVacioMensaje,
              icono: LucideIcons300.mapPin,
            ),
          );
        }
        final actual = lista.firstWhere(
          (s) => s.id == _elegida,
          orElse: () => lista.first,
        );
        return MarcoPantalla(
          titulo: titulo,
          conRegreso: true,
          alRefrescar: () => ref.refresh(sucursalesProvider.future),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(Espaciado.e4),
              sliver: SliverList.list(
                children: [
                  Mapa(
                    teselas: ref.watch(configuracionTeselasProvider),
                    fuenteTeselas: ref.watch(fuenteTeselasProvider),
                    pin: Coordenada(actual.latitud, actual.longitud),
                    descripcion: textos.sucursalesMapaDe(actual.nombre),
                    alto: 240,
                  ),
                  const SizedBox(height: Espaciado.e5),
                  _Portada(
                    sucursal: actual,
                    aviso: _aviso,
                    alCerrarAviso: () => setState(() => _aviso = null),
                    alLlamar: () => _abrir(
                      enlaceDeLlamada(actual)!,
                      textos.sucursalesNoSePudoLlamar,
                    ),
                    alLlegar: () => _abrir(
                      enlaceComoLlegar(
                        actual,
                        apple:
                            defaultTargetPlatform == TargetPlatform.iOS ||
                            defaultTargetPlatform == TargetPlatform.macOS,
                      ),
                      textos.sucursalesNoSePudoMapa,
                    ),
                  ),
                  const SizedBox(height: Espaciado.e5),
                  _Horarios(sucursal: actual),
                  if (lista.length > 1) ...[
                    const SizedBox(height: Espaciado.e5),
                    _Todas(
                      sucursales: lista,
                      elegida: actual.id,
                      alElegir: (id) => setState(() {
                        _elegida = id;
                        _aviso = null;
                      }),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// «Abierto ahora» o «Cerrado» con su icono: el estado no depende del color.
class _EstadoAbierto extends StatelessWidget {
  const _EstadoAbierto({required this.abierto, this.corto = false});

  final bool abierto;

  /// Dentro de un departamento basta «Abierto»; el «ahora» va en la sucursal.
  final bool corto;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Insignia(
      texto: abierto
          ? (corto ? textos.sucursalesAbierto : textos.sucursalesAbiertoAhora)
          : textos.sucursalesCerrado,
      tono: abierto ? Tono.exito : Tono.neutro,
      conIcono: true,
    );
  }
}

class _Portada extends StatelessWidget {
  const _Portada({
    required this.sucursal,
    required this.aviso,
    required this.alCerrarAviso,
    required this.alLlamar,
    required this.alLlegar,
  });

  final Sucursal sucursal;
  final String? aviso;
  final VoidCallback alCerrarAviso;
  final VoidCallback alLlamar;
  final VoidCallback alLlegar;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            sucursal.nombre,
            style: t.titulo2.copyWith(color: c.texto),
          ),
        ),
        const SizedBox(height: Espaciado.e2),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: _EstadoAbierto(abierto: sucursal.abiertaAhora),
        ),
        const SizedBox(height: Espaciado.e2),
        Text(
          sucursal.direccion,
          style: t.cuerpo.copyWith(color: c.textoSecundario),
        ),
        const SizedBox(height: Espaciado.e4),
        FilaAcciones(
          principal: AccionPantalla(
            texto: textos.sucursalesComoLlegar,
            icono: LucideIcons300.navigation,
            alPresionar: alLlegar,
          ),
          secundaria: sucursal.telefono == null
              ? null
              : AccionPantalla(
                  texto: textos.sucursalesLlamar,
                  icono: LucideIcons300.phone,
                  alPresionar: alLlamar,
                ),
        ),
        if (aviso != null) ...[
          const SizedBox(height: Espaciado.e3),
          Aviso(
            mensaje: aviso!,
            tono: Tono.advertencia,
            alCerrar: alCerrarAviso,
          ),
        ],
      ],
    );
  }
}

class _Horarios extends StatelessWidget {
  const _Horarios({required this.sucursal});

  final Sucursal sucursal;

  /// «lun a vie, sáb»: los días seguidos se juntan en un tramo.
  static String _dias(AppLocalizations textos, List<int> dias) => [
    for (final tramo in tramosDeDias(dias))
      tramo.desde == tramo.hasta
          ? textos.sucursalesDiaCorto('${tramo.desde}')
          : textos.sucursalesDiasRango(
              textos.sucursalesDiaCorto('${tramo.desde}'),
              textos.sucursalesDiaCorto('${tramo.hasta}'),
            ),
  ].join(', ');

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final grupos = sucursal.horariosPorDepartamento;
    if (grupos.isEmpty) return const SizedBox.shrink();

    return GrupoLista(
      encabezado: textos.sucursalesHorarios,
      filas: [
        for (final grupo in grupos)
          FilaGrupo(
            titulo: textos.sucursalesDepartamento(grupo.departamento.name),
            subtitulo: [
              for (final tramo in grupo.tramos)
                textos.sucursalesTramo(
                  _dias(textos, tramo.dias),
                  tramo.abre,
                  tramo.cierra,
                ),
            ].join('\n'),
            fin: _EstadoAbierto(abierto: grupo.abiertoAhora, corto: true),
            etiquetaFin: grupo.abiertoAhora
                ? textos.sucursalesAbierto
                : textos.sucursalesCerrado,
          ),
      ],
    );
  }
}

class _Todas extends StatelessWidget {
  const _Todas({
    required this.sucursales,
    required this.elegida,
    required this.alElegir,
  });

  final List<Sucursal> sucursales;
  final int elegida;
  final ValueChanged<int> alElegir;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;

    return GrupoLista(
      encabezado: textos.sucursalesTodas,
      filas: [
        for (final s in sucursales)
          FilaGrupo(
            titulo: s.nombre,
            subtitulo: s.direccion,
            icono: s.id == elegida
                ? LucideIcons300.check
                : LucideIcons300.mapPin,
            colorIcono: s.id == elegida ? c.acento : c.textoSecundario,
            fin: _EstadoAbierto(abierto: s.abiertaAhora),
            etiquetaFin: [
              if (s.id == elegida) textos.sucursalesSeleccionada,
              s.abiertaAhora
                  ? textos.sucursalesAbiertoAhora
                  : textos.sucursalesCerrado,
            ].join('. '),
            alToque: () => alElegir(s.id),
            conChevron: false,
          ),
      ],
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).sucursalesCargando,
      liveRegion: true,
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 240),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 120),
          ],
        ),
      ),
    );
  }
}
