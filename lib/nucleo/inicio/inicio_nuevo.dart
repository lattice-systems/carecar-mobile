import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../diseno/componentes/avatar.dart';
import '../diseno/componentes/barra_flotante.dart';
import '../diseno/componentes/barra_navegacion.dart' show DestinoNavegacion;
import '../diseno/componentes/boton_accion_flotante.dart';
import '../diseno/componentes/esqueleto.dart';
import '../diseno/componentes/rebote_tactil.dart';
import '../diseno/tema_pista.dart';
import '../diseno/tokens/espaciado.dart';
import '../diseno/tokens/radios.dart';
import '../diseno/tokens/tokens_pista.dart';
import 'silueta_auto.dart';

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

/// Un auto del cliente, como lo muestra el inicio.
class AutoInicio {
  const AutoInicio({
    required this.modelo,
    required this.anio,
    this.marca,
    this.placas,
    this.kilometraje,
  });

  final String modelo;
  final int anio;
  final String? marca;
  final String? placas;
  final int? kilometraje;
}

/// La próxima cita del cliente, como la muestra el inicio.
class CitaInicio {
  const CitaInicio({required this.fecha, required this.hora, this.vehiculo});

  final DateTime fecha;

  /// Hora de inicio ya formateada («10:00»).
  final String hora;
  final String? vehiculo;
}

/// Pantalla de inicio rediseñada, centrada en el auto del cliente.
///
/// Arriba, el saludo y el avatar (abre perfil y ajustes). Luego el auto como
/// protagonista (una tarjeta de color con su silueta, placas y kilometraje; se
/// desliza si hay varios), lo que el taller tiene en curso, la próxima cita y
/// tres accesos redondos. Abajo flotan la acción principal («Agendar cita») y la
/// [BarraFlotante] con los destinos. Mientras la v1 conviva, los destinos de la
/// barra abren su pantalla encima del inicio (`accesos[i]`) y el inicio sigue
/// siendo el destino activo.
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
    this.autos,
    this.proximaCita,
  }) : assert(accesos.length == 3, 'El inicio lleva tres accesos');

  /// Vehículos, citas y catálogo, en ese orden.
  final List<AccesoInicio> accesos;
  final VoidCallback alAbrirAjustes;
  final VoidCallback alAgendar;

  /// Nombre completo del cliente; hasta que llega no se muestra saludo.
  final String? nombre;

  /// Tarjeta de lo que el taller tiene en curso, si hay.
  final Widget? ordenEnCurso;

  /// Autos del cliente; `null` mientras cargan.
  final List<AutoInicio>? autos;

  /// Próxima cita confirmada, si hay.
  final CitaInicio? proximaCita;

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

/// Esquinas de las tarjetas grandes del inicio (las cuatro; `Radios.bordeHoja`
/// solo redondea arriba).
const BorderRadius _bordeTarjetaGrande = BorderRadius.all(
  Radius.circular(Radios.hoja),
);

