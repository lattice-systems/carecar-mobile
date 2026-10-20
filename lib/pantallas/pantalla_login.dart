import 'package:flutter/material.dart';

import '../sesion/controlador_sesion.dart';
import '../tema/tema_carecar.dart';
import '../widgets/aviso.dart';
import '../widgets/campo_texto.dart';

/// Pantalla de acceso · APP-2.1
///
/// El criterio de aceptacion es explicito: **no hay registro publico**. La
/// interfaz no muestra ningun boton ni flujo de «Registro de cuenta nueva»; las
/// credenciales las entrega la agencia tras validar la compra.
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({
    required this.controlador,
    this.alIniciarSesion,
    this.alOlvidarContrasena,
    super.key,
  });

  final ControladorSesion controlador;

  /// Se llama cuando la sesion queda iniciada.
  ///
  /// La navegacion la decide quien monta la pantalla. Asi, cuando el equipo
  /// defina como se navega (peticion EQ-1), el cambio no toca esta pantalla.
  final VoidCallback? alIniciarSesion;

  /// Se llama al tocar «¿Olvidaste tu contraseña?».
  ///
  /// Recibe lo que el cliente ya escribio en el campo de correo, para no
  /// pedirselo otra vez en la pantalla de recuperacion.
  final void Function(String correo)? alOlvidarContrasena;

  static const campoCorreo = Key('login_correo');
  static const campoContrasena = Key('login_contrasena');
  static const botonVerContrasena = Key('login_ver_contrasena');
  static const botonEntrar = Key('login_entrar');
  static const botonOlvide = Key('login_olvide');
  static const logo = Key('login_logo');
  static const avisoDeError = Key('login_aviso_error');

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formulario = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _verContrasena = false;

  @override
  void initState() {
    super.initState();
    widget.controlador.addListener(_alCambiarLaSesion);
  }

  @override
  void dispose() {
    widget.controlador.removeListener(_alCambiarLaSesion);
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  void _alCambiarLaSesion() {
    if (!mounted) return;
    setState(() {});
    if (widget.controlador.estado is Autenticada) {
      widget.alIniciarSesion?.call();
    }
  }

  /// Validacion minima: que tenga algo, una arroba y un punto despues.
  ///
  /// No se usa una expresion regular estricta a proposito: rechazar un correo
  /// valido es peor que dejar pasar uno raro, porque el backend valida igual.
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
    // Se valida antes de llamar al API: no tiene sentido una peticion de red
    // para descubrir que el campo venia vacio.
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

    return Scaffold(
      body: SafeArea(
        child: Center(
          // Se desplaza para que el teclado no tape el formulario en
          // pantallas chicas.
          child: SingleChildScrollView(
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
                    const SizedBox(height: TemaCareCar.espacioSecciones),
                    if (fallo != null) ...[
                      Aviso(
                        key: PantallaLogin.avisoDeError,
                        tono: fallo.esFalloDeRed
                            ? TonoAviso.advertencia
                            : TonoAviso.error,
                        icono: fallo.esFalloDeRed
                            ? Icons.wifi_off_outlined
                            : null,
                        titulo: fallo.esFalloDeRed
                            ? 'Sin conexión'
                            : 'No pudimos iniciar sesión',
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
                      icono: Icons.mail_outline,
                      // Teclado de correo, como pidio RIC-8.
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
                      icono: Icons.lock_outline,
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
                        ),
                        tooltip: _verContrasena
                            ? 'Ocultar la contraseña'
                            : 'Mostrar la contraseña',
                      ),
                      validar: (valor) => (valor == null || valor.isEmpty)
                          ? 'Escribe tu contraseña.'
                          : null,
                    ),
                    const SizedBox(height: TemaCareCar.espacioSecciones),
                    FilledButton(
                      key: PantallaLogin.botonEntrar,
                      // Deshabilitado mientras entra: evita el doble toque y
                      // cumple la regla de la guia de estilos.
                      onPressed: entrando ? null : _entrar,
                      child: Text(
                        entrando
                            ? 'Entrando…'
                            : (fallo?.esFalloDeRed ?? false)
                            ? 'Reintentar'
                            : 'Iniciar sesión',
                      ),
                    ),
                    if (widget.alOlvidarContrasena != null)
                      TextButton(
                        key: PantallaLogin.botonOlvide,
                        onPressed: entrando
                            ? null
                            : () => widget.alOlvidarContrasena!(
                                _correo.text.trim(),
                              ),
                        child: const Text('¿Olvidaste tu contraseña?'),
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
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // El logotipo de Agencia360: la app comparte su identidad y se
        // identifica como nombre de producto debajo, como en los mockups.
        // Ancho minimo de 120 px segun la guia; aqui va a 180.
        Image.asset(
          'assets/marca/agencia360-logo.png',
          key: PantallaLogin.logo,
          width: 180,
          semanticLabel: 'Agencia360',
        ),
        const SizedBox(height: TemaCareCar.espacioSecciones),
        Text(
          'CareCar',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Tu acceso a la agencia',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: TemaCareCar.textoSecundario),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Nota que explica por que no hay registro.
///
/// No es un enlace ni un boton: el criterio de APP-2.1 prohibe cualquier flujo
/// de registro, asi que es solo texto.
class _NotaSinRegistro extends StatelessWidget {
  const _NotaSinRegistro();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline,
          size: 16,
          color: TemaCareCar.textoSecundario,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'La agencia te entrega tu acceso cuando recibes '
            'tu unidad. Si no los tienes, comunícate con la agencia.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: TemaCareCar.textoSecundario),
          ),
        ),
      ],
    );
  }
}
