import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/navegacion/rutas.dart';
import 'estado_avisos.dart';

/// Pantalla previa al permiso de avisos · V2-M06.01.
///
/// Existe por una razon concreta: en Android 13 y despues el dialogo del
/// sistema **se muestra una sola vez en la vida de la instalacion**. Pedirlo
/// en frio, sin que la persona sepa para que, gasta ese unico tiro y deja la
/// app sin avisos para siempre.
///
/// Por eso aqui no se pide nada hasta que la persona toca «Activar avisos», y
/// «Ahora no» ni siquiera toca el sistema: se guarda el tiro para cuando de
/// verdad los quiera.
class PantallaPermisoAvisos extends ConsumerStatefulWidget {
  const PantallaPermisoAvisos({super.key});

  static const botonActivar = Key('avisos_activar');
  static const botonAhoraNo = Key('avisos_ahora_no');
  static const botonAjustes = Key('avisos_abrir_ajustes');
  static const avisoListo = Key('avisos_listo');
  static const avisoNegados = Key('avisos_negados');

  @override
  ConsumerState<PantallaPermisoAvisos> createState() =>
      _EstadoPantallaPermisoAvisos();
}

class _EstadoPantallaPermisoAvisos
    extends ConsumerState<PantallaPermisoAvisos> {
  bool _pidiendo = false;

  Future<void> _activar() async {
    setState(() => _pidiendo = true);
    await ref.read(permisoDeAvisosProvider.notifier).pedir();
    if (mounted) setState(() => _pidiendo = false);
    _salir();
  }

  Future<void> _ahoraNo() async {
    await ref.read(permisoDeAvisosProvider.notifier).ahoraNo();
    _salir();
  }

  /// Sale de la pantalla despues de contestar, por donde se haya entrado.
  ///
  /// Si se llego desde el perfil se regresa ahi; si fue la guardia la que
  /// mando -y entonces no hay nada atras- se va al inicio. Sin esto la
  /// compuerta se cierra pero la persona se queda viendo la misma pantalla.
  ///
  /// Sin enrutador no se mueve nada: asi la pantalla tambien se puede probar
  /// y mostrar sola.
  void _salir() {
    if (!mounted) return;
    final enrutador = GoRouter.maybeOf(context);
    if (enrutador == null) return;
    if (enrutador.canPop()) {
      enrutador.pop();
    } else {
      enrutador.go(Rutas.inicio);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final estado = ref.watch(permisoDeAvisosProvider);

    return MarcoPantalla(
      titulo: textos.avisosPermisoTitulo,
      conRegreso: true,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  textos.avisosPermisoExplicacion,
                  style: tokens.tipografia.cuerpo,
                ),
                const SizedBox(height: Espaciado.e5),
                _Motivo(
                  icono: LucideIcons300.wrench,
                  texto: textos.avisosPermisoTaller,
                ),
                _Motivo(
                  icono: LucideIcons300.calendarDays,
                  texto: textos.avisosPermisoCitas,
                ),
                _Motivo(
                  icono: LucideIcons300.messageSquare,
                  texto: textos.avisosPermisoRespuestas,
                ),
                const SizedBox(height: Espaciado.e4),
                Text(
                  textos.avisosPermisoSinPublicidad,
                  style: tokens.tipografia.cuerpo.copyWith(
                    color: tokens.colores.textoSecundario,
                  ),
                ),
                const SizedBox(height: Espaciado.e5),
                if (estado == EstadoAvisos.permitidos) ...[
                  Aviso(
                    key: PantallaPermisoAvisos.avisoListo,
                    tono: Tono.exito,
                    titulo: textos.avisosPermisoListoTitulo,
                    mensaje: textos.avisosPermisoListoMensaje,
                  ),
                ] else if (estado == EstadoAvisos.negados) ...[
                  // Negado no es un error de la persona ni un callejon sin
                  // salida: se le dice donde esta la puerta.
                  Aviso(
                    key: PantallaPermisoAvisos.avisoNegados,
                    tono: Tono.advertencia,
                    titulo: textos.avisosPermisoNegadosTitulo,
                    mensaje: textos.avisosPermisoNegadosMensaje,
                  ),
                  const SizedBox(height: Espaciado.e4),
                  Boton(
                    key: PantallaPermisoAvisos.botonAjustes,
                    texto: textos.avisosPermisoAbrirAjustes,
                    anchoCompleto: true,
                    alPresionar: () => ref
                        .read(permisoDeAvisosProvider.notifier)
                        .abrirAjustes(),
                  ),
                ] else ...[
                  Boton(
                    key: PantallaPermisoAvisos.botonActivar,
                    texto: textos.avisosPermisoActivar,
                    anchoCompleto: true,
                    cargando: _pidiendo,
                    alPresionar: _pidiendo ? null : _activar,
                  ),
                  const SizedBox(height: Espaciado.e2),
                  Boton(
                    key: PantallaPermisoAvisos.botonAhoraNo,
                    texto: textos.avisosPermisoAhoraNo,
                    variante: VarianteBoton.terciario,
                    anchoCompleto: true,
                    alPresionar: _pidiendo ? null : _ahoraNo,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Un motivo por el que la app avisa, con su icono.
class _Motivo extends StatelessWidget {
  const _Motivo({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Espaciado.e3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // El icono es decorativo: el texto de al lado ya lo dice todo, y
          // repetirlo haria que el lector de pantalla lea dos veces.
          ExcludeSemantics(
            child: Icon(icono, size: 20, color: tokens.colores.acento),
          ),
          const SizedBox(width: Espaciado.e3),
          Expanded(child: Text(texto, style: tokens.tipografia.cuerpo)),
        ],
      ),
    );
  }
}
