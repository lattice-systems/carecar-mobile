import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/dialogo.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/mapas/mapas.dart';
import '../dominio/direccion_guardada.dart';
import '../dominio/fallos_recoleccion.dart';
import 'componentes/marco_pantalla_recoleccion.dart';
import 'proveedores_recoleccion.dart';
import 'provisional/mapa_provisional.dart';

/// Por qué no se pudo seguir: lo que se explica en un aviso dentro de la
/// pantalla.
enum _Aviso {
  cobertura,
  sinConexion,
  guardar,
  enUso,
  borrar,
  ubicacionDenegada,
  ubicacionApagada,
  ubicacionTiempo,
  sinResultados,
  errorBusqueda,
}

/// Alta y edición de una dirección con su pin en el mapa (V2-M17.01).
///
/// El pin se pone tocando el mapa, con «Usar mi ubicación» o buscando la
/// dirección escrita; en los tres casos los campos vacíos se completan con la
/// dirección que devuelve el geocodificador, sin pisar lo que la persona ya
/// escribió. Si el pin queda fuera de la zona de cobertura se avisa y no se
/// guarda. Con `editando` también se puede borrar, con confirmación.
class PantallaDireccion extends ConsumerStatefulWidget {
  const PantallaDireccion({super.key, this.editando});

  /// La dirección que se edita; nulo es un alta.
  final DireccionGuardada? editando;

  @override
  ConsumerState<PantallaDireccion> createState() => _EstadoPantallaDireccion();
}

class _EstadoPantallaDireccion extends ConsumerState<PantallaDireccion> {
  late final _alias = TextEditingController(text: widget.editando?.alias);
  late final _calle = TextEditingController(text: widget.editando?.calle);
  late final _colonia = TextEditingController(text: widget.editando?.colonia);
  late final _cp = TextEditingController(text: widget.editando?.cp);
  late final _ciudad = TextEditingController(text: widget.editando?.ciudad);
  final _busqueda = TextEditingController();

  late Coordenada? _pin = widget.editando?.ubicacion;
  bool _intentado = false;
  bool _ocupado = false;
  _Aviso? _aviso;

  @override
  void dispose() {
    for (final c in [_alias, _calle, _colonia, _cp, _ciudad, _busqueda]) {
      c.dispose();
    }
    super.dispose();
  }

  BorradorDireccion get _borrador => BorradorDireccion(
    alias: _alias.text,
    calle: _calle.text,
    colonia: _colonia.text,
    cp: _cp.text,
    ciudad: _ciudad.text,
    ubicacion: _pin,
  );

  /// Pone el pin y completa los campos vacíos con la dirección de ese punto.
  Future<void> _ponerPin(Coordenada punto) async {
    setState(() {
      _pin = punto;
      _aviso = null;
    });
    try {
      final direccion = await ref
          .read(geocodificadorProvider)
          .direccionDe(punto);
      if (!mounted || direccion == null || _pin != punto) return;
      setState(() {
        _completar(_calle, direccion.calle);
        _completar(_colonia, direccion.colonia);
        _completar(_cp, direccion.codigoPostal);
        _completar(_ciudad, direccion.ciudad);
      });
    } on ErrorGeocodificacion {
      // El pin ya quedó puesto; la persona escribe los campos a mano.
    }
  }

  static void _completar(TextEditingController campo, String? valor) {
    if (campo.text.trim().isEmpty && valor != null && valor.isNotEmpty) {
      campo.text = valor;
    }
  }

