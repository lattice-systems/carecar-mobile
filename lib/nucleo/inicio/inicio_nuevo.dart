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
import '../diseno/componentes/tarjeta_auto.dart';
import '../diseno/componentes/tarjeta_resumen.dart';
import '../diseno/componentes/tinte_auto.dart';
import '../diseno/componentes/tono.dart';
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

/// Un auto del cliente, como lo muestra el inicio.
class AutoInicio {
  const AutoInicio({
    required this.modelo,
    required this.anio,
    this.marca,
    this.placas,
    this.kilometraje,
    this.color,
  });

  final String modelo;
  final int anio;
  final String? marca;
  final String? placas;
  final int? kilometraje;

  /// Nombre del color del auto; tiñe su tarjeta (ver `tinteDeColorAuto`).
  final String? color;
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

/// Alto que se deja bajo la tarjeta del auto para que se vea su sombra.
const double _huecoDeSombra = 28;

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
    final alto = TarjetaAuto.altoPara(conTitulo: true, escala: widget.escala);
    if (autos == null) {
      return Esqueleto(alto: alto, radio: Radios.hoja);
    }
    if (autos.isEmpty) {
      final textos = AppLocalizations.of(context);
      return TarjetaResumen(
        titulo: textos.inicioSinAutos,
        subtitulo: textos.inicioSinAutosDetalle,
        icono: Icons.directions_car_outlined,
        alToque: widget.alToque,
      );
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
                child: _TarjetaDelAuto(
                  auto: autos[i],
                  posicion: autos.length > 1 ? (i + 1, autos.length) : null,
                  alToque: widget.alToque,
                  alto: alto,
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

/// La tarjeta de un auto del cliente, con sus textos ya traducidos.
class _TarjetaDelAuto extends StatelessWidget {
  const _TarjetaDelAuto({
    required this.auto,
    required this.alToque,
    required this.alto,
    this.posicion,
  });

  final AutoInicio auto;
  final VoidCallback alToque;
  final double alto;

  /// (n, total) cuando hay varios autos.
  final (int, int)? posicion;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final idioma = Localizations.localeOf(context).toLanguageTag();
    final km = auto.kilometraje == null
        ? null
        : textos.inicioKilometros(
            NumberFormat.decimalPattern(idioma).format(auto.kilometraje),
          );
    final titulo = '${auto.modelo} ${auto.anio}';
    final etiqueta = [
      ?auto.marca,
      titulo,
      ?auto.placas,
      ?km,
      if (posicion != null)
        textos.inicioAutoDeTotal(posicion!.$1, posicion!.$2),
    ].join(', ');
    return TarjetaAuto(
      marca: auto.marca,
      titulo: titulo,
      placas: auto.placas,
      kilometraje: km,
      tinte: auto.color == null ? null : tinteDeColorAuto(c, auto.color),
      alToque: alToque,
      etiqueta: etiqueta,
      alto: alto,
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
    final textos = AppLocalizations.of(context);
    final cita = this.cita;
    if (cita == null) {
      return TarjetaResumen(
        titulo: textos.inicioSinCitas,
        subtitulo: textos.inicioSinCitasDetalle,
        icono: Icons.event_available_outlined,
        tono: Tono.exito,
        alToque: alAgendar,
      );
    }
    final idioma = Localizations.localeOf(context).toLanguageTag();
    final dia = DateFormat.EEEE(idioma).format(cita.fecha);
    final diaCapital = dia.isEmpty
        ? dia
        : '${dia[0].toUpperCase()}${dia.substring(1)}';
    return TarjetaResumen(
      titulo: textos.inicioProximaCita,
      subtitulo: textos.inicioCitaCuando(diaCapital, cita.hora),
      detalle: cita.vehiculo,
      visual: _BloqueFecha(
        dia: cita.fecha.day.toString(),
        mes: DateFormat.MMM(idioma).format(cita.fecha),
      ),
      alToque: alAbrirCitas,
    );
  }
}

/// El día y el mes de la cita en un cuadro pleno del acento, del mismo estilo
/// y ancho que el icono de las demás tarjetas de resumen.
class _BloqueFecha extends StatelessWidget {
  const _BloqueFecha({required this.dia, required this.mes});

  final String dia;
  final String mes;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.acento,
        borderRadius: Radios.bordeControl,
      ),
      child: SizedBox(
        width: 40,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Espaciado.e1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dia,
                style: t.titulo3.copyWith(
                  color: c.sobreAcento,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              Text(mes, style: t.micro.copyWith(color: c.sobreAcento)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Accesos
// ---------------------------------------------------------------------------

/// Tres accesos redondos (acento, éxito y marca), planos como los iconos de
/// las listas, con su nombre debajo.
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
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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
