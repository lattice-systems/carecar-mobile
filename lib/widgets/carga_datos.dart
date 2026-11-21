import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/excepciones.dart';
import '../tema/tema_carecar.dart';
import 'aviso.dart';
import 'menu_carecar.dart';
import 'movimiento.dart';

/// Ciclo compartido de carga, fallo y reintento, sin repetir solicitudes al rebuild.
class CargaDatos<T> extends StatefulWidget {
  const CargaDatos({
    required this.cargar,
    required this.mensajeCarga,
    required this.mensajeError,
    required this.construir,
    super.key,
  });
  final Future<T> Function() cargar;
  final String mensajeCarga;
  final String mensajeError;
  final Widget Function(T) construir;

  @override
  State<CargaDatos<T>> createState() => _CargaDatosState<T>();
}

class _CargaDatosState<T> extends State<CargaDatos<T>> {
  late Future<T> _solicitud;

  @override
  void initState() {
    super.initState();
    _solicitud = Future.sync(widget.cargar);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: _solicitud,
    builder: (context, resultado) {
      if (resultado.connectionState != ConnectionState.done) {
        return Semantics(
          liveRegion: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.mensajeCarga),
              const SizedBox(height: TemaCareCar.espacioCampos),
              // Placeholders con brillo mientras llega la respuesta.
              ExcludeSemantics(
                child: Column(
                  children: [
                    for (var i = 0; i < 2; i++)
                      Container(
                        height: 96,
                        margin: const EdgeInsets.only(
                          bottom: TemaCareCar.espacioCampos,
                        ),
                        decoration: BoxDecoration(
                          color: TemaCareCar.azulSuave,
                          borderRadius: BorderRadius.circular(EstiloMenu.radio),
                        ),
                      ).siempre(
                        context,
                        (w) => w
                            .animate(onPlay: (c) => c.repeat())
                            .shimmer(
                              duration: 1200.ms,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      if (resultado.hasError) {
        final error = resultado.error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Aviso.error(
              titulo: widget.mensajeError,
              detalle: error is ExcepcionApi
                  ? error.mensaje
                  : 'Intenta de nuevo más tarde.',
            ),
            const SizedBox(height: TemaCareCar.espacioCampos),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _solicitud = Future.sync(widget.cargar);
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        );
      }
      return widget
          .construir(resultado.data as T)
          .animate()
          .fadeIn(duration: 300.ms);
    },
  );
}
