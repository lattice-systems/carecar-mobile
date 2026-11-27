import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/guia_emergencia.dart';
import 'estilo_guias.dart';
import 'rutas_asistencia.dart';
import 'textos_guias.dart';

/// Lista de guias de emergencia (V2-M11.03).
///
/// Titulo grande, la tarjeta de pedir ayuda, el aviso de que las guias
/// funcionan sin conexion y la lista agrupada de guias. Antes habia ademas un
/// estante con las mismas guias como portadas de color: era la misma lista dos
/// veces (V2-T02.26). Las guias vienen empaquetadas en la app: no hay carga,
/// vacio ni error de red.
class PantallaGuias extends StatelessWidget {
  const PantallaGuias({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;

    return MarcoPantalla(
      titulo: textos.asistenciaListaTitulo,
      conRegreso: true,
      slivers: [
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
                    alToque: () => context.go(rutaGuiaDeEmergencia(guia.tipo)),
                  ),
              ],
            ),
          ),
        ),
      ],
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
          borderRadius: Radios.bordeTarjeta,
        ),
        child: Padding(
          padding: const EdgeInsets.all(Espaciado.e5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Icon(LucideIcons300.siren, size: 56, color: c.peligro),
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
                icono: LucideIcons300.siren,
                expandido: true,
                alPresionar: () => context.go(rutaPedirAyuda),
              ),
              const SizedBox(height: Espaciado.e2),
              BotonPildora(
                texto: textos.asistenciaLlamarAtajo,
                icono: LucideIcons300.phone,
                variante: VarianteBotonPildora.tonal,
                expandido: true,
                alPresionar: () => context.go(rutaLlamarRapido),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