  Future<void> _usarUbicacion() async {
    setState(() {
      _ocupado = true;
      _aviso = null;
    });
    try {
      final punto = await ref.read(proveedorUbicacionProvider).posicionActual();
      if (!mounted) return;
      await _ponerPin(punto);
    } on ErrorUbicacion catch (e) {
      if (!mounted) return;
      setState(
        () => _aviso = switch (e) {
          UbicacionPermisoDenegado() ||
          UbicacionPermisoDenegadoParaSiempre() => _Aviso.ubicacionDenegada,
          UbicacionServicioApagado() => _Aviso.ubicacionApagada,
          UbicacionTiempoAgotado() => _Aviso.ubicacionTiempo,
        },
      );
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _buscar() async {
    final texto = _busqueda.text.trim();
    if (texto.isEmpty) return;
    setState(() {
      _ocupado = true;
      _aviso = null;
    });
    try {
      final punto = await ref.read(geocodificadorProvider).coordenadasDe(texto);
      if (!mounted) return;
      if (punto == null) {
        setState(() => _aviso = _Aviso.sinResultados);
      } else {
        await _ponerPin(punto);
      }
    } on ErrorGeocodificacion {
      if (!mounted) return;
      setState(() => _aviso = _Aviso.errorBusqueda);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _guardar() async {
    setState(() => _intentado = true);
    final borrador = _borrador;
    if (borrador.camposInvalidos.isNotEmpty) return;
    setState(() {
      _ocupado = true;
      _aviso = null;
    });
    final notifier = ref.read(direccionesProvider.notifier);
    try {
      final editando = widget.editando;
      if (editando == null) {
        await notifier.guardar(borrador);
      } else {
        await notifier.editar(editando.id, borrador);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } on FueraDeCobertura {
      if (!mounted) return;
      setState(() => _aviso = _Aviso.cobertura);
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
    final direccion = widget.editando!;
    final confirmo = await mostrarDialogo<bool>(
      context,
      builder: (contexto) => Dialogo(
        titulo: textos.recoleccionBorrarTitulo,
        mensaje: textos.recoleccionBorrarMensaje(direccion.alias),
        textoPrincipal: textos.recoleccionBorrarConfirmar,
        alPrincipal: () => Navigator.of(contexto).pop(true),
        textoSecundario: textos.recoleccionBorrarCancelar,
        alSecundario: () => Navigator.of(contexto).pop(false),
        peligro: true,
      ),
    );
    if (confirmo != true || !mounted) return;
    setState(() {
      _ocupado = true;
      _aviso = null;
    });
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    try {
      await ref.read(direccionesProvider.notifier).borrar(direccion.id);
      mensajero.showSnackBar(
        SnackBar(content: Text(textos.recoleccionDireccionBorrada)),
      );
      navegador.pop();
    } on DireccionEnUso {
      if (!mounted) return;
      setState(() => _aviso = _Aviso.enUso);
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

  String? _error(CampoDireccion campo, String texto) =>
      _intentado && _borrador.camposInvalidos.contains(campo) ? texto : null;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final editando = widget.editando != null;

    return MarcoPantallaRecoleccion(
      titulo: editando
          ? textos.recoleccionFormEditarTitulo
          : textos.recoleccionFormNuevaTitulo,
      barraInferior: BarraInferiorRecoleccion(
        hijos: [
          BotonPildora(
            texto: textos.recoleccionGuardar,
            expandido: true,
            alPresionar: _ocupado ? null : _guardar,
          ),
          if (editando) ...[
            const SizedBox(height: Espaciado.e2),
            BotonPildora(
              texto: textos.recoleccionBorrar,
              icono: Icons.delete_outline,
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
              if (_aviso != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Espaciado.e4,
                    Espaciado.e2,
                    Espaciado.e4,
                    0,
                  ),
                  child: _avisoWidget(textos, _aviso!),
                ),
              SeccionRecoleccion(
                titulo: textos.recoleccionFormUbicacionTitulo,
                hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MapaProvisional(pin: _pin, alElegir: _ponerPin),
                    const SizedBox(height: Espaciado.e2),
                    Text(
                      textos.recoleccionFormPinAyuda,
                      style: tokens.tipografia.cuerpoChico.copyWith(
                        color: c.textoSecundario,
                      ),
                    ),
                    if (_intentado && _pin == null)
                      Padding(
                        padding: const EdgeInsets.only(top: Espaciado.e1),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            textos.recoleccionFormPinFalta,
                            style: tokens.tipografia.cuerpoChico.copyWith(
                              color: c.peligro,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: Espaciado.e3),
                    BotonPildora(
                      texto: textos.recoleccionFormUsarUbicacion,
                      icono: Icons.my_location_outlined,
                      variante: VarianteBotonPildora.vidrio,
                      expandido: true,
                      alPresionar: _ocupado ? null : _usarUbicacion,
                    ),
                    const SizedBox(height: Espaciado.e3),
                    CampoTexto(
                      etiqueta: textos.recoleccionFormBuscarEtiqueta,
                      sugerencia: textos.recoleccionFormBuscarSugerencia,
                      controlador: _busqueda,
                      accionTeclado: TextInputAction.search,
                      alEnviar: (_) => _buscar(),
                      sufijo: IconButton(
                        tooltip: textos.recoleccionFormBuscarAccion,
                        constraints: const BoxConstraints(
                          minWidth: Espaciado.objetivoTactilMinimo,
                          minHeight: Espaciado.objetivoTactilMinimo,
                        ),
                        icon: Icon(Icons.search_rounded, color: c.acento),
                        onPressed: _ocupado ? null : _buscar,
                      ),
                    ),
                  ],
                ),
              ),
              SeccionRecoleccion(
                titulo: textos.recoleccionSelectorDireccion,
                hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CampoTexto(
                      etiqueta: textos.recoleccionFormAliasEtiqueta,
                      sugerencia: textos.recoleccionFormAliasSugerencia,
                      controlador: _alias,
                      accionTeclado: TextInputAction.next,
                      error: _error(
                        CampoDireccion.alias,
                        textos.recoleccionErrorAlias,
                      ),
                    ),
                    const SizedBox(height: Espaciado.e3),
                    CampoTexto(
                      etiqueta: textos.recoleccionFormCalleEtiqueta,
                      controlador: _calle,
                      accionTeclado: TextInputAction.next,
                      pistasAutocompletar: const [
                        AutofillHints.streetAddressLine1,
                      ],
                      error: _error(
                        CampoDireccion.calle,
                        textos.recoleccionErrorCalle,
                      ),
                    ),
                    const SizedBox(height: Espaciado.e3),
                    CampoTexto(
                      etiqueta: textos.recoleccionFormColoniaEtiqueta,
                      controlador: _colonia,
                      accionTeclado: TextInputAction.next,
                      error: _error(
                        CampoDireccion.colonia,
                        textos.recoleccionErrorColonia,
                      ),
                    ),
                    const SizedBox(height: Espaciado.e3),
                    CampoTexto(
                      etiqueta: textos.recoleccionFormCpEtiqueta,
                      controlador: _cp,
                      teclado: TextInputType.number,
                      accionTeclado: TextInputAction.next,
                      formatos: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      pistasAutocompletar: const [AutofillHints.postalCode],
                      error: _error(
                        CampoDireccion.cp,
                        textos.recoleccionErrorCp,
                      ),
                    ),
                    const SizedBox(height: Espaciado.e3),
                    CampoTexto(
                      etiqueta: textos.recoleccionFormCiudadEtiqueta,
                      controlador: _ciudad,
                      accionTeclado: TextInputAction.done,
                      pistasAutocompletar: const [AutofillHints.addressCity],
                      error: _error(
                        CampoDireccion.ciudad,
                        textos.recoleccionErrorCiudad,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avisoWidget(AppLocalizations textos, _Aviso aviso) => switch (aviso) {
    _Aviso.cobertura => Aviso(
      titulo: textos.recoleccionCoberturaTitulo,
      mensaje: textos.recoleccionCoberturaMensaje,
      tono: Tono.advertencia,
    ),
    _Aviso.enUso => Aviso(
      mensaje: textos.recoleccionErrorEnUso,
      tono: Tono.advertencia,
    ),
    _Aviso.sinConexion => Aviso(
      mensaje: textos.recoleccionErrorSinConexion,
      tono: Tono.peligro,
    ),
    _Aviso.guardar => Aviso(
      mensaje: textos.recoleccionErrorGuardar,
      tono: Tono.peligro,
    ),
    _Aviso.borrar => Aviso(
      mensaje: textos.recoleccionErrorBorrar,
      tono: Tono.peligro,
    ),
    _Aviso.ubicacionDenegada => Aviso(
      mensaje: textos.recoleccionUbicacionDenegada,
      tono: Tono.advertencia,
    ),
    _Aviso.ubicacionApagada => Aviso(
      mensaje: textos.recoleccionUbicacionApagada,
      tono: Tono.advertencia,
    ),
    _Aviso.ubicacionTiempo => Aviso(
      mensaje: textos.recoleccionUbicacionTiempo,
      tono: Tono.advertencia,
    ),
    _Aviso.sinResultados => Aviso(
      mensaje: textos.recoleccionBusquedaSinResultados,
      tono: Tono.informacion,
    ),
    _Aviso.errorBusqueda => Aviso(
      mensaje: textos.recoleccionBusquedaError,
      tono: Tono.advertencia,
    ),
  };
}
