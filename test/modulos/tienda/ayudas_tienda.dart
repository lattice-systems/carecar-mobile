import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/tienda/datos/repositorio_tienda_fake.dart';
import 'package:carecar_mobile/modulos/tienda/presentacion/proveedores_tienda.dart';
import 'package:carecar_mobile/modulos/tienda/tienda.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

const march = VehiculoGaraje(id: 5, modelo: 'Nissan March', anio: 2020);
const jetta = VehiculoGaraje(id: 6, modelo: 'VW Jetta', anio: 2018);

const tapetes = Producto(
  id: 1,
  codigo: 'ACC-TAP-01',
  nombre: 'Tapetes de uso rudo',
  categoria: CategoriaProducto.accesorio,
  precio: 850,
  existencia: 3,
  universal: false,
  descripcion: 'Juego de cuatro piezas.',
  compatibilidad: [
    CompatibilidadProducto(modelo: 'March', anioDesde: 2017, anioHasta: 2022),
  ],
);

const shampoo = Producto(
  id: 2,
  codigo: 'CUI-SHA-01',
  nombre: 'Champú con cera',
  categoria: CategoriaProducto.cuidado,
  precio: 129.9,
  existencia: 20,
  universal: true,
);

const filtro = Producto(
  id: 3,
  codigo: 'REF-FIL-02',
  nombre: 'Filtro de aire Jetta',
  categoria: CategoriaProducto.refaccion,
  precio: 320,
  existencia: 0,
  universal: false,
);

/// El March es compatible con los tapetes y el Jetta con el filtro.
RepositorioTiendaFake tiendaDePrueba({
  List<Pedido> pedidos = const [],
  List<Producto> productos = const [tapetes, shampoo, filtro],
  Object? falla,
}) => RepositorioTiendaFake(
  productos: productos,
  pedidos: pedidos,
  compatiblesPorVehiculo: {
    5: {1},
    6: {3},
  },
  falla: falla,
  reloj: () => DateTime.utc(2026, 11, 26, 18),
);

Pedido pedido({
  int id = 7,
  EstadoPedido estado = EstadoPedido.apartado,
  CitaDePedido? cita,
  MotivoCancelacion? motivo,
}) {
  final abierto =
      estado == EstadoPedido.apartado || estado == EstadoPedido.listo;
  return Pedido(
    id: id,
    estado: estado,
    entrega: cita == null ? EntregaPedido.mostrador : EntregaPedido.cita,
    total: 1700,
    creadoEn: DateTime.utc(2026, 11, 26, 18),
    venceEn: abierto ? DateTime.utc(2026, 11, 28, 18) : null,
    listoEn: estado == EstadoPedido.listo || estado == EstadoPedido.entregado
        ? DateTime.utc(2026, 11, 27, 16)
        : null,
    entregadoEn: estado == EstadoPedido.entregado
        ? DateTime.utc(2026, 11, 27, 20)
        : null,
    canceladoEn: estado == EstadoPedido.cancelado
        ? DateTime.utc(2026, 11, 27, 20)
        : null,
    motivoCancelacion: motivo,
    cita: cita,
    renglones: const [
      RenglonPedido(
        productoId: 1,
        nombre: 'Tapetes de uso rudo',
        cantidad: 2,
        precio: 850,
        importe: 1700,
      ),
    ],
  );
}

final hoy = DateTime(2026, 11, 26, 10);

CitaCliente cita({
  int id = 31,
  int vehiculoId = 5,
  int dia = 28,
  EstadoDeCita estado = EstadoDeCita.confirmada,
}) => CitaCliente(
  id: id,
  vehiculoId: vehiculoId,
  fecha: DateTime(2026, 11, dia),
  horaInicio: '09:00',
  horaFin: '10:00',
  estado: estado,
);

List<Override> sustitutos({
  required RepositorioTiendaFake repositorio,
  List<VehiculoGaraje> garaje = const [march, jetta],
  List<CitaCliente> citas = const [],
  EventosEnVivoFake? eventos,
  List<Override> extra = const [],
}) => [
  repositorioTiendaProvider.overrideWithValue(repositorio),
  repositorioGarajeProvider.overrideWithValue(
    RepositorioGarajeFake(datos: garaje),
  ),
  repositorioCitasProvider.overrideWithValue(
    RepositorioCitasFake(citas: citas),
  ),
  relojCitasProvider.overrideWithValue(() => hoy),
  eventosEnVivoProvider.overrideWithValue(eventos ?? EventosEnVivoFake()),
  ...extra,
];

/// Monta una pantalla del módulo con el tema Pista y sus falsos. La sesión es
/// fija: no hay controlador de sesión en estas pruebas.
Widget app(
  Widget pantalla, {
  required RepositorioTiendaFake repositorio,
  List<VehiculoGaraje> garaje = const [march, jetta],
  List<CitaCliente> citas = const [],
  EventosEnVivoFake? eventos,
  List<Override> extra = const [],
  Escenario escenario = Escenario.claro,
  double ancho = 360,
}) => ProviderScope(
  // Cada escenario monta proveedores nuevos.
  key: UniqueKey(),
  overrides: [
    duenoSesionTiendaProvider.overrideWithValue('cliente'),
    ...sustitutos(
      repositorio: repositorio,
      garaje: garaje,
      citas: citas,
      eventos: eventos,
      extra: extra,
    ),
  ],
  child: conTemaPista(pantalla, escenario: escenario, ancho: ancho),
);

void pantallaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Un teléfono chico de 320 por 568.
void pantallaChica(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// El carrito del módulo montado en el árbol.
CarritoNotifier carritoDe(WidgetTester tester, Type pantalla) =>
    ProviderScope.containerOf(tester.element(find.byType(pantalla)))
        .read(carritoProvider.notifier);
