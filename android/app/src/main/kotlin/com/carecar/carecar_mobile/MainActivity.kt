package com.carecar.carecar_mobile

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Activity principal.
 *
 * Expone el canal `mx.carecar/privacidad` (V2-M22.06): Dart pide `bloquear`
 * al entrar a una pantalla de pago o documentos y `permitir` al salir. Con
 * FLAG_SECURE el sistema no deja capturar ni grabar la ventana y la muestra
 * vacia en el selector de apps. Solo se activa por pantalla, no en toda la app.
 */
class MainActivity : FlutterActivity() {
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
    }

    private companion object {
        const val CANAL_PRIVACIDAD = "mx.carecar/privacidad"
    }
}
