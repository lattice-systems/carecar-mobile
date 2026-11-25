import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/superficie_liquida.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/arco.dart';
import 'componentes_privacidad.dart';
import 'proveedores_arco.dart';

/// Pedir y descargar la copia de mis datos, el derecho de acceso (ARCO,
/// V2-M22.02): se pide, se prepara en unos segundos y se comparte con la hoja
/// del sistema. El archivo no se queda guardado en el teléfono.
class PantallaMisDatos extends ConsumerStatefulWidget {
  const PantallaMisDatos({super.key});

  @override
  ConsumerState<PantallaMisDatos> createState() => _PantallaMisDatosState();
}

/// Qué salió mal en la última acción de la persona.
enum _Fallo { sinConexion, errorAlPedir, errorAlDescargar, archivoNoDisponible }

class _PantallaMisDatosState extends ConsumerState<PantallaMisDatos> {
  bool _pidiendo = false;
  bool _descargando = false;
  _Fallo? _fallo;

  Future<void> _pedir() async {
    setState(() {
      _pidiendo = true;
      _fallo = null;
    });
    try {
      await ref.read(accesoArcoProvider.notifier).pedir();
    } on ArcoSinConexion {
      if (mounted) setState(() => _fallo = _Fallo.sinConexion);
    } on Object {
      if (mounted) setState(() => _fallo = _Fallo.errorAlPedir);
    } finally {
      if (mounted) setState(() => _pidiendo = false);
    }
  }

  Future<void> _descargar(SolicitudDeArco solicitud) async {
    setState(() {
      _descargando = true;
      _fallo = null;
    });
    try {
      final bytes = await ref
          .read(repositorioArcoProvider)
          .descargar(solicitud.id);
      await ref.read(compartirDatosProvider)(
        bytes,
        _nombreDelArchivo(solicitud),
        'application/json',
      );
    } on ArchivoArcoNoDisponible {
      // Ya no está: se vuelve a preguntar para que la pantalla lo diga con su
      // estado (vencida); si el servidor aún la da por lista, se avisa aquí.
      await ref.read(accesoArcoProvider.notifier).refrescar();
      if (mounted &&
          (ref.read(accesoArcoProvider).value?.puedeDescargar ?? false)) {
        setState(() => _fallo = _Fallo.archivoNoDisponible);
      }
    } on Object {
      if (mounted) setState(() => _fallo = _Fallo.errorAlDescargar);
    } finally {
      if (mounted) setState(() => _descargando = false);
    }
  }

