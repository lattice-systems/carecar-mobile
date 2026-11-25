import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/dialogo.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/selector.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/estadisticas.dart';
import '../dominio/fallos_bitacora.dart';
import '../dominio/gasto.dart';
import '../dominio/lector_ticket.dart';
import '../dominio/parser_ticket.dart';
import 'componentes/marco_bitacora.dart';
import 'formato_bitacora.dart';
import 'proveedores_bitacora.dart';

/// Lo que se explica en un aviso dentro del formulario.
enum _Aviso {
  guardar,
  borrar,
  sinConexion,
  ticketLeido,
  ticketNoLeyo,
  ticketSinPermiso,
  ticketError,
}

/// Alta y edición de un gasto (V2-M18.01 y V2-M18.04).
///
/// Con [tipoInicial] `gasolina` (o al editar una carga) pide litros, monto, km
/// y fecha, y ofrece llenarlos desde la foto del ticket (V2-M18.02). Con
/// cualquier otro tipo muestra el selector de tipo y, para «otro», la
/// descripción obligatoria. Cada campo explica su error; el 422 `KM_INVALIDO`
/// del servidor se muestra en el campo de km. Con [editando] también se puede
/// borrar, con confirmación.
class PantallaGasto extends ConsumerStatefulWidget {
  const PantallaGasto({
    required this.vehiculoId,
    super.key,
    this.tipoInicial = TipoGasto.gasolina,
    this.editando,
  });

  final int vehiculoId;
  final TipoGasto tipoInicial;

  /// El gasto que se edita; nulo es un alta.
  final Gasto? editando;

  @override
  ConsumerState<PantallaGasto> createState() => _EstadoPantallaGasto();
}

class _EstadoPantallaGasto extends ConsumerState<PantallaGasto> {
  late TipoGasto _tipo = widget.editando?.tipo ?? widget.tipoInicial;
  late final _monto = TextEditingController(
    text: widget.editando == null ? '' : _texto(widget.editando!.monto),
  );
  late final _litros = TextEditingController(
    text: widget.editando?.litros == null
        ? ''
        : _texto(widget.editando!.litros!),
  );
  late final _km = TextEditingController(
    text: widget.editando?.km?.toString() ?? '',
  );
  late final _descripcion = TextEditingController(
    text: widget.editando?.descripcion ?? '',
  );
  late DateTime _fecha = widget.editando?.fecha ?? _hoy();

  bool _intentado = false;
  bool _ocupado = false;
  bool _leyendo = false;
  bool _kmRechazado = false;
  _Aviso? _aviso;

