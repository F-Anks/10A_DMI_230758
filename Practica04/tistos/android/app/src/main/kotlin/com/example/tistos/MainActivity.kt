package com.example.tistos

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.tistos/dynamic_icon"

    private fun getAlias(name: String): String = "$packageName.$name"

    private val allAliases by lazy {
        listOf(
            getAlias("MainActivityNormal"),
            getAlias("MainActivityAnniversary"),
            getAlias("MainActivityHalloween"),
            getAlias("MainActivityChristmas"),
            getAlias("MainActivityValentine")
        )
    }

    private var pendingTargetAlias: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setSeasonalIcon") {
                val season = call.argument<String>("season") ?: "normal"
                val success = queueSeasonalIconUpdate(season)
                result.success(success)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun queueSeasonalIconUpdate(season: String): Boolean {
        val targetAlias = when (season) {
            "anniversary" -> getAlias("MainActivityAnniversary")
            "halloween" -> getAlias("MainActivityHalloween")
            "christmas" -> getAlias("MainActivityChristmas")
            "valentine" -> getAlias("MainActivityValentine")
            else -> getAlias("MainActivityNormal")
        }

        val pm = packageManager

        // Verificar si el alias objetivo ya es el único habilitado en el sistema
        var isTargetOnlyEnabled = true
        for (alias in allAliases) {
            val comp = ComponentName(this, alias)
            val state = pm.getComponentEnabledSetting(comp)
            if (alias == targetAlias) {
                if (state != PackageManager.COMPONENT_ENABLED_STATE_ENABLED) {
                    isTargetOnlyEnabled = false
                }
            } else {
                if (state != PackageManager.COMPONENT_ENABLED_STATE_DISABLED) {
                    isTargetOnlyEnabled = false
                }
            }
        }

        if (isTargetOnlyEnabled) {
            pendingTargetAlias = null
            return true
        }

        // NUNCA habilitamos dos alias simultáneamente en primer plano: si se habilitan dos a la vez,
        // el launcher de Android detecta dos actividades LAUNCHER activas y duplica el icono en la pantalla de inicio.
        // Tampoco deshabilitamos el alias activo mientras está en primer plano porque el sistema operativo cierra la app.
        // Agendamos el cambio para que se aplique de forma atómica en segundo plano al salir o minimizar la app (onStop).
        pendingTargetAlias = targetAlias
        return true
    }

    override fun onStop() {
        super.onStop()
        applyPendingIconChange()
    }

    private fun applyPendingIconChange() {
        val target = pendingTargetAlias ?: return
        try {
            val pm = packageManager
            val targetComponent = ComponentName(this, target)

            // 1. Habilitar primero el alias de la nueva temporada
            pm.setComponentEnabledSetting(
                targetComponent,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )

            // 2. Deshabilitar inmediatamente todos los demás alias.
            // Esto garantiza que en el sistema NUNCA existan dos alias activos al mismo tiempo,
            // impidiendo que el Launcher de Android cree accesos directos duplicados en la pantalla de inicio.
            for (alias in allAliases) {
                if (alias != target) {
                    val comp = ComponentName(this, alias)
                    pm.setComponentEnabledSetting(
                        comp,
                        PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                        PackageManager.DONT_KILL_APP
                    )
                }
            }
            pendingTargetAlias = null
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}

