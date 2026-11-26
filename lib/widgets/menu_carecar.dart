import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../tema/tema_carecar.dart';
import 'movimiento.dart';
import 'pantalla.dart';

/// Medidas compartidas del area autenticada. No modifica los formularios de acceso.
abstract final class EstiloMenu {
  static const anchoMaximo = 1080.0;
  static const radio = 24.0;
  static const icono = 64.0;
  static const anchoTarjeta = 336.0;
}

/// Opciones del menu con su icono Lucide (el trazo es uniforme y nitido).
enum IconoMenu {
  vehiculos(LucideIcons300.carFront),
  catalogo(LucideIcons300.layoutGrid),
  ajustes(LucideIcons300.settings),
  cita(LucideIcons300.calendarDays),
  historial(LucideIcons300.history),
  manual(LucideIcons300.bookText);

  const IconoMenu(this.icono);
  final IconData icono;
}

/// Burbuja translucida con brillo que enmarca el icono de una tarjeta.
class BurbujaIcono extends StatelessWidget {
  const BurbujaIcono(this.icono, {super.key, this.tamano = 64});
  final IconData icono;
  final double tamano;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.34),
            Colors.white.withValues(alpha: 0.12),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
      child: Icon(icono, color: Colors.white, size: tamano * 0.5),
    ),
  );
}

/// Una columna en telefono; dos o tres al disponer de suficiente espacio.
/// Wrap permite que las tarjetas crezcan con texto grande sin recortarlo.
class RejillaMenu extends StatelessWidget {
  const RejillaMenu({required this.tarjetas, super.key});
  final List<Widget> tarjetas;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, limites) {
      const espacio = TemaCareCar.espacioCampos;
      final columnas = Pantalla.deAncho(limites.maxWidth).columnas;
      final ancho = ((limites.maxWidth - espacio * (columnas - 1)) / columnas)
          .clamp(0.0, EstiloMenu.anchoTarjeta);
      return Wrap(
        spacing: espacio,
        runSpacing: espacio,
        children: [
          for (final (i, tarjeta) in tarjetas.indexed)
            SizedBox(width: ancho, child: tarjeta)
                .animate(delay: (70 * i).ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.12, curve: Curves.easeOutCubic),
        ],
      );
    },
  );
}

/// Tarjeta con degradado propio por seccion. [compacta] es la variante del
/// detalle del vehiculo (fila baja); [indice] escalona la animacion de entrada.
class TarjetaMenu extends StatelessWidget {
  const TarjetaMenu({
    required this.titulo,
    required this.icono,
    required this.alPulsar,
    super.key,
    this.subtitulo,
    this.colores = const [TemaCareCar.azulAgencia, TemaCareCar.azulProfundo],
    this.compacta = false,
    this.indice = 0,
  });
  final String titulo;
  final String? subtitulo;
  final IconData icono;
  final VoidCallback alPulsar;
  final List<Color> colores;
  final bool compacta;
  final int indice;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cuerpo = Row(
      children: [
        BurbujaIcono(icono, tamano: compacta ? 48 : 68),
        SizedBox(width: compacta ? 14 : 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titulo,
                style: (compacta ? texto.titleMedium : texto.headlineSmall)
                    ?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              if (subtitulo != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitulo!,
                  style: texto.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        ExcludeSemantics(
          child: Icon(
            LucideIcons300.arrowRight,
            color: Colors.white.withValues(alpha: 0.9),
            size: 22,
          ),
        ),
      ],
    );
    final tarjeta = Rebote(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(EstiloMenu.radio),
          boxShadow: [
            BoxShadow(
              color: colores.first.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(EstiloMenu.radio),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colores,
              ),
            ),
            child: InkWell(
              onTap: alPulsar,
              splashColor: Colors.white24,
              highlightColor: Colors.white10,
              child: Stack(
                children: [
                  Positioned(
                    right: -40,
                    top: -50,
                    child: ExcludeSemantics(
                      child: Container(
                        width: compacta ? 120 : 170,
                        height: compacta ? 120 : 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.09),
                        ),
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: compacta ? 80 : 128),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: compacta ? 16 : 20,
                        vertical: compacta ? 14 : 22,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: cuerpo,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return tarjeta
        .animate(delay: Duration(milliseconds: 90 * indice))
        .fadeIn(duration: 380.ms)
        .slideY(begin: 0.15, end: 0, duration: 420.ms, curve: Curves.easeOut);
  }
}

/// Conserva el objeto anterior en la pila y evita duplicarlo ante un doble toque.
void abrirPantalla(BuildContext context, Widget pantalla) {
  if (ModalRoute.of(context)?.isCurrent != true) return;
  Navigator.of(context).push(rutaCareCar(pantalla));
}

/// Ruta con fundido y deslizamiento coordinados: la pantalla nueva entra desde
/// la derecha mientras aparece, y la anterior se corre un poco al fondo.
Route<T> rutaCareCar<T>(Widget pantalla) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 380),
  reverseTransitionDuration: const Duration(milliseconds: 300),
  pageBuilder: (_, _, _) => pantalla,
  transitionsBuilder: (context, animacion, secundaria, hijo) {
    final entrada = CurvedAnimation(
      parent: animacion,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final salida = CurvedAnimation(parent: secundaria, curve: Curves.easeInOut);
    return SlideTransition(
      position: Tween(
        begin: Offset.zero,
        end: const Offset(-0.08, 0),
      ).animate(salida),
      child: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.85).animate(salida),
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0.12, 0),
            end: Offset.zero,
          ).animate(entrada),
          child: FadeTransition(opacity: entrada, child: hijo),
        ),
      ),
    );
  },
);
