import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../diseno/componentes/avatar.dart';
import '../diseno/componentes/barra_flotante.dart';
import '../diseno/componentes/barra_navegacion.dart' show DestinoNavegacion;
import '../diseno/componentes/boton_accion_flotante.dart';
import '../diseno/componentes/rebote_tactil.dart';
import '../diseno/tema_pista.dart';
import '../diseno/tokens/espaciado.dart';
import '../diseno/tokens/radios.dart';
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

/// Pantalla de inicio rediseñada: color del sistema (azul de acento, turquesa y
/// marino), un resplandor de fondo como el del login y mosaicos con degradado.
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

/// Por encima de esta escala de letra el botón flotante se esconde y los
/// accesos pasan a una sola columna.
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
          const Positioned.fill(child: _Aurora()),
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
                  const SizedBox(height: Espaciado.e5),
                  _Saludo(
                    saludo: textos.inicioSaludo(primero),
                    nombre: primero,
                    estilo: t.display.copyWith(color: c.texto),
                    colorNombre: c.acento,
                  ),
                ],
                if (inicio.ordenEnCurso != null) ...[
                  const SizedBox(height: Espaciado.e6),
                  inicio.ordenEnCurso!,
                ],
                const SizedBox(height: Espaciado.e8),
                Padding(
                  padding: const EdgeInsets.only(left: Espaciado.e1),
                  child: Text(
                    textos.inicioAccesos,
                    style: t.etiqueta.copyWith(color: c.textoSecundario),
                  ),
                ),
                const SizedBox(height: Espaciado.e3),
                _Accesos(accesos: inicio.accesos, enColumna: escala > 1.3),
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

/// Resplandor de fondo, como el del login: un halo azul arriba a la izquierda
/// y otro turquesa arriba a la derecha, que se funden con la superficie.
class _Aurora extends StatelessWidget {
  const _Aurora();

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final fuerza = oscuro ? 0.30 : 0.20;
    Widget halo(
      Color color, {
      double? izquierda,
      double? derecha,
      required double arriba,
      required double lado,
    }) => Positioned(
      left: izquierda,
      right: derecha,
      top: arriba,
      width: lado,
      height: lado,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: fuerza),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Stack(
          children: [
            halo(c.acento, izquierda: -140, arriba: -170, lado: 460),
            halo(c.exito, derecha: -160, arriba: 40, lado: 360),
          ],
        ),
      ),
    );
  }
}

/// Los accesos como mosaicos de color: el primero, ancho; los otros dos, uno
/// junto al otro (o todos en columna con letra grande).
class _Accesos extends StatelessWidget {
  const _Accesos({required this.accesos, required this.enColumna});

  final List<AccesoInicio> accesos;
  final bool enColumna;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    // Tres colores del sistema: acento, éxito (turquesa) y marca (marino).
    final colores = [c.acento, c.exito, c.marca];
    Widget mosaico(int i, {bool ancho = false}) =>
        _Mosaico(acceso: accesos[i], color: colores[i], ancho: ancho);
    if (enColumna) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < accesos.length; i++) ...[
            if (i > 0) const SizedBox(height: Espaciado.e3),
            mosaico(i, ancho: true),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        mosaico(0, ancho: true),
        const SizedBox(height: Espaciado.e3),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: mosaico(1)),
              const SizedBox(width: Espaciado.e3),
              Expanded(child: mosaico(2)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Mosaico extends StatelessWidget {
  const _Mosaico({
    required this.acceso,
    required this.color,
    required this.ancho,
  });

  final AccesoInicio acceso;
  final Color color;
  final bool ancho;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    // `sobreAcento` es el color que el sistema define para leer sobre el relleno
    // saturado: blanco en claro, casi negro en oscuro.
    final frente = c.sobreAcento;
    final etiqueta = [acceso.titulo, acceso.subtitulo].join(', ');
    final fin = Color.lerp(color, c.marca, 0.5)!;
    return Semantics(
      button: true,
      label: etiqueta,
      excludeSemantics: true,
      onTap: acceso.alPulsar,
      child: ReboteTactil(
        alPulsar: acceso.alPulsar,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: Radios.bordeHoja,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, fin],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.30),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: Radios.bordeHoja,
            child: Stack(
              children: [
                // Marca de agua del icono, cortada por la esquina.
                Positioned(
                  right: -18,
                  bottom: -22,
                  child: Icon(
                    acceso.icono,
                    size: ancho ? 120 : 96,
                    color: frente.withValues(alpha: 0.16),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: ancho ? 120 : 148),
                  child: Padding(
                    padding: const EdgeInsets.all(Espaciado.e5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: frente.withValues(alpha: 0.18),
                            border: Border.all(
                              color: frente.withValues(alpha: 0.28),
                            ),
                          ),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(acceso.icono, size: 22, color: frente),
                          ),
                        ),
                        const SizedBox(height: Espaciado.e4),
                        Text(
                          acceso.titulo,
                          style: t.titulo3.copyWith(
                            color: frente,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: Espaciado.e1),
                        Text(
                          acceso.subtitulo,
                          style: t.cuerpoChico.copyWith(
                            color: frente.withValues(alpha: 0.88),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// «Hola, María» con el nombre en el color de acento. El saludo viene ya
/// traducido y se parte alrededor del nombre, sea cual sea su lugar en la frase.
class _Saludo extends StatelessWidget {
  const _Saludo({
    required this.saludo,
    required this.nombre,
    required this.estilo,
    required this.colorNombre,
  });

  final String saludo;
  final String nombre;
  final TextStyle estilo;
  final Color colorNombre;

  @override
  Widget build(BuildContext context) {
    final i = saludo.indexOf(nombre);
    if (i < 0) return Text(saludo, style: estilo);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: saludo.substring(0, i)),
          TextSpan(
            text: nombre,
            style: TextStyle(color: colorNombre),
          ),
          TextSpan(text: saludo.substring(i + nombre.length)),
        ],
      ),
      style: estilo,
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
