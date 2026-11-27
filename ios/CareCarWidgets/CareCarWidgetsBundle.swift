// Punto de entrada de la extension de widgets: 5 widgets x 3 tamanos
// (.systemSmall, .systemMedium, .systemLarge) y la Live Activity del taller
// (V2-M25.05). Requiere iOS 17 por containerBackground(for:), asi que la Live
// Activity (iOS 16.1) entra sin comprobar la version. Ver WidgetComun.swift
// para enlazar el target.

import SwiftUI
import WidgetKit

@main
struct CareCarWidgetsBundle: WidgetBundle {
    var body: some Widget {
        ProximaCitaWidget()
        TallerWidget()
        MantenimientoWidget()
        BitacoraWidget()
        AccesosWidget()
        ActividadTallerLiveActivity()
    }
}
