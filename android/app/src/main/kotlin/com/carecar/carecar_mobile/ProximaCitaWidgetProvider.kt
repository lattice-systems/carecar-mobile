package com.carecar.carecar_mobile

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews

/**
 * Widget de pantalla de inicio con la proxima cita (V2-M25.01) o, si hay una
 * orden abierta, con el estado del auto en el taller (V2-M25.02).
 *
 * No consulta la red ni guarda nada propio: pinta lo que Flutter dejo en el
 * almacen de home_widget (`HomeWidgetPreferences`). Las claves son el contrato
 * con `WidgetCitaHomeWidget` (Dart). Sin datos (primer uso, sesion cerrada) se
 * ve el estado "sin cita" con el acceso a agendar.
 *
 * Un toque abre la app por el enlace `carecar://` que viene en los datos
 * (comprobante de la cita, flujo de agendar u orden en `carecar://taller/<id>`);
 * go_router lo traduce a ruta.
 *
 * Con el auto en el taller Flutter reutiliza las mismas claves: la etapa va en
 * `proxima_cita_fecha`, la entrega estimada en `proxima_cita_horario` y el auto
 * en `proxima_cita_vehiculo`. Este proveedor no distingue los dos casos.
 */
class ProximaCitaWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val datos = context.getSharedPreferences(PREFERENCIAS, Context.MODE_PRIVATE)
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, vistas(context, datos))
        }
    }

    private fun vistas(
        context: Context,
        datos: android.content.SharedPreferences,
    ): RemoteViews {
        val vistas = RemoteViews(context.packageName, R.layout.widget_proxima_cita)
        val hayCita = datos.getBoolean(CLAVE_HAY_CITA, false)
        val enlace = datos.getString(CLAVE_ENLACE, null) ?: ENLACE_AGENDAR

        datos.getString(CLAVE_TITULO, null)?.let {
            vistas.setTextViewText(R.id.widget_cita_titulo, it)
        }
        vistas.setViewVisibility(
            R.id.widget_cita_con_cita,
            if (hayCita) View.VISIBLE else View.GONE,
        )
        vistas.setViewVisibility(
            R.id.widget_cita_sin_cita,
            if (hayCita) View.GONE else View.VISIBLE,
        )

        if (hayCita) {
            vistas.setTextViewText(R.id.widget_cita_fecha, datos.getString(CLAVE_FECHA, ""))
            vistas.setTextViewText(R.id.widget_cita_horario, datos.getString(CLAVE_HORARIO, ""))
            val vehiculo = datos.getString(CLAVE_VEHICULO, null)
            vistas.setTextViewText(R.id.widget_cita_vehiculo, vehiculo ?: "")
            vistas.setViewVisibility(
                R.id.widget_cita_vehiculo,
                if (vehiculo.isNullOrEmpty()) View.GONE else View.VISIBLE,
            )
        } else {
            datos.getString(CLAVE_MENSAJE, null)?.let {
                vistas.setTextViewText(R.id.widget_cita_mensaje, it)
            }
            vistas.setTextViewText(
                R.id.widget_cita_accion,
                datos.getString(CLAVE_ACCION, null) ?: "Agendar cita",
            )
        }

        vistas.setOnClickPendingIntent(R.id.widget_cita_raiz, abrir(context, enlace))
        return vistas
    }

    /** Abre la app en el enlace `carecar://`; si ya estaba abierta, la reutiliza. */
    private fun abrir(context: Context, enlace: String): PendingIntent {
        val intento = Intent(Intent.ACTION_VIEW, Uri.parse(enlace)).apply {
            setClass(context, MainActivity::class.java)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        return PendingIntent.getActivity(
            context,
            0,
            intento,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private companion object {
        const val PREFERENCIAS = "HomeWidgetPreferences"
        const val CLAVE_HAY_CITA = "proxima_cita_hay"
        const val CLAVE_TITULO = "proxima_cita_titulo"
        const val CLAVE_FECHA = "proxima_cita_fecha"
        const val CLAVE_HORARIO = "proxima_cita_horario"
        const val CLAVE_VEHICULO = "proxima_cita_vehiculo"
        const val CLAVE_MENSAJE = "proxima_cita_mensaje"
        const val CLAVE_ACCION = "proxima_cita_accion"
        const val CLAVE_ENLACE = "proxima_cita_enlace"
        const val ENLACE_AGENDAR = "carecar://citas/agendar"
    }
}