/// Alto que se deja bajo la tarjeta del auto para que se vea su sombra.
const double _huecoDeSombra = 20;

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
    // pantalla: se esconde (Citas sigue en los accesos y en la barra) y la
    // reserva del final de la lista crece con la letra.
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
                Row(
                  children: [
                    Expanded(
                      child: primero.isEmpty
                          ? const SizedBox.shrink()
                          : Text(
                              textos.inicioSaludo(primero),
                              style: t.titulo1.copyWith(
                                color: c.texto,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                    _BotonPerfil(
                      nombre: inicio.nombre,
                      etiqueta: textos.inicioPerfilYAjustes,
                      alPulsar: inicio.alAbrirAjustes,
                    ),
                  ],
                ),
                const SizedBox(height: Espaciado.e4),
                _SeccionAutos(
                  autos: inicio.autos,
                  alToque: inicio.accesos[0].alPulsar,
                  escala: escala,
                ),
                if (inicio.ordenEnCurso != null) ...[
                  const SizedBox(height: Espaciado.e4),
                  inicio.ordenEnCurso!,
                ],
                if (inicio.autos != null) ...[
                  const SizedBox(height: Espaciado.e4),
                  _TarjetaCita(
                    cita: inicio.proximaCita,
                    alAbrirCitas: inicio.accesos[1].alPulsar,
                    alAgendar: inicio.alAgendar,
                  ),
                ],
                const SizedBox(height: Espaciado.e6),
                _Accesos(accesos: inicio.accesos),
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
/// y otro turquesa a la derecha, que se funden con la superficie.
class _Aurora extends StatelessWidget {
  const _Aurora();

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final fuerza = oscuro ? 0.26 : 0.16;
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
            halo(c.exito, derecha: -180, arriba: 300, lado: 380),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Autos
// ---------------------------------------------------------------------------

/// El auto del cliente: tarjeta protagonista (o su estado de carga / vacío),
/// con puntos si hay varios.
class _SeccionAutos extends StatefulWidget {
  const _SeccionAutos({
    required this.autos,
    required this.alToque,
    required this.escala,
  });

  final List<AutoInicio>? autos;
  final VoidCallback alToque;
  final double escala;

  @override
  State<_SeccionAutos> createState() => _SeccionAutosState();
}

class _SeccionAutosState extends State<_SeccionAutos> {
  final _controlador = PageController();
  int _pagina = 0;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    final autos = widget.autos;
    // Con letra grande la tarjeta crece para que el texto no se encime a la
    // silueta.
    final alto = 244 + (widget.escala - 1).clamp(0.0, 1.0) * 190;
    if (autos == null) {
      return Esqueleto(alto: alto, radio: Radios.hoja);
    }
    if (autos.isEmpty) {
      return _AutosVacio(alToque: widget.alToque);
    }
    return Column(
      children: [
        // Debajo de cada tarjeta queda un hueco para su sombra: el PageView
        // recorta lo que se sale de él.
        SizedBox(
          height: alto + _huecoDeSombra,
          // Con ratón o lápiz también se desliza (tabletas, escritorio, web).
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context)
                .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
            child: PageView.builder(
              controller: _controlador,
              itemCount: autos.length,
              onPageChanged: (i) => setState(() => _pagina = i),
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(
                  left: autos.length > 1 ? Espaciado.e1 : 0,
                  right: autos.length > 1 ? Espaciado.e1 : 0,
                  bottom: _huecoDeSombra,
                ),
                child: _TarjetaAuto(
                  auto: autos[i],
                  posicion: autos.length > 1 ? (i + 1, autos.length) : null,
                  alToque: widget.alToque,
                  placasAbajo: widget.escala > 1.3,
                ),
              ),
            ),
          ),
        ),
        if (autos.length > 1) ...[
          const SizedBox(height: Espaciado.e3),
          ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < autos.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _pagina ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: i == _pagina ? c.acento : c.borde,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TarjetaAuto extends StatelessWidget {
  const _TarjetaAuto({
    required this.auto,
    required this.alToque,
    this.posicion,
    this.placasAbajo = false,
  });

  final AutoInicio auto;
  final VoidCallback alToque;

  /// Con letra grande las placas bajan debajo del nombre para no quitarle el
  /// ancho.
  final bool placasAbajo;

  /// (n, total) cuando hay varios autos.
  final (int, int)? posicion;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).toLanguageTag();
    final oscuro = tokens.brillo == Brightness.dark;
    // `sobreAcento` es el color que el sistema define para leer sobre el
    // relleno saturado: blanco en claro, casi negro en oscuro.
    final frente = c.sobreAcento;
    final km = auto.kilometraje == null
        ? null
        : textos.inicioKilometros(
            NumberFormat.decimalPattern(idioma).format(auto.kilometraje),
          );
    final titulo = '${auto.modelo} ${auto.anio}';
    final conPlacas = (auto.placas ?? '').isNotEmpty;
    final partes = [
      ?auto.marca,
      titulo,
      ?auto.placas,
      ?km,
      if (posicion != null)
        textos.inicioAutoDeTotal(posicion!.$1, posicion!.$2),
    ];
    return Semantics(
      button: true,
      container: true,
      label: partes.join(', '),
      excludeSemantics: true,
      onTap: alToque,
      child: ReboteTactil(
        alPulsar: alToque,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: _bordeTarjetaGrande,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c.acento, Color.lerp(c.acento, c.marca, 0.85)!],
            ),
            boxShadow: [
              BoxShadow(
                color: c.acento.withValues(alpha: 0.34),
                blurRadius: 24,
                spreadRadius: -12,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: _bordeTarjetaGrande,
            child: Stack(
              children: [
                // Destello de luz arriba a la derecha.
                Positioned(
                  right: -70,
                  top: -90,
                  width: 260,
                  height: 260,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          frente.withValues(alpha: 0.22),
                          frente.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Espaciado.e5,
                    Espaciado.e5,
                    Espaciado.e5,
                    Espaciado.e3,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (auto.marca != null)
                                  Text(
                                    auto.marca!,
                                    style: t.cuerpoChico.copyWith(
                                      color: frente.withValues(alpha: 0.85),
                                    ),
                                  ),
                                Text(
                                  titulo,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.titulo1.copyWith(
                                    color: frente,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (placasAbajo && conPlacas) ...[
                                  const SizedBox(height: Espaciado.e2),
                                  _Placas(texto: auto.placas!, color: frente),
                                ],
                                if (km != null) ...[
                                  const SizedBox(height: Espaciado.e1),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.speed_rounded,
                                        size: 16,
                                        color: frente.withValues(alpha: 0.85),
                                      ),
                                      const SizedBox(width: Espaciado.e1),
                                      Flexible(
                                        child: Text(
                                          km,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: t.cuerpoChico.copyWith(
                                            color: frente.withValues(
                                              alpha: 0.85,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (!placasAbajo && conPlacas) ...[
                            const SizedBox(width: Espaciado.e3),
                            _Placas(texto: auto.placas!, color: frente),
                          ],
                        ],
                      ),
                      // La silueta toma el alto que sobra y nunca más ancho que
                      // 340: en pantallas anchas no crece hasta desbordar.
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 340),
                            child: SiluetaAuto(
                              carroceria: frente,
                              cristal: c.marca.withValues(
                                alpha: oscuro ? 0.9 : 0.85,
                              ),
                              llanta: oscuro
                                  ? frente
                                  : Color.lerp(c.marca, Colors.black, 0.5)!,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _Placas extends StatelessWidget {
  const _Placas({required this.texto, required this.color});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = TokensPista.de(context).tipografia;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: Radios.bordePildora,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Espaciado.e3,
          vertical: Espaciado.e1,
        ),
        child: Text(
          texto,
          style: t.cuerpoChico.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

class _AutosVacio extends StatelessWidget {
  const _AutosVacio({required this.alToque});

  final VoidCallback alToque;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final textos = AppLocalizations.of(context);
    final titulo = textos.inicioSinAutos;
    final detalle = textos.inicioSinAutosDetalle;
    return Semantics(
      button: true,
      container: true,
      label: [titulo, detalle].join(', '),
      excludeSemantics: true,
      onTap: alToque,
      child: ReboteTactil(
        alPulsar: alToque,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: _bordeTarjetaGrande,
            color: c.acentoSuave,
            border: Border.all(color: c.acento.withValues(alpha: 0.25)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: SiluetaAuto(
                    carroceria: c.acento.withValues(alpha: 0.35),
                    cristal: c.acento.withValues(alpha: 0.55),
                    llanta: c.acento.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: Espaciado.e3),
                Text(
                  titulo,
                  style: t.titulo3.copyWith(
                    color: c.texto,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Espaciado.e1),
                Text(
                  detalle,
                  style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Próxima cita
// ---------------------------------------------------------------------------

class _TarjetaCita extends StatelessWidget {
  const _TarjetaCita({
    required this.cita,
    required this.alAbrirCitas,
    required this.alAgendar,
  });

  final CitaInicio? cita;
  final VoidCallback alAbrirCitas;
  final VoidCallback alAgendar;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).toLanguageTag();
    final cita = this.cita;

    final String rotulo;
    final String titulo;
    final String? detalle;
    final Widget cabeza;
    if (cita == null) {
      rotulo = textos.inicioSinCitas;
      titulo = textos.inicioSinCitasDetalle;
      detalle = null;
      cabeza = DecoratedBox(
        decoration: BoxDecoration(
          color: c.exitoSuave,
          borderRadius: Radios.bordeTarjeta,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 56, minHeight: 64),
          child: Icon(Icons.event_available_outlined, color: c.exito),
        ),
      );
    } else {
      final dia = DateFormat.EEEE(idioma).format(cita.fecha);
      final diaCapital = dia.isEmpty
          ? dia
          : '${dia[0].toUpperCase()}${dia.substring(1)}';
      final numeroDia = cita.fecha.day.toString();
      rotulo = textos.inicioProximaCita;
      titulo = textos.inicioCitaCuando(diaCapital, cita.hora);
      detalle = cita.vehiculo;
      cabeza = DecoratedBox(
        decoration: BoxDecoration(
          color: c.acentoSuave,
          borderRadius: Radios.bordeTarjeta,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 56, minHeight: 64),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: Espaciado.e2),
              Text(
                numeroDia,
                style: t.titulo2.copyWith(
                  color: c.acento,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat.MMM(idioma).format(cita.fecha),
                style: t.micro.copyWith(color: c.acento),
              ),
              const SizedBox(height: Espaciado.e2),
            ],
          ),
        ),
      );
    }
    final alToque = cita == null ? alAgendar : alAbrirCitas;
    return Semantics(
      button: true,
      container: true,
      label: [rotulo, titulo, ?detalle].join(', '),
      excludeSemantics: true,
      onTap: alToque,
      child: ReboteTactil(
        alPulsar: alToque,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.superficie,
            borderRadius: _bordeTarjetaGrande,
            border: Border.all(color: c.borde),
            boxShadow: tokens.sombras,
          ),
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e4),
            child: Row(
              children: [
                cabeza,
                const SizedBox(width: Espaciado.e4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rotulo,
                        style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        titulo,
                        style: t.cuerpoFuerte.copyWith(color: c.texto),
                      ),
                      if (detalle != null)
                        Text(
                          detalle,
                          style: t.cuerpoChico.copyWith(
                            color: c.textoSecundario,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.textoTerciario),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Accesos
// ---------------------------------------------------------------------------

/// Tres accesos redondos de color (acento, éxito y marca), con su nombre
/// debajo.
class _Accesos extends StatelessWidget {
  const _Accesos({required this.accesos});

  final List<AccesoInicio> accesos;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    final colores = [c.acento, c.exito, c.marca];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < accesos.length; i++)
          Expanded(
            child: _Acceso(acceso: accesos[i], color: colores[i]),
          ),
      ],
    );
  }
}

class _Acceso extends StatelessWidget {
  const _Acceso({required this.acceso, required this.color});

  final AccesoInicio acceso;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
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
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, fin],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.32),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SizedBox(
                width: 64,
                height: 64,
                child: Icon(acceso.icono, size: 28, color: frente),
              ),
            ),
            const SizedBox(height: Espaciado.e2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Espaciado.e1),
              child: Text(
                acceso.titulo,
                textAlign: TextAlign.center,
                style: t.cuerpoChico.copyWith(
                  color: c.texto,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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
