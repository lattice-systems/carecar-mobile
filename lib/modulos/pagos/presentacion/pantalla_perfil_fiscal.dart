import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/control_binario.dart';
import '../../../nucleo/diseno/componentes/dialogo.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/selector.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../dominio/datos_fiscales.dart';
import '../dominio/repositorio_datos_fiscales.dart';
import 'formato_datos_fiscales.dart';
import 'proveedores_datos_fiscales.dart';

/// Alta y edicion de datos fiscales (V2-M08.05).
///
/// El RFC dice si es persona fisica o moral y, con eso, el regimen solo ofrece
/// los de esa persona y el uso de CFDI solo los que acepta el regimen elegido
/// (los catalogos vienen del servidor). Las reglas del SAT se revisan antes de
/// enviar y, si el servidor rechaza algo (`DATOS_FISCALES_INVALIDOS`), su
/// explicacion aparece en el campo. Con `perfilId` se edita y se puede borrar
/// con confirmacion. Al guardar o borrar regresa a la lista.
class PantallaPerfilFiscal extends ConsumerWidget {
  const PantallaPerfilFiscal({super.key, this.perfilId});

  /// El perfil que se edita; nulo es un alta.
  final int? perfilId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final id = perfilId;
    final titulo = id == null
        ? textos.datosFiscalesNuevoTitulo
        : textos.datosFiscalesEditarTitulo;
    final catalogo = ref.watch(catalogoFiscalProvider);
    final perfiles = id == null ? null : ref.watch(perfilesFiscalesProvider);

    Widget estado(Widget hijo) => MarcoPantalla.estado(
      icono: LucideIcons300.receipt,
      titulo: titulo,
      conRegreso: true,
      estado: hijo,
    );

    final error = catalogo.error ?? perfiles?.error;
    if (error != null) {
      return estado(
        EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          textoReintentar: textos.datosFiscalesReintentar,
          alReintentar: () {
            ref.invalidate(catalogoFiscalProvider);
            if (id != null) ref.invalidate(perfilesFiscalesProvider);
          },
        ),
      );
    }
    final delCatalogo = catalogo.value;
    final lista = perfiles?.value;
    if (delCatalogo == null || (id != null && lista == null)) {
      return estado(
        Semantics(
          label: textos.datosFiscalesCargando,
          liveRegion: true,
          child: const Padding(
            padding: EdgeInsets.all(Espaciado.e4),
            child: Column(
              children: [
                Esqueleto(alto: 56),
                SizedBox(height: Espaciado.e3),
                Esqueleto(alto: 56),
                SizedBox(height: Espaciado.e3),
                Esqueleto(alto: 56),
              ],
            ),
          ),
        ),
      );
    }
    final editando = id == null
        ? null
        : lista!.where((p) => p.id == id).firstOrNull;
    if (id != null && editando == null) {
      return estado(
        EstadoVacio(
          titulo: textos.datosFiscalesNoEncontradoTitulo,
          mensaje: textos.datosFiscalesNoEncontradoMensaje,
          icono: LucideIcons300.searchX,
        ),
      );
    }
    return FormularioPerfilFiscal(
      key: ValueKey(('perfil-fiscal', id)),
      titulo: titulo,
      catalogo: delCatalogo,
      editando: editando,
    );
  }
}

/// Por que no se pudo seguir: lo que se explica en un aviso arriba.
enum _Aviso { revisa, sinConexion, guardar, borrar }

/// El formulario ya con su catalogo y, si se edita, su perfil.
class FormularioPerfilFiscal extends ConsumerStatefulWidget {
  const FormularioPerfilFiscal({
    required this.titulo,
    required this.catalogo,
    super.key,
    this.editando,
  });

  final String titulo;
  final CatalogoFiscal catalogo;
  final PerfilFiscal? editando;

  @override
  ConsumerState<FormularioPerfilFiscal> createState() =>
      _EstadoFormularioPerfilFiscal();
}

