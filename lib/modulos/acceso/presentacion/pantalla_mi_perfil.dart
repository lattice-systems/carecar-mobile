import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/biometria/candado_biometrico.dart';
import '../../../nucleo/biometria/lector_biometrico.dart';
import '../../notificaciones/notificaciones.dart';
import '../../../nucleo/datos/vista_asincrona.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/control_binario.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/perfil_del_cliente.dart';
import 'proveedores_acceso.dart';
import 'rutas_acceso.dart';

/// Los datos del cliente, de solo lectura · V2-M01.06.
///
/// Son **dos lecturas distintas**: el perfil y el garaje. Cada una tiene su
/// estado, a propósito: si los vehículos no cargan, el perfil se sigue
/// viendo, porque el cliente vino a confirmar sus datos y perderlos todos por
/// una lista que no respondió sería peor.
///
/// Aquí también vive la entrada a «mis sesiones» (V2-M01.09), que hasta ahora
/// tenía ruta y nada que llevara a ella.
class PantallaMiPerfil extends ConsumerWidget {
  const PantallaMiPerfil({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);

    return VistaAsincrona<PerfilDelCliente>(
      estado: ref.watch(perfilProvider),
      cargando: (_) => MarcoPantalla.estado(
        icono: LucideIcons300.user,
        titulo: textos.accesoPerfilTitulo,
        conRegreso: true,
        estado: const _Cargando(),
      ),
      alReintentar: () => ref.invalidate(perfilProvider),
      datos: (_, perfil) => _Contenido(perfil),
    );
  }
}

class _Contenido extends ConsumerWidget {
  const _Contenido(this.perfil);

  final PerfilDelCliente perfil;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final idioma = Localizations.localeOf(context).toString();
    final sinLeer = ref.watch(avisosSinLeerProvider);

