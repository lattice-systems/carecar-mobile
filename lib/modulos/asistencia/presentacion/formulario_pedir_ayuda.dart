import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../config/agencia.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/chip_pista.dart';
import '../../../nucleo/diseno/componentes/control_binario.dart';
import '../../../nucleo/diseno/componentes/deslizar_para_confirmar.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/mapas/mapas.dart';
import '../../vehiculos/vehiculos.dart' show VehiculoGaraje;
import '../dominio/contacto_de_llamada.dart';
import '../dominio/repositorio_asistencia.dart';
import '../dominio/solicitud_asistencia.dart';
import 'estilo_solicitud.dart';
import 'proveedores_asistencia.dart';
import 'ubicacion_para_ayuda.dart';

/// Lo que se hace cuando la solicitud queda creada (o ya existia).
typedef AlEnviarSolicitud = void Function(
  SolicitudAsistencia solicitud, {
  required bool yaAbierta,
});

/// Lo que va leyendo la ubicacion: nada, buscando, lista o con un motivo.
sealed class _Ubicacion {
  const _Ubicacion();
}

class _Apagada extends _Ubicacion {
  const _Apagada();
}

class _Buscando extends _Ubicacion {
  const _Buscando();
}

class _Lista extends _Ubicacion {
  const _Lista(this.coordenada);

  final Coordenada coordenada;
}

class _Fallo extends _Ubicacion {
  const _Fallo(this.motivo);

  final MotivoSinUbicacion motivo;
}

/// Formulario de «Pedir ayuda»: vehiculo, tipo de problema, ubicacion
/// opcional, comentario y un deslizar para confirmar (V2-M11.01).
///
/// La ubicacion se lee una sola vez, en primer plano, al activar el
/// interruptor; vive solo en este estado (memoria) y se manda al crear la
/// solicitud. No se guarda ni se escribe en logs.
class FormularioPedirAyuda extends ConsumerStatefulWidget {
  const FormularioPedirAyuda({
    required this.vehiculos,
    required this.alEnviar,
    super.key,
  });

  final List<VehiculoGaraje> vehiculos;
  final AlEnviarSolicitud alEnviar;

  @override
  ConsumerState<FormularioPedirAyuda> createState() =>
      _FormularioPedirAyudaState();
}

class _FormularioPedirAyudaState extends ConsumerState<FormularioPedirAyuda> {
  static const int _maximoComentario = 500;

  final _comentario = TextEditingController();
  int? _vehiculoId;
  TipoAsistencia? _tipo;
  _Ubicacion _ubicacion = const _Apagada();
  bool _enviando = false;
  String? _error;
  bool _errorDeRed = false;

  /// Descarta la lectura de ubicacion que ya no importa (se apago el
  /// interruptor o se pidio otra).
  int _lectura = 0;

  @override
  void initState() {
    super.initState();
    if (widget.vehiculos.length == 1) _vehiculoId = widget.vehiculos.single.id;
  }

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  Coordenada? get _coordenada => switch (_ubicacion) {
    _Lista(:final coordenada) => coordenada,
    _ => null,
  };

  bool get _puedeEnviar =>
      _vehiculoId != null &&
      _tipo != null &&
      !_enviando &&
      _ubicacion is! _Buscando;

  Future<void> _buscarUbicacion() async {
    final lectura = ++_lectura;
    setState(() => _ubicacion = const _Buscando());
    final resultado = await obtenerUbicacionParaAyuda(
      ref.read(proveedorUbicacionProvider),
    );
    if (!mounted || lectura != _lectura) return;
    setState(() {
      _ubicacion = switch (resultado) {
        UbicacionObtenida(:final coordenada) => _Lista(coordenada),
        UbicacionNoDisponible(:final motivo) => _Fallo(motivo),
      };
    });
  }

  void _alternarUbicacion(bool compartir) {
    if (compartir) {
      _buscarUbicacion();
    } else {
      _lectura++;
      setState(() => _ubicacion = const _Apagada());
    }
  }

