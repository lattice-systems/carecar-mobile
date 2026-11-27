package com.carecar.carecar_mobile

import android.app.ActivityManager
import android.app.ApplicationExitInfo
import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Activity principal.
 *
 * Expone el canal `mx.carecar/privacidad` (V2-M22.06): Dart pide `bloquear`
 * al entrar a una pantalla de pago o documentos y `permitir` al salir. Con
 * FLAG_SECURE el sistema no deja capturar ni grabar la ventana y la muestra
 * vacia en el selector de apps. Solo se activa por pantalla, no en toda la app.
 *
 * Hereda de `FlutterFragmentActivity` y no de `FlutterActivity` porque el
 * BiometricPrompt de Android se monta como fragmento (V2-M01.05): con
 * `FlutterActivity` el desbloqueo con huella falla en tiempo de ejecucion.
 */
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CANAL_PRIVACIDAD)
            .setMethodCallHandler { llamada, resultado ->
                when (llamada.method) {
                    "bloquear" -> {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        resultado.success(null)
                    }
                    "permitir" -> {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        resultado.success(null)
                    }
                    else -> resultado.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CANAL_DIAGNOSTICO)
            .setMethodCallHandler { llamada, resultado ->
                if (llamada.method != "crashesDesde") {
                    resultado.notImplemented()
                } else {
                    val desde = (llamada.arguments as? Number)?.toLong()
                    resultado.success(if (desde == null) emptyList<Long>() else crashesDesde(desde))
                }
            }
    }

    private fun crashesDesde(desde: Long): List<Long> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return emptyList()
        val actividad = getSystemService(ActivityManager::class.java) ?: return emptyList()
        return actividad.getHistoricalProcessExitReasons(packageName, 0, 0)
            .filter {
                it.timestamp > desde &&
                    (it.processName == packageName || it.processName.startsWith("$packageName:")) &&
                    (it.reason == ApplicationExitInfo.REASON_CRASH ||
                        it.reason == ApplicationExitInfo.REASON_CRASH_NATIVE)
            }
            .map { it.timestamp }
    }

    private companion object {
        const val CANAL_PRIVACIDAD = "mx.carecar/privacidad"
        const val CANAL_DIAGNOSTICO = "mx.carecar/diagnostico"
    }
}
