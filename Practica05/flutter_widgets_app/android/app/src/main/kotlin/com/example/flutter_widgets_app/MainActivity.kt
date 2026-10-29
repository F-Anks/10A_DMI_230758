package com.example.flutter_widgets_app

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.flutter_widgets_app/dynamic_icon"

    private fun getAlias(name: String): String = "$packageName.$name"

    private val allAliases by lazy {
        (0..7).map { getAlias("MainActivityTheme$it") }
    }

    private var pendingTargetAlias: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setThemeIcon") {
                val index = call.argument<Int>("index") ?: 0
                val success = queueIconUpdate(index)
                result.success(success)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun queueIconUpdate(index: Int): Boolean {
        if (index < 0 || index >= allAliases.size) return false
        val targetAlias = allAliases[index]
        val pm = packageManager

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

        // Agendamos el cambio para aplicarlo en segundo plano (onStop) sin cerrar la app en primer plano
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

            pm.setComponentEnabledSetting(
                targetComponent,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )

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
