import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../nucleo/diseno/componentes/boton.dart';
import '../nucleo/diseno/componentes/campo_busqueda_liquido.dart';
import '../nucleo/diseno/componentes/campo_texto.dart';
import '../nucleo/diseno/componentes/control_binario.dart';
import '../nucleo/diseno/componentes/grupo_lista.dart';
import '../nucleo/diseno/componentes/hoja_inferior.dart';
import '../nucleo/diseno/componentes/insignia.dart';
import '../nucleo/diseno/componentes/rebote_tactil.dart';
import '../nucleo/diseno/componentes/superficie_liquida.dart';
import '../nucleo/diseno/componentes/tarjeta_accion.dart';
import '../nucleo/diseno/componentes/tono.dart';
import '../nucleo/diseno/tema_pista.dart';
import '../nucleo/diseno/tokens/espaciado.dart';
import '../nucleo/diseno/tokens/radios.dart';

/// Pantalla completa de demostración de la propuesta «Liquid Glass».
///
/// Muestra la atmósfera de estudio oscura (#08090C), el resplandor ambiental,
/// la foto del auto como protagonista, las tarjetas suspendidas con desenfoque
/// gaussiano, el buscador cápsula y el dock flotante interactivo con hápticos.
class PantallaPropuestaDiseno extends StatefulWidget {
  const PantallaPropuestaDiseno({super.key});

  @override
  State<PantallaPropuestaDiseno> createState() =>
      _PantallaPropuestaDisenoState();
}

class _PantallaPropuestaDisenoState extends State<PantallaPropuestaDiseno> {
  int _tabSeleccionada = 0;
  bool _notificacionesActivas = true;
  bool _recordatoriosActivos = false;
  final _controladorTexto = TextEditingController(text: 'cliente@carecar.mx');

  @override
  void dispose() {
    _controladorTexto.dispose();
    super.dispose();
  }

