import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/control_binario.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/lealtad.dart';
import '../dominio/repositorio_lealtad.dart';
import 'formato_lealtad.dart';
import 'proveedores_lealtad.dart';

/// Referir a un amigo (V2-M12.04): mi codigo personal para compartir con la
/// hoja del sistema, el formulario para registrar a un amigo con su nombre y
/// telefono o correo (sin la casilla de que acepto que lo contacten no se
/// envia) y la lista de mis referidos con su estado. `REFERIDO_DUPLICADO` no
/// dice de quien y `LIMITE_REFERIDOS` pide esperar. Se recarga jalando hacia
/// abajo.
class PantallaReferir extends ConsumerStatefulWidget {
  const PantallaReferir({super.key});

  @override
  ConsumerState<PantallaReferir> createState() => _PantallaReferirState();
}

class _PantallaReferirState extends ConsumerState<PantallaReferir> {
  static final _correo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _correoAmigo = TextEditingController();
  bool _consentimiento = false;
  bool _enviando = false;
  String? _rechazo;
  String? _enviado;

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _correoAmigo.dispose();
    super.dispose();
  }

  String get _telefonoCapturado => _telefono.text.trim();

  String get _correoCapturado => _correoAmigo.text.trim();

  bool get _telefonoValido =>
      _telefonoCapturado.isEmpty || _telefonoCapturado.length == 10;

  bool get _correoValido =>
      _correoCapturado.isEmpty || _correo.hasMatch(_correoCapturado);

  bool get _listo =>
      _nombre.text.trim().isNotEmpty &&
      (_telefonoCapturado.isNotEmpty || _correoCapturado.isNotEmpty) &&
      _telefonoValido &&
      _correoValido &&
      _consentimiento &&
      !_enviando;

  void _cambio() => setState(() {
    _rechazo = null;
    _enviado = null;
  });

  Future<void> _enviar() async {
    final textos = AppLocalizations.of(context);
    final nombre = _nombre.text.trim();
    setState(() {
      _enviando = true;
      _rechazo = null;
      _enviado = null;
    });
    try {
      await ref
          .read(referidosProvider.notifier)
          .referir(
            nombre: nombre,
            telefono: _telefonoCapturado.isEmpty ? null : _telefonoCapturado,
            correo: _correoCapturado.isEmpty ? null : _correoCapturado,
          );
      if (!mounted) return;
      _nombre.clear();
      _telefono.clear();
      _correoAmigo.clear();
      setState(() {
        _enviando = false;
        _consentimiento = false;
        _enviado = textos.referirEnviado(nombre);
      });
    } on ReferidoRechazado catch (rechazo) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _rechazo = switch (rechazo.motivo) {
          MotivoRechazoReferido.duplicado => textos.referirDuplicado,
          MotivoRechazoReferido.limite => textos.referirLimite,
        };
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _rechazo = textos.referirError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final rechazo = _rechazo;
    final enviado = _enviado;

    return MarcoPantalla(
      titulo: textos.referirTitulo,
      subtitulo: textos.referirSubtitulo,
      conRegreso: true,
      alRefrescar: () {
        ref.invalidate(resumenLealtadProvider);
        return ref.refresh(referidosProvider.future);
      },
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _MiCodigo(),
              SeccionPantalla(
                titulo: textos.referirFormularioTitulo,
                nota: textos.referirFormularioNota,
                hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CampoTexto(
                      etiqueta: textos.referirNombre,
                      controlador: _nombre,
                      teclado: TextInputType.name,
                      accionTeclado: TextInputAction.next,
                      pistasAutocompletar: const [AutofillHints.name],
                      alCambiar: (_) => _cambio(),
                    ),
                    const SizedBox(height: Espaciado.e3),
                    CampoTexto(
                      etiqueta: textos.referirTelefono,
                      controlador: _telefono,
                      teclado: TextInputType.phone,
                      accionTeclado: TextInputAction.next,
                      formatos: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      ayuda: textos.referirTelefonoAyuda,
                      error: _telefonoValido
                          ? null
                          : textos.referirTelefonoInvalido,
                      alCambiar: (_) => _cambio(),
                    ),
                    const SizedBox(height: Espaciado.e3),
                    CampoTexto(
                      etiqueta: textos.referirCorreo,
                      controlador: _correoAmigo,
                      teclado: TextInputType.emailAddress,
                      accionTeclado: TextInputAction.done,
                      error: _correoValido
                          ? null
                          : textos.referirCorreoInvalido,
                      alCambiar: (_) => _cambio(),
                    ),
                    const SizedBox(height: Espaciado.e3),
                    Casilla(
                      etiqueta: textos.referirConsentimiento,
                      valor: _consentimiento,
                      alCambiar: (valor) => setState(() {
                        _consentimiento = valor;
                        _rechazo = null;
                        _enviado = null;
                      }),
                    ),
                    if (rechazo != null) ...[
                      const SizedBox(height: Espaciado.e3),
                      Aviso(mensaje: rechazo, tono: Tono.advertencia),
                    ],
                    if (enviado != null) ...[
                      const SizedBox(height: Espaciado.e3),
                      Aviso(mensaje: enviado, tono: Tono.exito),
                    ],
                    const SizedBox(height: Espaciado.e4),
                    BotonPildora(
                      texto: textos.referirEnviar,
                      icono: LucideIcons300.send,
                      expandido: true,
                      cargando: _enviando,
                      alPresionar: _listo ? _enviar : null,
                    ),
                  ],
                ),
              ),
              const _MisReferidos(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Mi codigo personal y el boton que lo comparte con la hoja del sistema.
class _MiCodigo extends ConsumerWidget {
  const _MiCodigo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final codigo = ref.watch(resumenLealtadProvider).value?.codigoReferido;
    return SeccionPantalla(
      titulo: textos.referirCodigoTitulo,
      nota: textos.referirCodigoAyuda,
      hijo: codigo == null
          ? const Esqueleto(alto: 96)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SelectableText(
                  codigo,
                  textAlign: TextAlign.center,
                  style: tokens.tipografia.titulo1.copyWith(
                    color: c.texto,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: Espaciado.e3),
                BotonPildora(
                  texto: textos.referirCompartir,
                  icono: LucideIcons300.share,
                  variante: VarianteBotonPildora.vidrio,
                  expandido: true,
                  alPresionar: () =>
                      _compartir(ref, textos.referirMensaje(codigo)),
                ),
              ],
            ),
    );
  }

  void _compartir(WidgetRef ref, String texto) {
    ref.read(compartirTextoProvider)(texto);
  }
}

