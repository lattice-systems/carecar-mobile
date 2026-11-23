import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/ficha_tecnica_vehiculo.dart';
import 'proveedores_vehiculos.dart';
import 'provisional/seccion_plegable.dart';

/// Ficha tecnica del vehiculo por modelo y ano (V2-M02.04), en secciones
/// plegables.
///
/// Sale de la API y, mientras el backend no la tenga o no haya red, de lo que
/// trae la app (lo avisa). Resuelve los cinco estados: esqueleto, datos, vacio,
/// error con reintento y sin conexion; se recarga jalando hacia abajo.
class PantallaFichaTecnica extends ConsumerWidget {
  const PantallaFichaTecnica({required this.vehiculoId, super.key});

  final int vehiculoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ficha = ref.watch(fichaTecnicaProvider(vehiculoId));
    final textos = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(textos.vehiculosFichaTitulo)),
      body: ficha.when(
        skipLoadingOnReload: true,
        loading: () => const _Cargando(),
        error: (error, _) => EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(fichaTecnicaProvider(vehiculoId)),
        ),
        data: (f) => f == null || f.secciones.isEmpty && !f.delRespaldo
            ? EstadoVacio(
                titulo: textos.vehiculosFichaVacioTitulo,
                mensaje: textos.vehiculosFichaVacioMensaje,
                icono: Icons.fact_check_outlined,
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(fichaTecnicaProvider(vehiculoId).future),
                child: _Ficha(ficha: f),
              ),
      ),
    );
  }
}

class _Ficha extends StatelessWidget {
  const _Ficha({required this.ficha});

  final FichaTecnicaVehiculo ficha;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return ListView(
      padding: const EdgeInsets.all(Espaciado.e4),
      children: [
        if (ficha.delRespaldo)
          Padding(
            padding: const EdgeInsets.only(bottom: Espaciado.e3),
            child: Aviso(mensaje: textos.vehiculosFichaRespaldo),
          ),
        for (final s in ficha.secciones)
          Padding(
            padding: const EdgeInsets.only(bottom: Espaciado.e3),
            child: SeccionPlegable(
              titulo: _tituloDe(textos, s),
              hijo: Column(
                children: [
                  for (final e in s.especificaciones)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Espaciado.e1,
                      ),
                      child: MergeSemantics(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                _claveDe(textos, e),
                                style: t.cuerpoChico.copyWith(
                                  color: c.textoSecundario,
                                ),
                              ),
                            ),
                            const SizedBox(width: Espaciado.e3),
                            Expanded(
                              child: Text(
                                e.valor,
                                textAlign: TextAlign.end,
                                style: t.cuerpoFuerte.copyWith(color: c.texto),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        Text(
          textos.vehiculosFichaNota,
          style: t.cuerpoChico.copyWith(color: c.textoSecundario),
        ),
      ],
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).vehiculosFichaCargando,
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
    );
  }
}

/// Titulo de la seccion: el de la agencia o, en el respaldo local, el texto del
/// idioma que corresponde a su codigo.
String _tituloDe(AppLocalizations textos, SeccionFicha s) => switch (s.codigo) {
  'general' => textos.vehiculosFichaSeccionGeneral,
  'motor' => textos.vehiculosFichaSeccionMotor,
  'transmision' => textos.vehiculosFichaSeccionTransmision,
  _ => s.titulo,
};

String _claveDe(AppLocalizations textos, EspecificacionFicha e) =>
    switch (e.codigo) {
      'carroceria' => textos.vehiculosFichaClaveCarroceria,
      'pasajeros' => textos.vehiculosFichaClavePasajeros,
      'propulsion' => textos.vehiculosFichaClavePropulsion,
      'motor' => textos.vehiculosFichaClaveMotor,
      'potencia' => textos.vehiculosFichaClavePotencia,
      'transmision' => textos.vehiculosFichaClaveTransmision,
      'traccion' => textos.vehiculosFichaClaveTraccion,
      _ => e.clave,
    };
