package com.navigo.app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.content.pm.verify.domain.DomainVerificationManager
import android.content.pm.verify.domain.DomainVerificationUserState
import android.os.Build
import android.provider.Settings
import android.util.Base64
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    private val WIDGET_CHANNEL = "com.navigo.app/widget"
    private val DEEPLINK_CHANNEL = "com.navigo.app/deeplink"

    private var deepLinkSink: EventChannel.EventSink? = null
    private var pendingDeepLink: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Log the signing certificate SHA-256 so we can add it to assetlinks.json
        logSigningFingerprint()

        // Widget method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestPinWidget" -> result.success(requestPinWidget())
                    "isWidgetPinned" -> result.success(isWidgetPinned())
                    "getSigningFingerprint" -> result.success(getSigningFingerprint())
                    "isAppLinkVerified" -> result.success(isAppLinkVerified())
                    "openAppLinkSettings" -> {
                        openAppLinkSettings()
                        result.success(true)
                    }
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

        val isCustomScheme = uri.startsWith("navigo://")
        val isAppLink = uri.startsWith("https://navigo-widget.github.io")

        if (!isCustomScheme && !isAppLink) return

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
            pendingDeepLink = deepLinkUri
        }
        intent.data = null
    }

    /** Log the SHA-256 fingerprint of this APK's signing certificate. */
    private fun logSigningFingerprint() {
        val fp = getSigningFingerprint()
        if (fp != null) {
            Log.i("NaviGo", "APK signing SHA-256: $fp")
            Log.i("NaviGo", "Add this to assetlinks.json if App Links aren't auto-verifying")
        }
    }

    /** Get the SHA-256 fingerprint of this APK's signing certificate. */
    private fun getSigningFingerprint(): String? {
        return try {
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageManager.getPackageInfo(packageName,
                    android.content.pm.PackageManager.GET_SIGNING_CERTIFICATES)
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(packageName,
                    android.content.pm.PackageManager.GET_SIGNATURES)
            }

            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.signingInfo?.apkContentsSigners
            } else {
                @Suppress("DEPRECATION")
                packageInfo.signatures
            }

            val sig = signatures?.firstOrNull() ?: return null
            val digest = MessageDigest.getInstance("SHA-256")
            val hash = digest.digest(sig.toByteArray())
            hash.joinToString(":") { "%02X".format(it) }
        } catch (e: Exception) {
            Log.e("NaviGo", "Failed to get signing fingerprint", e)
            null
        }
    }

    /** Check if App Links are verified for our domain (Android 12+). */
    private fun isAppLinkVerified(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            // Before Android 12, autoVerify just works if assetlinks.json matches
            return true
        }
        return try {
            val manager = getSystemService(DomainVerificationManager::class.java)
            val userState = manager.getDomainVerificationUserState(packageName) ?: return false
            val domain = userState.hostToStateMap["navigo-widget.github.io"]
            domain == DomainVerificationUserState.DOMAIN_STATE_VERIFIED ||
                domain == DomainVerificationUserState.DOMAIN_STATE_SELECTED
        } catch (e: Exception) {
            Log.e("NaviGo", "Failed to check app link verification", e)
            false
        }
    }

    /** Open the system "Open by default" settings for this app. */
    private fun openAppLinkSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val intent = Intent(
                Settings.ACTION_APP_OPEN_BY_DEFAULT_SETTINGS,
                android.net.Uri.parse("package:$packageName")
            )
            startActivity(intent)
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