/// Mis referidos con su estado; el que compro dice los puntos que dio.
class _MisReferidos extends ConsumerWidget {
  const _MisReferidos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final t = TokensPista.de(context).tipografia;
    final c = TokensPista.de(context).colores;
    final referidos = ref.watch(referidosProvider);
    return SeccionPantalla(
      titulo: textos.referirListaTitulo,
      nota: textos.referirPuntosAyuda,
      hijo: switch (referidos) {
        AsyncData(:final value) when value.isEmpty => Text(
          textos.referirVacio,
          style: t.cuerpo.copyWith(color: c.textoSecundario),
        ),
        AsyncData(:final value) => GrupoLista(
          filas: [for (final r in value) filaReferido(context, r)],
        ),
        AsyncError() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Aviso(mensaje: textos.referirListaError, tono: Tono.peligro),
            const SizedBox(height: Espaciado.e2),
            BotonPildora(
              texto: textos.lealtadReintentar,
              variante: VarianteBotonPildora.vidrio,
              icono: LucideIcons300.refreshCw,
              alPresionar: () => ref.invalidate(referidosProvider),
            ),
          ],
        ),
        _ => const Esqueleto(alto: 120),
      },
    );
  }
}

/// Un referido como fila: nombre, estado y desde cuando; si compro, los
/// puntos que dio al final.
FilaGrupo filaReferido(BuildContext context, Referido r) {
  final textos = AppLocalizations.of(context);
  final tokens = TokensPista.de(context);
  final c = tokens.colores;
  final compro = r.estado == EstadoReferido.compro && r.puntos > 0;
  final puntos = puntosLealtad(context, r.puntos);
  return FilaGrupo(
    titulo: r.nombre,
    subtitulo: textos.referidoDesde(
      textoEstadoReferido(textos, r.estado),
      fechaLealtad(context, r.creadoEn),
    ),
    icono: switch (r.estado) {
      EstadoReferido.registrado => LucideIcons300.userPlus,
      EstadoReferido.enSeguimiento => LucideIcons300.headset,
      EstadoReferido.compro => LucideIcons300.partyPopper,
      EstadoReferido.descartado => LucideIcons300.userX,
    },
    colorIcono: switch (r.estado) {
      EstadoReferido.registrado => c.acento,
      EstadoReferido.enSeguimiento => c.advertencia,
      EstadoReferido.compro => c.exito,
      EstadoReferido.descartado => c.textoTerciario,
    },
    fin: compro
        ? Text(
            textos.referidoGanaste(puntos),
            style: tokens.tipografia.cuerpoFuerte.copyWith(color: c.exito),
          )
        : null,
    etiquetaFin: compro ? textos.movimientosGanaste(puntos) : null,
  );
}