class _EstadoFormularioPerfilFiscal
    extends ConsumerState<FormularioPerfilFiscal> {
  late final _rfc = TextEditingController(text: widget.editando?.rfc);
  late final _razon = TextEditingController(text: widget.editando?.razonSocial);
  late final _codigoPostal = TextEditingController(
    text: widget.editando?.codigoPostal,
  );
  late final _correo = TextEditingController(text: widget.editando?.correo);
  late String? _regimen = widget.editando?.regimenFiscal;
  late String? _uso = widget.editando?.usoCfdi;
  bool _predeterminado = false;
  bool _intentado = false;
  bool _ocupado = false;
  _Aviso? _aviso;
  Map<CampoFiscal, String> _delServidor = const {};

  @override
  void dispose() {
    for (final c in [_rfc, _razon, _codigoPostal, _correo]) {
      c.dispose();
    }
    super.dispose();
  }

  BorradorPerfilFiscal get _borrador => BorradorPerfilFiscal(
    rfc: _rfc.text,
    razonSocial: _razon.text,
    codigoPostal: _codigoPostal.text,
    regimenFiscal: _regimen,
    usoCfdi: _uso,
    correo: _correo.text,
    predeterminado: _predeterminado,
  );

  /// Un cambio en un campo borra lo que dijo el servidor de ese campo y, si la
  /// persona o el regimen ya no admiten lo elegido, lo suelta.
  void _cambio(CampoFiscal campo) {
    setState(() {
      _delServidor = Map.of(_delServidor)..remove(campo);
      _aviso = null;
      final persona = _borrador.tipoPersona;
      final regimen = widget.catalogo.regimen(_regimen);
      if (persona != null && regimen != null && !regimen.aplicaA(persona)) {
        _regimen = null;
      }
      final uso = widget.catalogo.uso(_uso);
      if (uso != null &&
          ((persona != null && !uso.aplicaA(persona)) ||
              (_regimen != null && !uso.aceptaRegimen(_regimen!)))) {
        _uso = null;
      }
    });
  }

  Future<void> _guardar() async {
    setState(() => _intentado = true);
    final borrador = _borrador;
    if (borrador.errores(widget.catalogo).isNotEmpty) {
      setState(() => _aviso = _Aviso.revisa);
      return;
    }
    setState(() {
      _ocupado = true;
      _aviso = null;
    });
    final notifier = ref.read(perfilesFiscalesProvider.notifier);
    try {
      final editando = widget.editando;
      if (editando == null) {
        await notifier.crear(borrador);
      } else {
        await notifier.editar(editando.id, borrador);
      }
      if (!mounted) return;
      context.pop();
    } on DatosFiscalesRechazados catch (rechazo) {
      if (!mounted) return;
      setState(() {
        _delServidor = rechazo.campos;
        _aviso = _Aviso.revisa;
      });
    } on SinConexion {
      if (!mounted) return;
      setState(() => _aviso = _Aviso.sinConexion);
    } on Object {
      if (!mounted) return;
      setState(() => _aviso = _Aviso.guardar);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _confirmarBorrado() async {
    final textos = AppLocalizations.of(context);
    final perfil = widget.editando!;
    final confirmo = await mostrarDialogo<bool>(
      context,
      builder: (contexto) => Dialogo(
        titulo: textos.datosFiscalesBorrarTitulo,
        mensaje: textos.datosFiscalesBorrarMensaje(perfil.rfc),
        textoPrincipal: textos.datosFiscalesBorrarConfirmar,
        alPrincipal: () => Navigator.of(contexto).pop(true),
        textoSecundario: textos.datosFiscalesBorrarCancelar,
        alSecundario: () => Navigator.of(contexto).pop(false),
        peligro: true,
      ),
    );
    if (confirmo != true || !mounted) return;
    setState(() {
      _ocupado = true;
      _aviso = null;
    });
    try {
      await ref.read(perfilesFiscalesProvider.notifier).borrar(perfil.id);
      if (!mounted) return;
      context.pop();
    } on SinConexion {
      if (!mounted) return;
      setState(() => _aviso = _Aviso.sinConexion);
    } on Object {
      if (!mounted) return;
      setState(() => _aviso = _Aviso.borrar);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  /// Lo que dijo el servidor del campo y, si no, lo que dicen las reglas
  /// locales despues del primer intento.
  String? _error(
    AppLocalizations textos,
    Map<CampoFiscal, MotivoFiscal> locales,
    CampoFiscal campo,
  ) {
    final delServidor = _delServidor[campo];
    if (delServidor != null) return delServidor;
    final motivo = _intentado ? locales[campo] : null;
    return motivo == null ? null : textoMotivoFiscal(textos, motivo);
  }

  String _avisoTexto(AppLocalizations textos, _Aviso aviso) => switch (aviso) {
    _Aviso.revisa => textos.datosFiscalesRevisa,
    _Aviso.sinConexion => textos.datosFiscalesSinConexion,
    _Aviso.guardar => textos.datosFiscalesErrorGuardar,
    _Aviso.borrar => textos.datosFiscalesErrorBorrar,
  };

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    // Mantiene viva la lista mientras se guarda: al volver ya trae el cambio.
    ref.listen(perfilesFiscalesProvider, (_, _) {});
    final catalogo = widget.catalogo;
    final borrador = _borrador;
    final locales = borrador.errores(catalogo);
    final persona = borrador.tipoPersona;
    final regimenes = catalogo.regimenesPara(persona);
    final usos = catalogo.usosPara(persona, _regimen);
    final editando = widget.editando;
    final yaEsPredeterminado = editando?.predeterminado ?? false;
    final aviso = _aviso;

    return MarcoPantalla(
      icono: LucideIcons300.receipt,
      titulo: widget.titulo,
      conRegreso: true,
      barraInferior: BarraInferior(
        hijos: [
          BotonPildora(
            texto: textos.datosFiscalesGuardar,
            expandido: true,
            cargando: _ocupado,
            alPresionar: _ocupado ? null : _guardar,
          ),
          if (editando != null) ...[
            const SizedBox(height: Espaciado.e2),
            BotonPildora(
              texto: textos.datosFiscalesBorrar,
              icono: LucideIcons300.trash2,
              variante: VarianteBotonPildora.vidrio,
              expandido: true,
              alPresionar: _ocupado ? null : _confirmarBorrado,
            ),
          ],
        ],
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (aviso != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Espaciado.e4,
                    Espaciado.e2,
                    Espaciado.e4,
                    0,
                  ),
                  child: Aviso(
                    mensaje: _avisoTexto(textos, aviso),
                    tono: aviso == _Aviso.revisa
                        ? Tono.advertencia
                        : Tono.peligro,
                  ),
                ),
              SeccionPantalla(
                titulo: textos.datosFiscalesSeccionContribuyente,
                hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CampoTexto(
                      etiqueta: textos.datosFiscalesRfc,
                      sugerencia: textos.datosFiscalesRfcSugerencia,
                      controlador: _rfc,
                      accionTeclado: TextInputAction.next,
                      formatos: [
                        LengthLimitingTextInputFormatter(13),
                        const _Mayusculas(),
                      ],
                      ayuda: persona == null
                          ? textos.datosFiscalesRfcAyuda
                          : textoPersona(textos, persona),
                      error: _error(textos, locales, CampoFiscal.rfc),
                      alCambiar: (_) => _cambio(CampoFiscal.rfc),
                    ),
                    const SizedBox(height: Espaciado.e3),
                    CampoTexto(
                      etiqueta: textos.datosFiscalesRazonSocial,
                      controlador: _razon,
                      teclado: TextInputType.name,
                      accionTeclado: TextInputAction.next,
                      formatos: [
                        LengthLimitingTextInputFormatter(
                          BorradorPerfilFiscal.maxRazonSocial,
                        ),
                      ],
                      ayuda: textos.datosFiscalesRazonSocialAyuda,
                      error: _error(textos, locales, CampoFiscal.razonSocial),
                      alCambiar: (_) => _cambio(CampoFiscal.razonSocial),
                    ),
                    const SizedBox(height: Espaciado.e3),
                    CampoTexto(
                      etiqueta: textos.datosFiscalesCodigoPostal,
                      controlador: _codigoPostal,
                      teclado: TextInputType.number,
                      accionTeclado: TextInputAction.next,
                      formatos: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      pistasAutocompletar: const [AutofillHints.postalCode],
                      ayuda: textos.datosFiscalesCodigoPostalAyuda,
                      error: _error(textos, locales, CampoFiscal.codigoPostal),
                      alCambiar: (_) => _cambio(CampoFiscal.codigoPostal),
                    ),
                  ],
                ),
              ),
              SeccionPantalla(
                titulo: textos.datosFiscalesSeccionFacturar,
                hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Selector<String>(
                      key: ValueKey(('regimen', persona, _regimen)),
                      etiqueta: textos.datosFiscalesRegimen,
                      sugerencia: textos.datosFiscalesRegimenSugerencia,
                      opciones: [
                        for (final r in regimenes)
                          OpcionSelector(
                            valor: r.clave,
                            texto: textos.datosFiscalesOpcion(
                              r.clave,
                              r.descripcion,
                            ),
                          ),
                      ],
                      valor: _regimen,
                      error: _error(textos, locales, CampoFiscal.regimenFiscal),
                      alCambiar: _ocupado
                          ? null
                          : (clave) {
                              _regimen = clave;
                              _cambio(CampoFiscal.regimenFiscal);
                            },
                    ),
                    const SizedBox(height: Espaciado.e3),
                    Selector<String>(
                      key: ValueKey(('uso', persona, _regimen, _uso)),
                      etiqueta: textos.datosFiscalesUso,
                      sugerencia: textos.datosFiscalesUsoSugerencia,
                      ayuda: textos.datosFiscalesUsoAyuda,
                      opciones: [
                        for (final u in usos)
                          OpcionSelector(
                            valor: u.clave,
                            texto: textos.datosFiscalesOpcion(
                              u.clave,
                              u.descripcion,
                            ),
                          ),
                      ],
                      valor: _uso,
                      error: _error(textos, locales, CampoFiscal.usoCfdi),
                      alCambiar: _ocupado
                          ? null
                          : (clave) {
                              _uso = clave;
                              _cambio(CampoFiscal.usoCfdi);
                            },
                    ),
                    const SizedBox(height: Espaciado.e3),
                    CampoTexto(
                      etiqueta: textos.datosFiscalesCorreo,
                      controlador: _correo,
                      teclado: TextInputType.emailAddress,
                      accionTeclado: TextInputAction.done,
                      pistasAutocompletar: const [AutofillHints.email],
                      error: _error(textos, locales, CampoFiscal.correo),
                      alCambiar: (_) => _cambio(CampoFiscal.correo),
                    ),
                    if (!yaEsPredeterminado) ...[
                      const SizedBox(height: Espaciado.e3),
                      Casilla(
                        etiqueta: textos.datosFiscalesHacerPredeterminado,
                        descripcion:
                            textos.datosFiscalesHacerPredeterminadoAyuda,
                        valor: _predeterminado,
                        alCambiar: (valor) =>
                            setState(() => _predeterminado = valor),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pasa a mayusculas lo que se escribe, como se guarda el RFC.
class _Mayusculas extends TextInputFormatter {
  const _Mayusculas();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue nuevo,
  ) => nuevo.copyWith(text: nuevo.text.toUpperCase());
}
