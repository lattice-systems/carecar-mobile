import 'package:flutter/material.dart';

import 'api/api_config.dart';
import 'api/carecar_api_http.dart';
import 'api/cliente_api.dart';
import 'pantallas/pantalla_inicio.dart';
import 'pantallas/pantalla_login.dart';
import 'sesion/almacen_sesion.dart';
import 'sesion/controlador_sesion.dart';
import 'tema/tema_carecar.dart';

void main() {
  runApp(const AppCareCar());
}

/// Arma la app y conecta las piezas.
///
/// Este es el unico lugar que conoce a la vez la direccion del servidor, el
/// cliente HTTP y las pantallas. Mas abajo nadie sabe de donde vienen los
/// datos: las pantallas solo ven `CarecarApi` y `ControladorSesion`.
///
/// El cableado esta a mano a proposito: la inyeccion de dependencias todavia no
/// esta decidida (peticion EQ-1) y para dos objetos no vale la pena una
/// libreria.
class AppCareCar extends StatefulWidget {
  const AppCareCar({super.key});

  @override
  State<AppCareCar> createState() => _AppCareCarState();
}

class _AppCareCarState extends State<AppCareCar> {
  ControladorSesion? _sesion;
  ClienteApi? _cliente;
  Object? _errorDeArranque;

  @override
  void initState() {
    super.initState();
    _armar();
  }

  void _armar() {
    try {
      final almacen = AlmacenEnMemoria();

      // El cliente pide el token al almacen en cada peticion, asi que iniciar
      // o cerrar sesion no obliga a reconstruirlo.
      final cliente = ClienteApi(
        config: ApiConfig.desdeEntorno(),
        obtenerToken: almacen.leerToken,
      );

      _cliente = cliente;
      _sesion = ControladorSesion(CarecarApiHttp(cliente), almacen);
    } on ApiConfigInvalida catch (e) {
      // Falta --dart-define=API_URL. Es preferible decirlo con el comando
      // exacto que arrancar apuntando a ningun lado.
      _errorDeArranque = e;
    }
  }

  @override
  void dispose() {
    _cliente?.cerrar();
    _sesion?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareCar',
      theme: TemaCareCar.claro,
      debugShowCheckedModeBanner: false,
      home: _errorDeArranque != null
          ? _PantallaDeErrorDeArranque(error: _errorDeArranque!)
          : _Raiz(controlador: _sesion!),
    );
  }
}

/// Decide si se muestra el login o el inicio, segun si hay sesion.
///
/// Es la navegacion minima que APP-2.1 necesita. Cuando el equipo defina como
/// se navega (peticion EQ-1), se cambia aqui sin tocar las pantallas.
class _Raiz extends StatefulWidget {
  const _Raiz({required this.controlador});

  final ControladorSesion controlador;

  @override
  State<_Raiz> createState() => _RaizState();
}

class _RaizState extends State<_Raiz> {
  @override
  Widget build(BuildContext context) {
    if (widget.controlador.haySesion) {
      return PantallaInicio(
        controlador: widget.controlador,
        alCerrarSesion: () => setState(() {}),
      );
    }

    return PantallaLogin(
      controlador: widget.controlador,
      alIniciarSesion: () => setState(() {}),
    );
  }
}

/// Lo que se ve si la app se compilo sin la direccion de la API.
class _PantallaDeErrorDeArranque extends StatelessWidget {
  const _PantallaDeErrorDeArranque({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TemaCareCar.espacioSecciones),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.settings_outlined,
                size: 48,
                color: TemaCareCar.peligro,
              ),
              const SizedBox(height: TemaCareCar.espacioCampos),
              Text(
                'Falta configurar la dirección de la API',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: TemaCareCar.espacioCampos),
              SelectableText(
                '$error',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
