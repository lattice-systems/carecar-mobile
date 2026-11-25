import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/encabezado_grande.dart';
import '../../../nucleo/diseno/componentes/estante.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/tokens/colores.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/guia_emergencia.dart';
import 'estilo_guias.dart';
import 'rutas_asistencia.dart';
import 'textos_guias.dart';

/// Lista de guias de emergencia (V2-M11.03), en estilo portada.
///
/// Titulo grande translucido, tarjeta heroe de pedir ayuda, un estante con las
/// guias como portadas y debajo la misma lista agrupada. Las guias vienen
/// empaquetadas en la app: no hay carga, vacio ni error de red.
class PantallaGuias extends StatelessWidget {
  const PantallaGuias({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;

    return Scaffold(
      backgroundColor: c.fondo,
      body: CustomScrollView(
        slivers: [
          EncabezadoGrande(
            titulo: textos.asistenciaListaTitulo,
            translucido: true,
            conRegreso: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
              child: const _TarjetaHeroe(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Espaciado.e4,
                Espaciado.e3,
                Espaciado.e4,
                0,
              ),
              child: Aviso(mensaje: textos.asistenciaGuiasAvisoSinConexion),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Espaciado.e6)),
          SliverToBoxAdapter(
            child: Estante(
              titulo: textos.asistenciaEstanteGuias,
              anchoTarjeta: 168,
              // Con letra grande la portada crece con el texto: sin esto el
              // titulo y los pasos desbordan la tarjeta.
              alto: 236 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 2),
              hijos: [
                for (final guia in guiasDeEmergencia) _PortadaGuia(guia: guia),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Espaciado.e6)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
              child: GrupoLista(
                encabezado: textos.asistenciaGrupoGuias,
                filas: [
                  for (final guia in guiasDeEmergencia)
                    FilaGrupo(
                      titulo: textos.tituloDeGuia(guia.tipo),
                      subtitulo: textos.asistenciaGuiaCantidadPasos(guia.pasos),
                      icono: guia.tipo.icono,
                      colorIcono: guia.tipo.color(c),
                      alToque: () =>
                          context.go(rutaGuiaDeEmergencia(guia.tipo)),
                    ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Espaciado.e6)),
        ],
      ),
    );
  }
}

/// Tarjeta protagonista: pedir ayuda (V2-M11.01). Su boton abre el flujo de
/// la solicitud con ubicacion.
class _TarjetaHeroe extends StatelessWidget {
  const _TarjetaHeroe();

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.peligroSuave,
          borderRadius: Radios.bordeHoja,
        ),
        child: Padding(
          padding: const EdgeInsets.all(Espaciado.e5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Icon(Icons.sos_outlined, size: 56, color: c.peligro),
              ),
              const SizedBox(height: Espaciado.e3),
              Semantics(
                header: true,
                child: Text(
                  textos.asistenciaHeroeTitulo,
                  style: t.titulo1.copyWith(color: c.texto),
                ),
              ),
              const SizedBox(height: Espaciado.e2),
              Text(
                textos.asistenciaHeroeTextoDisponible,
                style: t.cuerpo.copyWith(color: c.textoSecundario),
              ),
              const SizedBox(height: Espaciado.e4),
              BotonPildora(
                texto: textos.asistenciaHeroeAccion,
                icono: Icons.sos_outlined,
                expandido: true,
                alPresionar: () => context.go(rutaPedirAyuda),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Portada de una guia en el estante: icono grande sobre su color.
class _PortadaGuia extends StatelessWidget {
  const _PortadaGuia({required this.guia});

  final GuiaEmergencia guia;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final PaletaColores c = tokens.colores;
    final color = guia.tipo.color(c);
    final titulo = textos.tituloDeGuia(guia.tipo);

    return Semantics(
      button: true,
      label: [
        titulo,
        textos.asistenciaGuiaCantidadPasos(guia.pasos),
      ].join(', '),
      excludeSemantics: true,
      onTap: () => context.go(rutaGuiaDeEmergencia(guia.tipo)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: Radios.bordeTarjeta,
          onTap: () => context.go(rutaGuiaDeEmergencia(guia.tipo)),
          child: Ink(
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                color.withValues(alpha: 0.22),
                c.superficie,
              ),
              borderRadius: Radios.bordeTarjeta,
            ),
            child: Padding(
              padding: const EdgeInsets.all(Espaciado.e4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(guia.tipo.icono, size: 64, color: color),
                  const Spacer(),
                  Text(
                    titulo,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: tokens.tipografia.titulo3.copyWith(color: c.texto),
                  ),
                  const SizedBox(height: Espaciado.e1),
                  Text(
                    textos.asistenciaGuiaCantidadPasos(guia.pasos),
                    style: tokens.tipografia.cuerpoChico.copyWith(
                      color: c.textoSecundario,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