    return MarcoPantalla(
      icono: LucideIcons300.user,
      titulo: textos.accesoPerfilTitulo,
      conRegreso: true,
      alRefrescar: () async {
        ref
          ..invalidate(perfilProvider)
          ..invalidate(garajeProvider);
        await ref.read(perfilProvider.future);
      },
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: Espaciado.e2),
            child: Column(
              children: [
                GrupoLista(
                  encabezado: textos.accesoPerfilDatosEncabezado,
                  // De solo lectura hasta V2-M01.07: mejor decir qué hacer
                  // mientras tanto que dejar al cliente buscando un botón.
                  pie: textos.accesoPerfilPie,
                  filas: [
                    FilaGrupo(
                      titulo: textos.accesoPerfilNombre,
                      subtitulo: perfil.nombre,
                      icono: LucideIcons300.user,
                      colorIcono: c.acento,
                    ),
                    FilaGrupo(
                      titulo: textos.accesoPerfilCorreo,
                      subtitulo: perfil.correo,
                      icono: LucideIcons300.mail,
                      colorIcono: c.acento,
                      // Solo el correo se edita (V2-M01.07). El telefono no:
                      // verificarlo exige un SMS y todavia no hay con que.
                      alToque: () => context.push(rutaCambiarCorreo),
                    ),
                    FilaGrupo(
                      titulo: textos.accesoPerfilTelefono,
                      // Sin teléfono se dice que falta, en vez de dejar el
                      // renglón vacío, que parecería un error de la app.
                      subtitulo:
                          perfil.telefono ?? textos.accesoPerfilSinTelefono,
                      icono: LucideIcons300.phone,
                      colorIcono: c.acento,
                    ),
                    FilaGrupo(
                      titulo: textos.accesoPerfilClienteDesde,
                      // El servidor ya resolvió la fecha en la zona de la
                      // agencia: aquí solo se escribe en palabras.
                      subtitulo: DateFormat.yMMMM(idioma)
                          .format(perfil.clienteDesde),
                      icono: LucideIcons300.calendarDays,
                      colorIcono: c.acento,
                    ),
                  ],
                ),
                const _Vehiculos(),
                GrupoLista(
                  encabezado: textos.accesoPerfilCuentaEncabezado,
                  filas: [
                    FilaGrupo(
                      titulo: textos.accesoPerfilMisSesiones,
                      subtitulo: textos.accesoPerfilMisSesionesDetalle,
                      icono: LucideIcons300.monitorSmartphone,
                      colorIcono: c.acento,
                      alToque: () => context.push(rutaSesiones),
                    ),
                    // V2-M06.01: la puerta para reactivar los avisos
                    // despues de negarlos. En Android 13 y despues el dialogo
                    // del sistema ya no vuelve, asi que si no esta aqui no
                    // hay forma de prenderlos.
                    // V2-M06.04: la bandeja, con su contador de no leidos.
                    FilaGrupo(
                      titulo: textos.accesoPerfilMisAvisos,
                      subtitulo: sinLeer > 0
                          ? textos.bandejaSinLeer(sinLeer)
                          : null,
                      icono: LucideIcons300.inbox,
                      colorIcono: c.acento,
                      alToque: () => context.push(rutaBandeja),
                    ),
                    // V2-M06.05: elegir que avisos recibir.
                    FilaGrupo(
                      titulo: textos.accesoPerfilPreferenciasAvisos,
                      icono: LucideIcons300.slidersHorizontal,
                      colorIcono: c.acento,
                      alToque: () => context.push(rutaPreferenciasAvisos),
                    ),
                    FilaGrupo(
                      titulo: textos.accesoPerfilAvisos,
                      subtitulo: switch (ref.watch(permisoDeAvisosProvider)) {
                        EstadoAvisos.permitidos =>
                          textos.accesoPerfilAvisosPrendidos,
                        EstadoAvisos.negados =>
                          textos.accesoPerfilAvisosApagados,
                        EstadoAvisos.sinPreguntar =>
                          textos.accesoPerfilAvisosSinPreguntar,
                      },
                      icono: LucideIcons300.bell,
                      colorIcono: c.acento,
                      alToque: () => context.push(rutaPermisoAvisos),
                    ),
                  ],
                ),
                const SizedBox(height: Espaciado.e4),
                const _CandadoBiometrico(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// El interruptor del desbloqueo con huella o rostro · V2-M01.05.
///
/// Va **fuera** del `GrupoLista`, suelto en la columna, y no como `fin` de una
/// fila: `GrupoLista` envuelve la fila en `Semantics(excludeSemantics: true)`,
/// así que un interruptor ahí dentro no lo leería el lector de pantalla. El
/// componente `Interruptor` ya es una fila completa, con su etiqueta y su
/// descripción.
///
/// Si el equipo no tiene biometría utilizable **no se pinta nada**: un
/// interruptor que no se puede prender solo hace preguntarse qué falta.
class _CandadoBiometrico extends ConsumerStatefulWidget {
  const _CandadoBiometrico();

  static const interruptor = Key('perfil_candado_biometrico');

  @override
  ConsumerState<_CandadoBiometrico> createState() => _EstadoCandadoBiometrico();
}

class _EstadoCandadoBiometrico extends ConsumerState<_CandadoBiometrico> {
  bool? _hayBiometria;
  bool _ocupado = false;

  @override
  void initState() {
    super.initState();
    _preguntar();
  }

  Future<void> _preguntar() async {
    final lector = ref.read(lectorBiometricoProvider);
    final hay = lector != null && await lector.disponible();
    if (mounted) setState(() => _hayBiometria = hay);
  }

  Future<void> _cambiar(bool prender) async {
    final textos = AppLocalizations.of(context);
    final candado = ref.read(candadoProvider.notifier);
    if (!prender) {
      await candado.apagar();
      return;
    }

    final lector = ref.read(lectorBiometricoProvider);
    if (lector == null) return;

    setState(() => _ocupado = true);
    // Se pide la huella **antes** de prenderlo: prenderlo sin comprobar que
    // funciona dejaría a la persona encerrada fuera en el siguiente arranque.
    final reconocido = await lector.identificar(
      motivo: textos.accesoPerfilCandadoMotivo,
    );
    if (reconocido) await candado.prender(await lector.firma());
    if (!mounted) return;
    setState(() => _ocupado = false);
    if (!reconocido) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(textos.accesoPerfilCandadoNoSePudo)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    if (_hayBiometria != true) return const SizedBox.shrink();

    return Interruptor(
      key: _CandadoBiometrico.interruptor,
      etiqueta: textos.accesoPerfilCandado,
      descripcion: textos.accesoPerfilCandadoDetalle,
      valor: ref.watch(candadoProvider) != EstadoCandado.apagado,
      alCambiar: _ocupado ? null : _cambiar,
    );
  }
}

/// Los vehículos del cliente, con **su propio estado**.
///
/// Vienen del módulo `vehiculos` por su contrato público (regla R1), así que
/// esta pantalla no duplica la lectura del garaje ni su modelo.
class _Vehiculos extends ConsumerWidget {
  const _Vehiculos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;

    // Aqui no se usa `VistaAsincrona`: esa pinta `EstadoError` a pantalla
    // completa, y un fallo del garaje **no** debe tapar el perfil. Es una
    // seccion embebida con su propio estado degradado.
    return ref
        .watch(garajeProvider)
        .when(
          skipLoadingOnReload: true,
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(horizontal: Espaciado.e4),
            child: Esqueleto(alto: 96, radio: 16),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
            child: Aviso(
              tono: Tono.informacion,
              mensaje: textos.accesoPerfilVehiculosFallo,
            ),
          ),
          data: (vehiculos) => vehiculos.isEmpty
              ? GrupoLista(
                  encabezado: textos.accesoPerfilVehiculosEncabezado,
                  filas: [
                    FilaGrupo(
                      titulo: textos.accesoPerfilSinVehiculos,
                      icono: LucideIcons300.carFront,
                      colorIcono: c.textoTerciario,
                    ),
                  ],
                )
              : GrupoLista(
                  encabezado: textos.accesoPerfilVehiculosEncabezado,
                  filas: [
                    for (final v in vehiculos)
                      FilaGrupo(
                        titulo: v.titulo,
                        icono: LucideIcons300.carFront,
                        colorIcono: c.acento,
                        alToque: () => context.push(rutaDetalleVehiculo(v.id)),
                      ),
                  ],
                ),
        );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).accesoPerfilCargando,
      liveRegion: true,
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(Espaciado.e4),
          child: Column(
            children: [
              Esqueleto(alto: 220, radio: 16),
              SizedBox(height: Espaciado.e3),
              Esqueleto(alto: 96, radio: 16),
            ],
          ),
        ),
      ),
    );
  }
}
