import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

enum IconoMenu {
  vehiculos(
    '<path d="m5 7 2-4h10l2 4 2 3v7H3v-7l2-3Zm0 0h14M3 12h18M6 12v2m12-2v2M5 17v3m14-3v3"/>',
  ),
  catalogo(
    '<rect x="4" y="3" width="16" height="18" rx="2"/><path d="M8 3v18m3-13h6m-6 4h6m-6 4h4"/>',
  ),
  ajustes(
    '<path d="m9 3-.7 3-2 .9-2.7-.9-2 3.5 2 2.1v2.4l-2 2.1 2 3.5 2.7-.9 2 .9.7 3h4l.7-3 2-.9 2.7.9 2-3.5-2-2.1v-2.4l2-2.1-2-3.5-2.7.9-2-.9-.7-3Z"/><circle cx="11" cy="12" r="3"/>',
  ),
  cita(
    '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4m10-4v4M3 11h18m-13 5h2m4 0h2"/>',
  ),
  historial('<path d="M3 10a9 9 0 1 1 1 7M3 4v6h6m3-3v6l4 2"/>'),
  manual(
    '<path d="M12 5C9 3 5 3 2 4v16c3-1 7-1 10 1 3-2 7-2 10-1V4c-3-1-7-1-10 1Zm0 0v16"/>',
  );

  const IconoMenu(this.trazos);
  final String trazos;
}

/// SVG propios con el mismo trazo y color de marca, sin solicitudes de red.
class DibujoMenu extends StatelessWidget {
  const DibujoMenu(this.icono, {super.key, this.tamano = EstiloMenu.icono});
  final IconoMenu icono;
  final double tamano;

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
    'fill="none" stroke="#1D3557" stroke-width="1.5" '
    'stroke-linecap="round" stroke-linejoin="round">${icono.trazos}</svg>',
    width: tamano,
    height: tamano,
    excludeFromSemantics: true,
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

class TarjetaMenu extends StatelessWidget {
  const TarjetaMenu({
    required this.titulo,
    required this.imagen,
    required this.alPulsar,
    super.key,
    this.color = TemaCareCar.azulSuave,
  });
  final String titulo;
  final Widget imagen;
  final VoidCallback alPulsar;
  final Color color;

  @override
  Widget build(BuildContext context) => Rebote(
    child: Material(
      color: TemaCareCar.tarjeta,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(EstiloMenu.radio),
        side: const BorderSide(color: TemaCareCar.borde),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alPulsar,
        child: Padding(
          padding: const EdgeInsets.all(TemaCareCar.rellenoTarjeta + 4),
          // Arriba y no al centro: asi los titulos de una fila quedan alineados
          // aunque uno ocupe dos lineas con texto grande.
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // El color de la tarjeta queda como fondo del icono.
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ExcludeSemantics(
                  child: SizedBox.square(
                    dimension: 44,
                    child: FittedBox(child: imagen),
                  ),
                ),
              ),
              const SizedBox(width: TemaCareCar.espacioCampos),
              Expanded(
                child: Text(
                  titulo,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Icon(
                  Icons.chevron_right,
                  color: TemaCareCar.textoSecundario,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Conserva el objeto anterior en la pila y evita duplicarlo ante un doble toque.
void abrirPantalla(BuildContext context, Widget pantalla) {
  if (ModalRoute.of(context)?.isCurrent != true) return;
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => pantalla));
}
