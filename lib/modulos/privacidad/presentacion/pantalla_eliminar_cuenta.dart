import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/deslizar_para_confirmar.dart';
import '../../../nucleo/diseno/componentes/superficie_liquida.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/sesion/proveedores_sesion.dart';
import '../dominio/arco.dart';
import 'proveedores_arco.dart';

/// Eliminar mi cuenta, el derecho de cancelación (ARCO, V2-M22.03).
///
/// No se puede deshacer, así que pide tres cosas: leer qué se borra y qué se
/// conserva, escribir la contraseña (confirma que es la persona y no alguien
/// con el teléfono desbloqueado) y deslizar el control hasta el final. Al
/// terminar, la cuenta ya no existe en el servidor y la sesión se cierra.
class PantallaEliminarCuenta extends ConsumerStatefulWidget {
  const PantallaEliminarCuenta({super.key});

  @override
  ConsumerState<PantallaEliminarCuenta> createState() =>
      _PantallaEliminarCuentaState();
}

/// Qué salió mal en el último intento.
enum _Fallo { contrasenaIncorrecta, bloqueada, sinConexion, error }

class _PantallaEliminarCuentaState
    extends ConsumerState<PantallaEliminarCuenta> {
  final _contrasena = TextEditingController();
  bool _eliminando = false;
  _Fallo? _fallo;

  /// Cuánto falta para volver a intentar, cuando [_fallo] es un bloqueo.
  Duration? _espera;

  @override
  void dispose() {
    _contrasena.dispose();
    super.dispose();
  }

  /// El control de deslizar solo se ofrece con una contraseña escrita; mientras
  /// se elimina ni siquiera se muestra, así que no hace falta comprobar más.
  bool get _puedeEliminar => _contrasena.text.isNotEmpty;

  Future<void> _eliminar() async {
    final contrasena = _contrasena.text;
    // Todo lo que hace falta después de esperar se toma antes: la cuenta se
    // elimina en el servidor aunque la persona salga de la pantalla, y la
    // sesión tiene que cerrarse con ella.
    final repositorio = ref.read(repositorioArcoProvider);
    final sesion = ref.read(controladorSesionProvider);
    final mensajero = ScaffoldMessenger.of(context);
    final aviso = AppLocalizations.of(context).eliminarCuentaListo;
    setState(() {
      _eliminando = true;
      _fallo = null;
    });
    try {
      await repositorio.cancelarCuenta(contrasena);
    } on CuentaYaCerrada {
      // Ya estaba hecho (por ejemplo, la respuesta anterior se perdió): lo que
      // se pedía es lo que hay, así que se sigue como si hubiera terminado.
    } on Object catch (fallo) {
      if (!mounted) return;
      setState(() {
        _eliminando = false;
        _fallo = switch (fallo) {
          ContrasenaIncorrecta() => _Fallo.contrasenaIncorrecta,
          CancelacionBloqueada() => _Fallo.bloqueada,
          ArcoSinConexion() => _Fallo.sinConexion,
          _ => _Fallo.error,
        };
        _espera = fallo is CancelacionBloqueada ? fallo.espera : null;
      });
      return;
    }
    // Cerrar la sesión lleva a la entrada; el aviso vive en el mensajero de
    // la app y sobrevive al cambio de pantalla.
    try {
      await sesion.cerrarSesion();
    } finally {
      mensajero.showSnackBar(SnackBar(content: Text(aviso)));
    }
  }

  String _textoDelBloqueo(AppLocalizations textos) {
    final espera = _espera;
    if (espera == null || espera <= Duration.zero) {
      return textos.eliminarCuentaBloqueadaSinEspera;
    }
    // Hacia arriba y sobre el tiempo exacto: 61 s son 2 minutos y medio segundo,
    // uno; nunca «0 minutos».
    final minutos = (espera.inMicroseconds / Duration.microsecondsPerMinute)
        .ceil();
    return textos.eliminarCuentaBloqueada(minutos);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final aviso = switch (_fallo) {
      _Fallo.bloqueada => Aviso(
        mensaje: _textoDelBloqueo(textos),
        tono: Tono.advertencia,
      ),
      _Fallo.sinConexion => Aviso(
        mensaje: textos.eliminarCuentaSinConexion,
        tono: Tono.advertencia,
      ),
      _Fallo.error => Aviso(
        mensaje: textos.eliminarCuentaError,
        tono: Tono.peligro,
      ),
      _ => null,
    };

    return MarcoPantalla(
      icono: LucideIcons300.userX,
      tono: Tono.peligro,
      titulo: textos.eliminarCuentaTitulo,
      conRegreso: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(Espaciado.e4),
          sliver: SliverList.list(
            children: [
              Aviso(
                titulo: textos.eliminarCuentaAdvertenciaTitulo,
                mensaje: textos.eliminarCuentaAdvertencia,
                tono: Tono.peligro,
              ),
              const SizedBox(height: Espaciado.e5),
              _Lista(
                titulo: textos.eliminarCuentaSeBorraTitulo,
                icono: LucideIcons300.trash2,
                lineas: [
                  textos.eliminarCuentaBorra1,
                  textos.eliminarCuentaBorra2,
                  textos.eliminarCuentaBorra3,
                  textos.eliminarCuentaBorra4,
                ],
              ),
              const SizedBox(height: Espaciado.e4),
              _Lista(
                titulo: textos.eliminarCuentaConservaTitulo,
                icono: LucideIcons300.package,
                lineas: [textos.eliminarCuentaConserva],
              ),
              const SizedBox(height: Espaciado.e5),
              CampoContrasena(
                etiqueta: textos.eliminarCuentaContrasena,
                ayuda: textos.eliminarCuentaContrasenaAyuda,
                controlador: _contrasena,
                habilitado: !_eliminando,
                error: _fallo == _Fallo.contrasenaIncorrecta
                    ? textos.eliminarCuentaContrasenaIncorrecta
                    : null,
                // Una contraseña nueva ya no es la que falló.
                alCambiar: (_) => setState(() {
                  if (_fallo == _Fallo.contrasenaIncorrecta) _fallo = null;
                }),
              ),
              const SizedBox(height: Espaciado.e5),
              if (aviso != null) ...[
                aviso,
                const SizedBox(height: Espaciado.e4),
              ],
              if (_eliminando)
                _Eliminando(texto: textos.eliminarCuentaEliminando)
              else
                DeslizarParaConfirmar(
                  texto: textos.eliminarCuentaDeslizar,
                  mensajeConfirmacion: textos.eliminarCuentaConfirmarMensaje,
                  peligro: true,
                  alConfirmar: _puedeEliminar ? _eliminar : null,
                ),
              const SizedBox(height: Espaciado.e6),
            ],
          ),
        ),
      ],
    );
  }
}

/// Un encabezado y sus líneas, cada una con el mismo icono.
class _Lista extends StatelessWidget {
  const _Lista({
    required this.titulo,
    required this.icono,
    required this.lineas,
  });

  final String titulo;
  final IconData icono;
  final List<String> lineas;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    return SuperficieLiquida(
      padding: const EdgeInsets.all(Espaciado.e4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(titulo, style: t.titulo3.copyWith(color: c.texto)),
          ),
          const SizedBox(height: Espaciado.e3),
          for (var i = 0; i < lineas.length; i++) ...[
            if (i > 0) const SizedBox(height: Espaciado.e2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icono, size: 20, color: c.textoSecundario),
                const SizedBox(width: Espaciado.e3),
                Expanded(
                  child: Text(
                    lineas[i],
                    style: t.cuerpo.copyWith(color: c.textoSecundario),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Mientras el servidor borra la cuenta; el lector de pantalla lo anuncia.
class _Eliminando extends StatelessWidget {
  const _Eliminando({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Espaciado.e4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ExcludeSemantics(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            const SizedBox(width: Espaciado.e3),
            Flexible(
              child: Text(
                texto,
                style: tokens.tipografia.cuerpo.copyWith(
                  color: tokens.colores.textoSecundario,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
