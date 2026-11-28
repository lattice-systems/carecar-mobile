import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/dialogo.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../dominio/lealtad.dart';
import '../dominio/repositorio_lealtad.dart';
import 'esqueleto_lealtad.dart';
import 'formato_lealtad.dart';
import 'proveedores_lealtad.dart';
import 'rutas_lealtad.dart';

/// Catalogo de recompensas (V2-M12.03) con su costo y el saldo arriba. Las
/// que no alcanzan o se agotaron no se tocan y dicen lo que falta. Al tocar
/// una se confirma con el costo y el saldo que queda; el canje abre su codigo
/// con QR. `SALDO_INSUFICIENTE` y `RECOMPENSA_AGOTADA` se explican en un
/// dialogo. Resuelve esqueleto, datos, vacio, error y sin conexion; se
/// recarga jalando hacia abajo.
class PantallaRecompensas extends ConsumerStatefulWidget {
  const PantallaRecompensas({super.key});

  @override
  ConsumerState<PantallaRecompensas> createState() =>
      _PantallaRecompensasState();
}

class _PantallaRecompensasState extends ConsumerState<PantallaRecompensas> {
  bool _canjeando = false;

  Future<void> _canjear(Recompensa recompensa, int saldo) async {
    final textos = AppLocalizations.of(context);
    final confirmado = await mostrarDialogo<bool>(
      context,
      builder: (contexto) => Dialogo(
        titulo: textos.recompensasConfirmarTitulo(recompensa.nombre),
        mensaje: textos.recompensasConfirmarMensaje(
          puntosLealtad(contexto, recompensa.puntos),
          puntosLealtad(contexto, saldo - recompensa.puntos),
        ),
        textoPrincipal: textos.recompensasConfirmar,
        alPrincipal: () => Navigator.of(contexto).pop(true),
        textoSecundario: textos.recompensasCancelar,
        alSecundario: () => Navigator.of(contexto).pop(false),
      ),
    );
    if (confirmado != true || !mounted) return;
    setState(() => _canjeando = true);
    try {
      final canje = await ref
          .read(canjesProvider.notifier)
          .canjear(recompensa.id);
      if (!mounted) return;
      setState(() => _canjeando = false);
      await context.push(rutaCanje(canje.id));
    } on CanjeRechazado catch (rechazo) {
      if (!mounted) return;
      setState(() => _canjeando = false);
      switch (rechazo.motivo) {
        case MotivoRechazoCanje.saldoInsuficiente:
          ref.invalidate(resumenLealtadProvider);
        case MotivoRechazoCanje.agotada:
          ref.invalidate(recompensasProvider);
      }
      await _avisar(switch (rechazo.motivo) {
        MotivoRechazoCanje.saldoInsuficiente => textos.recompensasSinSaldo,
        MotivoRechazoCanje.agotada => textos.recompensasSeAgoto,
      });
    } on Object {
      if (!mounted) return;
      setState(() => _canjeando = false);
      await _avisar(textos.recompensasError);
    }
  }

  Future<void> _avisar(String mensaje) {
    final textos = AppLocalizations.of(context);
    return mostrarDialogo<void>(
      context,
      builder: (contexto) => Dialogo(
        titulo: textos.recompensasNoSePudoTitulo,
        mensaje: mensaje,
        textoPrincipal: textos.recompensasEntendido,
        alPrincipal: () => Navigator.of(contexto).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final titulo = textos.recompensasTitulo;
    // Mantiene vivos los canjes: el nuevo ya esta en la lista cuando se abre
    // su codigo.
    ref.listen(canjesProvider, (_, _) {});
    final saldo = ref.watch(resumenLealtadProvider).value?.saldo;

    return ref
        .watch(recompensasProvider)
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            icono: LucideIcons300.gift,
            titulo: titulo,
            conRegreso: true,
            estado: EsqueletoLealtad(
              altos: const [96, 96, 96],
              etiqueta: textos.lealtadCargando,
            ),
          ),
          error: (error, _) => MarcoPantalla.estado(
            icono: LucideIcons300.gift,
            titulo: titulo,
            conRegreso: true,
            estado: EstadoError(
              causa: error is SinConexion
                  ? CausaError.sinConexion
                  : CausaError.generico,
              textoReintentar: textos.lealtadReintentar,
              alReintentar: () => ref.invalidate(recompensasProvider),
            ),
          ),
          data: (recompensas) => recompensas.isEmpty
              ? MarcoPantalla.estado(
                  icono: LucideIcons300.gift,
                  titulo: titulo,
                  conRegreso: true,
                  estado: EstadoVacio(
                    titulo: textos.recompensasVaciaTitulo,
                    mensaje: textos.recompensasVaciaMensaje,
                    icono: LucideIcons300.gift,
                  ),
                )
              : MarcoPantalla(
                  icono: LucideIcons300.gift,
                  titulo: titulo,
                  subtitulo: saldo == null
                      ? null
                      : textos.recompensasSaldo(puntosLealtad(context, saldo)),
                  conRegreso: true,
                  alRefrescar: () {
                    ref.invalidate(resumenLealtadProvider);
                    return ref.refresh(recompensasProvider.future);
                  },
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Espaciado.e4,
                      ),
                      sliver: SliverList.list(
                        children: [
                          const SizedBox(height: Espaciado.e2),
                          for (final recompensa in recompensas) ...[
                            TarjetaRecompensa(
                              recompensa: recompensa,
                              saldo: saldo,
                              alCanjear: _canjeando || saldo == null
                                  ? null
                                  : () => _canjear(recompensa, saldo),
                            ),
                            const SizedBox(height: Espaciado.e3),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
        );
  }
}

/// Una recompensa como tarjeta: nombre, costo, descripcion y si se puede
/// canjear, se agoto o cuanto falta. Solo se toca si alcanza y hay.
class TarjetaRecompensa extends StatelessWidget {
  const TarjetaRecompensa({
    required this.recompensa,
    required this.saldo,
    super.key,
    this.alCanjear,
  });

  final Recompensa recompensa;

  /// Nulo mientras no se conoce: no se ofrece canjear.
  final int? saldo;
  final VoidCallback? alCanjear;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final saldo = this.saldo;
    final falta = saldo == null ? 0 : recompensa.puntos - saldo;
    final alcanza = saldo != null && falta <= 0 && !recompensa.agotada;
    String? estado;
    var tono = Tono.neutro;
    if (recompensa.agotada) {
      estado = textos.recompensasAgotada;
      tono = Tono.peligro;
    } else if (falta > 0) {
      estado = textos.recompensasTeFaltan(puntosLealtad(context, falta));
    } else if (alcanza) {
      estado = textos.recompensasDisponible;
      tono = Tono.exito;
    }
    return TarjetaResumen(
      titulo: recompensa.nombre,
      subtitulo: textos.recompensasCosto(
        puntosLealtad(context, recompensa.puntos),
      ),
      detalle: recompensa.descripcion,
      icono: LucideIcons300.gift,
      tono: alcanza ? Tono.informacion : Tono.neutro,
      estado: estado,
      tonoEstado: tono,
      alToque: alcanza ? alCanjear : null,
    );
  }
}
