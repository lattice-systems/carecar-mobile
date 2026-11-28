// Puente Flutter <-> ActivityKit de la Live Activity del taller (V2-M25.05).
//
// AUN NO ESTA EN EL TARGET Runner NI SE REGISTRA EN AppDelegate: agregarlo sin
// ActividadTallerAtributos.swift en el mismo target romperia la compilacion.
// Mientras tanto Dart recibe MissingPluginException y la actividad queda «no
// disponible». Pasos exactos en plan/modulos/M25-widgets-y-wallet.md
// ("Avance de V2-M25.05 y V2-M25.06 (Apple)"). Al enlazarlo, en
// AppDelegate.didInitializeImplicitFlutterEngine:
//
//   if let registrador = engineBridge.pluginRegistry.registrar(forPlugin: "PuenteActividadEnVivo") {
//     PuenteActividadEnVivo.registrar(con: registrador)
//   }
//
// Contrato con lib/modulos/widgets/datos/servicio_actividad_en_vivo_canal.dart:
// - Canal "carecar/actividad_en_vivo": disponible -> Bool; iniciar {ordenId,
//   estado} -> Bool; actualizar {ordenId, estado}; terminar {ordenId, estado?};
//   terminarTodas; activas -> [Int]. `estado` es el content-state del backend.
// - Canal de eventos "carecar/actividad_en_vivo/tokens": {ordenId, pushToken}
//   en hexadecimal cada vez que ActivityKit da o rota el token.
//
// No se escribe nada en logs: el token identifica la actividad.

import ActivityKit
import Flutter
import Foundation

final class PuenteActividadEnVivo: NSObject, FlutterStreamHandler {
    static let nombreCanal = "carecar/actividad_en_vivo"
    static let nombreCanalTokens = "carecar/actividad_en_vivo/tokens"

    /// Cuanto se queda en la pantalla bloqueada al terminar con un estado
    /// final; el backend usa lo mismo en su `dismissal-date`.
    private static let permanenciaAlTerminar: TimeInterval = 15 * 60

    /// El puente vive lo que dura la app.
    private static var instancia: PuenteActividadEnVivo?

    private var receptor: FlutterEventSink?

    /// Tokens que llegaron sin que Dart escuchara; se mandan al escuchar.
    private var pendientes: [[String: Any]] = []

    /// Una tarea por actividad que escucha sus push tokens (por Activity.id).
    private var observadores: [String: Task<Void, Never>] = [:]

    static func registrar(con registrador: FlutterPluginRegistrar) {
        let puente = PuenteActividadEnVivo()
        let metodos = FlutterMethodChannel(name: nombreCanal, binaryMessenger: registrador.messenger())
        metodos.setMethodCallHandler { llamada, resultado in
            puente.manejar(llamada, resultado)
        }
        let eventos = FlutterEventChannel(name: nombreCanalTokens, binaryMessenger: registrador.messenger())
        eventos.setStreamHandler(puente)
        instancia = puente
    }

    // MARK: - Canal de metodos

