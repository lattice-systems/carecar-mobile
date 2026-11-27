import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../api/carecar_api.dart';
import '../../api/excepciones.dart';
import '../../api/modelos/modelos.dart';
import '../../config/agencia.dart';
import '../../config/version_app.dart';
import '../../modulos/acceso/acceso.dart' show rutaMiPerfil;
import '../../modulos/lealtad/lealtad.dart' show rutaLealtad;
import '../../modulos/pagos/pagos.dart'
    show rutaDatosFiscales, rutaMetodosPago, rutaMisPagos;
import '../../modulos/privacidad/privacidad.dart' show rutaPrivacidad;
import '../../modulos/recoleccion/recoleccion.dart' show rutaMisDirecciones;
import '../../notificaciones/servicio_notificaciones.dart';
import '../../nucleo/diseno/componentes/avatar.dart';
import '../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../nucleo/diseno/componentes/control_binario.dart';
import '../../nucleo/diseno/componentes/dialogo.dart';
import '../../nucleo/diseno/componentes/esqueleto.dart';
import '../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../nucleo/diseno/componentes/hoja_inferior.dart';
import '../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../nucleo/diseno/componentes/tono.dart';
import '../../nucleo/diseno/tokens/espaciado.dart';
import '../../nucleo/diseno/tokens/radios.dart';
import '../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../nucleo/idioma/selector_idioma.dart';
import '../../widgets/dialogos.dart' show mostrarToast;
import '../../widgets/pagina_carecar.dart' show PaginaCareCar;
import '../pantalla_cambiar_contrasena.dart';

