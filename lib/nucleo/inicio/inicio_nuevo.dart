import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../l10n/app_localizations.dart';
import '../diseno/componentes/aparecer.dart';
import '../diseno/componentes/avatar.dart';
import '../diseno/componentes/barra_flotante.dart';
import '../diseno/componentes/barra_navegacion.dart' show DestinoNavegacion;
import '../diseno/componentes/boton_accion_flotante.dart';
import '../diseno/componentes/cuadro_fecha.dart';
import '../autos/foto_de_modelo.dart';
import '../diseno/componentes/esqueleto.dart';
import '../diseno/componentes/marca_carecar.dart';
import '../diseno/componentes/tarjeta_auto.dart';
import '../diseno/componentes/tarjeta_resumen.dart';
import '../diseno/componentes/tinte_auto.dart';
import '../diseno/componentes/tono.dart';
import '../diseno/tema_pista.dart';
import '../diseno/tokens/espaciado.dart';
import '../diseno/tokens/movimiento.dart';
import '../diseno/tokens/radios.dart';
import '../diseno/tokens/tokens_pista.dart';
import '../idioma/formato_numeros.dart';

/// Un auto del cliente, como lo muestra el inicio.
class AutoInicio {
  const AutoInicio({
    required this.id,
    required this.modelo,
    required this.anio,
    this.marca,
    this.placas,
    this.kilometraje,
    this.color,
  });

  /// El vehículo en el servidor: de él cuelgan los datos que el inicio pide
  /// según el auto que se está viendo (el próximo servicio, por ejemplo).
  final int id;
  final String modelo;
  final int anio;
  final String? marca;
  final String? placas;
  final int? kilometraje;

  /// Nombre del color del auto; tiñe su tarjeta (ver `tinteDeColorAuto`).
  final String? color;

  /// La marca para mostrarla aparte, o `null` si falta o el modelo ya la trae
  /// («Nissan March» no se vuelve «Nissan / Nissan March»). Es la misma regla
  /// del garaje.
  String? get marcaAparte {
    final m = marca;
    if (m == null || modelo.toLowerCase().startsWith(m.toLowerCase())) {
      return null;
    }
    return m;
  }
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
/// desliza si hay varios) y, debajo, lo que le importa de él: lo que el taller
/// tiene en curso, la próxima cita y el próximo servicio del auto que se está
/// viendo. Abajo flotan la acción principal («Agendar cita») y la
/// [BarraFlotante] con los destinos.
///
/// Los destinos viven solo en la barra: el cuerpo no los repite con accesos,
/// sino que muestra datos. Mientras la v1 conviva, los destinos de la barra
/// abren su pantalla encima del inicio y el inicio sigue siendo el destino
/// activo.
///
/// Lleva su propio tema Pista (claro u oscuro según el sistema) porque el
/// inicio v1 aún no está bajo el tema v2 global (V2-T01.05).
class InicioNuevo extends StatelessWidget {
  const InicioNuevo({
    required this.alAbrirVehiculos,
    required this.alAbrirCitas,
    required this.alAbrirCatalogo,
    required this.alAbrirAjustes,
    required this.alAgendar,
    super.key,
    this.nombre,
    this.ordenEnCurso,
    this.autos,
    this.proximaCita,
    this.servicioDelAuto,
    this.conBarra = true,
    this.ahora,
  });

  /// Reloj para el saludo según la hora; las pruebas lo fijan.
  final DateTime Function()? ahora;

  /// Destinos de la barra (y de las tarjetas que llevan a ellos).
  final VoidCallback alAbrirVehiculos;
  final VoidCallback alAbrirCitas;
  final VoidCallback alAbrirCatalogo;
  final VoidCallback alAbrirAjustes;
  final VoidCallback alAgendar;

  /// Nombre completo del cliente; hasta que llega no se muestra saludo.
  final String? nombre;

  /// Tarjeta de lo que el taller tiene en curso, si hay. Lleva su propia
  /// separación inferior y no ocupa lugar cuando no hay orden.
  final Widget? ordenEnCurso;

  /// Autos del cliente; `null` mientras cargan.
  final List<AutoInicio>? autos;

  /// Próxima cita confirmada, si hay.
  final CitaInicio? proximaCita;

  /// Tarjeta con el próximo servicio del auto cuyo `id` recibe, la del que se
  /// está viendo en el carrusel. Igual que [ordenEnCurso], lleva su propia
  /// separación inferior y no ocupa lugar si no hay qué mostrar.
  final Widget Function(int vehiculoId)? servicioDelAuto;

  /// Si el inicio dibuja su propia barra. Con las pestañas v2 la barra vive
  /// fuera (`MarcoDePestanas`) y aquí es `false`; con módulos en v1 (salida de
  /// emergencia) la barra sigue aquí porque abre pantallas v1 encima del menú.
  final bool conBarra;

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
const double _escalaMaximaDelBoton = BotonAccionFlotante.escalaMaxima;

class _Cuerpo extends StatefulWidget {
  const _Cuerpo({required this.inicio});

  final InicioNuevo inicio;

