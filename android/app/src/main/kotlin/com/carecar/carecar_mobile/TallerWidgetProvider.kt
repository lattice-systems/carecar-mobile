package com.carecar.carecar_mobile

import android.content.Context
import android.widget.RemoteViews

/**
 * Widget del taller en vivo (V2-M25.02): etapa actual con barra de avance por
 * etapas y entrega estimada. Un toque abre la orden (`carecar://taller/<id>`);
 * sin orden abierta invita a agendar. Claves con prefijo `taller_`.
 */
class TallerWidgetProvider : WidgetCarecar() {
    override val prefijo = "taller"
    override val layoutChico = R.layout.widget_taller_s
    override val layoutMediano = R.layout.widget_taller_m
    override val layoutGrande = R.layout.widget_taller_l
    override val enlaceVacio = "carecar://citas/agendar"
    override val tituloPorDefecto = R.string.widget_taller_nombre

    override fun rellenar(context: Context, vistas: RemoteViews, datos: Datos, id: Int) {
        if (!datos.bool("hay")) return
        mostrarTexto(vistas, R.id.taller_etapa, datos.texto("etapa"))
        mostrarTexto(vistas, R.id.taller_paso, datos.texto("paso_texto"))
        mostrarTexto(vistas, R.id.taller_entrega, datos.texto("entrega"))
        mostrarTexto(vistas, R.id.taller_vehiculo, datos.texto("vehiculo"))
        val total = datos.entero("total", 7).coerceAtLeast(1)
        val paso = datos.entero("paso", 0).coerceIn(0, total)
        vistas.setProgressBar(R.id.taller_barra, total, paso, false)
    }
}
