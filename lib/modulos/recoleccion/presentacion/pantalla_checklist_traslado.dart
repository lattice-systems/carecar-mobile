import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../api/excepciones.dart';
import '../../../api/modelos/traslado.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/barra_pantalla.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/comparacion_antes_despues.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/firma.dart';
import '../../../nucleo/diseno/componentes/galeria_fotos.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/pestanas.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/recoleccion_agendada.dart' show TipoTraslado;
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
///
/// Con [trasladoContrarioId] (el otro traslado de la misma cita) aparecen las
/// pestañas «Al recoger», «Al entregar» y «Comparar», que pone lado a lado el
/// kilometraje, la gasolina y las fotos de los dos checklists. [tipo] dice si
/// [trasladoId] es el de recoger o el de entregar; [verComparacion] abre
/// directo en «Comparar».
class PantallaChecklistTraslado extends ConsumerStatefulWidget {
  const PantallaChecklistTraslado({
    required this.trasladoId,
    super.key,
    this.trasladoContrarioId,
    this.tipo = TipoTraslado.recoger,
    this.verComparacion = false,
  });

  final int trasladoId;
  final int? trasladoContrarioId;
  final TipoTraslado tipo;
  final bool verComparacion;

  @override
  ConsumerState<PantallaChecklistTraslado> createState() =>
      _EstadoPantallaChecklist();
}

class _EstadoPantallaChecklist
    extends ConsumerState<PantallaChecklistTraslado> {
  late int _indice = widget.verComparacion
      ? 2
      : (widget.tipo == TipoTraslado.recoger ? 0 : 1);

  @override
  Widget build(BuildContext context) {
    final contrario = widget.trasladoContrarioId;
    if (contrario == null) {
      return _VistaChecklist(trasladoId: widget.trasladoId, conMarco: true);
    }

    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final esRecoger = widget.tipo == TipoTraslado.recoger;
    final recogerId = esRecoger ? widget.trasladoId : contrario;
    final entregarId = esRecoger ? contrario : widget.trasladoId;

    return Scaffold(
      backgroundColor: c.fondo,
      body: Column(
        children: [
          BarraPantalla(titulo: textos.recoleccionChecklistTitulo),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
            child: Pestanas(
              etiquetas: [
                textos.recoleccionChecklistPestanaRecoger,
                textos.recoleccionChecklistPestanaEntregar,
                textos.recoleccionChecklistPestanaComparar,
              ],
              indice: _indice,
              alCambiar: (i) => setState(() => _indice = i),
            ),
          ),
          Expanded(
            child: switch (_indice) {
              0 => _VistaChecklist(
                key: ValueKey('checklist_$recogerId'),
                trasladoId: recogerId,
                conMarco: false,
              ),
              1 => _VistaChecklist(
                key: ValueKey('checklist_$entregarId'),
                trasladoId: entregarId,
                conMarco: false,
              ),
              _ => _Comparacion(recogerId: recogerId, entregarId: entregarId),
            },
          ),
        ],
      ),
    );
  }
}

/// El checklist de un traslado en sus cinco estados. Con [conMarco] trae su
/// propia pantalla; sin él solo el cuerpo, para ir dentro de las pestañas.
class _VistaChecklist extends ConsumerWidget {
  const _VistaChecklist({
    required this.trasladoId,
    required this.conMarco,
    super.key,
  });

  final int trasladoId;
  final bool conMarco;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final proveedor = checklistTrasladoProvider(trasladoId);
    final checklist = ref.watch(proveedor);

    Widget marco(Widget hijo) => conMarco
        ? MarcoPantalla.estado(
            titulo: textos.recoleccionChecklistTitulo,
            conRegreso: true,
            estado: hijo,
          )
        : hijo;

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
          : _Datos(checklist: datos, conMarco: conMarco),
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
  const _Datos({required this.checklist, required this.conMarco});

  final ChecklistTraslado checklist;
  final bool conMarco;

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

    final contenido = Padding(
      padding: const EdgeInsets.all(Espaciado.e4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!conMarco) ...[
            Text(
              textos.recoleccionChecklistRegistrado(registrado),
              style: t.cuerpoChico.copyWith(color: c.textoSecundario),
            ),
            const SizedBox(height: Espaciado.e3),
          ],
          GrupoLista(
            filas: [
              FilaGrupo(
                titulo: textos.recoleccionChecklistKm,
                subtitulo: textos.recoleccionChecklistKmValor(checklist.km),
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
                  descripcion: textos.recoleccionChecklistGasolinaLector(nivel),
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
                  descripcion: textos.recoleccionChecklistFotoDescripcion(
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
              fecha: DateFormat.yMMMd(localidad).add_Hm().format(registrado),
            ),
          ],
          const SizedBox(height: Espaciado.e6),
        ],
      ),
    );
    if (!conMarco) return SingleChildScrollView(child: contenido);
    return MarcoPantalla(
      titulo: textos.recoleccionChecklistTitulo,
      subtitulo: textos.recoleccionChecklistRegistrado(registrado),
      conRegreso: true,
      slivers: [SliverToBoxAdapter(child: contenido)],
    );
  }
}

