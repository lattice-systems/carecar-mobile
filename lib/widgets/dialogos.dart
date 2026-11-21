import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Aviso emergente (toast) de shadcn_ui para exito y errores.
///
/// Reemplaza a los SnackBar. Necesita el `ShadAppBuilder` de la app; en las
/// pruebas se envuelve con `envolverConShad`.
void mostrarToast(
  BuildContext context,
  String texto, {
  String? titulo,
  bool exito = false,
  bool error = false,
}) {
  final toaster = ShadToaster.maybeOf(context);
  if (toaster == null) return;
  if (exito) HapticFeedback.lightImpact();
  toaster.hide();
  final contenido = Text(texto);
  toaster.show(
    error
        ? ShadToast.destructive(
            title: titulo == null ? null : Text(titulo),
            description: contenido,
          )
        : ShadToast(
            title: titulo == null ? null : Text(titulo),
            description: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 20),
                const SizedBox(width: 8),
                Expanded(child: contenido),
              ],
            ),
          ),
  );
}

/// Dialogo de confirmacion de shadcn_ui. Devuelve `true` si se confirma.
Future<bool> confirmarAccion(
  BuildContext context, {
  required String titulo,
  required String descripcion,
  required String textoConfirmar,
  String textoCancelar = 'Cancelar',
  bool destructiva = false,
  Key? llaveConfirmar,
  Key? llaveCancelar,
}) async {
  HapticFeedback.selectionClick();
  final r = await showShadDialog<bool>(
    context: context,
    builder: (contexto) => ShadDialog.alert(
      title: Text(titulo),
      description: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(descripcion),
      ),
      actions: [
        ShadButton.outline(
          key: llaveCancelar,
          onPressed: () => Navigator.of(contexto).pop(false),
          child: Text(textoCancelar),
        ),
        destructiva
            ? ShadButton.destructive(
                key: llaveConfirmar,
                onPressed: () => Navigator.of(contexto).pop(true),
                child: Text(textoConfirmar),
              )
            : ShadButton(
                key: llaveConfirmar,
                onPressed: () => Navigator.of(contexto).pop(true),
                child: Text(textoConfirmar),
              ),
      ],
    ),
  );
  return r == true;
}

/// Check grande que aparece con resorte, se sostiene un momento y se va solo.
///
/// Se usa al confirmar una cita. El cierre lo dispara el final de la propia
/// animacion, asi que no deja temporizadores colgando.
Future<void> mostrarCheckExito(BuildContext context) {
  HapticFeedback.mediumImpact();
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (contexto, _, _) => Center(
      child:
          Container(
                width: 112,
                height: 112,
                decoration: const BoxDecoration(
                  color: Color(0xFF1B6E3A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 64),
              )
              .animate(onComplete: (_) => Navigator.of(contexto).pop())
              .scale(
                begin: const Offset(0.3, 0.3),
                duration: 550.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 150.ms)
              .then(delay: 450.ms)
              .fadeOut(duration: 200.ms),
    ),
  );
}