  static String _texto(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  DateTime _hoy() {
    final h = ref.read(relojBitacoraProvider)();
    return DateTime(h.year, h.month, h.day);
  }

  @override
  void dispose() {
    for (final c in [_monto, _litros, _km, _descripcion]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _esCarga => _tipo == TipoGasto.gasolina;

  static double? _decimal(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.'));

  BorradorGasto get _borrador => BorradorGasto(
    tipo: _tipo,
    monto: _decimal(_monto.text),
    litros: _esCarga ? _decimal(_litros.text) : null,
    km: _esCarga ? int.tryParse(_km.text.trim()) : null,
    fecha: _fecha,
    descripcion: _descripcion.text,
  );

  /// La última lectura de km que conoce la app, sin contar el gasto editado.
  int? get _kmMinimo {
    final todos = ref.read(gastosProvider(widget.vehiculoId)).value;
    if (todos == null) return null;
    return kmMasAlto([
      for (final g in todos)
        if (g.id != widget.editando?.id) g,
    ]);
  }

  Set<CampoGasto> get _invalidos =>
      _borrador.camposInvalidos(hoy: _hoy(), kmMinimo: _kmMinimo);

  Future<void> _leerTicket(OrigenFoto origen) async {
    setState(() {
      _leyendo = true;
      _aviso = null;
    });
    try {
      final lectura = await ref.read(lectorTicketProvider).leer(origen);
      if (!mounted) return;
      if (lectura == null) {
        setState(() => _aviso = null);
      } else if (lectura.estaVacia) {
        setState(() => _aviso = _Aviso.ticketNoLeyo);
      } else {
        _proponer(lectura);
        setState(() => _aviso = _Aviso.ticketLeido);
      }
    } on FalloLecturaTicket catch (e) {
      if (!mounted) return;
      setState(
        () => _aviso = e.permisoDenegado
            ? _Aviso.ticketSinPermiso
            : _Aviso.ticketError,
      );
    } on Object {
      if (!mounted) return;
      setState(() => _aviso = _Aviso.ticketError);
    } finally {
      if (mounted) setState(() => _leyendo = false);
    }
  }

  /// Propone lo leído sin pisar nada con vacíos; la persona confirma o corrige.
  void _proponer(LecturaTicket l) {
    final hoy = _hoy();
    if (l.litros != null) _litros.text = _texto(l.litros!);
    if (l.monto != null) _monto.text = _texto(l.monto!);
    final f = l.fecha;
    if (f != null && !f.isAfter(hoy)) _fecha = f;
  }

  Future<void> _elegirFecha() async {
    final hoy = _hoy();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha.isAfter(hoy) ? hoy : _fecha,
      firstDate: DateTime(2000),
      lastDate: hoy,
    );
    if (elegida != null && mounted) setState(() => _fecha = elegida);
  }

  Future<void> _guardar() async {
    setState(() {
      _intentado = true;
      _kmRechazado = false;
    });
    if (_invalidos.isNotEmpty) return;
    setState(() {
      _ocupado = true;
      _aviso = null;
    });
    final notifier = ref.read(gastosProvider(widget.vehiculoId).notifier);
    final textos = AppLocalizations.of(context);
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    try {
      final editando = widget.editando;
      if (editando == null) {
        await notifier.registrar(_borrador);
      } else {
        await notifier.editar(editando.id, _borrador);
      }
      mensajero.showSnackBar(
        SnackBar(content: Text(textos.bitacoraGastoGuardado)),
      );
      navegador.pop();
    } on KmInvalido {
      if (!mounted) return;
      setState(() => _kmRechazado = true);
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
    final gasto = widget.editando!;
    final nombre = gasto.tipo == TipoGasto.otro
        ? (gasto.descripcion ?? nombreTipo(textos, gasto.tipo))
        : nombreTipo(textos, gasto.tipo);
    final confirmo = await mostrarDialogo<bool>(
      context,
      builder: (contexto) => Dialogo(
        titulo: textos.bitacoraBorrarTitulo,
        mensaje: textos.bitacoraBorrarMensaje(nombre),
        textoPrincipal: textos.bitacoraBorrarConfirmar,
        alPrincipal: () => Navigator.of(contexto).pop(true),
        textoSecundario: textos.bitacoraBorrarCancelar,
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
      await ref
          .read(gastosProvider(widget.vehiculoId).notifier)
          .borrar(gasto.id);
      mensajero.showSnackBar(
        SnackBar(content: Text(textos.bitacoraGastoBorrado)),
      );
      navegador.pop();
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

  String? _error(AppLocalizations textos, CampoGasto campo) {
    if (campo == CampoGasto.km && _kmRechazado) {
      return textos.bitacoraErrorKmServidor;
    }
    if (!_intentado || !_invalidos.contains(campo)) return null;
    return switch (campo) {
      CampoGasto.monto => textos.bitacoraErrorMonto,
      CampoGasto.litros => textos.bitacoraErrorLitros,
      CampoGasto.km =>
        int.tryParse(_km.text.trim()) == null || _kmMinimo == null
            ? textos.bitacoraErrorKm
            : (int.parse(_km.text.trim()) < _kmMinimo!
                  ? textos.bitacoraErrorKmMenor(numero(context, _kmMinimo!))
                  : textos.bitacoraErrorKm),
      CampoGasto.fecha => textos.bitacoraErrorFecha,
      CampoGasto.descripcion => textos.bitacoraErrorDescripcion,
    };
  }

  String _titulo(AppLocalizations textos) {
    final editando = widget.editando != null;
    if (_esCarga) {
      return editando
          ? textos.bitacoraFormEditarCargaTitulo
          : textos.bitacoraFormCargaTitulo;
    }
    return editando
        ? textos.bitacoraFormEditarGastoTitulo
        : textos.bitacoraFormGastoTitulo;
  }

  @override
  Widget build(BuildContext context) {
    // Se observa para conocer la última lectura de km aunque el formulario
    // se abra sin que la bitácora la haya cargado.
    ref.watch(gastosProvider(widget.vehiculoId));
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final editando = widget.editando != null;
    final kmMinimo = _kmMinimo;
    final otrosTipos = [
      for (final t in TipoGasto.values)
        if (t != TipoGasto.gasolina) t,
    ];

    return MarcoBitacora(
      titulo: _titulo(textos),
      barraInferior: BarraInferiorBitacora(
        hijos: [
          BotonPildora(
            texto: textos.bitacoraGuardar,
            expandido: true,
            alPresionar: _ocupado ? null : _guardar,
          ),
          if (editando) ...[
            const SizedBox(height: Espaciado.e2),
            BotonPildora(
              texto: textos.bitacoraBorrar,
              icono: Icons.delete_outline,
              variante: VarianteBotonPildora.tonal,
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
              if (_esCarga && !editando)
                SeccionBitacora(
                  titulo: textos.bitacoraTicketTitulo,
                  hijo: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        textos.bitacoraTicketPrivacidad,
                        style: tokens.tipografia.cuerpoChico.copyWith(
                          color: c.textoSecundario,
                        ),
                      ),
                      const SizedBox(height: Espaciado.e3),
                      if (_leyendo)
                        Semantics(
                          liveRegion: true,
                          label: textos.bitacoraTicketLeyendo,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else ...[
                        BotonPildora(
                          texto: textos.bitacoraTicketTomar,
                          icono: Icons.photo_camera_outlined,
                          variante: VarianteBotonPildora.tonal,
                          expandido: true,
                          alPresionar: _ocupado
                              ? null
                              : () => _leerTicket(OrigenFoto.camara),
                        ),
                        const SizedBox(height: Espaciado.e2),
                        BotonPildora(
                          texto: textos.bitacoraTicketElegir,
                          icono: Icons.photo_library_outlined,
                          variante: VarianteBotonPildora.tonal,
                          expandido: true,
                          alPresionar: _ocupado
                              ? null
                              : () => _leerTicket(OrigenFoto.galeria),
                        ),
                      ],
                    ],
                  ),
                ),
              SeccionBitacora(
                titulo: _esCarga
                    ? textos.bitacoraTipoGasolina
                    : textos.bitacoraCampoTipo,
                hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_esCarga) ...[
                      Selector<TipoGasto>(
                        etiqueta: textos.bitacoraCampoTipo,
                        valor: _tipo,
                        opciones: [
                          for (final t in otrosTipos)
                            OpcionSelector(
                              valor: t,
                              texto: nombreTipo(textos, t),
                            ),
                        ],
                        alCambiar: editando
                            ? null
                            : (t) => setState(() => _tipo = t ?? _tipo),
                      ),
                      const SizedBox(height: Espaciado.e3),
                    ],
                    if (_esCarga) ...[
                      CampoTexto(
                        etiqueta: textos.bitacoraCampoLitros,
                        controlador: _litros,
                        teclado: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        accionTeclado: TextInputAction.next,
                        formatos: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        error: _error(textos, CampoGasto.litros),
                      ),
                      const SizedBox(height: Espaciado.e3),
                    ],
                    CampoTexto(
                      etiqueta: textos.bitacoraCampoMonto,
                      controlador: _monto,
                      teclado: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      accionTeclado: TextInputAction.next,
                      formatos: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      error: _error(textos, CampoGasto.monto),
                    ),
                    if (_esCarga) ...[
                      const SizedBox(height: Espaciado.e3),
                      CampoTexto(
                        etiqueta: textos.bitacoraCampoKm,
                        controlador: _km,
                        teclado: TextInputType.number,
                        accionTeclado: TextInputAction.next,
                        formatos: [FilteringTextInputFormatter.digitsOnly],
                        ayuda: kmMinimo == null
                            ? null
                            : textos.bitacoraAyudaKm(numero(context, kmMinimo)),
                        error: _error(textos, CampoGasto.km),
                      ),
                    ],
                    const SizedBox(height: Espaciado.e3),
                    GrupoLista(
                      filas: [
                        FilaGrupo(
                          titulo: textos.bitacoraCampoFecha,
                          icono: Icons.calendar_today_outlined,
                          colorIcono: c.acento,
                          fin: Text(
                            fechaCorta(context, _fecha),
                            style: tokens.tipografia.cuerpo.copyWith(
                              color: c.textoSecundario,
                            ),
                          ),
                          alToque: _elegirFecha,
                        ),
                      ],
                    ),
                    if (_error(textos, CampoGasto.fecha) != null)
                      Padding(
                        padding: const EdgeInsets.only(top: Espaciado.e1),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            _error(textos, CampoGasto.fecha)!,
                            style: tokens.tipografia.cuerpoChico.copyWith(
                              color: c.peligro,
                            ),
                          ),
                        ),
                      ),
                    if (!_esCarga) ...[
                      const SizedBox(height: Espaciado.e3),
                      CampoTexto(
                        etiqueta: textos.bitacoraCampoDescripcion,
                        controlador: _descripcion,
                        ayuda: textos.bitacoraAyudaDescripcion,
                        lineas: 2,
                        accionTeclado: TextInputAction.done,
                        formatos: [LengthLimitingTextInputFormatter(200)],
                        error: _error(textos, CampoGasto.descripcion),
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

  Widget _avisoWidget(AppLocalizations textos, _Aviso aviso) => switch (aviso) {
    _Aviso.guardar => Aviso(
      mensaje: textos.bitacoraErrorGuardar,
      tono: Tono.peligro,
    ),
    _Aviso.borrar => Aviso(
      mensaje: textos.bitacoraErrorBorrar,
      tono: Tono.peligro,
    ),
    _Aviso.sinConexion => Aviso(
      mensaje: textos.bitacoraErrorSinConexion,
      tono: Tono.peligro,
    ),
    _Aviso.ticketLeido => Aviso(
      mensaje: textos.bitacoraTicketLeido,
      tono: Tono.exito,
    ),
    _Aviso.ticketNoLeyo => Aviso(
      mensaje: textos.bitacoraTicketNoLeyo,
      tono: Tono.informacion,
    ),
    _Aviso.ticketSinPermiso => Aviso(
      mensaje: textos.bitacoraTicketSinPermiso,
      tono: Tono.advertencia,
    ),
    _Aviso.ticketError => Aviso(
      mensaje: textos.bitacoraTicketError,
      tono: Tono.advertencia,
    ),
  };
}
