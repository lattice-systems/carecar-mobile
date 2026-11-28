import 'dart:async';

import '../dominio/push.dart';

/// `ServicioPush` en memoria para pruebas y para el flavor de desarrollo:
/// entrega el [token] que se le dé y simula que el proveedor lo rote.
class ServicioPushFake implements ServicioPush {
  ServicioPushFake({this.token});

  String? token;
  final _nuevos = StreamController<String>.broadcast();

  @override
  Future<String?> tokenActual() async => token;

  @override
  Stream<String> get tokensNuevos => _nuevos.stream;

  /// Como cuando Firebase entrega un token distinto.
  void rotar(String nuevo) {
    token = nuevo;
    _nuevos.add(nuevo);
  }
}
