import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/dialogo.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/datos/vista_asincrona.dart';
import '../../../nucleo/sesion/proveedores_sesion.dart';
import '../dominio/antiguedad.dart';
import '../dominio/fallos_acceso.dart';
import '../dominio/sesion_de_la_cuenta.dart';
import 'proveedores_acceso.dart';

/// Sesiones y dispositivos activos · V2-M01.09.
///
/// Responde una pregunta de seguridad: «¿quién está dentro de mi cuenta
/// ahora?». De ahí vienen las dos decisiones que mandan en esta pantalla:
///
/// 1. **Nunca decir que una sesión se cerró si no se cerró.** Un 404 al cerrar
///    no es éxito: el `id` de una sesión cambia en cada refresco, así que puede
///    significar que la otra sesión se refrescó y **sigue viva**. En ese caso
///    la fila se queda y se invita a intentar otra vez.
/// 2. **Cerrar todas avisa antes**, porque incluye la sesión de este teléfono.
///
/// La lista **no marca «este dispositivo»**: el JWT no lleva el id de la sesión
/// y el servidor no sabe cuál de ellas está preguntando. Está documentado en el
/// diseño de la historia y se propuso aparte, porque exigiría un claim nuevo en
/// `shared`, que también usan el ERP y el CRM.
class PantallaSesiones extends ConsumerWidget {
  const PantallaSesiones({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final estado = ref.watch(sesionesProvider);

    return VistaAsincrona<List<SesionDeLaCuenta>>(
      estado: estado,
      cargando: (_) => MarcoPantalla.estado(
        titulo: textos.accesoSesionesTitulo,
        conRegreso: true,
        estado: const _Cargando(),
      ),
      estaVacio: (sesiones) => sesiones.isEmpty,
      vacio: (_) => MarcoPantalla.estado(
        titulo: textos.accesoSesionesTitulo,
        conRegreso: true,
        estado: EstadoVacio(
          titulo: textos.accesoSesionesVacioTitulo,
          mensaje: textos.accesoSesionesVacioMensaje,
          icono: Icons.devices_other_outlined,
        ),
      ),
      alReintentar: () => ref.invalidate(sesionesProvider),
      datos: (_, sesiones) => _Lista(sesiones),
    );
  }
}

class _Lista extends ConsumerWidget {
  const _Lista(this.sesiones);

  final List<SesionDeLaCuenta> sesiones;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;

