package com.navigo.app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.navigo.app/widget"

    // Forward new intents so app_links receives deep links while the app is already running
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestPinWidget" -> {
                        val success = requestPinWidget()
                        result.success(success)
                    }
                    "isWidgetPinned" -> {
                        val pinned = isWidgetPinned()
                        result.success(pinned)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun requestPinWidget(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false

        val appWidgetManager = getSystemService(AppWidgetManager::class.java) ?: return false
        if (!appWidgetManager.isRequestPinAppWidgetSupported) return false

        val widgetProvider = ComponentName(this, ShortcutWidgetProvider::class.java)
        return appWidgetManager.requestPinAppWidget(widgetProvider, null, null)
    }

    private fun isWidgetPinned(): Boolean {
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val widgetProvider = ComponentName(this, ShortcutWidgetProvider::class.java)
        val widgetIds = appWidgetManager.getAppWidgetIds(widgetProvider)
        return widgetIds.isNotEmpty()
    }
}
