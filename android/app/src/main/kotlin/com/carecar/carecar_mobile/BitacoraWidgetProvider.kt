package com.carecar.carecar_mobile

import android.content.Context
import android.widget.RemoteViews

/**
 * Widget de la bitacora: rendimiento en km/l y gasto del mes en cifras
 * grandes. Un toque abre la bitacora del vehiculo (`carecar://bitacora/<id>`);
 * sin gastos invita a registrar el primero. Claves con prefijo `bit_`.
 */
class BitacoraWidgetProvider : WidgetCarecar() {
    override val prefijo = "bit"
    override val layoutChico = R.layout.widget_bit_s
    override val layoutMediano = R.layout.widget_bit_m
    override val layoutGrande = R.layout.widget_bit_l
    override val enlaceVacio = "carecar://garaje"
    override val tituloPorDefecto = R.string.widget_bit_nombre

    override fun rellenar(context: Context, vistas: RemoteViews, datos: Datos, id: Int) {
        if (!datos.bool("hay")) return
        mostrarTexto(vistas, R.id.bit_rendimiento, datos.texto("rendimiento"))
        mostrarTexto(vistas, R.id.bit_unidad, datos.texto("unidad"))
        mostrarTexto(vistas, R.id.bit_etiqueta_rendimiento, datos.texto("etiqueta_rendimiento"))
        mostrarTexto(vistas, R.id.bit_gasto, datos.texto("gasto"))
        mostrarTexto(vistas, R.id.bit_etiqueta_gasto, datos.texto("etiqueta_gasto"))
        mostrarTexto(vistas, R.id.bit_vehiculo, datos.texto("vehiculo"))
    }
}
