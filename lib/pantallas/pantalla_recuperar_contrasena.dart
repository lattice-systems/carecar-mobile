import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/carecar_api.dart';
import '../api/excepciones.dart';
import '../api/modelos/modelos.dart';
import '../tema/tema_carecar.dart';
import '../widgets/aviso.dart';
import '../widgets/campo_texto.dart';

/// En que paso va la recuperacion.
enum _Paso { pedirCodigo, escribirCodigo, listo }

/// APP-2.3 · Recuperacion de contrasena por correo.
///
/// Los dos pasos viven en una sola pantalla a proposito: el correo que el
/// cliente escribio en el paso 1 hace falta en el paso 2, porque
/// `POST /auth/restablecer-contrasena` pide `{ correo, codigo,
/// contrasenaNueva }`. Teniendolos juntos no hay que pasarlo entre pantallas
/// ni arriesgarse a perderlo.
///
/// En la v1.1 **ya no hay enlace**: llega un codigo de 6 digitos al correo
/// (RIC-18). Vive 15 minutos, se usa una sola vez y admite 5 intentos; pedir
/// uno nuevo invalida el anterior (RIC-19).
class PantallaRecuperarContrasena extends StatefulWidget {
  const PantallaRecuperarContrasena({
    required this.api,
    required this.alVolver,
    super.key,
    this.correoInicial,
  });

  final CarecarApi api;

  /// Vuelve al login. Tambien es la salida cuando ya quedo restablecida.
  final VoidCallback alVolver;

  /// Lo que el cliente ya habia escrito en el login, para no pedirlo dos veces.
  final String? correoInicial;

  static const campoCorreo = Key('recuperar_correo');
  static const campoCodigo = Key('recuperar_codigo');
  static const campoNueva = Key('recuperar_nueva');
  static const botonEnviar = Key('recuperar_enviar');
  static const botonGuardar = Key('recuperar_guardar');
  static const botonOtroCodigo = Key('recuperar_otro_codigo');
  static const botonVolver = Key('recuperar_volver');
  static const aviso = Key('recuperar_aviso');

  @override
  State<PantallaRecuperarContrasena> createState() =>
      _PantallaRecuperarContrasenaState();
}

