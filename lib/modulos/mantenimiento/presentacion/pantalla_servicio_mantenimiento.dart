import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../citas/citas.dart';
import '../../recoleccion/recoleccion.dart' show formatearPesos;
import '../dominio/plan_mantenimiento.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import 'formato_mantenimiento.dart';
import 'proveedores_mantenimiento.dart';

/// Qué incluye un servicio del plan y cuánto cuesta aproximadamente
/// (V2-M05.06).
///
/// Lista los conceptos y muestra el precio siempre como estimado, con la
/// leyenda «Estimación no vinculante». Un servicio sin hacer se puede agendar
/// desde aquí con el vehículo y el motivo mantenimiento precargados
/// (V2-M05.04). Resuelve cargando, datos, vacío (el servicio ya no está en el
/// plan), error y sin conexión.
class PantallaServicioMantenimiento extends ConsumerWidget {
  const PantallaServicioMantenimiento({
    required this.vehiculoId,
    required this.servicioId,
    super.key,
  });

  final int vehiculoId;
  final int servicioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final plan = ref.watch(planMantenimientoProvider(vehiculoId));

    return plan.when(
      skipLoadingOnReload: true,
      loading: () => MarcoPantalla.estado(
        icono: LucideIcons300.wrench,
        titulo: textos.mantenimientoTitulo,
        estado: const _Cargando(),
      ),
      error: (error, _) => MarcoPantalla.estado(
        icono: LucideIcons300.wrench,
        titulo: textos.mantenimientoTitulo,
        estado: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () =>
              ref.invalidate(planMantenimientoProvider(vehiculoId)),
        ),
      ),
      data: (p) {
        final servicio = p.servicioPorId(servicioId);
        if (servicio == null) {
          return MarcoPantalla.estado(
            icono: LucideIcons300.wrench,
            titulo: textos.mantenimientoTitulo,
            estado: EstadoVacio(
              titulo: textos.mantenimientoServicioNoEncontradoTitulo,
              mensaje: textos.mantenimientoServicioNoEncontradoMensaje,
              icono: LucideIcons300.wrench,
            ),
          );
        }
        return MarcoPantalla(
          icono: LucideIcons300.wrench,
          titulo: servicio.nombre,
          alRefrescar: () =>
              ref.refresh(planMantenimientoProvider(vehiculoId).future),
          barraInferior: servicio.sePuedeAgendar
              ? BarraInferior(
                  hijos: [
                    BotonPildora(
                      texto: textos.mantenimientoAgendar,
                      icono: LucideIcons300.calendarCheck,
                      expandido: true,
                      alPresionar: () => context.push(
                        rutaAgendarCitaCon(
                          vehiculoId: vehiculoId,
                          motivo: MotivoCita.mantenimiento,
                        ),
                      ),
                    ),
                  ],
                )
              : null,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
              sliver: SliverToBoxAdapter(child: _Servicio(servicio: servicio)),
            ),
          ],
        );
      },
    );
  }
}

class _Servicio extends StatelessWidget {
  const _Servicio({required this.servicio});

  final ServicioMantenimiento servicio;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final hechoEn = servicio.hechoEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: Espaciado.e2,
          runSpacing: Espaciado.e1,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Insignia(
              texto: textoEstado(textos, servicio.estado),
              tono: tonoEstado(servicio.estado),
              conIcono: true,
            ),
            Text(
              textos.mantenimientoResumenServicio(
                formatearKm(context, servicio.km),
                '${servicio.meses}',
              ),
              style: t.cuerpo.copyWith(color: c.textoSecundario),
            ),
          ],
        ),
        if (hechoEn != null) ...[
          const SizedBox(height: Espaciado.e2),
          Text(
            textos.mantenimientoHechoEl(formatearFecha(context, hechoEn)),
            style: t.cuerpoChico.copyWith(color: c.textoSecundario),
          ),
        ],
        const SizedBox(height: Espaciado.e5),
        if (servicio.conceptos.isEmpty)
          Text(
            textos.mantenimientoSinConceptos,
            style: t.cuerpo.copyWith(color: c.textoSecundario),
          )
        else
          GrupoLista(
            encabezado: textos.mantenimientoEncabezadoConceptos,
            filas: [
              for (final concepto in servicio.conceptos)
                FilaGrupo(
                  titulo: concepto,
                  icono: LucideIcons300.check,
                  colorIcono: c.exito,
                ),
            ],
          ),
        const SizedBox(height: Espaciado.e5),
        _TarjetaPrecio(precio: servicio.precioEstimado),
      ],
    );
  }
}

/// El precio estimado y su leyenda, juntos como una sola frase para el lector
/// de pantalla: nunca se anuncia el monto sin decir que es una estimación.
class _TarjetaPrecio extends StatelessWidget {
  const _TarjetaPrecio({required this.precio});

  final double precio;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: BorderRadius.circular(Radios.tarjeta),
        boxShadow: tokens.sombras,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.e4),
        child: MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                textos.mantenimientoPrecioEtiqueta,
                style: t.cuerpoChico.copyWith(color: c.textoSecundario),
              ),
              Text(
                formatearPesos(context, precio),
                style: t.cifra.copyWith(color: c.texto),
              ),
              Text(
                textos.mantenimientoPrecioLeyenda,
                style: t.cuerpoChico.copyWith(color: c.textoSecundario),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).mantenimientoCargandoServicio,
      liveRegion: true,
      // Desplazable aunque no se pueda mover: con letra grande el encabezado
      // deja poco alto y el esqueleto no debe desbordar.
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 32),
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