  @override
  State<_Cuerpo> createState() => _CuerpoState();
}

class _CuerpoState extends State<_Cuerpo> with SingleTickerProviderStateMixin {
  /// Posición en el carrusel del auto que se está viendo.
  int _auto = 0;

  /// La entrada del inicio: el saludo sube palabra por palabra y la foto del
  /// auto se asienta. Una sola vez, al abrir; con «reducir movimiento» ya
  /// arranca terminada.
  late final AnimationController _entrada = AnimationController(
    vsync: this,
    duration: _duracionEntrada,
  );
  bool _entradaLista = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entradaLista) return;
    _entradaLista = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrada.value = 1;
    } else {
      _entrada.forward();
    }
  }

  @override
  void dispose() {
    _entrada.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inicio = widget.inicio;
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final textos = AppLocalizations.of(context);
    final primero = (inicio.nombre ?? '').trim().split(RegExp(r'\s+')).first;
    final autos = inicio.autos;
    final enPantalla = autos == null || autos.isEmpty
        ? null
        : autos[_auto.clamp(0, autos.length - 1)];
    // Con letra grande la barra crece y el botón flotante taparía media
    // pantalla: se esconde (Citas sigue en la barra) y la reserva del final de
    // la lista crece con la letra.
    final escala = MediaQuery.textScalerOf(context).scale(1);
    final conBotonFlotante = escala <= _escalaMaximaDelBoton;
    final reservaInferior =
        (inicio.conBarra
            ? BarraFlotante.altoReservado *
                  (escala > 1 ? escala.clamp(1, 2).toDouble() : 1)
            : 0) +
        (conBotonFlotante
            ? BotonAccionFlotante.alto + Espaciado.e6
            : Espaciado.e4) +
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
                    const MarcaCareCar(tamano: 28),
                    const Spacer(),
                    _BotonPerfil(
                      nombre: inicio.nombre,
                      etiqueta: textos.inicioPerfilYAjustes,
                      alPulsar: inicio.alAbrirAjustes,
                    ),
                  ],
                ),
                const SizedBox(height: Espaciado.e5),
                _Saludo(
                  nombre: primero,
                  ahora: inicio.ahora?.call() ?? DateTime.now(),
                  entrada: _entrada,
                ),
                const SizedBox(height: Espaciado.e4),
                _SeccionAutos(
                  entrada: _entrada,
                  autos: autos,
                  alToque: inicio.alAbrirVehiculos,
                  escala: escala,
                  alCambiarDeAuto: (i) => setState(() => _auto = i),
                ),
                const SizedBox(height: Espaciado.e4),
                // Lo que importa del auto, de lo más concreto a lo más
                // estimado. Cada tarjeta lleva su separación inferior, así que
                // no sobran huecos cuando alguna no se ve. Lo vacío (la
                // invitación a agendar) va al final: nunca por encima de lo
                // que sí hay.
                ?inicio.ordenEnCurso,
                if (autos != null) ...[
                  if (inicio.proximaCita != null)
                    _TarjetaCita(
                      cita: inicio.proximaCita,
                      alAbrirCitas: inicio.alAbrirCitas,
                      alAgendar: inicio.alAgendar,
                    ),
                  if (enPantalla != null)
                    ?inicio.servicioDelAuto?.call(enPantalla.id),
                  if (inicio.proximaCita == null)
                    _TarjetaCita(
                      cita: null,
                      alAbrirCitas: inicio.alAbrirCitas,
                      alAgendar: inicio.alAgendar,
                    ),
                ],
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            // Sin barra propia, justo sobre la de fuera: su espacio ya viene en
            // el margen inferior.
            bottom: inicio.conBarra
                ? 0
                : MediaQuery.paddingOf(context).bottom - Espaciado.e4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (conBotonFlotante) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: Espaciado.e4),
                    child: BotonAccionFlotante(
                      texto: textos.inicioAgendarCita,
                      icono: LucideIcons300.plus,
                      alPresionar: inicio.alAgendar,
                    ),
                  ),
                  const SizedBox(height: Espaciado.e3),
                ],
                if (inicio.conBarra)
                  BarraFlotante(
                    indice: 0,
                    alCambiar: (i) => switch (i) {
                      1 => inicio.alAbrirVehiculos(),
                      2 => inicio.alAbrirCitas(),
                      3 => inicio.alAbrirCatalogo(),
                      _ => null,
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
    required this.entrada,
    required this.autos,
    required this.alToque,
    required this.escala,
    required this.alCambiarDeAuto,
  });

  final Animation<double> entrada;
  final List<AutoInicio>? autos;
  final VoidCallback alToque;
  final double escala;

  /// Se llama con la posición del auto al que se desliza.
  final ValueChanged<int> alCambiarDeAuto;

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
    // silueta (o, con foto, para que los datos quepan bajo ella). Si alguno de
    // los autos lleva foto, todos toman ese alto: el carrusel no salta.
    final conFoto = autos?.any((a) => _fotoDe(a) != null) ?? false;
    final alto = conFoto
        ? TarjetaAuto.altoConFoto(escala: widget.escala)
        : TarjetaAuto.altoPara(conTitulo: true, escala: widget.escala);
    if (autos == null) {
      return Esqueleto(alto: alto, radio: Radios.hoja);
    }
    if (autos.isEmpty) {
      final textos = AppLocalizations.of(context);
      return TarjetaResumen(
        titulo: textos.inicioSinAutos,
        subtitulo: textos.inicioSinAutosDetalle,
        icono: LucideIcons300.car,
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
              onPageChanged: (i) {
                setState(() => _pagina = i);
                widget.alCambiarDeAuto(i);
              },
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(
                  left: autos.length > 1 ? Espaciado.e1 : 0,
                  right: autos.length > 1 ? Espaciado.e1 : 0,
                  bottom: _huecoDeSombra,
                ),
                // La tarjeta aparece después del saludo, al abrir.
                child: FadeTransition(
                  opacity: _curvaTarjeta.animate(widget.entrada),
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
/// Foto incluida para el auto: primero por el modelo, luego con la marca.
String? _fotoDe(AutoInicio auto) =>
    fotoDeModelo(auto.modelo) ?? fotoDeModelo('${auto.marca} ${auto.modelo}');

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
    final km = auto.kilometraje == null
        ? null
        : textos.inicioKilometros(formatearMiles(context, auto.kilometraje!));
    final titulo = '${auto.modelo} ${auto.anio}';
    final etiqueta = [
      ?auto.marcaAparte,
      titulo,
      ?auto.placas,
      ?km,
      if (posicion != null)
        textos.inicioAutoDeTotal(posicion!.$1, posicion!.$2),
    ].join(', ');
    return TarjetaAuto(
      marca: auto.marcaAparte,
      titulo: titulo,
      placas: auto.placas,
      kilometraje: km,
      tinte: auto.color == null ? null : tinteDeColorAuto(c, auto.color),
      alToque: alToque,
      etiqueta: etiqueta,
      alto: alto,
      foto: _fotoDe(auto),
    );
  }
}

// ---------------------------------------------------------------------------
// Saludo
// ---------------------------------------------------------------------------

final _duracionEntrada = Movimiento.portada.duracion;
final _curvaTarjeta = CurveTween(
  curve: Interval(0.3, 0.85, curve: Movimiento.portada.curva),
);

/// La fecha y el saludo según la hora con el nombre. Cada línea sube y
/// aparece un poco después de la otra.
class _Saludo extends StatelessWidget {
  const _Saludo({
    required this.nombre,
    required this.ahora,
    required this.entrada,
  });

  final String nombre;
  final DateTime ahora;
  final Animation<double> entrada;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).toLanguageTag();
    final saludo = switch (ahora.hour) {
      >= 5 && < 12 => textos.inicioSaludoManana,
      >= 12 && < 19 => textos.inicioSaludoTarde,
      _ => textos.inicioSaludoNoche,
    };
    final fecha = DateFormat.MMMMEEEEd(idioma).format(ahora).toUpperCase();
    // Hasta que llega el nombre solo se ve la fecha: «Buenos días,» solo se
    // leería cortado.
    final conNombre = nombre.isNotEmpty;
    final saludoConNombre = '$saludo $nombre';
    return Semantics(
      header: true,
      label: conNombre ? saludoConNombre : fecha,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Aparecer(
            entrada: entrada,
            desde: 0,
            hasta: 0.45,
            child: Text(
              fecha,
              style: t.micro.copyWith(
                color: c.textoSecundario,
                letterSpacing: 11 * 0.14,
              ),
            ),
          ),
          if (conNombre) ...[
            const SizedBox(height: Espaciado.e2),
            Aparecer(
              entrada: entrada,
              desde: 0.08,
              hasta: 0.6,
              child: Text(
                saludoConNombre,
                style: t.titulo2.copyWith(color: c.texto),
              ),
            ),
          ],
        ],
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
    final textos = AppLocalizations.of(context);
    final cita = this.cita;
    if (cita == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: Espaciado.e4),
        child: TarjetaResumen(
          titulo: textos.inicioSinCitas,
          subtitulo: textos.inicioSinCitasDetalle,
          icono: LucideIcons300.calendarCheck,
          tono: Tono.exito,
          alToque: alAgendar,
        ),
      );
    }
    final idioma = Localizations.localeOf(context).toLanguageTag();
    final dia = DateFormat.EEEE(idioma).format(cita.fecha);
    final diaCapital = dia.isEmpty
        ? dia
        : '${dia[0].toUpperCase()}${dia.substring(1)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: Espaciado.e4),
      child: TarjetaResumen(
        titulo: textos.inicioProximaCita,
        subtitulo: textos.inicioCitaCuando(diaCapital, cita.hora),
        detalle: cita.vehiculo,
        // Solo se muestra una cita confirmada: el mismo tono que en Mis citas.
        visual: CuadroFecha(fecha: cita.fecha, tono: Tono.exito),
        alToque: alAbrirCitas,
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
                  : Icon(LucideIcons300.user, color: c.textoSecundario),
            ),
          ),
        ),
      ),
    );
  }
}
