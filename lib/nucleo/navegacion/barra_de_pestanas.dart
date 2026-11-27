import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../l10n/app_localizations.dart';
import '../diseno/componentes/barra_flotante.dart';
import '../diseno/componentes/barra_navegacion.dart' show DestinoNavegacion;
import '../diseno/tema_pista.dart';
import 'rutas.dart';

/// Raíces de las cuatro pestañas, en el orden de la barra.
const _raices = ['/', '/garaje', '/citas', '/catalogo'];

/// Pantallas que se abren a pantalla completa y no llevan la barra.
const _sinBarra = {
  'agendar',
  'disponibilidad',
  'comprobante',
  'reprogramar',
  'manual',
  'ficha-tecnica',
  'calculadora',
};

/// Pestaña a la que pertenece [camino], o `null` si ahí no va la barra.
int? pestanaDe(String camino) {
  final partes = Uri.parse(camino).pathSegments;
  if (partes.isEmpty) return 0;
  if (partes.any(_sinBarra.contains)) return null;
  final i = _raices.indexOf('/${partes.first}');
  return i < 1 ? null : i;
}

/// Contenedor de las pestañas: la barra se queda fija mientras se navega
/// dentro de una pestaña y se esconde en las pantallas completas.
class MarcoDePestanas extends StatelessWidget {
  const MarcoDePestanas({required this.camino, required this.hijo, super.key});

  final String camino;
  final Widget hijo;

  @override
  Widget build(BuildContext context) {
    final pestana = pestanaDe(camino);
    if (pestana == null) return hijo;
    final tema = MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? TemaPista.oscuro()
        : TemaPista.claro();
    final textos = AppLocalizations.of(context);
    return Theme(
      data: tema,
      child: Builder(
        builder: (context) => Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              // La barra flota sobre el contenido: se le avisa a la pantalla
              // que ese espacio de abajo está ocupado.
              Positioned.fill(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    padding: MediaQuery.paddingOf(context).copyWith(
                      bottom:
                          MediaQuery.paddingOf(context).bottom +
                          BarraFlotante.altoReservado,
                    ),
                  ),
                  child: hijo,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BarraFlotante(
                  indice: pestana,
                  alCambiar: (i) {
                    if (i != pestana) context.go(_raices[i]);
                  },
                  destinos: [
                    DestinoNavegacion(
                      etiqueta: textos.inicioDestinoInicio,
                      icono: LucideIcons300.house,
                      iconoActivo: LucideIcons300.house,
                    ),
                    DestinoNavegacion(
                      etiqueta: textos.inicioDestinoVehiculos,
                      icono: LucideIcons300.car,
                      iconoActivo: LucideIcons300.car,
                    ),
                    DestinoNavegacion(
                      etiqueta: textos.inicioDestinoCitas,
                      icono: LucideIcons300.calendarDays,
                      iconoActivo: LucideIcons300.calendarDays,
                    ),
                    DestinoNavegacion(
                      etiqueta: textos.inicioDestinoCatalogo,
                      icono: LucideIcons300.layoutGrid,
                      iconoActivo: LucideIcons300.layoutGrid,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Envuelve en el marco de pestañas las rutas que viven dentro de ellas.
RouteBase conPestanas(List<RouteBase> rutas) => ShellRoute(
  builder: (context, state, hijo) =>
      MarcoDePestanas(camino: state.uri.path, hijo: hijo),
  routes: rutas,
);

/// Ruta del inicio dentro de [rutas] y el resto (para sacarla del orden).
({RouteBase? inicio, List<RouteBase> resto}) separarInicio(
  List<RouteBase> rutas,
) {
  final inicio = rutas
      .whereType<GoRoute>()
      .where((r) => r.path == Rutas.inicio)
      .firstOrNull;
  return (inicio: inicio, resto: [...rutas.where((r) => r != inicio)]);
}
