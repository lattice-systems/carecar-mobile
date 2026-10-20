import 'package:flutter/material.dart';

import '../sesion/controlador_sesion.dart';
import '../tema/tema_carecar.dart';

/// Pantalla de acceso · APP-2.1
///
/// El criterio de aceptacion es explicito: **no hay registro publico**. La
/// interfaz no muestra ningun boton ni flujo de «Registro de cuenta nueva»; las
/// credenciales las entrega la agencia tras validar la compra.
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({
    required this.controlador,
    this.alIniciarSesion,
    super.key,
  });

  final ControladorSesion controlador;

  /// Se llama cuando la sesion queda iniciada.
  ///
  /// La navegacion la decide quien monta la pantalla. Asi, cuando el equipo
  /// defina como se navega (peticion EQ-1), el cambio no toca esta pantalla.
  final VoidCallback? alIniciarSesion;

  static const campoUsuario = Key('login_usuario');
  static const campoContrasena = Key('login_contrasena');
  static const botonVerContrasena = Key('login_ver_contrasena');
  static const botonEntrar = Key('login_entrar');
  static const avisoDeError = Key('login_aviso_error');

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formulario = GlobalKey<FormState>();
  final _usuario = TextEditingController();
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
    _usuario.dispose();
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

  Future<void> _entrar() async {
    // Se valida antes de llamar al API: no tiene sentido una peticion de red
    // para descubrir que el campo venia vacio.
    if (!_formulario.currentState!.validate()) return;

    await widget.controlador.iniciarSesion(
      usuario: _usuario.text.trim(),
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
                      _AvisoDeError(fallo: fallo),
                      const SizedBox(height: TemaCareCar.espacioCampos),
                    ],
                    _CampoTexto(
                      llave: PantallaLogin.campoUsuario,
                      controlador: _usuario,
                      etiqueta: 'Usuario',
                      ayuda: 'El que te dio la agencia',
                      habilitado: !entrando,
                      icono: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validar: (valor) =>
                          (valor == null || valor.trim().isEmpty)
                          ? 'Escribe tu usuario.'
                          : null,
                    ),
                    const SizedBox(height: TemaCareCar.espacioCampos),
                    _CampoTexto(
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
                      child: Text(entrando ? 'Entrando…' : 'Iniciar sesión'),
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
        // Marcador de posicion del icono de la app: los archivos del logo no
        // vinieron con la guia de estilos (peticion EQ-3).
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: TemaCareCar.azulAgencia,
            borderRadius: BorderRadius.circular(TemaCareCar.radioTarjeta),
          ),
          child: const Icon(
            Icons.directions_car_outlined,
            color: TemaCareCar.turquesa,
            size: 40,
          ),
        ),
        const SizedBox(height: TemaCareCar.espacioCampos),
        Text(
          'CareCar',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Escribe tu usuario y tu contraseña.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: TemaCareCar.textoSecundario),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Aviso de error arriba del formulario.
///
/// Lleva texto **y** icono: la guia de estilos pide que un estado nunca se
/// comunique solo con color.
class _AvisoDeError extends StatelessWidget {
  const _AvisoDeError({required this.fallo});

  final FalloDeSesion fallo;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: PantallaLogin.avisoDeError,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TemaCareCar.peligroFondo,
        borderRadius: BorderRadius.circular(TemaCareCar.radioControl),
        border: Border.all(color: TemaCareCar.peligro.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            fallo.esFalloDeRed ? Icons.wifi_off_outlined : Icons.error_outline,
            color: TemaCareCar.peligro,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fallo.mensaje,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: TemaCareCar.peligro),
            ),
          ),
        ],
      ),
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
            'La agencia te entrega tu usuario y tu contraseña cuando recibes '
            'tu unidad. Si no los tienes, comunícate con la agencia.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: TemaCareCar.textoSecundario),
          ),
        ),
      ],
    );
  }
}

/// Campo de formulario con la etiqueta siempre visible arriba.
///
/// La guia de estilos lo pide asi: «nunca se usa solo el placeholder».
class _CampoTexto extends StatelessWidget {
  const _CampoTexto({
    required this.llave,
    required this.controlador,
    required this.etiqueta,
    required this.habilitado,
    required this.icono,
    required this.validar,
    this.ayuda,
    this.ocultar = false,
    this.sufijo,
    this.textInputAction,
    this.alEnviar,
  });

  final Key llave;
  final TextEditingController controlador;
  final String etiqueta;
  final String? ayuda;
  final bool habilitado;
  final IconData icono;
  final bool ocultar;
  final Widget? sufijo;
  final TextInputAction? textInputAction;
  final VoidCallback? alEnviar;
  final String? Function(String?) validar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        TextFormField(
          key: llave,
          controller: controlador,
          enabled: habilitado,
          obscureText: ocultar,
          textInputAction: textInputAction,
          onFieldSubmitted: alEnviar == null ? null : (_) => alEnviar!(),
          autocorrect: false,
          enableSuggestions: false,
          // Siempre 16: con menos, iOS hace zoom al enfocar el campo.
          style: const TextStyle(fontSize: TemaCareCar.tamanoCampo),
          decoration: InputDecoration(
            hintText: ayuda,
            prefixIcon: Icon(icono, size: 20),
            suffixIcon: sufijo,
          ),
          validator: validar,
        ),
      ],
    );
  }
}
