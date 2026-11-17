package com.example.flutter_cinemapedia

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.flutter_cinemapedia/dynamic_icon"

    private fun getAlias(name: String): String = "$packageName.$name"

    private val allAliases by lazy {
        listOf(
            getAlias("MainActivityNormal"),
            getAlias("MainActivityChristmas"),
            getAlias("MainActivityCinemaWorldDay"),
            getAlias("MainActivityAnniversary"),
            getAlias("MainActivityHalloween"),
            getAlias("MainActivityValentine"),
            getAlias("MainActivityCinemaValentine")
        )
    }

    private var pendingTargetAlias: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
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
            "christmas" -> getAlias("MainActivityChristmas")
            "cinemaWorldDay" -> getAlias("MainActivityCinemaWorldDay")
            "anniversary" -> getAlias("MainActivityAnniversary")
            "halloween" -> getAlias("MainActivityHalloween")
            "valentine" -> getAlias("MainActivityValentine")
            "cinemaValentine" -> getAlias("MainActivityCinemaValentine")
            else -> getAlias("MainActivityNormal")
        }

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
