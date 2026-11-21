import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../api/carecar_api.dart';
import '../../api/excepciones.dart';
import '../../api/modelos/modelos.dart';
import '../../tema/tema_carecar.dart';
import '../pantalla_cambiar_contrasena.dart';
import '../../widgets/pagina_carecar.dart';

/// Version que se muestra en «Acerca de».
///
/// Se escribe a mano para no agregar `package_info_plus`: hay que mantenerla
/// igual que `version` en `pubspec.yaml` al publicar.
const versionDeLaApp = '1.0.0';

// TODO(agencia): reemplazar por los datos reales de contacto de la agencia.
const _telefonoAgencia = '+52 000 000 0000';
// TODO(agencia): reemplazar por el correo real de atencion a clientes.
const _correoAgencia = 'contacto@agencia.example.com';

/// APP-2.2 · Perfil del cliente: sus datos, la cuenta, ayuda y cerrar sesion.
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
  static const botonReintentar = Key('perfil_reintentar');
  static const avatar = Key('perfil_avatar');
  static const botonCambiarContrasena = Key('perfil_cambiar_contrasena');
  static const botonContactar = Key('perfil_contactar');
  static const botonPrivacidad = Key('perfil_privacidad');
  static const botonConfirmarCierre = Key('perfil_confirmar_cierre');
  static const botonCancelarCierre = Key('perfil_cancelar_cierre');

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  late Future<Perfil> _perfil;

  /// Lo que dibuja el esqueleto mientras carga.
  static const _deMentira = Perfil(
    id: 0,
    nombre: 'Nombre del cliente',
    correo: 'correo@example.com',
  );

  @override
  void initState() {
    super.initState();
    _perfil = widget.api.miPerfil();
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tu contraseña quedó actualizada.')),
            );
          },
        ),
      ),
    );
  }

  void _contactar() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: TemaCareCar.tarjeta,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _HojaContacto(),
    );
  }

  void _privacidad() {
    // TODO(agencia): mostrar el aviso de privacidad real cuando exista.
    showDialog<void>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Aviso de privacidad'),
        content: const Text(
          'La agencia publicará aquí su aviso de privacidad. Tus datos solo '
          'se usan para darte servicio a ti y a tus vehículos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarCierre() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        icon: const Icon(Icons.logout, color: TemaCareCar.peligro),
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Tendrás que escribir tu correo y contraseña para volver a entrar.',
        ),
        actions: [
          TextButton(
            key: PantallaPerfil.botonCancelarCierre,
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: PantallaPerfil.botonConfirmarCierre,
            style: FilledButton.styleFrom(backgroundColor: TemaCareCar.peligro),
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmado == true) await widget.alCerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _recargar,
      color: TemaCareCar.azulAgencia,
      child: FutureBuilder<Perfil>(
        future: _perfil,
        builder: (context, foto) {
          final cargando = foto.connectionState != ConnectionState.done;
          final conError = !cargando && foto.hasError;
          final perfil = cargando || conError ? _deMentira : foto.data!;

          final secciones = <Widget>[
            _Seccion(
              titulo: 'Cuenta',
              opciones: [
                _Opcion(
                  llave: PantallaPerfil.botonCambiarContrasena,
                  icono: Icons.lock_reset_outlined,
                  titulo: 'Cambiar contraseña',
                  subtitulo: 'Actualiza la contraseña con la que entras',
                  alTocar: _cambiarContrasena,
                ),
              ],
            ),
            _Seccion(
              titulo: 'Ayuda',
              opciones: [
                _Opcion(
                  llave: PantallaPerfil.botonContactar,
                  icono: Icons.support_agent_outlined,
                  titulo: 'Contactar a la agencia',
                  subtitulo: 'Teléfono y correo de atención',
                  alTocar: _contactar,
                ),
                _Opcion(
                  llave: PantallaPerfil.botonPrivacidad,
                  icono: Icons.privacy_tip_outlined,
                  titulo: 'Aviso de privacidad',
                  alTocar: _privacidad,
                ),
              ],
            ),
            const _Seccion(
              titulo: 'Acerca de',
              opciones: [
                _Opcion(
                  icono: Icons.info_outline,
                  titulo: 'CareCar',
                  subtitulo: 'Versión $versionDeLaApp',
                ),
              ],
            ),
            _Seccion(
              opciones: [
                _Opcion(
                  llave: PaginaCareCar.botonCerrarSesion,
                  icono: Icons.logout,
                  titulo: 'Cerrar sesión',
                  peligro: true,
                  alTocar: _confirmarCierre,
                ),
              ],
            ),
          ];

          return ListView(
            key: PantallaPerfil.lista,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              if (conError)
                _EncabezadoError(error: foto.error, alReintentar: _recargar)
              else
                Skeletonizer(
                  enabled: cargando,
                  child: _Encabezado(perfil: perfil),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < secciones.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: secciones[i]
                            .animate(delay: (70 * i).ms)
                            .fadeIn(duration: 350.ms)
                            .slideY(begin: 0.12, curve: Curves.easeOutCubic),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Encabezado con el degradado de marca, el avatar y los datos del cliente.
class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.perfil});

  final Perfil perfil;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    return _Fondo(
      child: Column(
        children: [
          Container(
            key: PantallaPerfil.avatar,
            width: 92,
            height: 92,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(color: TemaCareCar.turquesa, width: 2.5),
            ),
            child: Text(
              _iniciales(perfil.nombre),
              style: temas.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ).animate().scale(
            begin: const Offset(0.85, 0.85),
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
          const SizedBox(height: 14),
          Text(
            perfil.nombre,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: temas.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mail_outline,
                  size: 16,
                  color: TemaCareCar.turquesa,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    perfil.correo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: temas.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// El encabezado cuando no se pudo cargar el perfil: explica y reintenta.
class _EncabezadoError extends StatelessWidget {
  const _EncabezadoError({required this.error, required this.alReintentar});

  final Object? error;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    final sinRed = error is SinConexion;
    return _Fondo(
      child: Column(
        children: [
          Icon(
            sinRed ? Icons.wifi_off_rounded : Icons.error_outline,
            size: 44,
            color: TemaCareCar.turquesa,
          ),
          const SizedBox(height: 12),
          Text(
            sinRed ? 'Sin conexión' : 'No pudimos cargar tu perfil',
            textAlign: TextAlign.center,
            style: temas.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            sinRed
                ? 'Revisa tu conexión a internet e inténtalo de nuevo.'
                : 'Ocurrió un problema con el servidor. Inténtalo de nuevo.',
            textAlign: TextAlign.center,
            style: temas.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: PantallaPerfil.botonReintentar,
            style: FilledButton.styleFrom(
              backgroundColor: TemaCareCar.turquesa,
              foregroundColor: TemaCareCar.azulProfundo,
            ),
            onPressed: alReintentar,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ).animate().fadeIn().shake(hz: 3, offset: const Offset(4, 0)),
    );
  }
}

/// Fondo con degradado y esquinas inferiores redondeadas.
class _Fondo extends StatelessWidget {
  const _Fondo({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: TemaCareCar.degradadoMarca,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'MI PERFIL',
              style: temas.labelSmall?.copyWith(
                color: TemaCareCar.turquesa,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

/// Grupo de opciones con titulo, en una tarjeta de 20 px con borde.
class _Seccion extends StatelessWidget {
  const _Seccion({required this.opciones, this.titulo});

  final String? titulo;
  final List<_Opcion> opciones;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titulo != null)
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Text(
              titulo!.toUpperCase(),
              style: temas.labelSmall?.copyWith(
                color: TemaCareCar.textoSecundario,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        Material(
          color: TemaCareCar.tarjeta,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: TemaCareCar.borde),
            ),
            child: Column(
              children: [
                for (var i = 0; i < opciones.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: 64,
                      color: TemaCareCar.borde,
                    ),
                  opciones[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Una fila de una seccion: icono en un cuadro suave, textos y flecha.
class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.icono,
    required this.titulo,
    this.subtitulo,
    this.alTocar,
    this.llave,
    this.peligro = false,
  });

  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final VoidCallback? alTocar;
  final Key? llave;
  final bool peligro;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    final color = peligro ? TemaCareCar.peligro : TemaCareCar.azulAgencia;
    return InkWell(
      key: llave,
      onTap: alTocar,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: peligro
                      ? TemaCareCar.peligroFondo
                      : TemaCareCar.azulSuave,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icono, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: temas.titleSmall?.copyWith(
                        color: peligro
                            ? TemaCareCar.peligro
                            : TemaCareCar.textoPrincipal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitulo != null)
                      Text(
                        subtitulo!,
                        style: temas.bodySmall?.copyWith(
                          color: TemaCareCar.textoSecundario,
                        ),
                      ),
                  ],
                ),
              ),
              if (alTocar != null && !peligro)
                const Icon(
                  Icons.chevron_right,
                  color: TemaCareCar.textoSecundario,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hoja inferior con los datos de contacto de la agencia.
class _HojaContacto extends StatelessWidget {
  const _HojaContacto();

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Contactar a la agencia', style: temas.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Estamos para ayudarte con tus vehículos y tus citas.',
              style: temas.bodyMedium?.copyWith(
                color: TemaCareCar.textoSecundario,
              ),
            ),
            const SizedBox(height: 18),
            const _Seccion(
              opciones: [
                _Opcion(
                  icono: Icons.phone_outlined,
                  titulo: 'Teléfono',
                  subtitulo: _telefonoAgencia,
                ),
                _Opcion(
                  icono: Icons.alternate_email,
                  titulo: 'Correo',
                  subtitulo: _correoAgencia,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// «Laura Méndez» → «LM».
String _iniciales(String nombre) {
  final partes = nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  return partes.take(2).map((p) => p[0].toUpperCase()).join();
}
