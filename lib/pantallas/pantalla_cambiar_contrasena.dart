import 'package:flutter/material.dart';

import '../api/carecar_api.dart';
import '../api/excepciones.dart';
import '../api/modelos/modelos.dart';
import '../tema/tema_carecar.dart';
import '../widgets/aviso.dart';
import '../widgets/campo_texto.dart';

/// APP-2.3 · Cambio de la contrasena temporal en el primer ingreso.
///
/// Se muestra cuando el login devuelve `debeCambiarContrasena: true`. **No se
/// puede saltar**: el criterio de APP-2.3 dice «en el primer ingreso se obliga
/// a cambiar la contrasena temporal», asi que esta pantalla no tiene boton de
/// regreso ni forma de seguir sin cambiarla. Lo unico que ofrece es cerrar
/// sesion.
class PantallaCambiarContrasena extends StatefulWidget {
  const PantallaCambiarContrasena({
    required this.api,
    required this.alCambiar,
    required this.alCerrarSesion,
    super.key,
  });

  final CarecarApi api;

  /// Se llama cuando la contrasena quedo cambiada.
  final VoidCallback alCambiar;

  /// Unica salida: el criterio prohibe continuar sin cambiarla.
  final VoidCallback alCerrarSesion;

  static const campoActual = Key('cambiar_actual');
  static const campoNueva = Key('cambiar_nueva');
  static const campoConfirmar = Key('cambiar_confirmar');
  static const botonGuardar = Key('cambiar_guardar');
  static const botonCerrarSesion = Key('cambiar_cerrar_sesion');
  static const avisoDeError = Key('cambiar_aviso_error');

  @override
  State<PantallaCambiarContrasena> createState() =>
      _PantallaCambiarContrasenaState();
}

class _PantallaCambiarContrasenaState extends State<PantallaCambiarContrasena> {
  final _formulario = GlobalKey<FormState>();
  final _actual = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmar = TextEditingController();

  bool _guardando = false;
  bool _ver = false;
  String? _error;
  bool _errorDeRed = false;

  @override
  void dispose() {
    _actual.dispose();
    _nueva.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate()) return;
    if (_guardando) return;

    setState(() {
      _guardando = true;
      _error = null;
      _errorDeRed = false;
    });

    try {
      await widget.api.cambiarContrasena(
        actual: _actual.text,
        nueva: _nueva.text,
      );
      if (!mounted) return;
      widget.alCambiar();
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
      _guardando = false;
      _error = mensaje;
      _errorDeRed = red;
    });
  }

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;

    return Scaffold(
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
                  children: [
                    Text(
                      'Cambia tu contraseña',
                      style: estilos.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'La agencia te dio una contraseña temporal. '
                      'Elige una nueva para continuar.',
                      style: estilos.bodyMedium?.copyWith(
                        color: TemaCareCar.textoSecundario,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: TemaCareCar.espacioSecciones),
                    if (_error != null) ...[
                      Aviso(
                        key: PantallaCambiarContrasena.avisoDeError,
                        tono: _errorDeRed
                            ? TonoAviso.advertencia
                            : TonoAviso.error,
                        icono: _errorDeRed ? Icons.wifi_off_outlined : null,
                        titulo: _errorDeRed
                            ? 'Sin conexión'
                            : 'No pudimos cambiar tu contraseña',
                        detalle: _error,
                      ),
                      const SizedBox(height: TemaCareCar.espacioCampos),
                    ],
                    CampoTexto(
                      llave: PantallaCambiarContrasena.campoActual,
                      controlador: _actual,
                      etiqueta: 'Contraseña temporal',
                      ayuda: 'La que te dio la agencia',
                      habilitado: !_guardando,
                      icono: Icons.lock_clock_outlined,
                      ocultar: !_ver,
                      enfocar: true,
                      textInputAction: TextInputAction.next,
                      validar: (v) => (v == null || v.isEmpty)
                          ? 'Escribe tu contraseña temporal.'
                          : null,
                    ),
                    const SizedBox(height: TemaCareCar.espacioCampos),
                    CampoTexto(
                      llave: PantallaCambiarContrasena.campoNueva,
                      controlador: _nueva,
                      etiqueta: 'Contraseña nueva',
                      ayuda: 'Al menos 8 caracteres, con letra y número',
                      habilitado: !_guardando,
                      icono: Icons.lock_outline,
                      ocultar: !_ver,
                      textInputAction: TextInputAction.next,
                      sufijo: IconButton(
                        onPressed: _guardando
                            ? null
                            : () => setState(() => _ver = !_ver),
                        icon: Icon(
                          _ver
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        tooltip: _ver
                            ? 'Ocultar las contraseñas'
                            : 'Mostrar las contraseñas',
                      ),
                      validar: (v) => ReglasContrasena.revisar(
                        v ?? '',
                        actual: _actual.text,
                      ),
                    ),
                    const SizedBox(height: TemaCareCar.espacioCampos),
                    CampoTexto(
                      llave: PantallaCambiarContrasena.campoConfirmar,
                      controlador: _confirmar,
                      etiqueta: 'Repite la contraseña nueva',
                      habilitado: !_guardando,
                      icono: Icons.lock_outline,
                      ocultar: !_ver,
                      textInputAction: TextInputAction.done,
                      alEnviar: _guardando ? null : _guardar,
                      validar: (v) => v != _nueva.text
                          ? 'Las dos contraseñas deben ser iguales.'
                          : null,
                    ),
                    const SizedBox(height: TemaCareCar.espacioSecciones),
                    FilledButton(
                      key: PantallaCambiarContrasena.botonGuardar,
                      onPressed: _guardando ? null : _guardar,
                      child: Text(
                        _guardando ? 'Guardando…' : 'Guardar contraseña',
                      ),
                    ),
                    const SizedBox(height: TemaCareCar.espacioCampos),
                    TextButton(
                      key: PantallaCambiarContrasena.botonCerrarSesion,
                      onPressed: _guardando ? null : widget.alCerrarSesion,
                      child: const Text('Cerrar sesión'),
                    ),
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