  Future<void> _marcar(String telefono) async {
    final contacto = ContactoDeLlamada(
      tipo: TipoContacto.emergencias,
      telefono: telefono,
    );
    try {
      await ref.read(abrirLlamadaProvider)(contacto.enlace);
    } on Object {
      // Sin marcador no hay mas que hacer aqui: el aviso ya muestra el 911.
    }
  }

  Future<void> _enviar() async {
    if (!_puedeEnviar) return;
    setState(() {
      _enviando = true;
      _error = null;
      _errorDeRed = false;
    });
    final textos = AppLocalizations.of(context);
    final repositorio = ref.read(repositorioAsistenciaProvider);
    try {
      final solicitud = await repositorio.pedirAyuda(
        vehiculoId: _vehiculoId!,
        tipo: _tipo!,
        ubicacion: _coordenada,
        comentario: _comentario.text,
      );
      if (!mounted) return;
      widget.alEnviar(solicitud, yaAbierta: false);
    } on SolicitudAbierta {
      // Otra solicitud ya estaba abierta: se muestra esa en vez de crear otra.
      final existente = await _consultarAbierta(repositorio);
      if (!mounted) return;
      if (existente != null) {
        widget.alEnviar(existente, yaAbierta: true);
      } else {
        setState(() => _error = textos.asistenciaErrorEnviar);
      }
    } on SinConexion {
      if (mounted) {
        setState(() {
          _error = textos.asistenciaErrorSinConexion;
          _errorDeRed = true;
        });
      }
    } on NoEncontrado {
      if (mounted) setState(() => _error = textos.asistenciaErrorVehiculo);
    } on Object {
      // El texto del servidor no se muestra: en 400 y 5xx trae detalle tecnico.
      if (mounted) setState(() => _error = textos.asistenciaErrorEnviar);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<SolicitudAsistencia?> _consultarAbierta(
    RepositorioAsistencia repositorio,
  ) async {
    try {
      return await repositorio.activa();
    } on Object {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;

    final conUbicacion = _coordenada != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Encabezado(textos.asistenciaPedirVehiculoEncabezado),
          const SizedBox(height: Espaciado.e2),
          GrupoLista(
            filas: [
              for (final v in widget.vehiculos)
                FilaGrupo(
                  titulo: v.titulo,
                  subtitulo: v.placas,
                  icono: Icons.directions_car_outlined,
                  colorIcono: _vehiculoId == v.id ? c.acento : null,
                  fin: _vehiculoId == v.id
                      ? Icon(
                          Icons.check_circle,
                          color: c.acento,
                          semanticLabel: textos.asistenciaPedirSeleccionado,
                        )
                      : null,
                  alToque: _enviando
                      ? null
                      : () => setState(() => _vehiculoId = v.id),
                ),
            ],
          ),
          const SizedBox(height: Espaciado.e6),
          _Encabezado(textos.asistenciaPedirTipoEncabezado),
          const SizedBox(height: Espaciado.e2),
          Wrap(
            spacing: Espaciado.e2,
            runSpacing: Espaciado.e1,
            children: [
              for (final tipo in TipoAsistencia.values)
                ChipPista(
                  texto: textos.nombreDeTipo(tipo),
                  icono: tipo.icono,
                  seleccionado: _tipo == tipo,
                  alCambiar: _enviando
                      ? null
                      : (_) => setState(() => _tipo = tipo),
                ),
            ],
          ),
          const SizedBox(height: Espaciado.e6),
          _Encabezado(textos.asistenciaUbicacionEncabezado),
          const SizedBox(height: Espaciado.e2),
          Interruptor(
            etiqueta: textos.asistenciaUbicacionCompartir,
            descripcion: textos.asistenciaUbicacionExplicacion,
            valor: _ubicacion is! _Apagada,
            alCambiar: _enviando ? null : _alternarUbicacion,
          ),
          _EstadoUbicacion(
            ubicacion: _ubicacion,
            alReintentar: _buscarUbicacion,
            alEnviarSin: () => _alternarUbicacion(false),
          ),
          const SizedBox(height: Espaciado.e6),
          CampoTexto(
            etiqueta: conUbicacion
                ? textos.asistenciaComentarioEtiqueta
                : textos.asistenciaComentarioEtiquetaSinUbicacion,
            ayuda: textos.asistenciaComentarioAyuda,
            controlador: _comentario,
            lineas: 3,
            teclado: TextInputType.multiline,
            habilitado: !_enviando,
            formatos: [LengthLimitingTextInputFormatter(_maximoComentario)],
          ),
          const SizedBox(height: Espaciado.e6),
          if (_error != null) ...[
            Aviso(tono: Tono.peligro, mensaje: _error!),
            if (_errorDeRed) ...[
              const SizedBox(height: Espaciado.e3),
              // Atajo a llamar (V2-M11.02): el marcador no necesita datos.
              BotonPildora(
                texto: textos.asistenciaLlamarAccion(
                  textos.asistenciaLlamarEmergencias,
                ),
                icono: Icons.call_outlined,
                expandido: true,
                variante: VarianteBotonPildora.peligro,
                alPresionar: () => _marcar(telefonoEmergencias),
              ),
              const SizedBox(height: Espaciado.e2),
              BotonPildora(
                texto: textos.asistenciaLlamarAccion(
                  textos.asistenciaLlamarAgencia,
                ),
                icono: Icons.call_outlined,
                expandido: true,
                variante: VarianteBotonPildora.tonal,
                alPresionar: () => _marcar(Agencia.telefono),
              ),
            ],
            const SizedBox(height: Espaciado.e4),
          ],
          if (_enviando)
            Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Espaciado.e4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: Espaciado.e3),
                    Flexible(
                      child: Text(
                        textos.asistenciaEnviando,
                        style: tokens.tipografia.cuerpo.copyWith(
                          color: c.textoSecundario,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            DeslizarParaConfirmar(
              texto: textos.asistenciaConfirmarTexto,
              peligro: true,
              alConfirmar: _puedeEnviar ? _enviar : null,
            ),
          const SizedBox(height: Espaciado.e6),
        ],
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    return Semantics(
      header: true,
      child: Text(
        texto,
        style: tokens.tipografia.titulo3.copyWith(color: tokens.colores.texto),
      ),
    );
  }
}

/// Lo que dice el interruptor de ubicacion: buscando, lista o por que fallo,
/// con las dos salidas (intentar otra vez o enviar sin ubicacion).
class _EstadoUbicacion extends StatelessWidget {
  const _EstadoUbicacion({
    required this.ubicacion,
    required this.alReintentar,
    required this.alEnviarSin,
  });

  final _Ubicacion ubicacion;
  final VoidCallback alReintentar;
  final VoidCallback alEnviarSin;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;

    switch (ubicacion) {
      case _Apagada():
        return const SizedBox.shrink();
      case _Buscando():
        return Semantics(
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.only(top: Espaciado.e2),
            child: Row(
              children: [
                const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: Espaciado.e3),
                Flexible(
                  child: Text(
                    textos.asistenciaUbicacionObteniendo,
                    style: tokens.tipografia.cuerpoChico.copyWith(
                      color: c.textoSecundario,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case _Lista():
        return Padding(
          padding: const EdgeInsets.only(top: Espaciado.e2),
          child: Aviso(
            tono: Tono.exito,
            mensaje: textos.asistenciaUbicacionLista,
          ),
        );
      case _Fallo(:final motivo):
        return Padding(
          padding: const EdgeInsets.only(top: Espaciado.e2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Aviso(
                tono: Tono.advertencia,
                mensaje: textos.mensajeSinUbicacion(motivo),
              ),
              const SizedBox(height: Espaciado.e3),
              BotonPildora(
                texto: textos.asistenciaUbicacionReintentar,
                icono: Icons.refresh,
                variante: VarianteBotonPildora.vidrio,
                expandido: true,
                alPresionar: alReintentar,
              ),
              const SizedBox(height: Espaciado.e2),
              BotonPildora(
                texto: textos.asistenciaUbicacionSinUbicacion,
                icono: Icons.location_off_outlined,
                variante: VarianteBotonPildora.vidrio,
                expandido: true,
                alPresionar: alEnviarSin,
              ),
            ],
          ),
        );
    }
  }
}