    return MarcoPantalla(
      titulo: textos.accesoSesionesTitulo,
      conRegreso: true,
      alRefrescar: () async {
        ref.invalidate(sesionesProvider);
        await ref.read(sesionesProvider.future);
      },
      barraInferior: BarraInferior(
        hijos: [
          BotonPildora(
            texto: textos.accesoSesionesCerrarTodas,
            icono: Icons.logout_outlined,
            variante: VarianteBotonPildora.peligro,
            expandido: true,
            alPresionar: () => _cerrarTodas(context, ref),
          ),
        ],
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: Espaciado.e2),
            child: GrupoLista(
              encabezado: textos.accesoSesionesEncabezado,
              pie: textos.accesoSesionesPie,
              filas: [
                for (final s in sesiones)
                  FilaGrupo(
                    titulo:
                        s.dispositivo ?? textos.accesoSesionesEquipoSinNombre,
                    subtitulo: _ultimoUso(context, s, ref),
                    icono: Icons.smartphone_outlined,
                    colorIcono: c.acento,
                    // `fin` es adorno: `GrupoLista` no lo deja leer al lector
                    // de pantalla («el `fin` no se lee»), asi que la accion es
                    // la fila completa y lo hablado va en `etiquetaFin`.
                    fin: Text(
                      textos.accesoSesionesCerrar,
                      style: TokensPista.de(context).tipografia.cuerpoChico
                          .copyWith(color: c.peligro),
                    ),
                    etiquetaFin: textos.accesoSesionesCerrarEtiqueta(
                      s.dispositivo ?? textos.accesoSesionesEquipoSinNombre,
                    ),
                    alToque: () => _cerrarUna(context, ref, s),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// «Hace 5 minutos», o la fecha si ya pasó una semana.
  ///
  /// Sin ninguna fecha -las sesiones abiertas antes de esta historia- se dice
  /// que no hay actividad, en vez de inventar una.
  String _ultimoUso(BuildContext context, SesionDeLaCuenta s, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final cuando = s.ultimaSenal;
    if (cuando == null) return textos.accesoSesionesSinActividad;

    final antiguedad = Antiguedad.entre(
      cuando: cuando,
      ahora: ref.read(relojAccesoProvider)(),
    );

    return switch (antiguedad.tramo) {
      TramoDeAntiguedad.ahora => textos.accesoSesionesActivaAhora,
      TramoDeAntiguedad.minutos => textos.accesoSesionesHaceMinutos(
        antiguedad.cantidad!,
      ),
      TramoDeAntiguedad.horas => textos.accesoSesionesHaceHoras(
        antiguedad.cantidad!,
      ),
      TramoDeAntiguedad.dias => textos.accesoSesionesHaceDias(
        antiguedad.cantidad!,
      ),
      TramoDeAntiguedad.fecha => textos.accesoSesionesUltimoUsoFecha(
        DateFormat.yMMMMd(
          Localizations.localeOf(context).toString(),
          // La fecha se enseña en la zona del teléfono: el contrato manda UTC.
        ).format(cuando.toLocal()),
      ),
    };
  }

  /// Cierra una sesion, preguntando primero.
  ///
  /// La confirmacion no es ceremonia: la accion es la fila completa -porque el
  /// sistema de diseno no deja que el lector de pantalla alcance un boton
  /// dentro de `fin`-, y una fila que echa a un dispositivo con un solo toque
  /// se dispararia sin querer al desplazarse.
  Future<void> _cerrarUna(
    BuildContext context,
    WidgetRef ref,
    SesionDeLaCuenta sesion,
  ) async {
    final textos = AppLocalizations.of(context);
    final nombre = sesion.dispositivo ?? textos.accesoSesionesEquipoSinNombre;

    final confirmado = await mostrarDialogo<bool>(
      context,
      builder: (dialogo) => Dialogo(
        titulo: textos.accesoSesionesCerrarUnaTitulo(nombre),
        mensaje: textos.accesoSesionesCerrarUnaMensaje,
        peligro: true,
        textoPrincipal: textos.accesoSesionesCerrar,
        alPrincipal: () => Navigator.of(dialogo).pop(true),
        textoSecundario: textos.accesoSesionesCancelar,
        alSecundario: () => Navigator.of(dialogo).pop(false),
      ),
    );

    if (confirmado != true || !context.mounted) return;

    final notifier = ref.read(sesionesProvider.notifier);
    final mensajero = ScaffoldMessenger.of(context);
    final listo = textos.accesoSesionesCerrada;
    final cambio = textos.accesoSesionesCambio;
    final fallo = textos.accesoSesionesFalloCerrar;

    try {
      await notifier.cerrar(sesion.id);
      mensajero.showSnackBar(SnackBar(content: Text(listo)));
    } on SesionYaNoEsta {
      // No se cerro nada: la sesion se refresco y sigue viva con otro id. La
      // lista ya se releyo, asi que intentarlo otra vez si funciona.
      mensajero.showSnackBar(SnackBar(content: Text(cambio)));
    } on Object {
      mensajero.showSnackBar(SnackBar(content: Text(fallo)));
    }
  }

  Future<void> _cerrarTodas(BuildContext context, WidgetRef ref) async {
    final textos = AppLocalizations.of(context);

    final confirmado = await mostrarDialogo<bool>(
      context,
      // Es una acción que no se puede deshacer y que cierra la sesión de quien
      // la pide: no debe dispararse por un toque fuera del diálogo.
      cerrarAlTocarFuera: false,
      builder: (dialogo) => Dialogo(
        titulo: textos.accesoSesionesCerrarTodasTitulo,
        mensaje: textos.accesoSesionesCerrarTodasMensaje,
        peligro: true,
        textoPrincipal: textos.accesoSesionesCerrarTodasConfirmar,
        alPrincipal: () => Navigator.of(dialogo).pop(true),
        textoSecundario: textos.accesoSesionesCancelar,
        alSecundario: () => Navigator.of(dialogo).pop(false),
      ),
    );

    if (confirmado != true || !context.mounted) return;

    // Se toman antes de esperar: cerrar todas se lleva esta sesión, así que la
    // pantalla puede dejar de existir mientras el servidor contesta.
    final notifier = ref.read(sesionesProvider.notifier);
    final sesionLocal = ref.read(controladorSesionProvider);
    final mensajero = ScaffoldMessenger.of(context);
    final falloTexto = textos.accesoSesionesFalloCerrar;

    try {
      await notifier.cerrarTodas();
    } on Object {
      mensajero.showSnackBar(SnackBar(content: Text(falloTexto)));
      return;
    }

    // El access token en curso sigue valiendo hasta que expire, así que la app
    // tiene que soltar la sesión por su cuenta: si se quedara dentro, el
    // cliente creería que no se cerró nada.
    await sesionLocal.cerrarSesion();
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).accesoSesionesCargando,
      liveRegion: true,
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(Espaciado.e4),
          child: Column(
            children: [
              Esqueleto(alto: 72, radio: 16),
              SizedBox(height: Espaciado.e3),
              Esqueleto(alto: 72, radio: 16),
            ],
          ),
        ),
      ),
    );
  }
}
