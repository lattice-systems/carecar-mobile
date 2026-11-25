import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../diseno/componentes/avatar.dart';
import '../diseno/componentes/barra_flotante.dart';
import '../diseno/componentes/barra_navegacion.dart' show DestinoNavegacion;
import '../diseno/componentes/boton_accion_flotante.dart';
import '../diseno/componentes/grupo_lista.dart';
import '../diseno/tema_pista.dart';
import '../diseno/tokens/espaciado.dart';
import '../diseno/tokens/tokens_pista.dart';

/// Un acceso de la lista del inicio.
class AccesoInicio {
  const AccesoInicio({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.alPulsar,
  });

  final String titulo;
  final String subtitulo;
  final IconData icono;
  final VoidCallback alPulsar;
}

/// Pantalla de inicio rediseñada: sin héroe ni tarjetas de color, con aire.
///
/// Arriba, el avatar (abre perfil y ajustes) y el saludo; luego lo que está en
/// curso y una lista limpia de accesos. Abajo flotan la acción principal («Agendar
/// cita») y la [BarraFlotante] con los destinos. Mientras la v1 conviva, los
/// destinos de la barra abren su pantalla encima del inicio (`accesos[i]`) y el
/// inicio sigue siendo el destino activo.
///
/// Lleva su propio tema Pista (claro u oscuro según el sistema) porque el
/// inicio v1 aún no está bajo el tema v2 global (V2-T01.05).
class InicioNuevo extends StatelessWidget {
  const InicioNuevo({
    required this.accesos,
    required this.alAbrirAjustes,
    required this.alAgendar,
    super.key,
    this.nombre,
    this.ordenEnCurso,
  }) : assert(accesos.length == 3, 'El inicio lleva tres accesos');

  /// Vehículos, citas y catálogo, en ese orden.
  final List<AccesoInicio> accesos;
  final VoidCallback alAbrirAjustes;
  final VoidCallback alAgendar;

  /// Nombre completo del cliente; hasta que llega no se muestra saludo.
  final String? nombre;

  /// Tarjeta de lo que el taller tiene en curso, si hay.
  final Widget? ordenEnCurso;

  @override
  Widget build(BuildContext context) {
    final tema = MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? TemaPista.oscuro()
        : TemaPista.claro();
    return Theme(
      data: tema,
      child: Builder(builder: (context) => _Cuerpo(inicio: this)),
    );
  }
}

/// Por encima de esta escala de letra el botón flotante se esconde.
const double _escalaMaximaDelBoton = 1.5;

class _Cuerpo extends StatelessWidget {
  const _Cuerpo({required this.inicio});

  final InicioNuevo inicio;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final textos = AppLocalizations.of(context);
    final primero = (inicio.nombre ?? '').trim().split(RegExp(r'\s+')).first;
    // Con letra grande la barra crece y el botón flotante taparía media
    // pantalla: se esconde (Citas sigue en la lista y en la barra) y la reserva
    // del final de la lista crece con la letra.
    final escala = MediaQuery.textScalerOf(context).scale(1);
    final conBotonFlotante = escala <= _escalaMaximaDelBoton;
    final reservaInferior =
        (BarraFlotante.altoReservado *
            (escala > 1 ? escala.clamp(1, 2).toDouble() : 1)) +
        (conBotonFlotante ? 56 + Espaciado.e6 : Espaciado.e4) +
        MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: c.fondo,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                Espaciado.margenTelefono,
                Espaciado.e3,
                Espaciado.margenTelefono,
                reservaInferior,
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _BotonPerfil(
                    nombre: inicio.nombre,
                    etiqueta: textos.inicioPerfilYAjustes,
                    alPulsar: inicio.alAbrirAjustes,
                  ),
                ),
                if (primero.isNotEmpty) ...[
                  const SizedBox(height: Espaciado.e6),
                  Text(
                    textos.inicioSaludo(primero),
                    style: t.display.copyWith(color: c.texto),
                  ),
                ],
                if (inicio.ordenEnCurso != null) ...[
                  const SizedBox(height: Espaciado.e6),
                  inicio.ordenEnCurso!,
                ],
                const SizedBox(height: Espaciado.e8),
                GrupoLista(
                  encabezado: textos.inicioAccesos,
                  filas: [
                    for (final a in inicio.accesos)
                      FilaGrupo(
                        titulo: a.titulo,
                        subtitulo: a.subtitulo,
                        icono: a.icono,
                        alToque: a.alPulsar,
                      ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (conBotonFlotante) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: Espaciado.e4),
                    child: BotonAccionFlotante(
                      texto: textos.inicioAgendarCita,
                      icono: Icons.add,
                      alPresionar: inicio.alAgendar,
                    ),
                  ),
                  const SizedBox(height: Espaciado.e3),
                ],
                BarraFlotante(
                  indice: 0,
                  alCambiar: (i) {
                    if (i > 0) inicio.accesos[i - 1].alPulsar();
                  },
                  destinos: [
                    DestinoNavegacion(
                      etiqueta: textos.inicioDestinoInicio,
                      icono: Icons.home_outlined,
                      iconoActivo: Icons.home_rounded,
                    ),
                    DestinoNavegacion(
                      etiqueta: textos.inicioDestinoVehiculos,
                      icono: Icons.directions_car_outlined,
                      iconoActivo: Icons.directions_car_rounded,
                    ),
                    DestinoNavegacion(
                      etiqueta: textos.inicioDestinoCitas,
                      icono: Icons.calendar_month_outlined,
                      iconoActivo: Icons.calendar_month_rounded,
                    ),
                    DestinoNavegacion(
                      etiqueta: textos.inicioDestinoCatalogo,
                      icono: Icons.grid_view_outlined,
                      iconoActivo: Icons.grid_view_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonPerfil extends StatelessWidget {
  const _BotonPerfil({
    required this.nombre,
    required this.etiqueta,
    required this.alPulsar,
  });

  final String? nombre;
  final String etiqueta;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    final conNombre = (nombre ?? '').trim().isNotEmpty;
    return Semantics(
      button: true,
      label: etiqueta,
      excludeSemantics: true,
      child: Tooltip(
        message: etiqueta,
        child: InkResponse(
          onTap: alPulsar,
          radius: 30,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: conNombre
                  ? Avatar(nombre: nombre!)
                  : Icon(Icons.person_outline, color: c.textoSecundario),
            ),
          ),
        ),
      ),
    );
  }
}
