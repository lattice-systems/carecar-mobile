import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_datos;
import 'package:timezone/timezone.dart' as tz;

import '../tema/tema_carecar.dart';
import 'servicio_notificaciones.dart';

/// Notificaciones nativas locales: sin Firebase ni servidor.
///
/// Usa alarmas inexactas para no pedir el permiso especial de alarmas exactas;
/// el aviso puede llegar algunos minutos tarde, que para un recordatorio basta.
class PluginNotificacionesLocal implements PluginNotificaciones {
  PluginNotificacionesLocal({required this.alTocar});

  /// Se llama cuando el usuario toca un aviso con la app viva.
  ///
  /// Recibe el destino que traia el aviso, si traia uno (V2-M06.03).
  final void Function(String? destino) alTocar;

  @override
  bool abiertaDesdeAviso = false;

  @override
  String? destinoDeArranque;

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _detalles = NotificationDetails(
    android: AndroidNotificationDetails(
      'recordatorios_citas',
      'Recordatorios de citas',
      channelDescription: 'Avisos antes de tus citas en Agencia360',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notificacion',
      color: TemaCareCar.azulAgencia,
    ),
    iOS: DarwinNotificationDetails(),
  );

  late tz.Location _zona;

  @override
  Future<void> inicializar() async {
    tz_datos.initializeTimeZones();
    // La agencia esta en el centro del pais: las horas de las citas son de ahi.
    _zona = tz.getLocation('America/Mexico_City');
    tz.setLocalLocation(_zona);

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notificacion'),
        // El permiso se pide despues, cuando tiene sentido para el usuario.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) => alTocar(r.payload),
    );
    final arranque = await _plugin.getNotificationAppLaunchDetails();
    abiertaDesdeAviso = arranque?.didNotificationLaunchApp ?? false;
    // Con la app cerrada no hay toque que escuchar: el destino solo esta aqui
    // (V2-M06.03). Es el unico camino para el arranque en frio.
    if (abiertaDesdeAviso) {
      destinoDeArranque = arranque?.notificationResponse?.payload;
    }
  }

  @override
  Future<bool> pedirPermiso() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  @override
  Future<void> mostrar(
    int id,
    String titulo,
    String cuerpo, {
    String? destino,
  }) => _plugin.show(
    id: id,
    title: titulo,
    body: cuerpo,
    notificationDetails: _detalles,
    payload: destino,
  );

  @override
  Future<void> programar(
    int id,
    DateTime cuando,
    String titulo,
    String cuerpo, {
    String? destino,
  }) => _plugin.zonedSchedule(
    id: id,
    scheduledDate: tz.TZDateTime(
      _zona,
      cuando.year,
      cuando.month,
      cuando.day,
      cuando.hour,
      cuando.minute,
    ),
    notificationDetails: _detalles,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    title: titulo,
    body: cuerpo,
    payload: destino,
  );

  @override
  Future<void> cancelar(int id) => _plugin.cancel(id: id);

  @override
  Future<void> cancelarTodas() => _plugin.cancelAll();

  @override
  Future<List<int>> pendientes() async => [
    for (final p in await _plugin.pendingNotificationRequests()) p.id,
  ];

  @override
  DateTime ahora() {
    final t = tz.TZDateTime.now(_zona);
    return DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second);
  }
}
