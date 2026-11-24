import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../api/excepciones.dart';
import '../../../api/modelos/traslado.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/barra_portada.dart';
import '../../../nucleo/diseno/componentes/cabecera_portada.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/firma.dart';
import '../../../nucleo/diseno/componentes/galeria_fotos.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import 'estilo_seguimiento.dart';
import 'proveedores_recoleccion.dart';

/// Cómo se convierte la URL firmada de una foto en imagen. En pruebas se
/// sustituye por una imagen en memoria; en la app es una descarga directa sin
/// guardarla en disco.
final imagenDeChecklistProvider = Provider<ImageProvider Function(String)>(
  (ref) =>
      (url) => NetworkImage(url),
  name: 'imagenDeChecklistProvider',
);

/// Checklist del chofer al recoger o entregar el auto (V2-M17.04): kilometraje,
/// gasolina, notas, fotos y firma.
///
/// «Estilo portada». Las fotos y la firma llegan con URLs firmadas de 15
/// minutos, así que el checklist se pide de nuevo cada vez que se abre y no se
/// guarda. Un 404 significa que el chofer aún no lo registra y se explica con
/// un estado vacío. Resuelve los cinco estados: cargando, datos, vacío, error
/// con reintento y sin conexión.
class PantallaChecklistTraslado extends ConsumerWidget {
  const PantallaChecklistTraslado({required this.trasladoId, super.key});

  final int trasladoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final proveedor = checklistTrasladoProvider(trasladoId);
    final checklist = ref.watch(proveedor);

    Widget marco(Widget hijo) => Scaffold(
      backgroundColor: TokensPista.de(context).colores.fondo,
      appBar: BarraPortada(titulo: textos.recoleccionChecklistTitulo),
      body: hijo,
    );

    return checklist.when(
      loading: () => marco(const _Cargando()),
      error: (error, _) => marco(
        EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(proveedor),
        ),
      ),
      data: (datos) => datos == null
          ? marco(
              EstadoVacio(
                titulo: textos.recoleccionChecklistVacioTitulo,
                mensaje: textos.recoleccionChecklistVacioMensaje,
                icono: Icons.fact_check_outlined,
              ),
            )
          : _Datos(checklist: datos),
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).recoleccionChecklistCargando,
    liveRegion: true,
    child: const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 240, radio: 28),
            SizedBox(height: Espaciado.e4),
            Esqueleto(alto: 72, radio: 16),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 160, radio: 16),
          ],
        ),
      ),
    ),
  );
}

class _Datos extends ConsumerWidget {
  const _Datos({required this.checklist});

  final ChecklistTraslado checklist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final imagen = ref.watch(imagenDeChecklistProvider);
    final nivel = textos.nombreDeGasolina(checklist.gasolina);
    final registrado = checklist.registradoEn.toLocal();
    final notas = checklist.notas;
    final firmaUrl = checklist.firmaUrl;
    final localidad = Localizations.localeOf(context).toString();
    final total = checklist.fotos.length;

    return Scaffold(
      backgroundColor: c.fondo,
      extendBodyBehindAppBar: true,
      appBar: const BarraPortada(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CabeceraPortada(
              titulo: textos.recoleccionChecklistTitulo,
              subtitulo: textos.recoleccionChecklistRegistrado(registrado),
              descripcion: textos.recoleccionChecklistTitulo,
              tinte: c.marca,
              portada: ColoredBox(
                color: c.superficieElevada,
                child: Icon(
                  Icons.fact_check_outlined,
                  size: 120,
                  color: c.marca,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Espaciado.e4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GrupoLista(
                    filas: [
                      FilaGrupo(
                        titulo: textos.recoleccionChecklistKm,
                        subtitulo: textos.recoleccionChecklistKmValor(
                          checklist.km,
                        ),
                        icono: Icons.speed_outlined,
                        colorIcono: c.marca,
                      ),
                      FilaGrupo(
                        titulo: textos.recoleccionChecklistGasolina,
                        subtitulo: nivel,
                        icono: Icons.local_gas_station_outlined,
                        colorIcono: c.advertencia,
                        fin: IndicadorGasolina(
                          cuartos: checklist.gasolina.cuartos,
                          descripcion: textos
                              .recoleccionChecklistGasolinaLector(nivel),
                        ),
                      ),
                      if (notas != null)
                        FilaGrupo(
                          titulo: textos.recoleccionChecklistNotas,
                          subtitulo: notas,
                          icono: Icons.notes_outlined,
                          colorIcono: c.acento,
                        ),
                    ],
                  ),
                  const SizedBox(height: Espaciado.e5),
                  Semantics(
                    header: true,
                    child: Text(
                      textos.recoleccionChecklistFotos,
                      style: t.titulo3.copyWith(color: c.texto),
                    ),
                  ),
                  const SizedBox(height: Espaciado.e3),
                  GaleriaFotos(
                    mensajeVacio: textos.recoleccionChecklistSinFotos,
                    fotos: [
                      for (var i = 0; i < total; i++)
                        FotoGaleria(
                          imagen: imagen(checklist.fotos[i]),
                          descripcion: textos
                              .recoleccionChecklistFotoDescripcion(
                                i + 1,
                                total,
                              ),
                        ),
                    ],
                  ),
                  if (firmaUrl != null) ...[
                    const SizedBox(height: Espaciado.e5),
                    Firma(
                      firmante: textos.recoleccionChecklistFirmante,
                      imagen: imagen(firmaUrl),
                      fecha: DateFormat.yMMMd(localidad)
                          .add_Hm()
                          .format(registrado),
                    ),
                  ],
                  const SizedBox(height: Espaciado.e6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicador de gasolina de cuatro segmentos. El nivel no depende del color:
/// el lector de pantalla oye `descripcion` y los segmentos llenos se distinguen
/// por relleno y por borde.
class IndicadorGasolina extends StatelessWidget {
  const IndicadorGasolina({
    required this.cuartos,
    required this.descripcion,
    super.key,
  });

  /// Segmentos llenos, de 0 a 4.
  final int cuartos;
  final String descripcion;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return Semantics(
      label: descripcion,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(width: Espaciado.e1),
            Container(
              key: ValueKey(
                '${i < cuartos ? 'gasolina_llena' : 'gasolina_vacia'}_$i',
              ),
              width: 14,
              height: 20,
              decoration: BoxDecoration(
                color: i < cuartos ? c.advertencia : Colors.transparent,
                border: Border.all(color: c.advertencia, width: 1.5),
                borderRadius: Radios.bordeControl,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
