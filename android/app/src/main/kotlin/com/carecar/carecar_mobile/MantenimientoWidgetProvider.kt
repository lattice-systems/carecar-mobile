package com.carecar.carecar_mobile

import android.content.Context
import android.view.View
import android.widget.RemoteViews

/**
 * Widget de mantenimiento: proximo servicio con km faltantes, fecha estimada
 * e indicador de avance. Un toque abre el plan del vehiculo
 * (`carecar://mantenimiento/<vehiculo>`). Cuando ya toca, el faltante y la
 * barra se pintan en rojo. Claves con prefijo `mant_`.
 */
class MantenimientoWidgetProvider : WidgetCarecar() {
    override val prefijo = "mant"
    override val layoutChico = R.layout.widget_mant_s
    override val layoutMediano = R.layout.widget_mant_m
    override val layoutGrande = R.layout.widget_mant_l
    override val enlaceVacio = "carecar://garaje"
    override val tituloPorDefecto = R.string.widget_mant_nombre

    override fun rellenar(context: Context, vistas: RemoteViews, datos: Datos, id: Int) {
        if (!datos.bool("hay")) return
        mostrarTexto(vistas, R.id.mant_servicio, datos.texto("servicio"))
        mostrarTexto(vistas, R.id.mant_fecha, datos.texto("fecha"))
        mostrarTexto(vistas, R.id.mant_vehiculo, datos.texto("vehiculo"))

        val urgente = datos.bool("urgente")
        val faltan = datos.texto("faltan")
        vistas.setTextViewText(R.id.mant_faltan, faltan)
        vistas.setTextViewText(R.id.mant_faltan_urgente, faltan)
        vistas.setViewVisibility(R.id.mant_faltan, if (urgente) View.GONE else View.VISIBLE)
        vistas.setViewVisibility(R.id.mant_faltan_urgente, if (urgente) View.VISIBLE else View.GONE)

        val progreso = datos.entero("progreso", 0).coerceIn(0, 100)
        vistas.setProgressBar(R.id.mant_barra, 100, progreso, false)
        vistas.setProgressBar(R.id.mant_barra_urgente, 100, progreso, false)
        vistas.setViewVisibility(R.id.mant_barra, if (urgente) View.GONE else View.VISIBLE)
        vistas.setViewVisibility(R.id.mant_barra_urgente, if (urgente) View.VISIBLE else View.GONE)
    }
}