  void _mostrarFeedback(String mensaje) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '⚡ $mensaje (Respuesta táctil instantánea)',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFFF3F4F6),
            fontSize: 13,
          ),
        ),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF14161B),
        margin: const EdgeInsets.only(bottom: 90, left: 20, right: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF5B8CFF), width: 0.8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const fondoLienzo = Color(0xFF08090C);
    const azulCobalto = Color(0xFF2457F5);
    const textoPrimario = Color(0xFFF3F4F6);
    const textoSecundario = Color(0xFF94A3B8);

    return Theme(
      data: TemaPista.oscuro(),
      child: Scaffold(
        backgroundColor: fondoLienzo,
        extendBody: true,
        body: Stack(
          children: [
            // 1. Resplandor de estudio ambiental (Ambient Mesh Glow)
            Positioned(
              top: -80,
              left: -40,
              right: -40,
              height: 480,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.0, -0.2),
                      radius: 0.85,
                      colors: [
                        azulCobalto.withValues(alpha: 0.28),
                        const Color(0xFF1D3557).withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // 2. Contenido desplazable
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Barra superior transparente
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: textoPrimario,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Volver',
                  ),
                  title: Row(
                    children: [
                      const Text(
                        'Propuesta Liquid Glass',
                        style: TextStyle(
                          color: textoPrimario,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: Espaciado.e2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: azulCobalto.withValues(alpha: 0.2),
                          borderRadius: Radios.bordePildora,
                          border: Border.all(
                            color: azulCobalto.withValues(alpha: 0.6),
                            width: 0.5,
                          ),
                        ),
                        child: const Text(
                          'Pista v2',
                          style: TextStyle(
                            color: Color(0xFF5B8CFF),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Espaciado.e4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: Espaciado.e2),

                        // Buscador estilo cápsula de Telegram
                        const CampoBusquedaLiquido(
                          sugerencia: 'Buscar manual, testigo o servicio…',
                        ),

                        const SizedBox(height: Espaciado.e5),

                        // 3. Hero del auto con foto real
                        Center(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Image.asset(
                                      'assets/autos/sentra.jpg',
                                      height: 190,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    Container(
                                      height: 70,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            fondoLienzo.withValues(alpha: 0.85),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: Espaciado.e3),
                              const Text(
                                'Nissan Sentra 2024',
                                style: TextStyle(
                                  color: textoPrimario,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: Espaciado.e1),
                              const Text(
                                'Advance CVT · Placas GTO-482-B',
                                style: TextStyle(
                                  color: textoSecundario,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: Espaciado.e5),

                        // 4. Tarjetas de cristal líquido suspendidas (optimizadas para 120 FPS)
                        Row(
                          children: [
                            Expanded(
                              child: SuperficieLiquida(
                                intensidadDesenfoque: 0, // Cero blur en scroll para máximo rendimiento
                                opacidad: 0.08,
                                colorFondo: Colors.white.withValues(
                                  alpha: 0.06,
                                ),
                                colorBorde: Colors.white.withValues(
                                  alpha: 0.12,
                                ),
                                padding: const EdgeInsets.all(Espaciado.e4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.speed_rounded,
                                          color: azulCobalto,
                                          size: 20,
                                        ),
                                        const SizedBox(width: Espaciado.e2),
                                        const Text(
                                          'Odómetro',
                                          style: TextStyle(
                                            color: textoSecundario,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: Espaciado.e2),
                                    const Text(
                                      '18,400',
                                      style: TextStyle(
                                        color: textoPrimario,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const Text(
                                      'km registrados',
                                      style: TextStyle(
                                        color: textoSecundario,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: Espaciado.e3),
                            Expanded(
                              child: SuperficieLiquida(
                                intensidadDesenfoque: 0,
                                opacidad: 0.08,
                                colorFondo: Colors.white.withValues(
                                  alpha: 0.06,
                                ),
                                colorBorde: Colors.white.withValues(
                                  alpha: 0.12,
                                ),
                                padding: const EdgeInsets.all(Espaciado.e4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: Color(0xFF10B981),
                                          size: 20,
                                        ),
                                        const SizedBox(width: Espaciado.e2),
                                        const Text(
                                          'Garantía',
                                          style: TextStyle(
                                            color: textoSecundario,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: Espaciado.e2),
                                    const Text(
                                      'Vigente',
                                      style: TextStyle(
                                        color: Color(0xFF34C38F),
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Text(
                                      '3 años o 60,000 km',
                                      style: TextStyle(
                                        color: textoSecundario,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: Espaciado.e4),

                        // Tarjeta vítrea del Asistente IA (ligera y fluida)
                        SuperficieLiquida(
                          intensidadDesenfoque: 0,
                          opacidad: 0.08,
                          colorFondo: Colors.white.withValues(alpha: 0.06),
                          colorBorde: Colors.white.withValues(alpha: 0.12),
                          padding: const EdgeInsets.all(Espaciado.e4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: azulCobalto.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome,
                                      color: Color(0xFF5B8CFF),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: Espaciado.e3),
                                  const Expanded(
                                    child: Text(
                                      'Pregúntale a tu auto · Asistente IA',
                                      style: TextStyle(
                                        color: textoPrimario,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: Espaciado.e3),
                              Container(
                                padding: const EdgeInsets.all(Espaciado.e3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '«¿Qué presión deben llevar los neumáticos delanteros?»',
                                      style: TextStyle(
                                        color: textoPrimario,
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: azulCobalto.withValues(
                                              alpha: 0.25,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Text(
                                            'Manual, pág. 214',
                                            style: TextStyle(
                                              color: Color(0xFF8FB0DA),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          '32 PSI en frío',
                                          style: TextStyle(
                                            color: Color(0xFF34C38F),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: Espaciado.e4),

                        // 5. Botones y accesos con rebote elástico
                        const Text(
                          'Acciones rápidas con rebote háptico',
                          style: TextStyle(
                            color: textoSecundario,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: Espaciado.e3),

                        Row(
                          children: [
                            Expanded(
                              child: _BotonAccionVidrio(
                                icono: Icons.calendar_month_rounded,
                                titulo: 'Agendar cita',
                                alPulsar: () =>
                                    _mostrarFeedback('Agendar cita'),
                              ),
                            ),
                            const SizedBox(width: Espaciado.e3),
                            Expanded(
                              child: _BotonAccionVidrio(
                                icono: Icons.menu_book_rounded,
                                titulo: 'Manual PDF',
                                alPulsar: () => _mostrarFeedback('Manual PDF'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Espaciado.e3),
                        Row(
                          children: [
                            Expanded(
                              child: _BotonAccionVidrio(
                                icono: Icons.sos_rounded,
                                titulo: 'Asistencia SOS',
                                alPulsar: () =>
                                    _mostrarFeedback('Asistencia SOS'),
                              ),
                            ),
                            const SizedBox(width: Espaciado.e3),
                            Expanded(
                              child: _BotonAccionVidrio(
                                icono: Icons.build_circle_rounded,
                                titulo: 'Taller en vivo',
                                alPulsar: () =>
                                    _mostrarFeedback('Taller en vivo'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: Espaciado.e5),

                        // 6. Demostración de componentes actualizados del sistema
                        const Text(
                          'Componentes actualizados (TokensPista)',
                          style: TextStyle(
                            color: textoSecundario,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: Espaciado.e3),

                        // Botones del sistema con física instantánea (70ms) y sin splash lag
                        Row(
                          children: [
                            Expanded(
                              child: Boton(
                                texto: 'Boton Principal',
                                icono: Icons.bolt_rounded,
                                alPresionar: () =>
                                    _mostrarFeedback('Boton Principal'),
                              ),
                            ),
                            const SizedBox(width: Espaciado.e3),
                            Expanded(
                              child: Boton(
                                texto: 'Secundario',
                                variante: VarianteBoton.secundario,
                                alPresionar: () =>
                                    _mostrarFeedback('Boton Secundario'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: Espaciado.e3),

                        // TarjetaAccion con ReboteTactil elástico integrado
                        TarjetaAccion(
                          titulo: 'Mantenimiento Preventivo',
                          descripcion:
                              'Servicio de 20,000 km listo para agendar',
                          icono: Icons.car_repair_rounded,
                          tono: Tono.exito,
                          alToque: () =>
                              _mostrarFeedback('TarjetaAccion tocada'),
                        ),

                        const SizedBox(height: Espaciado.e3),

                        // Insignias vítreas de estado
                        const Row(
                          children: [
                            Insignia(
                              texto: 'Al corriente',
                              tono: Tono.exito,
                              conIcono: true,
                            ),
                            SizedBox(width: Espaciado.e2),
                            Insignia(
                              texto: 'Servicio sugerido',
                              tono: Tono.advertencia,
                              conIcono: true,
                            ),
                            SizedBox(width: Espaciado.e2),
                            Insignia(
                              texto: 'Garantía 100%',
                              tono: Tono.informacion,
                              conIcono: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: Espaciado.e5),

                        // Campos de formulario estilo Obsidian
                        const Text(
                          'Campos de entrada e interactivos',
                          style: TextStyle(
                            color: textoSecundario,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: Espaciado.e3),

                        CampoTexto(
                          etiqueta: 'Correo registrado',
                          controlador: _controladorTexto,
                          ayuda: 'Campo de texto con borde cobalto al foco',
                          sugerencia: 'ejemplo@dominio.com',
                        ),
                        const SizedBox(height: Espaciado.e3),
                        const CampoContrasena(
                          etiqueta: 'Contraseña del cliente',
                          ayuda: 'Con icono de visibilidad háptico',
                        ),

                        const SizedBox(height: Espaciado.e4),

                        // Controles binarios (Interruptor y Casilla con hápticos)
                        Interruptor(
                          etiqueta: 'Notificaciones en tiempo real',
                          descripcion: 'Avisos de taller y avances de servicio',
                          valor: _notificacionesActivas,
                          alCambiar: (v) =>
                              setState(() => _notificacionesActivas = v),
                        ),
                        const SizedBox(height: Espaciado.e2),
                        Casilla(
                          etiqueta: 'Recordatorio vía WhatsApp y SMS',
                          descripcion: 'Confirmación 24 hrs antes de tu cita',
                          valor: _recordatoriosActivos,
                          alCambiar: (v) =>
                              setState(() => _recordatoriosActivos = v),
                        ),

                        const SizedBox(height: Espaciado.e4),

                        // Grupo de lista estilo iOS / Obsidian
                        GrupoLista(
                          encabezado: 'Preferencias del vehículo',
                          filas: [
                            FilaGrupo(
                              titulo: 'Historial de mantenimiento',
                              subtitulo: '4 servicios registrados y validados',
                              icono: Icons.history_rounded,
                              alToque: () =>
                                  _mostrarFeedback('Historial seleccionado'),
                            ),
                            FilaGrupo(
                              titulo: 'Póliza de garantía y seguro',
                              subtitulo: 'Vigente hasta octubre 2027',
                              icono: Icons.shield_outlined,
                              colorIcono: const Color(0xFF10B981),
                              alToque: () =>
                                  _mostrarFeedback('Póliza seleccionada'),
                            ),
                          ],
                        ),

                        const SizedBox(height: Espaciado.e4),

                        // Botón para probar Modal Bottom Sheet con fondo translúcido
                        Boton(
                          texto: 'Probar Hoja Inferior (Modal Sheet)',
                          icono: Icons.vertical_align_top_rounded,
                          variante: VarianteBoton.secundario,
                          anchoCompleto: true,
                          alPresionar: () {
                            mostrarHojaInferior(
                              context,
                              titulo: 'Hoja Inferior Liquid Glass',
                              builder: (c) => Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Esta hoja modal cuenta con asa elástica, cromo translúcido y bordes hairline para menús contextuales y selecciones rápidas.',
                                    style: TextStyle(
                                      color: Color(0xFFA3A9B5),
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: Espaciado.e5),
                                  Boton(
                                    texto: 'Aceptar y cerrar',
                                    anchoCompleto: true,
                                    alPresionar: () => Navigator.of(c).pop(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(
                          height: 120,
                        ), // Espacio para el dock flotante
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 6. Dock de navegación flotante estilo cápsula (Liquid Dock)
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: SuperficieLiquida(
                radio: Radios.pildora,
                intensidadDesenfoque: 24,
                opacidad: 0.85,
                colorFondo: const Color(0xFF14161B).withValues(alpha: 0.82),
                colorBorde: Colors.white.withValues(alpha: 0.15),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ElementoDock(
                      icono: Icons.home_rounded,
                      etiqueta: 'Inicio',
                      activo: _tabSeleccionada == 0,
                      alTocar: () {
                        HapticFeedback.selectionClick();
                        setState(() => _tabSeleccionada = 0);
                      },
                    ),
                    _ElementoDock(
                      icono: Icons.directions_car_rounded,
                      etiqueta: 'Mi auto',
                      activo: _tabSeleccionada == 1,
                      alTocar: () {
                        HapticFeedback.selectionClick();
                        setState(() => _tabSeleccionada = 1);
                      },
                    ),
                    _ElementoDock(
                      icono: Icons.build_rounded,
                      etiqueta: 'Servicio',
                      activo: _tabSeleccionada == 2,
                      alTocar: () {
                        HapticFeedback.selectionClick();
                        setState(() => _tabSeleccionada = 2);
                      },
                    ),
                    _ElementoDock(
                      icono: Icons.auto_awesome,
                      etiqueta: 'Asistente',
                      activo: _tabSeleccionada == 3,
                      alTocar: () {
                        HapticFeedback.selectionClick();
                        setState(() => _tabSeleccionada = 3);
                      },
                    ),
                    _ElementoDock(
                      icono: Icons.person_rounded,
                      etiqueta: 'Cuenta',
                      activo: _tabSeleccionada == 4,
                      alTocar: () {
                        HapticFeedback.selectionClick();
                        setState(() => _tabSeleccionada = 4);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonAccionVidrio extends StatelessWidget {
  const _BotonAccionVidrio({
    required this.icono,
    required this.titulo,
    required this.alPulsar,
  });

  final IconData icono;
  final String titulo;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    return ReboteTactil(
      alPulsar: alPulsar,
      child: SuperficieLiquida(
        radio: Radios.pildora,
        intensidadDesenfoque: 0,
        colorFondo: Colors.white.withValues(alpha: 0.06),
        colorBorde: Colors.white.withValues(alpha: 0.12),
        padding: const EdgeInsets.symmetric(
          horizontal: Espaciado.e4,
          vertical: Espaciado.e3,
        ),
        child: Row(
          children: [
            Icon(icono, color: const Color(0xFF5B8CFF), size: 22),
            const SizedBox(width: Espaciado.e3),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  color: Color(0xFFF3F4F6),
                  fontSize: 13,
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

class _ElementoDock extends StatelessWidget {
  const _ElementoDock({
    required this.icono,
    required this.etiqueta,
    required this.activo,
    required this.alTocar,
  });

  final IconData icono;
  final String etiqueta;
  final bool activo;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    const azulCobalto = Color(0xFF5B8CFF);
    const textoInactivo = Color(0xFF6B7280);

    return ReboteTactil(
      alPulsar: alTocar,
      escalaAlPresionar: 0.90,
      activarHaptico: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: activo
              ? azulCobalto.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 22, color: activo ? azulCobalto : textoInactivo),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: TextStyle(
                fontSize: 10,
                fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                color: activo ? azulCobalto : textoInactivo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
