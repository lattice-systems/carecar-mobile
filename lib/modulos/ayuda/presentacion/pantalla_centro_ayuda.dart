import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../config/version_app.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/barra_pantalla.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/dispositivo/lector_del_dispositivo.dart';
import '../../../nucleo/dispositivo/nombre_del_dispositivo.dart';
import 'proveedores_ayuda.dart';

class PantallaPreguntasFrecuentes extends ConsumerStatefulWidget {
  const PantallaPreguntasFrecuentes({super.key});
  @override
  ConsumerState<PantallaPreguntasFrecuentes> createState() => _PreguntasState();
}

class _PreguntasState extends ConsumerState<PantallaPreguntasFrecuentes> {
  String _consulta = '';
  @override
  Widget build(BuildContext context) {
    final preguntas = ref.watch(preguntasFrecuentesProvider);
    return Scaffold(
      body: Column(
        children: [
          BarraPantalla(titulo: AppLocalizations.of(context).ayudaPreguntas),
          Padding(
            padding: const EdgeInsets.all(Espaciado.e4),
            child: CampoTexto(
              etiqueta: AppLocalizations.of(context).ayudaBuscar,
              sugerencia: AppLocalizations.of(context).ayudaBuscarSugerencia,
              alCambiar: (texto) =>
                  setState(() => _consulta = texto.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: preguntas.when(
              loading: () => const Center(child: Esqueleto(alto: 56)),
              error: (error, _) => EstadoError(
                causa: error is SinConexion
                    ? CausaError.sinConexion
                    : CausaError.generico,
                alReintentar: () => ref.invalidate(preguntasFrecuentesProvider),
              ),
              data: (datos) {
                final encontrados = datos
                    .where(
                      (p) => '${p.tema} ${p.pregunta} ${p.respuesta}'
                          .toLowerCase()
                          .contains(_consulta),
                    )
                    .toList();
                if (encontrados.isEmpty)
                  return EstadoVacio(
                    titulo: AppLocalizations.of(context).ayudaSinResultados,
                    mensaje: AppLocalizations.of(context).ayudaOtrasPalabras,
                  );
                return ListView(
                  children: [
                    BarraPantalla(
                      titulo: AppLocalizations.of(context).ayudaPreguntas,
                    ),
                    for (final p in encontrados)
                      ExpansionTile(
                        title: Text(p.pregunta),
                        subtitle: Text(p.tema),
                        children: [
                          BarraPantalla(
                            titulo: AppLocalizations.of(context).ayudaPreguntas,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(Espaciado.e4),
                            child: Text(p.respuesta),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PantallaReporteApp extends ConsumerStatefulWidget {
  const PantallaReporteApp({
    super.key,
    this.leerEquipo = leerDatosDelDispositivo,
  });
  final LectorDelDispositivo leerEquipo;
  @override
  ConsumerState<PantallaReporteApp> createState() => _ReporteState();
}

class _ReporteState extends ConsumerState<PantallaReporteApp> {
  final _descripcion = TextEditingController();
  String? _error;
  bool _guardando = false;
  bool _enviado = false;
  @override
  void dispose() {
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_descripcion.text.trim().length < 10 ||
        _descripcion.text.trim().length > 2000) {
      setState(() => _error = AppLocalizations.of(context).ayudaLongitud);
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      final sistema = Theme.of(context).platform.name;
      final version = await leerVersionApp();
      final dispositivo =
          await nombreDelDispositivo(leer: widget.leerEquipo) ?? 'desconocido';
      if (!mounted) return;
      await ref
          .read(repositorioCentroAyudaProvider)
          .reportar(
            descripcion: _descripcion.text.trim(),
            version: version,
            sistema: sistema,
            dispositivo: dispositivo.length <= 120
                ? dispositivo
                : dispositivo.substring(0, 120),
          );
      if (mounted) setState(() => _enviado = true);
    } on Object {
      if (mounted)
        setState(() => _error = AppLocalizations.of(context).ayudaErrorReporte);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        BarraPantalla(titulo: AppLocalizations.of(context).ayudaReporte),
        Expanded(
          child: _enviado
              ? EstadoVacio(
                  titulo: AppLocalizations.of(context).ayudaEnviado,
                  mensaje: AppLocalizations.of(context).ayudaGracias,
                )
              : ListView(
                  padding: const EdgeInsets.all(Espaciado.e4),
                  children: [
                    CampoTexto(
                      etiqueta: AppLocalizations.of(context).ayudaDescripcion,
                      sugerencia: AppLocalizations.of(context)
                          .ayudaDescripcionPista,
                      controlador: _descripcion,
                      habilitado: !_guardando,
                      lineas: 6,
                      error: _error,
                    ),
                    const SizedBox(height: Espaciado.e3),
                    Text(AppLocalizations.of(context).ayudaPrivacidadReporte),
                    const SizedBox(height: Espaciado.e3),
                    Boton(
                      texto: AppLocalizations.of(context).ayudaEnviar,
                      alPresionar: _enviar,
                      cargando: _guardando,
                      anchoCompleto: true,
                    ),
                  ],
                ),
        ),
      ],
    ),
  );
}