class _PantallaRecuperarContrasenaState
    extends State<PantallaRecuperarContrasena> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _correo = TextEditingController(
    text: widget.correoInicial ?? '',
  );
  final _codigo = TextEditingController();
  final _nueva = TextEditingController();

  _Paso _paso = _Paso.pedirCodigo;
  bool _trabajando = false;
  bool _ver = false;
  String? _error;
  bool _errorDeRed = false;

  @override
  void dispose() {
    _correo.dispose();
    _codigo.dispose();
    _nueva.dispose();
    super.dispose();
  }

  /// Pide otro codigo desde el paso 2.
  ///
  /// No valida el formulario completo a proposito: en el paso 2 la contrasena
  /// nueva suele estar vacia todavia, y validarla impediria pedir el codigo.
  /// El correo ya quedo validado en el paso 1.
  Future<void> _pedirOtroCodigo() => _pedirCodigo(validarFormulario: false);

  Future<void> _pedirCodigo({bool validarFormulario = true}) async {
    if (validarFormulario && !_formulario.currentState!.validate()) return;
    if (_trabajando) return;
    setState(() {
      _trabajando = true;
      _error = null;
      _errorDeRed = false;
    });

    await _intentar(() async {
      await widget.api.recuperarContrasena(_correo.text.trim());
      if (!mounted) return;
      setState(() {
        _trabajando = false;
        _paso = _Paso.escribirCodigo;
        // Si venia de «pedir otro», el codigo anterior ya no sirve (RIC-19).
        _codigo.clear();
      });
    });
  }

  Future<void> _restablecer() async {
    if (!_formulario.currentState!.validate()) return;
    if (_trabajando) return;
    setState(() {
      _trabajando = true;
      _error = null;
      _errorDeRed = false;
    });

    await _intentar(() async {
      await widget.api.restablecerContrasena(
        PeticionRestablecer(
          correo: _correo.text.trim(),
          codigo: _codigo.text.trim(),
          contrasenaNueva: _nueva.text,
        ),
      );
      if (!mounted) return;
      setState(() {
        _trabajando = false;
        _paso = _Paso.listo;
      });
    });
  }

  Future<void> _intentar(Future<void> Function() accion) async {
    try {
      await accion();
    } on SinConexion catch (e) {
      _reportar(e.mensaje, red: true);
    } on ExcepcionApi catch (e) {
      _reportar(e.mensaje);
    } catch (_) {
      _reportar('Ocurrió un error inesperado. Intenta de nuevo.');
    }
  }

  void _reportar(String mensaje, {bool red = false}) {
    if (!mounted) return;
    setState(() {
      _trabajando = false;
      _error = mensaje;
      _errorDeRed = red;
    });
  }

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: PantallaRecuperarContrasena.botonVolver,
          icon: const Icon(Icons.arrow_back),
          onPressed: _trabajando ? null : widget.alVolver,
          tooltip: 'Volver al inicio de sesión',
        ),
        title: const Text('Recuperar contraseña'),
      ),
      body: SafeArea(
        child: Center(
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _paso == _Paso.listo
                      ? _listo(estilos)
                      : [
                          ..._encabezado(estilos),
                          if (_error != null) ...[
                            Aviso(
                              key: PantallaRecuperarContrasena.aviso,
                              tono: _errorDeRed
                                  ? TonoAviso.advertencia
                                  : TonoAviso.error,
                              icono: _errorDeRed
                                  ? Icons.wifi_off_outlined
                                  : null,
                              titulo: _errorDeRed
                                  ? 'Sin conexión'
                                  : 'No se pudo continuar',
                              detalle: _error,
                            ),
                            const SizedBox(height: TemaCareCar.espacioCampos),
                          ],
                          ...(_paso == _Paso.pedirCodigo
                              ? _pasoCorreo()
                              : _pasoCodigo()),
                        ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _encabezado(TextTheme estilos) => [
    Text(
      _paso == _Paso.pedirCodigo
          ? 'Te mandamos un código'
          : 'Escribe el código',
      style: estilos.headlineSmall,
      textAlign: TextAlign.center,
    ),
    const SizedBox(height: 4),
    Text(
      _paso == _Paso.pedirCodigo
          ? 'Escribe tu correo y te enviamos un código de 6 dígitos '
                'para cambiar tu contraseña.'
          : 'Revisa tu correo. El código tiene 6 dígitos y vence en '
                '15 minutos.',
      style: estilos.bodyMedium?.copyWith(color: TemaCareCar.textoSecundario),
      textAlign: TextAlign.center,
    ),
    const SizedBox(height: TemaCareCar.espacioSecciones),
  ];

  List<Widget> _pasoCorreo() => [
    CampoTexto(
      llave: PantallaRecuperarContrasena.campoCorreo,
      controlador: _correo,
      etiqueta: 'Correo',
      ayuda: 'El que le diste a la agencia',
      habilitado: !_trabajando,
      icono: Icons.mail_outline,
      teclado: TextInputType.emailAddress,
      autocompletar: const [AutofillHints.email],
      enfocar: widget.correoInicial == null,
      textInputAction: TextInputAction.done,
      alEnviar: _trabajando ? null : _pedirCodigo,
      validar: _validarCorreo,
    ),
    const SizedBox(height: TemaCareCar.espacioSecciones),
    FilledButton(
      key: PantallaRecuperarContrasena.botonEnviar,
      onPressed: _trabajando ? null : _pedirCodigo,
      child: Text(_trabajando ? 'Enviando…' : 'Enviar código'),
    ),
    const SizedBox(height: TemaCareCar.espacioCampos),
    // El contrato responde 202 exista o no el correo, para no revelar que
    // cuentas hay. Se le dice al usuario para que no se quede esperando.
    Text(
      'Si ese correo tiene una cuenta, te llega el código. '
      'Si no lo ves, revisa tu carpeta de correo no deseado.',
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: TemaCareCar.textoSecundario),
      textAlign: TextAlign.center,
    ),
  ];

  List<Widget> _pasoCodigo() => [
    CampoTexto(
      llave: PantallaRecuperarContrasena.campoCodigo,
      controlador: _codigo,
      etiqueta: 'Código de 6 dígitos',
      ayuda: '123456',
      habilitado: !_trabajando,
      icono: Icons.pin_outlined,
      teclado: TextInputType.number,
      formatos: [FilteringTextInputFormatter.digitsOnly],
      largoMaximo: 6,
      enfocar: true,
      autocompletar: const [AutofillHints.oneTimeCode],
      textInputAction: TextInputAction.next,
      validar: (v) {
        final codigo = (v ?? '').trim();
        if (codigo.isEmpty) return 'Escribe el código que te llegó.';
        if (codigo.length != 6) return 'El código tiene 6 dígitos.';
        return null;
      },
    ),
    const SizedBox(height: TemaCareCar.espacioCampos),
    CampoTexto(
      llave: PantallaRecuperarContrasena.campoNueva,
      controlador: _nueva,
      etiqueta: 'Contraseña nueva',
      ayuda: 'Al menos 8 caracteres, con letra y número',
      habilitado: !_trabajando,
      icono: Icons.lock_outline,
      ocultar: !_ver,
      textInputAction: TextInputAction.done,
      alEnviar: _trabajando ? null : _restablecer,
      sufijo: IconButton(
        onPressed: _trabajando ? null : () => setState(() => _ver = !_ver),
        icon: Icon(
          _ver ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        ),
        tooltip: _ver ? 'Ocultar la contraseña' : 'Mostrar la contraseña',
      ),
      validar: (v) => ReglasContrasena.revisar(v ?? ''),
    ),
    const SizedBox(height: TemaCareCar.espacioSecciones),
    FilledButton(
      key: PantallaRecuperarContrasena.botonGuardar,
      onPressed: _trabajando ? null : _restablecer,
      child: Text(_trabajando ? 'Guardando…' : 'Cambiar contraseña'),
    ),
    const SizedBox(height: TemaCareCar.espacioCampos),
    TextButton(
      key: PantallaRecuperarContrasena.botonOtroCodigo,
      onPressed: _trabajando ? null : _pedirOtroCodigo,
      child: const Text('Enviar otro código'),
    ),
  ];

  List<Widget> _listo(TextTheme estilos) => [
    const Aviso.exito(
      key: PantallaRecuperarContrasena.aviso,
      titulo: 'Listo, ya cambiaste tu contraseña',
      detalle: 'Inicia sesión con la contraseña nueva.',
    ),
    const SizedBox(height: TemaCareCar.espacioSecciones),
    FilledButton(
      key: PantallaRecuperarContrasena.botonVolver,
      onPressed: widget.alVolver,
      child: const Text('Iniciar sesión'),
    ),
  ];

  String? _validarCorreo(String? valor) {
    final correo = (valor ?? '').trim();
    if (correo.isEmpty) return 'Escribe tu correo.';
    final arroba = correo.indexOf('@');
    if (arroba <= 0 || !correo.contains('.', arroba)) {
      return 'Escribe un correo válido, como nombre@dominio.com.';
    }
    return null;
  }
}
