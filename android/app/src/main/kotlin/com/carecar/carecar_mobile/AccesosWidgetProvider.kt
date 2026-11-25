package com.carecar.carecar_mobile

import android.content.Context
import android.widget.RemoteViews

/**
 * Widget de accesos rapidos: Agendar, Mi auto, SOS y Comprobante. Cada boton
 * abre su pantalla por su enlace `carecar://`. Los botones se ven siempre: sin
 * datos publicados usan los textos y enlaces por defecto, para que el widget
 * sirva desde el primer momento. Claves con prefijo `acc_`.
 */
class AccesosWidgetProvider : WidgetCarecar() {
    override val prefijo = "acc"
    override val layoutChico = R.layout.widget_acc_s
    override val layoutMediano = R.layout.widget_acc_m
    override val layoutGrande = R.layout.widget_acc_l
    override val enlaceVacio = ENLACE_AGENDAR
    override val tituloPorDefecto = R.string.widget_acc_nombre
    override val siempreConDatos = true

    private class Boton(
        val clave: String,
        val vista: Int,
        val texto: Int,
        val etiqueta: Int,
        val enlace: String,
    )

    private val botones = listOf(
        Boton("agendar", R.id.acc_btn_agendar, R.id.acc_txt_agendar, R.string.widget_acc_agendar, ENLACE_AGENDAR),
        Boton("mi_auto", R.id.acc_btn_mi_auto, R.id.acc_txt_mi_auto, R.string.widget_acc_mi_auto, "carecar://garaje"),
        Boton("sos", R.id.acc_btn_sos, R.id.acc_txt_sos, R.string.widget_acc_sos, "carecar://asistencia/guias/pedir"),
        Boton("comprobante", R.id.acc_btn_comprobante, R.id.acc_txt_comprobante, R.string.widget_acc_comprobante, "carecar://citas"),
    )

    override fun rellenar(context: Context, vistas: RemoteViews, datos: Datos, id: Int) {
        botones.forEachIndexed { indice, boton ->
            val etiqueta = datos.texto(boton.clave) ?: context.getString(boton.etiqueta)
            vistas.setTextViewText(boton.texto, etiqueta)
            // Cada boton es un solo elemento para el lector de pantalla.
            vistas.setContentDescription(boton.vista, etiqueta)
            vistas.setOnClickPendingIntent(
                boton.vista,
                abrir(context, datos.texto("enlace_${boton.clave}") ?: boton.enlace, id * 10 + indice + 1),
            )
        }
    }

    private companion object {
        const val ENLACE_AGENDAR = "carecar://citas/agendar"
    }
}