    private func manejar(_ llamada: FlutterMethodCall, _ resultado: @escaping FlutterResult) {
        guard #available(iOS 16.1, *) else {
            // Antes de iOS 16.1 no hay Live Activities: todo es «no disponible».
            switch llamada.method {
            case "disponible", "iniciar": resultado(false)
            case "activas": resultado([Int]())
            default: resultado(nil)
            }
            return
        }
        let argumentos = llamada.arguments as? [String: Any] ?? [:]
        switch llamada.method {
        case "disponible":
            resultado(ActivityAuthorizationInfo().areActivitiesEnabled)
        case "iniciar":
            resultado(iniciar(argumentos))
        case "actualizar":
            if let ordenId = argumentos["ordenId"] as? Int,
               let estado = Self.estado(de: argumentos["estado"]) {
                for actividad in Self.vigentes(de: ordenId) {
                    Task { await Self.actualizar(actividad, con: estado) }
                }
            }
            resultado(nil)
        case "terminar":
            if let ordenId = argumentos["ordenId"] as? Int {
                let estadoFinal = Self.estado(de: argumentos["estado"])
                for actividad in Self.vigentes(de: ordenId) {
                    dejarDeObservar(actividad)
                    Task { await Self.terminar(actividad, con: estadoFinal) }
                }
            }
            resultado(nil)
        case "terminarTodas":
            for actividad in Activity<AtributosActividadTaller>.activities {
                dejarDeObservar(actividad)
                Task { await Self.terminar(actividad, con: nil) }
            }
            resultado(nil)
        case "activas":
            resultado(Self.todasVigentes().map { $0.attributes.ordenId })
        default:
            resultado(FlutterMethodNotImplemented)
        }
    }

    /// Inicia la actividad de la orden o reutiliza la que ya habia (de antes de
    /// cerrar la app). Devuelve si quedo una viva.
    @available(iOS 16.1, *)
    private func iniciar(_ argumentos: [String: Any]) -> Bool {
        guard let ordenId = argumentos["ordenId"] as? Int,
              let estado = Self.estado(de: argumentos["estado"]),
              ActivityAuthorizationInfo().areActivitiesEnabled
        else { return false }

        if let existente = Self.vigentes(de: ordenId).first {
            observar(existente)
            if let token = existente.pushToken {
                emitir(ordenId: ordenId, token: token)
            }
            Task { await Self.actualizar(existente, con: estado) }
            return true
        }

        let atributos = AtributosActividadTaller(ordenId: ordenId)
        do {
            let actividad: Activity<AtributosActividadTaller>
            if #available(iOS 16.2, *) {
                actividad = try Activity<AtributosActividadTaller>.request(
                    attributes: atributos,
                    content: ActivityContent(state: estado, staleDate: nil),
                    pushType: .token
                )
            } else {
                actividad = try Activity<AtributosActividadTaller>.request(
                    attributes: atributos,
                    contentState: estado,
                    pushType: .token
                )
            }
            observar(actividad)
            return true
        } catch {
            // Actividades apagadas, demasiadas actividades o sin permiso de
            // push: para Dart es «no se pudo iniciar».
            return false
        }
    }

    // MARK: - ActivityKit

    @available(iOS 16.1, *)
    private static func vigente(_ actividad: Activity<AtributosActividadTaller>) -> Bool {
        actividad.activityState != .ended && actividad.activityState != .dismissed
    }

    @available(iOS 16.1, *)
    private static func todasVigentes() -> [Activity<AtributosActividadTaller>] {
        Activity<AtributosActividadTaller>.activities.filter(vigente)
    }

    @available(iOS 16.1, *)
    private static func vigentes(de ordenId: Int) -> [Activity<AtributosActividadTaller>] {
        todasVigentes().filter { $0.attributes.ordenId == ordenId }
    }

    /// El `content-state` que manda Dart, con el mismo decodificador que usa
    /// ActivityKit para el push del backend.
    @available(iOS 16.1, *)
    private static func estado(de valor: Any?) -> EstadoActividadTaller? {
        guard let mapa = valor as? [String: Any],
              JSONSerialization.isValidJSONObject(mapa),
              let datos = try? JSONSerialization.data(withJSONObject: mapa)
        else { return nil }
        return try? JSONDecoder().decode(EstadoActividadTaller.self, from: datos)
    }

    @available(iOS 16.1, *)
    private static func actualizar(
        _ actividad: Activity<AtributosActividadTaller>,
        con estado: EstadoActividadTaller
    ) async {
        if #available(iOS 16.2, *) {
            await actividad.update(ActivityContent(state: estado, staleDate: nil))
        } else {
            await actividad.update(using: estado)
        }
    }

    /// Con [estadoFinal] se queda un rato con ese estado; sin el, se quita ya.
    @available(iOS 16.1, *)
    private static func terminar(
        _ actividad: Activity<AtributosActividadTaller>,
        con estadoFinal: EstadoActividadTaller?
    ) async {
        let politica: ActivityUIDismissalPolicy = estadoFinal == nil
            ? .immediate
            : .after(Date().addingTimeInterval(permanenciaAlTerminar))
        if #available(iOS 16.2, *) {
            let contenido = estadoFinal.map { ActivityContent(state: $0, staleDate: nil) }
            await actividad.end(contenido, dismissalPolicy: politica)
        } else {
            await actividad.end(using: estadoFinal, dismissalPolicy: politica)
        }
    }

    // MARK: - Push tokens

    @available(iOS 16.1, *)
    private func observar(_ actividad: Activity<AtributosActividadTaller>) {
        guard observadores[actividad.id] == nil else { return }
        let ordenId = actividad.attributes.ordenId
        observadores[actividad.id] = Task { [weak self] in
            for await token in actividad.pushTokenUpdates {
                self?.emitir(ordenId: ordenId, token: token)
            }
        }
    }

    @available(iOS 16.1, *)
    private func dejarDeObservar(_ actividad: Activity<AtributosActividadTaller>) {
        observadores.removeValue(forKey: actividad.id)?.cancel()
    }

    private func emitir(ordenId: Int, token: Data) {
        let hexadecimal = token.map { String(format: "%02x", $0) }.joined()
        let evento: [String: Any] = ["ordenId": ordenId, "pushToken": hexadecimal]
        // El canal de eventos solo se usa desde el hilo principal.
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let receptor = self.receptor {
                receptor(evento)
            } else {
                self.pendientes.append(evento)
            }
        }
    }

    // MARK: - FlutterStreamHandler

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        receptor = events
        let enEspera = pendientes
        pendientes.removeAll()
        enEspera.forEach { events($0) }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        receptor = nil
        return nil
    }
}
