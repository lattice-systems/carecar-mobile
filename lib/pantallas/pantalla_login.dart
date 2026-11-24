import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../nucleo/diseno/componentes/rebote_tactil.dart';
import '../nucleo/diseno/componentes/superficie_liquida.dart';
import '../nucleo/diseno/tema_pista.dart';
import '../nucleo/diseno/tokens/radios.dart';
import '../sesion/controlador_sesion.dart';
import '../tema/tema_carecar.dart';
import '../widgets/aviso.dart';
import '../widgets/campo_texto.dart';
import '../widgets/espera_servidor.dart';

/// Pantalla de acceso · APP-2.1 con estética Liquid Glass / Telegram.
///
/// El criterio de aceptación es explícito: **no hay registro público**. La
/// interfaz no muestra ningún botón ni flujo de «Registro de cuenta nueva»; las
/// credenciales las entrega la agencia tras validar la compra.
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({
    required this.controlador,
    this.alIniciarSesion,
    this.alOlvidarContrasena,
    super.key,
  });

  final ControladorSesion controlador;

  /// Se llama cuando la sesión queda iniciada.
  final VoidCallback? alIniciarSesion;

  /// Se llama al tocar «¿Olvidaste tu contraseña?».
  final void Function(String correo)? alOlvidarContrasena;

  static const campoCorreo = Key('login_correo');
  static const campoContrasena = Key('login_contrasena');
  static const botonVerContrasena = Key('login_ver_contrasena');
  static const botonEntrar = Key('login_entrar');
  static const botonOlvide = Key('login_olvide');
  static const logo = Key('login_logo');
  static const avisoDeError = Key('login_aviso_error');
  static const avisoServidorDespertando = Key('login_aviso_despertando');

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formulario = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _verContrasena = false;

  /// Arranca al empezar la petición y avisa si el servidor tarda.
  Timer? _temporizadorDeEspera;
  bool _servidorTarda = false;

  @override
  void initState() {
    super.initState();
    widget.controlador.addListener(_alCambiarLaSesion);
  }

  @override
  void dispose() {
    widget.controlador.removeListener(_alCambiarLaSesion);
    _temporizadorDeEspera?.cancel();
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  void _alCambiarLaSesion() {
    if (!mounted) return;
    if (widget.controlador.estado is Autenticando) {
      _temporizadorDeEspera ??= Timer(umbralServidorDespertando, () {
        if (mounted) setState(() => _servidorTarda = true);
      });
    } else {
      _temporizadorDeEspera?.cancel();
      _temporizadorDeEspera = null;
      _servidorTarda = false;
    }
    setState(() {});
    if (widget.controlador.estado is Autenticada) {
      widget.alIniciarSesion?.call();
    }
  }

  String? _validarCorreo(String? valor) {
    final correo = (valor ?? '').trim();
    if (correo.isEmpty) return 'Escribe tu correo.';
    final arroba = correo.indexOf('@');
    if (arroba <= 0 || !correo.contains('.', arroba)) {
      return 'Escribe un correo válido, como nombre@dominio.com.';
    }
    return null;
  }

  Future<void> _entrar() async {
    if (!_formulario.currentState!.validate()) return;

    await widget.controlador.iniciarSesion(
      correo: _correo.text.trim(),
      contrasena: _contrasena.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = widget.controlador.estado;
    final entrando = estado is Autenticando;
    final fallo = estado is FalloDeSesion ? estado : null;

    // Fondo oscuro: hora, senal y bateria en claro para que se lean.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: TemaPista.oscuro(),
        child: Scaffold(
          backgroundColor: const Color(0xFF08090C),
          body: Stack(
            children: [
              // 1. Atmósfera luminosa Liquid Glass: radial cobalto
              Positioned(
                top: -120,
                left: -60,
                right: -60,
                height: 400,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF2457F5).withValues(alpha: 0.22),
                          const Color(0xFF2457F5).withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Contenido desplazable y protegido de SafeArea
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: TemaCareCar.rellenoTarjeta,
                      vertical: TemaCareCar.espacioSecciones,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Form(
                        key: _formulario,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _Encabezado(),
                            const SizedBox(
                              height: TemaCareCar.espacioSecciones,
                            ),
                            if (entrando && _servidorTarda) ...[
                              const AvisoServidorDespertando(
                                key: PantallaLogin.avisoServidorDespertando,
                              ),
                              const SizedBox(height: TemaCareCar.espacioCampos),
                            ],
                            if (fallo != null) ...[
                              Aviso(
                                key: PantallaLogin.avisoDeError,
                                tono:
                                    fallo.esFalloDeRed ||
                                        fallo.esBloqueoTemporal
                                    ? TonoAviso.advertencia
                                    : TonoAviso.error,
                                icono: switch (fallo) {
                                  _ when fallo.esFalloDeRed =>
                                    Icons.wifi_off_outlined,
                                  _ when fallo.esBloqueoTemporal =>
                                    Icons.lock_clock_outlined,
                                  _ => null,
                                },
                                titulo: switch (fallo) {
                                  _ when fallo.esFalloDeRed => 'Sin conexión',
                                  _ when fallo.esBloqueoTemporal =>
                                    'Demasiados intentos',
                                  _ => 'No pudimos iniciar sesión',
                                },
                                detalle: fallo.mensaje,
                              ),
                              const SizedBox(height: TemaCareCar.espacioCampos),
                            ],
                            CampoTexto(
                              llave: PantallaLogin.campoCorreo,
                              controlador: _correo,
                              etiqueta: 'Correo',
                              ayuda: 'El que le diste a la agencia',
                              habilitado: !entrando,
                              icono: Icons.mail_outline_rounded,
                              teclado: TextInputType.emailAddress,
                              autocompletar: const [AutofillHints.email],
                              textInputAction: TextInputAction.next,
                              validar: _validarCorreo,
                            ),
                            const SizedBox(height: TemaCareCar.espacioCampos),
                            CampoTexto(
                              llave: PantallaLogin.campoContrasena,
                              controlador: _contrasena,
                              etiqueta: 'Contraseña',
                              habilitado: !entrando,
                              icono: Icons.lock_outline_rounded,
                              ocultar: !_verContrasena,
                              textInputAction: TextInputAction.done,
                              alEnviar: entrando ? null : _entrar,
                              sufijo: IconButton(
                                key: PantallaLogin.botonVerContrasena,
                                onPressed: entrando
                                    ? null
                                    : () => setState(
                                        () => _verContrasena = !_verContrasena,
                                      ),
                                icon: Icon(
                                  _verContrasena
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF8E9BAE),
                                  size: 20,
                                ),
                                tooltip: _verContrasena
                                    ? 'Ocultar la contraseña'
                                    : 'Mostrar la contraseña',
                              ),
                              validar: (valor) =>
                                  (valor == null || valor.isEmpty)
                                  ? 'Escribe tu contraseña.'
                                  : null,
                            ),
                            const SizedBox(
                              height: TemaCareCar.espacioSecciones,
                            ),
                            ReboteTactil(
                              habilitado: !entrando,
                              child: ShadButton(
                                key: PantallaLogin.botonEntrar,
                                size: ShadButtonSize.lg,
                                backgroundColor: const Color(0xFF2457F5),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2457F5),
                                    Color(0xFF3B72FF),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                decoration: const ShadDecoration(
                                  border: ShadBorder(
                                    radius: Radios.bordePildora,
                                  ),
                                ),
                                shadows: [
                                  BoxShadow(
                                    color: const Color(0xFF2457F5)
                                        .withValues(alpha: 0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                                onPressed: entrando ? null : _entrar,
                                child: Text(
                                  entrando
                                      ? 'Entrando…'
                                      : (fallo?.esFalloDeRed ?? false)
                                      ? 'Reintentar'
                                      : 'Iniciar sesión',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ),
                            if (widget.alOlvidarContrasena != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ShadButton.link(
                                  key: PantallaLogin.botonOlvide,
                                  foregroundColor: const Color(0xFF5B8CFF),
                                  onPressed: entrando
                                      ? null
                                      : () => widget.alOlvidarContrasena!(
                                          _correo.text.trim(),
                                        ),
                                  child: const Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: TextStyle(
                                      color: Color(0xFF5B8CFF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: TemaCareCar.espacioCampos),
                            const _NotaSinRegistro(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          // Variante con letras claras: la original es azul marino y se pierde
          // sobre el fondo oscuro del login.
          'assets/marca/agencia360-logo-oscuro.png',
          key: PantallaLogin.logo,
          width: 180,
          semanticLabel: 'Agencia360',
        ),
        const SizedBox(height: 18),
        const Text(
          'CareCar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'Tu acceso a la agencia',
          style: TextStyle(
            color: Color(0xFF8E9BAE),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _NotaSinRegistro extends StatelessWidget {
  const _NotaSinRegistro();

  @override
  Widget build(BuildContext context) {
    return SuperficieLiquida(
      radio: 16,
      opacidad: 0.08,
      colorFondo: Colors.white.withValues(alpha: 0.04),
      colorBorde: Colors.white.withValues(alpha: 0.10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: Color(0xFF8E9BAE)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'La agencia te entrega tu acceso cuando recibes '
              'tu unidad. Si no los tienes, comunícate con la agencia.',
              style: TextStyle(
                color: Color(0xFF8E9BAE),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
