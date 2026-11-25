package com.carecar.carecar_mobile

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews

/**
 * Base de los widgets de pantalla de inicio de CareCar (V2-M25).
 *
 * Cada widget (proxima cita, taller, mantenimiento, bitacora, accesos) es un
 * proveedor aparte que se agrega por separado desde el selector del lanzador.
 * Ninguno consulta la red ni guarda nada propio: pintan lo que Flutter dejo en
 * el almacen de home_widget (`HomeWidgetPreferences`). Las claves llevan el
 * prefijo del widget (`cita_`, `taller_`, `mant_`, `bit_`, `acc_`) y son el
 * contrato con `TipoWidget` y `WidgetsHomeWidget` (Dart).
 *
 * Responsivo: cada widget tiene un layout chico (2x2), mediano (4x2) y grande
 * (4x4). En Android 12 (API 31) o mas se entregan los tres en un mapa de
 * tamanos y es el lanzador quien elige segun el espacio; en versiones
 * anteriores se elige por el ancho y alto minimos que reporta el lanzador y se
 * repinta al redimensionar.
 *
 * Un toque abre la app por el enlace `carecar://` que viene en los datos;
 * go_router lo traduce a ruta. Sin datos (primer uso, sesion cerrada) se ve el
 * estado vacio con los textos por defecto del selector.
 */
abstract class WidgetCarecar : AppWidgetProvider() {

    /** Prefijo de las claves del almacen: `cita`, `taller`, `mant`, `bit`, `acc`. */
    protected abstract val prefijo: String

    protected abstract val layoutChico: Int
    protected abstract val layoutMediano: Int
    protected abstract val layoutGrande: Int

    /** Enlace que se abre cuando no hay datos publicados. */
    protected abstract val enlaceVacio: String

    /** Titulo (recurso de texto) mientras Flutter no haya publicado el traducido. */
    protected abstract val tituloPorDefecto: Int

    /** Los accesos rapidos no dependen de datos: siempre muestran sus botones. */
    protected open val siempreConDatos: Boolean = false

    /** Pinta los datos propios del widget; lo comun ya esta puesto. */
    protected abstract fun rellenar(
        context: Context,
        vistas: RemoteViews,
        datos: Datos,
        id: Int,
    )

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (id in appWidgetIds) actualizar(context, appWidgetManager, id)
    }

    /** El usuario redimensiono el widget: en API < 31 hay que elegir otro layout. */
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        actualizar(context, appWidgetManager, appWidgetId)
    }

    private fun actualizar(context: Context, manager: AppWidgetManager, id: Int) {
        val datos = Datos(
            context.getSharedPreferences(PREFERENCIAS, Context.MODE_PRIVATE),
            prefijo,
        )
        val vistas = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            RemoteViews(
                mapOf(
                    SizeF(ANCHO_CHICO, ALTO_CHICO) to armar(context, layoutChico, datos, id),
                    SizeF(ANCHO_MEDIANO, ALTO_CHICO) to armar(context, layoutMediano, datos, id),
                    SizeF(ANCHO_MEDIANO, ALTO_GRANDE) to armar(context, layoutGrande, datos, id),
                ),
            )
        } else {
            val opciones = manager.getAppWidgetOptions(id)
            val ancho = opciones.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
            val alto = opciones.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
            val layout = when {
                ancho >= ANCHO_MEDIANO && alto >= ALTO_GRANDE -> layoutGrande
                ancho >= ANCHO_MEDIANO -> layoutMediano
                else -> layoutChico
            }
            armar(context, layout, datos, id)
        }
        manager.updateAppWidget(id, vistas)
    }

    private fun armar(context: Context, layout: Int, datos: Datos, id: Int): RemoteViews {
        val vistas = RemoteViews(context.packageName, layout)
        val hay = siempreConDatos || datos.bool("hay")
        vistas.setViewVisibility(R.id.w_con_datos, if (hay) View.VISIBLE else View.GONE)
        vistas.setViewVisibility(R.id.w_vacio, if (hay) View.GONE else View.VISIBLE)
        vistas.setTextViewText(
            R.id.w_titulo,
            datos.texto("titulo") ?: context.getString(tituloPorDefecto),
        )
        if (!hay) {
            datos.texto("mensaje")?.let { vistas.setTextViewText(R.id.w_mensaje, it) }
            datos.texto("accion")?.let { vistas.setTextViewText(R.id.w_accion, it) }
        }
        rellenar(context, vistas, datos, id)
        val descripcion = datos.texto("descripcion")
            ?: datos.texto("mensaje")
        if (descripcion != null) vistas.setContentDescription(R.id.w_raiz, descripcion)
        vistas.setOnClickPendingIntent(
            R.id.w_raiz,
            abrir(context, datos.texto("enlace") ?: enlaceVacio, id),
        )
        return vistas
    }

    /** Pone [valor] en [vista]; si falta, oculta la vista en vez de dejar un hueco. */
    protected fun mostrarTexto(vistas: RemoteViews, vista: Int, valor: String?) {
        vistas.setViewVisibility(vista, if (valor.isNullOrEmpty()) View.GONE else View.VISIBLE)
        if (!valor.isNullOrEmpty()) vistas.setTextViewText(vista, valor)
    }

    /** Abre la app en [enlace]; si ya estaba abierta, la reutiliza. */
    protected fun abrir(context: Context, enlace: String, codigo: Int): PendingIntent {
        val intento = Intent(Intent.ACTION_VIEW, Uri.parse(enlace)).apply {
            setClass(context, MainActivity::class.java)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        return PendingIntent.getActivity(
            context,
            codigo,
            intento,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    /** Lectura de las claves del widget con su prefijo. */
    class Datos(private val almacen: SharedPreferences, private val prefijo: String) {
        fun texto(campo: String): String? = almacen.getString("${prefijo}_$campo", null)
        fun bool(campo: String): Boolean = almacen.getBoolean("${prefijo}_$campo", false)

        /** home_widget guarda los enteros como Int o Long segun su tamano. */
        fun entero(campo: String, defecto: Int = 0): Int =
            (almacen.all["${prefijo}_$campo"] as? Number)?.toInt() ?: defecto
    }

    companion object {
        const val PREFERENCIAS = "HomeWidgetPreferences"

        // Tamanos de referencia en dp: 2x2 ~ 110, 4 columnas ~ 250, 4 filas ~ 250.
        const val ANCHO_CHICO = 110f
        const val ALTO_CHICO = 110f
        const val ANCHO_MEDIANO = 250f
        const val ALTO_GRANDE = 250f
    }
}