/// APP-2.2 · Perfil del cliente: sus datos, la cuenta, ayuda y cerrar sesion.
///
/// En el lenguaje del sistema de diseno v2 (V2-T02.24): `MarcoPantalla` con
/// titulo grande y regreso, el perfil en una `TarjetaResumen` y cada grupo de
/// opciones en un `GrupoLista`. Los textos siguen escritos a mano porque la
/// pantalla es de la v1 y aun no esta en `lib/modulos`.
class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({
    required this.api,
    required this.alCerrarSesion,
    super.key,
  });

  final CarecarApi api;

  /// Cierra la sesion de verdad; se llama despues de confirmar.
  final Future<void> Function() alCerrarSesion;

  static const lista = Key('perfil_lista');
  static const interruptorRecordatorios = Key('perfil_recordatorios');
  static const botonReintentar = Key('perfil_reintentar');
  static const avatar = Key('perfil_avatar');
  static const botonCambiarContrasena = Key('perfil_cambiar_contrasena');
  static const botonMisPuntos = Key('perfil_mis_puntos');
  static const botonMisDirecciones = Key('perfil_mis_direcciones');
  static const botonDatosFiscales = Key('perfil_datos_fiscales');
  static const botonMisPagos = Key('perfil_mis_pagos');
  static const botonMetodosPago = Key('perfil_metodos_pago');
  static const botonMiPerfil = Key('perfil_mi_perfil');
  static const botonContactar = Key('perfil_contactar');
  static const botonPrivacidad = Key('perfil_privacidad');
  static const botonConfirmarCierre = Key('perfil_confirmar_cierre');
  static const botonCancelarCierre = Key('perfil_cancelar_cierre');

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  /// Interruptor de recordatorios; se guarda en el telefono.
  bool _recordatorios = Notificaciones.actual.activo;

  Future<void> _cambiarRecordatorios(bool valor) async {
    setState(() => _recordatorios = valor);
    await Notificaciones.actual.cambiarActivo(valor);
  }

  late Future<Perfil> _perfil;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _perfil = widget.api.miPerfil();
    leerVersionApp().then((v) {
      if (mounted) setState(() => _version = v);
    });
  }

  Future<void> _recargar() async {
    final nuevo = widget.api.miPerfil();
    setState(() {
      _perfil = nuevo;
    });
    try {
      await nuevo;
    } on ExcepcionApi {
      // El FutureBuilder ya muestra el error.
    }
  }

  void _cambiarContrasena() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (contexto) => PantallaCambiarContrasena(
          api: widget.api,
          obligatorio: false,
          alCambiar: () {
            Navigator.of(contexto).pop();
            mostrarToast(
              context,
              'Tu contraseña quedó actualizada.',
              exito: true,
            );
          },
        ),
      ),
    );
  }

  /// Abre «Mis puntos» (V2-M12.01). Solo se ofrece dentro de la app enrutada.
  void _abrirMisPuntos() => GoRouter.of(context).push(rutaLealtad);

  /// Abre «Mis direcciones» (V2-M17.06). Solo se ofrece dentro de la app
  /// enrutada: sin enrutador no habria a donde ir.
  void _abrirDirecciones() => GoRouter.of(context).push(rutaMisDirecciones);

  /// Abre «Datos fiscales» (V2-M08.05), para facturar los servicios.
  void _abrirDatosFiscales() => GoRouter.of(context).push(rutaDatosFiscales);

  /// Abre «Mis pagos» (V2-M08.07): lo que se pago desde la app.
  void _abrirMisPagos() => GoRouter.of(context).push(rutaMisPagos);

  /// Abre «Métodos de pago» (V2-M08.04): las tarjetas guardadas.
  void _abrirMetodosPago() => GoRouter.of(context).push(rutaMetodosPago);

  /// Abre «Mi perfil» (V2-M01.06). Solo se ofrece dentro de la app enrutada.
  void _abrirMiPerfil() => GoRouter.of(context).push(rutaMiPerfil);

  /// Las hojas y los dialogos se montan bajo el tema de la aplicacion, no bajo
  /// el de esta pantalla; se vuelve a aplicar el de la pantalla (claro u
  /// oscuro) para que se vean como ella.
  Widget _conElTemaDeLaPantalla(Widget hijo) =>
      Theme(data: Theme.of(context), child: hijo);

  void _contactar() {
    mostrarHojaInferior<void>(
      context,
      titulo: 'Contactar a la agencia',
      builder: (_) => _conElTemaDeLaPantalla(const _HojaContacto()),
    );
  }

  /// Privacidad y mis datos (V2-M22.01 y V2-M22.02): el aviso vigente del
  /// servidor y la copia de mis datos. Sin enrutador (la v1 suelta, en pruebas)
  /// queda el texto del aviso que la app trae incluido.
  void _privacidad() {
    if (GoRouter.maybeOf(context) != null) {
      GoRouter.of(context).push(rutaPrivacidad);
      return;
    }
    mostrarDialogo<void>(
      context,
      builder: (contexto) => _conElTemaDeLaPantalla(
        Dialogo(
          titulo: 'Aviso de privacidad',
          contenido: const SingleChildScrollView(
            child: Text(Agencia.avisoPrivacidad),
          ),
          textoPrincipal: 'Entendido',
          alPrincipal: () => Navigator.of(contexto).pop(),
        ),
      ),
    );
  }

  Future<void> _confirmarCierre() async {
    HapticFeedback.selectionClick();
    final confirmado = await mostrarDialogo<bool>(
      context,
      builder: (contexto) => _conElTemaDeLaPantalla(
        Dialogo(
          titulo: '¿Cerrar sesión?',
          mensaje:
              'Tendrás que escribir tu correo y contraseña para volver a '
              'entrar.',
          textoPrincipal: 'Cerrar sesión',
          alPrincipal: () => Navigator.of(contexto).pop(true),
          llavePrincipal: PantallaPerfil.botonConfirmarCierre,
          textoSecundario: 'Cancelar',
          alSecundario: () => Navigator.of(contexto).pop(false),
          llaveSecundario: PantallaPerfil.botonCancelarCierre,
          peligro: true,
        ),
      ),
    );
    if (confirmado == true) await widget.alCerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Perfil>(
      future: _perfil,
      builder: (context, foto) {
        final cargando = foto.connectionState != ConnectionState.done;
        final conError = !cargando && foto.hasError;
        final perfil = cargando || conError ? null : foto.data;

        final secciones = <_Seccion>[
          _Seccion(
            titulo: 'Cuenta',
            opciones: [
              if (GoRouter.maybeOf(context) != null)
                _Opcion(
                  llave: PantallaPerfil.botonMiPerfil,
                  icono: LucideIcons300.user,
                  titulo: 'Mi perfil',
                  subtitulo: 'Tus datos, tus vehículos y tus sesiones',
                  alTocar: _abrirMiPerfil,
                ),
              _Opcion(
                llave: PantallaPerfil.botonCambiarContrasena,
                icono: LucideIcons300.keyRound,
                titulo: 'Cambiar contraseña',
                subtitulo: 'Actualiza la contraseña con la que entras',
                alTocar: _cambiarContrasena,
              ),
              if (GoRouter.maybeOf(context) != null)
                _Opcion(
                  llave: PantallaPerfil.botonMisPuntos,
                  icono: LucideIcons300.award,
                  titulo: 'Mis puntos',
                  subtitulo: 'Tu saldo, nivel y recompensas',
                  alTocar: _abrirMisPuntos,
                ),
              if (GoRouter.maybeOf(context) != null)
                _Opcion(
                  llave: PantallaPerfil.botonMisDirecciones,
                  icono: LucideIcons300.mapPin,
                  titulo: 'Mis direcciones',
                  subtitulo: 'Donde recogemos y entregamos tu auto',
                  alTocar: _abrirDirecciones,
                ),
              if (GoRouter.maybeOf(context) != null)
                _Opcion(
                  llave: PantallaPerfil.botonDatosFiscales,
                  icono: LucideIcons300.fileText,
                  titulo: 'Datos fiscales',
                  subtitulo: 'Tu RFC y régimen para facturar tus servicios',
                  alTocar: _abrirDatosFiscales,
                ),
              if (GoRouter.maybeOf(context) != null)
                _Opcion(
                  llave: PantallaPerfil.botonMisPagos,
                  icono: LucideIcons300.receiptText,
                  titulo: 'Mis pagos',
                  subtitulo: 'Lo que pagaste desde la app',
                  alTocar: _abrirMisPagos,
                ),
              if (GoRouter.maybeOf(context) != null)
                _Opcion(
                  llave: PantallaPerfil.botonMetodosPago,
                  icono: LucideIcons300.creditCard,
                  titulo: 'Métodos de pago',
                  subtitulo: 'Tus tarjetas guardadas para pagar más rápido',
                  alTocar: _abrirMetodosPago,
                ),
            ],
          ),
          _Seccion(
            titulo: 'Notificaciones',
            opciones: [
              _Opcion(
                llave: PantallaPerfil.interruptorRecordatorios,
                icono: LucideIcons300.bellRing,
                titulo: 'Recordatorios de citas',
                subtitulo: 'Un día y dos horas antes de cada cita',
                alTocar: () => _cambiarRecordatorios(!_recordatorios),
                extremo: ControlInterruptor(valor: _recordatorios),
              ),
            ],
          ),
          _Seccion(
            titulo: 'Ayuda',
            opciones: [
              _Opcion(
                llave: PantallaPerfil.botonContactar,
                icono: LucideIcons300.headset,
                titulo: 'Contactar a la agencia',
                subtitulo: 'Teléfono y correo de atención',
                alTocar: _contactar,
              ),
              _Opcion(
                llave: PantallaPerfil.botonPrivacidad,
                icono: LucideIcons300.shieldAlert,
                titulo: 'Privacidad y mis datos',
                subtitulo: 'Aviso de privacidad y copia de tus datos',
                alTocar: _privacidad,
              ),
            ],
          ),
          _Seccion(
            titulo: 'Acerca de',
            opciones: [
              _Opcion(
                icono: LucideIcons300.info,
                titulo: 'CareCar',
                subtitulo: _version.isEmpty ? null : 'Versión $_version',
              ),
            ],
          ),
          _Seccion(
            opciones: [
              _Opcion(
                llave: PaginaCareCar.botonCerrarSesion,
                icono: LucideIcons300.logOut,
                titulo: 'Cerrar sesión',
                peligro: true,
                alTocar: _confirmarCierre,
              ),
            ],
          ),
        ];

        return MarcoPantalla(
          titulo: 'Ajustes',
          conRegreso: true,
          alRefrescar: _recargar,
          slivers: [
            SliverPadding(
              key: PantallaPerfil.lista,
              padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
              sliver: SliverList.list(
                children: [
                  const SizedBox(height: Espaciado.e2),
                  if (cargando)
                    const Esqueleto(
                      alto: _altoTarjetaPerfil,
                      radio: Radios.tarjeta,
                    )
                  else if (conError)
                    _PerfilConError(error: foto.error, alReintentar: _recargar)
                  else if (perfil != null)
                    _TarjetaPerfil(perfil: perfil),
                  const SizedBox(height: Espaciado.e4),
                  const SelectorIdioma(),
                  const SizedBox(height: Espaciado.e4),
                  for (final seccion in secciones) ...[
                    seccion.aGrupo(context),
                    const SizedBox(height: Espaciado.e4),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Alto de la tarjeta del perfil; el esqueleto reserva ese lugar mientras
/// llegan los datos, para que la lista no salte.
const double _altoTarjetaPerfil = 72;

/// Nombre y correo del cliente. Sin ninguno de los dos no se dibuja nada: no se
/// inventa un nombre.
class _TarjetaPerfil extends StatelessWidget {
  const _TarjetaPerfil({required this.perfil});

  final Perfil perfil;

  @override
  Widget build(BuildContext context) {
    if (perfil.nombre.trim().isEmpty && perfil.correo.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return TarjetaResumen(
      visual: Avatar(key: PantallaPerfil.avatar, nombre: perfil.nombre),
      titulo: perfil.nombre,
      subtitulo: perfil.correo,
    );
  }
}

/// El perfil cuando no se pudo cargar: explica y reintenta. Lo demas de
/// Ajustes (idioma, cerrar sesion) sigue a la vista.
class _PerfilConError extends StatelessWidget {
  const _PerfilConError({required this.error, required this.alReintentar});

  final Object? error;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    final sinRed = error is SinConexion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TarjetaResumen(
          titulo: sinRed ? 'Sin conexión' : 'No pudimos cargar tu perfil',
          subtitulo: sinRed
              ? 'Revisa tu conexión a internet e inténtalo de nuevo.'
              : 'Ocurrió un problema con el servidor. Inténtalo de nuevo.',
          icono: sinRed ? LucideIcons300.wifiOff : LucideIcons300.circleAlert,
          tono: sinRed ? Tono.neutro : Tono.peligro,
        ),
        const SizedBox(height: Espaciado.e3),
        Align(
          alignment: Alignment.centerLeft,
          child: BotonPildora(
            key: PantallaPerfil.botonReintentar,
            texto: 'Reintentar',
            icono: LucideIcons300.refreshCw,
            variante: VarianteBotonPildora.tonal,
            alPresionar: alReintentar,
          ),
        ),
      ],
    );
  }
}

/// Un grupo de opciones con titulo opcional: se dibuja como `GrupoLista`.
class _Seccion {
  const _Seccion({required this.opciones, this.titulo});

  final String? titulo;
  final List<_Opcion> opciones;

  Widget aGrupo(BuildContext context) => GrupoLista(
    encabezado: titulo,
    filas: [for (final opcion in opciones) opcion.aFila(context)],
  );
}

/// Una fila de una seccion: icono en un cuadro del color del tono, textos y
/// flecha. Se dibuja como `FilaGrupo`.
class _Opcion {
  const _Opcion({
    required this.icono,
    required this.titulo,
    this.subtitulo,
    this.alTocar,
    this.llave,
    this.peligro = false,
    this.extremo,
  });

  /// Lo que va a la derecha en lugar de la flecha (un interruptor).
  final Widget? extremo;
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final VoidCallback? alTocar;
  final Key? llave;
  final bool peligro;

  FilaGrupo aFila(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return FilaGrupo(
      llave: llave,
      titulo: titulo,
      subtitulo: subtitulo,
      icono: icono,
      colorIcono: peligro ? c.peligro : c.acento,
      fin: extremo,
      alToque: alTocar,
      // Cerrar sesion no lleva a otra pantalla, y una fila con interruptor
      // tampoco: sin flecha.
      conChevron: peligro || extremo != null ? false : null,
    );
  }
}

/// Contenido de la hoja con los datos de contacto de la agencia.
class _HojaContacto extends StatelessWidget {
  const _HojaContacto();

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Estamos para ayudarte con tus vehículos y tus citas.',
          style: tokens.tipografia.cuerpo.copyWith(
            color: tokens.colores.textoSecundario,
          ),
        ),
        const SizedBox(height: Espaciado.e4),
        _Seccion(
          opciones: [
            _Opcion(
              icono: LucideIcons300.phone,
              titulo: 'Teléfono',
              subtitulo: Agencia.telefono,
              alTocar: () => _abrir(
                context,
                Uri(scheme: 'tel', path: Agencia.telefono.replaceAll(' ', '')),
              ),
            ),
            _Opcion(
              icono: LucideIcons300.atSign,
              titulo: 'Correo',
              subtitulo: Agencia.correo,
              alTocar: () =>
                  _abrir(context, Uri(scheme: 'mailto', path: Agencia.correo)),
            ),
            const _Opcion(
              icono: LucideIcons300.mapPin,
              titulo: 'Dirección',
              subtitulo: Agencia.direccion,
            ),
          ],
        ).aGrupo(context),
        const SizedBox(height: Espaciado.e4),
      ],
    );
  }
}

/// Abre el marcador o el correo; avisa si el telefono no puede hacerlo.
Future<void> _abrir(BuildContext context, Uri uri) async {
  var abierto = false;
  try {
    abierto = await launchUrl(uri);
  } on Object {
    abierto = false;
  }
  if (!abierto) {
    if (context.mounted) {
      mostrarToast(
        context,
        'No se pudo abrir en este dispositivo.',
        error: true,
      );
    }
  }
}