/// Los dos checklists de una recolección lado a lado: kilometraje recorrido,
/// gasolina y, foto por foto, cómo estaba el auto al recoger y al entregar.
///
/// Si falta alguno de los dos (404) se explica cuál y por qué; no se dibuja
/// una comparación a medias.
class _Comparacion extends ConsumerWidget {
  const _Comparacion({required this.recogerId, required this.entregarId});

  final int recogerId;
  final int entregarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final alRecoger = ref.watch(checklistTrasladoProvider(recogerId));
    final alEntregar = ref.watch(checklistTrasladoProvider(entregarId));

    final error = alRecoger.error ?? alEntregar.error;
    if (error != null) {
      return EstadoError(
        causa: error is SinConexion
            ? CausaError.sinConexion
            : CausaError.generico,
        alReintentar: () {
          ref.invalidate(checklistTrasladoProvider(recogerId));
          ref.invalidate(checklistTrasladoProvider(entregarId));
        },
      );
    }
    if (alRecoger.isLoading || alEntregar.isLoading) return const _Cargando();

    final recoger = alRecoger.value;
    final entregar = alEntregar.value;
    if (recoger == null || entregar == null) {
      return EstadoVacio(
        titulo: textos.recoleccionComparacionFaltaTitulo,
        mensaje: recoger == null && entregar == null
            ? textos.recoleccionComparacionFaltaAmbos
            : recoger == null
            ? textos.recoleccionComparacionFaltaRecoger
            : textos.recoleccionComparacionFaltaEntregar,
        icono: Icons.compare_outlined,
      );
    }
    return _DatosComparacion(recoger: recoger, entregar: entregar);
  }
}

class _DatosComparacion extends ConsumerWidget {
  const _DatosComparacion({required this.recoger, required this.entregar});

  final ChecklistTraslado recoger;
  final ChecklistTraslado entregar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final imagen = ref.watch(imagenDeChecklistProvider);
    final comparadas = recoger.fotos.length < entregar.fotos.length
        ? recoger.fotos.length
        : entregar.fotos.length;
    final desiguales = recoger.fotos.length != entregar.fotos.length;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.e4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GrupoLista(
              filas: [
                FilaGrupo(
                  titulo: textos.recoleccionChecklistKm,
                  subtitulo: textos.recoleccionComparacionKmDetalle(
                    recoger.km,
                    entregar.km,
                  ),
                  icono: Icons.speed_outlined,
                  colorIcono: c.marca,
                  fin: Text(
                    textos.recoleccionChecklistKmValor(
                      entregar.km - recoger.km,
                    ),
                    style: t.cuerpoFuerte.copyWith(color: c.texto),
                  ),
                ),
                FilaGrupo(
                  titulo: textos.recoleccionChecklistGasolina,
                  subtitulo: textos.recoleccionComparacionGasolinaDetalle(
                    textos.nombreDeGasolina(recoger.gasolina),
                    textos.nombreDeGasolina(entregar.gasolina),
                  ),
                  icono: Icons.local_gas_station_outlined,
                  colorIcono: c.advertencia,
                ),
              ],
            ),
            const SizedBox(height: Espaciado.e5),
            Semantics(
              header: true,
              child: Text(
                textos.recoleccionComparacionFotosTitulo,
                style: t.titulo3.copyWith(color: c.texto),
              ),
            ),
            if (comparadas == 0) ...[
              const SizedBox(height: Espaciado.e3),
              Aviso(
                mensaje: textos.recoleccionComparacionSinFotos,
                tono: Tono.informacion,
              ),
            ] else ...[
              const SizedBox(height: Espaciado.e2),
              Text(
                textos.recoleccionComparacionFotosAyuda,
                style: t.cuerpoChico.copyWith(color: c.textoSecundario),
              ),
              if (desiguales) ...[
                const SizedBox(height: Espaciado.e3),
                Aviso(
                  mensaje: textos.recoleccionComparacionFotosDesiguales(
                    recoger.fotos.length,
                    entregar.fotos.length,
                    comparadas,
                  ),
                  tono: Tono.informacion,
                ),
              ],
              for (var i = 0; i < comparadas; i++) ...[
                const SizedBox(height: Espaciado.e3),
                ComparacionAntesDespues(
                  antes: FotoGaleria(
                    imagen: imagen(recoger.fotos[i]),
                    descripcion: textos.recoleccionComparacionFotoRecoger(
                      i + 1,
                      comparadas,
                    ),
                  ),
                  despues: FotoGaleria(
                    imagen: imagen(entregar.fotos[i]),
                    descripcion: textos.recoleccionComparacionFotoEntregar(
                      i + 1,
                      comparadas,
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: Espaciado.e6),
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
