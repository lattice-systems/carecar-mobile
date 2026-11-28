import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/ficha_tecnica_vehiculo.dart';
import 'proveedores_vehiculos.dart';

/// Ficha tecnica del vehiculo por modelo y ano (V2-M02.04) en estilo portada:
/// titulo grande translucido y una lista agrupada plegable por seccion.
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

    Widget estado(Widget hijo) =>
        SliverFillRemaining(hasScrollBody: true, child: hijo);

    final contenido = ficha.when(
      skipLoadingOnReload: true,
      loading: () => estado(const _Cargando()),
      error: (error, _) => estado(
        EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(fichaTecnicaProvider(vehiculoId)),
        ),
      ),
      data: (f) => f == null || f.secciones.isEmpty && !f.delRespaldo
          ? estado(
              EstadoVacio(
                titulo: textos.vehiculosFichaVacioTitulo,
                mensaje: textos.vehiculosFichaVacioMensaje,
                icono: LucideIcons300.clipboardCheck,
              ),
            )
          : SliverToBoxAdapter(child: _Ficha(ficha: f)),
    );

    return MarcoPantalla(
      icono: LucideIcons300.fileText,
      titulo: textos.vehiculosFichaTitulo,
      conRegreso: true,
      alRefrescar: () => ref.refresh(fichaTecnicaProvider(vehiculoId).future),
      slivers: [contenido],
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
    final colores = [c.acento, c.exito, c.marca, c.advertencia];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ficha.delRespaldo)
            Padding(
              padding: const EdgeInsets.only(bottom: Espaciado.e3),
              child: Aviso(mensaje: textos.vehiculosFichaRespaldo),
            ),
          for (var i = 0; i < ficha.secciones.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Espaciado.e3),
              child: _SeccionFicha(
                titulo: _tituloDe(textos, ficha.secciones[i]),
                color: colores[i % colores.length],
                filas: [
                  for (final e in ficha.secciones[i].especificaciones)
                    (_claveDe(textos, e), e.valor),
                ],
              ),
            ),
          Text(
            textos.vehiculosFichaNota,
            style: t.cuerpoChico.copyWith(color: c.textoSecundario),
          ),
        ],
      ),
    );
  }
}

/// Una seccion de la ficha como lista agrupada: su primera fila (con ícono de
/// color) pliega y despliega las especificaciones, cada una con su valor al
/// final. Cerrada solo se ve el titulo.
class _SeccionFicha extends StatefulWidget {
  const _SeccionFicha({
    required this.titulo,
    required this.color,
    required this.filas,
  });

  final String titulo;
  final Color color;
  final List<(String, String)> filas;

  @override
  State<_SeccionFicha> createState() => _SeccionFichaState();
}

class _SeccionFichaState extends State<_SeccionFicha> {
  bool _abierta = false;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return GrupoLista(
      filas: [
        FilaGrupo(
          titulo: widget.titulo,
          icono: LucideIcons300.clipboardCheck,
          colorIcono: widget.color,
          fin: Icon(
            _abierta ? LucideIcons300.chevronUp : LucideIcons300.chevronDown,
            color: c.textoSecundario,
          ),
          alToque: () => setState(() => _abierta = !_abierta),
          // Desplegar no lleva a otra pantalla: la flecha de desplegar basta.
          conChevron: false,
        ),
        if (_abierta)
          for (final (clave, valor) in widget.filas)
            FilaGrupo(
              titulo: clave,
              fin: Text(
                valor,
                textAlign: TextAlign.end,
                style: t.cuerpoFuerte.copyWith(color: c.texto),
              ),
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
