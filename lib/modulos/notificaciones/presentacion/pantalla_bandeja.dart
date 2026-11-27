import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/aviso_cliente.dart';
import 'proveedores_bandeja.dart';

/// La bandeja de avisos · V2-M06.04.
///
/// Paginada, con el contador de no leidos y «marcar todos como leidos». Tocar
/// un aviso lo marca leido y lleva a su pantalla (V2-M06.03).
class PantallaBandeja extends ConsumerStatefulWidget {
  const PantallaBandeja({super.key});

  static const marcarTodos = Key('bandeja_marcar_todos');
  static const errorAlCargarMas = Key('bandeja_error_cargar_mas');

  static Key aviso(int id) => Key('bandeja_aviso_$id');

  @override
  ConsumerState<PantallaBandeja> createState() => _EstadoPantallaBandeja();
}

class _EstadoPantallaBandeja extends ConsumerState<PantallaBandeja> {
  final _desplazamiento = ScrollController();

  @override
  void initState() {
    super.initState();
    _desplazamiento.addListener(_alDesplazar);
  }

  @override
  void dispose() {
    _desplazamiento
      ..removeListener(_alDesplazar)
      ..dispose();
    super.dispose();
  }

  /// Pide la pagina siguiente antes de llegar al fondo, para que la lista no
  /// se sienta cortada.
  void _alDesplazar() {
    final p = _desplazamiento.position;
    if (p.pixels >= p.maxScrollExtent - 400) {
      ref.read(bandejaProvider.notifier).cargarMas();
    }
  }

  Future<void> _abrir(AvisoCliente aviso) async {
    await ref.read(bandejaProvider.notifier).marcarLeido(aviso.id);
    final destino = aviso.destino;
    if (destino == null || !mounted) return;
    // Sin enrutador no se mueve nada: asi la pantalla se puede probar y
    // mostrar sola.
    GoRouter.maybeOf(context)?.go(destino);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final bandeja = ref.watch(bandejaProvider);

    if (bandeja.hasError && !bandeja.hasValue) {
      return MarcoPantalla.estado(
        titulo: textos.bandejaTitulo,
        conRegreso: true,
        estado: EstadoError(
          causa: bandeja.error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(bandejaProvider),
        ),
      );
    }
    if (!bandeja.hasValue) {
      return MarcoPantalla.estado(
        titulo: textos.bandejaTitulo,
        conRegreso: true,
        estado: Semantics(
          label: textos.bandejaCargando,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final estado = bandeja.requireValue;
    if (estado.avisos.isEmpty) {
      return MarcoPantalla.estado(
        titulo: textos.bandejaTitulo,
        conRegreso: true,
        estado: EstadoVacio(
          titulo: textos.bandejaVacioTitulo,
          mensaje: textos.bandejaVacioMensaje,
          icono: LucideIcons300.bell,
        ),
      );
    }

    return MarcoPantalla(
      titulo: textos.bandejaTitulo,
      subtitulo: estado.noLeidos > 0
          ? textos.bandejaSinLeer(estado.noLeidos)
          : null,
      conRegreso: true,
      alRefrescar: () async {
        ref.invalidate(bandejaProvider);
        await ref.read(bandejaProvider.future);
      },
      slivers: [
        if (estado.noLeidos > 0)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Espaciado.e4,
                Espaciado.e3,
                Espaciado.e4,
                0,
              ),
              child: Boton(
                key: PantallaBandeja.marcarTodos,
                texto: textos.bandejaMarcarTodos,
                variante: VarianteBoton.secundario,
                anchoCompleto: true,
                alPresionar: () =>
                    ref.read(bandejaProvider.notifier).marcarTodosLeidos(),
              ),
            ),
          ),
        SliverList.separated(
          itemCount: estado.avisos.length,
          separatorBuilder: (_, _) => const SizedBox(height: Espaciado.e2),
          itemBuilder: (context, i) => Padding(
            padding: EdgeInsets.fromLTRB(
              Espaciado.e4,
              i == 0 ? Espaciado.e3 : 0,
              Espaciado.e4,
              0,
            ),
            child: _Fila(
              aviso: estado.avisos[i],
              alToque: () => _abrir(estado.avisos[i]),
            ),
          ),
        ),
        if (estado.errorAlCargarMas)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Espaciado.e4),
              child: Aviso(
                key: PantallaBandeja.errorAlCargarMas,
                tono: Tono.advertencia,
                titulo: textos.bandejaErrorMasTitulo,
                mensaje: textos.bandejaErrorMasMensaje,
              ),
            ),
          )
        else if (estado.cargandoMas)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(Espaciado.e4),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: Espaciado.e6)),
      ],
    );
  }
}

/// Un aviso de la lista. El no leido se distingue **con punto y con negrita**,
/// no solo con color: el color solo no lo ve quien no distingue tonos.
class _Fila extends StatelessWidget {
  const _Fila({required this.aviso, required this.alToque});

  final AvisoCliente aviso;
  final VoidCallback alToque;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final textos = AppLocalizations.of(context);
    final sinLeer = !aviso.leida;

    // Un solo nodo por fila: sin esto el lector lee el titulo y el cuerpo por
    // separado y el «Sin leer» se pierde entre ellos.
    return Semantics(
      container: true,
      button: true,
      label: [
        if (sinLeer) textos.bandejaSinLeerUno,
        aviso.titulo,
        aviso.cuerpo,
      ].join('. '),
      child: ExcludeSemantics(
        child: Material(
          color: tokens.colores.superficie,
          borderRadius: BorderRadius.circular(Radios.tarjeta),
          child: InkWell(
            key: PantallaBandeja.aviso(aviso.id),
            onTap: alToque,
            borderRadius: BorderRadius.circular(Radios.tarjeta),
            child: Padding(
              padding: const EdgeInsets.all(Espaciado.e4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      _icono(aviso.categoria),
                      size: 20,
                      color: tokens.colores.acento,
                    ),
                  ),
                  const SizedBox(width: Espaciado.e3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aviso.titulo,
                          style: sinLeer
                              ? tokens.tipografia.cuerpoFuerte
                              : tokens.tipografia.cuerpo,
                        ),
                        const SizedBox(height: Espaciado.e1),
                        Text(
                          aviso.cuerpo,
                          style: tokens.tipografia.cuerpoChico.copyWith(
                            color: tokens.colores.textoSecundario,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (sinLeer) ...[
                    const SizedBox(width: Espaciado.e2),
                    ExcludeSemantics(
                      child: Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: Espaciado.e1),
                        decoration: BoxDecoration(
                          color: tokens.colores.acento,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Un icono nuevo del backend cae en la campana, no en un hueco.
  IconData _icono(CategoriaDeAviso categoria) => switch (categoria) {
    CategoriaDeAviso.taller => LucideIcons300.wrench,
    CategoriaDeAviso.citas => LucideIcons300.calendarDays,
    CategoriaDeAviso.mantenimiento => LucideIcons300.gauge,
    CategoriaDeAviso.documentos => LucideIcons300.fileText,
    CategoriaDeAviso.promociones => LucideIcons300.tag,
    CategoriaDeAviso.mensajes => LucideIcons300.messageSquare,
    CategoriaDeAviso.desconocida => LucideIcons300.bell,
  };
}
