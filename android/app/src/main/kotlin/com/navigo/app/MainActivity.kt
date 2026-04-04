package com.navigo.app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val WIDGET_CHANNEL = "com.navigo.app/widget"
    private val DEEPLINK_CHANNEL = "com.navigo.app/deeplink"

    private var deepLinkSink: EventChannel.EventSink? = null
    private var pendingDeepLink: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Widget method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestPinWidget" -> result.success(requestPinWidget())
                    "isWidgetPinned" -> result.success(isWidgetPinned())
                    else -> result.notImplemented()
                }
            }

        // Deep link event channel — streams URIs to Flutter
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, DEEPLINK_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    deepLinkSink = events
                    // Flush any link that arrived before Flutter was ready
                    pendingDeepLink?.let {
                        events?.success(it)
                        pendingDeepLink = null
                    }
                }
                override fun onCancel(arguments: Any?) {
                    deepLinkSink = null
                }
            })

        // Handle the intent that launched the activity (cold start)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val data = intent?.data ?: return
        val uri = data.toString()

        // Accept navigo:// custom scheme deep links
        // AND https://navigo-widget.github.io App Links (verified HTTPS)
        val isCustomScheme = uri.startsWith("navigo://")
        val isAppLink = uri.startsWith("https://navigo-widget.github.io")

        if (!isCustomScheme && !isAppLink) return

        // For HTTPS App Links, convert to navigo:// so Flutter handles them uniformly
        val deepLinkUri = if (isAppLink) {
            val params = data.query ?: ""
            "navigo://add?$params"
        } else {
            uri
        }

        val sink = deepLinkSink
        if (sink != null) {
            sink.success(deepLinkUri)
        } else {
            // Flutter not ready yet — buffer it
            pendingDeepLink = deepLinkUri
        }
        // Clear the intent data so it doesn't fire again on config change
        intent.data = null
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
