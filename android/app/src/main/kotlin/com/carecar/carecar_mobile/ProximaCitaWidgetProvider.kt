package com.carecar.carecar_mobile

import android.content.Context
import android.widget.RemoteViews

/**
 * Widget de la proxima cita (V2-M25.01): dia grande, mes, horario y vehiculo.
 * Un toque abre el comprobante (`carecar://citas/<id>/comprobante`); sin cita
 * invita a agendar. Claves con prefijo `cita_`.
 */
class ProximaCitaWidgetProvider : WidgetCarecar() {
    override val prefijo = "cita"
    override val layoutChico = R.layout.widget_cita_s
    override val layoutMediano = R.layout.widget_cita_m
    override val layoutGrande = R.layout.widget_cita_l
    override val enlaceVacio = "carecar://citas/agendar"
    override val tituloPorDefecto = R.string.widget_cita_nombre

    override fun rellenar(context: Context, vistas: RemoteViews, datos: Datos, id: Int) {
        if (!datos.bool("hay")) return
        mostrarTexto(vistas, R.id.cita_dia, datos.texto("dia"))
        mostrarTexto(vistas, R.id.cita_mes, datos.texto("mes"))
        mostrarTexto(vistas, R.id.cita_semana, datos.texto("semana"))
        mostrarTexto(vistas, R.id.cita_horario, datos.texto("horario"))
        mostrarTexto(vistas, R.id.cita_vehiculo, datos.texto("vehiculo"))
    }
}