  /// `mis-datos-carecar-2026-11-25.json`, con la fecha de hoy del teléfono.
  static String _nombreDelArchivo(SolicitudDeArco solicitud) {
    final dia = (solicitud.resueltaEn ?? solicitud.creadaEn).toLocal();
    final mes = dia.month.toString().padLeft(2, '0');
    final d = dia.day.toString().padLeft(2, '0');
    return 'mis-datos-carecar-${dia.year}-$mes-$d.json';
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final acceso = ref.watch(accesoArcoProvider);

    final titulo = textos.arcoTitulo;

    return acceso.when(
      skipLoadingOnReload: true,
      loading: () => MarcoPantalla.estado(
        titulo: titulo,
        conRegreso: true,
        estado: Semantics(
          label: textos.arcoCargando,
          liveRegion: true,
          child: const SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(Espaciado.e4),
            child: Column(
              children: [
                Esqueleto(alto: 72),
                SizedBox(height: Espaciado.e3),
                Esqueleto(alto: 56),
              ],
            ),
          ),
        ),
      ),
      error: (error, _) => MarcoPantalla.estado(
        titulo: titulo,
        conRegreso: true,
        estado: EstadoError(
          causa: error is ArcoSinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(accesoArcoProvider),
        ),
      ),
      data: (solicitud) => MarcoPantalla(
        titulo: titulo,
        conRegreso: true,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(Espaciado.e4),
            sliver: SliverList.list(
              children: [
                _Introduccion(textos: textos),
                const SizedBox(height: Espaciado.e5),
                ..._segunLaSolicitud(context, textos, solicitud),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _segunLaSolicitud(
    BuildContext context,
    AppLocalizations textos,
    SolicitudDeArco? solicitud,
  ) {
    final aviso = _fallo == null
        ? null
        : Aviso(
            mensaje: switch (_fallo!) {
              _Fallo.sinConexion => textos.arcoSinConexionPedir,
              _Fallo.errorAlPedir => textos.arcoErrorPedir,
              _Fallo.errorAlDescargar => textos.arcoErrorDescarga,
              _Fallo.archivoNoDisponible => textos.arcoArchivoNoDisponible,
            },
            tono: _fallo == _Fallo.sinConexion
                ? Tono.advertencia
                : Tono.peligro,
          );
    final espacio = const SizedBox(height: Espaciado.e3);

    if (solicitud?.estado == EstadoArco.pendiente) {
      return [_Preparando(textos: textos)];
    }
    if (solicitud != null && solicitud.puedeDescargar) {
      return [
        _Lista(solicitud: solicitud, textos: textos),
        if (aviso != null) ...[espacio, aviso],
        espacio,
        BotonPildora(
          texto: _descargando ? textos.arcoDescargando : textos.arcoDescargar,
          icono: Icons.download_outlined,
          expandido: true,
          alPresionar: _descargando || _pidiendo
              ? null
              : () => _descargar(solicitud),
        ),
        espacio,
        BotonPildora(
          texto: _pidiendo ? textos.arcoPidiendo : textos.arcoPedirOtra,
          variante: VarianteBotonPildora.vidrio,
          expandido: true,
          alPresionar: _descargando || _pidiendo ? null : _pedir,
        ),
      ];
    }
    return [
      if (solicitud?.estado == EstadoArco.fallida) ...[
        Aviso(mensaje: textos.arcoFallida, tono: Tono.peligro),
        espacio,
      ] else if (solicitud?.estado == EstadoArco.vencida) ...[
        Aviso(mensaje: textos.arcoVencida, tono: Tono.informacion),
        espacio,
      ],
      if (aviso != null) ...[aviso, espacio],
      BotonPildora(
        texto: _pidiendo ? textos.arcoPidiendo : textos.arcoPedir,
        icono: Icons.folder_copy_outlined,
        expandido: true,
        alPresionar: _pidiendo ? null : _pedir,
      ),
    ];
  }
}

class _Introduccion extends StatelessWidget {
  const _Introduccion({required this.textos});

  final AppLocalizations textos;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          textos.arcoIntro,
          style: tokens.tipografia.cuerpo.copyWith(color: c.texto),
        ),
        const SizedBox(height: Espaciado.e2),
        Text(
          textos.arcoAlcance,
          style: tokens.tipografia.cuerpoChico.copyWith(
            color: c.textoSecundario,
          ),
        ),
      ],
    );
  }
}

/// La copia se está preparando; el lector de pantalla lo anuncia.
class _Preparando extends StatelessWidget {
  const _Preparando({required this.textos});

  final AppLocalizations textos;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    return Semantics(
      liveRegion: true,
      container: true,
      child: SuperficieLiquida(
        padding: const EdgeInsets.all(Espaciado.e4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textos.arcoPreparando,
              style: tokens.tipografia.titulo3.copyWith(color: c.texto),
            ),
            const SizedBox(height: Espaciado.e2),
            Text(
              textos.arcoPreparandoDetalle,
              style: tokens.tipografia.cuerpo.copyWith(
                color: c.textoSecundario,
              ),
            ),
            const SizedBox(height: Espaciado.e4),
            const ExcludeSemantics(child: Esqueleto(alto: 14)),
            const SizedBox(height: Espaciado.e2),
            const ExcludeSemantics(child: Esqueleto(alto: 14, ancho: 180)),
          ],
        ),
      ),
    );
  }
}

/// La copia está lista: hasta cuándo y cómo cuidarla.
class _Lista extends StatelessWidget {
  const _Lista({required this.solicitud, required this.textos});

  final SolicitudDeArco solicitud;
  final AppLocalizations textos;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final vence = solicitud.venceEn;
    return SuperficieLiquida(
      padding: const EdgeInsets.all(Espaciado.e4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(Icons.check_circle_outline, color: c.exito),
              ),
              const SizedBox(width: Espaciado.e2),
              Expanded(
                child: Text(
                  textos.arcoLista,
                  style: tokens.tipografia.titulo3.copyWith(color: c.texto),
                ),
              ),
            ],
          ),
          if (vence != null) ...[
            const SizedBox(height: Espaciado.e2),
            Text(
              textos.arcoVence(diaDelAviso(context, vence)),
              style: tokens.tipografia.cuerpo.copyWith(
                color: c.textoSecundario,
              ),
            ),
          ],
          const SizedBox(height: Espaciado.e3),
          Text(
            textos.arcoCuidado,
            style: tokens.tipografia.cuerpoChico.copyWith(
              color: c.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}
