package com.navigo.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

/**
 * NaviGo home screen widget — displays up to 6 location shortcuts.
 * Each shortcut button directly opens Google Maps navigation.
 *
 * Icons use Material-style vector drawables that match the Flutter app icons.
 */
class ShortcutWidgetProvider : HomeWidgetProvider() {

    companion object {
        private data class SlotIds(val container: Int, val icon: Int, val label: Int)

        private val slots = listOf(
            SlotIds(R.id.slot_0, R.id.icon_0, R.id.label_0),
            SlotIds(R.id.slot_1, R.id.icon_1, R.id.label_1),
            SlotIds(R.id.slot_2, R.id.icon_2, R.id.label_2),
            SlotIds(R.id.slot_3, R.id.icon_3, R.id.label_3),
            SlotIds(R.id.slot_4, R.id.icon_4, R.id.label_4),
            SlotIds(R.id.slot_5, R.id.icon_5, R.id.label_5),
        )

        // Map icon names to custom drawable resources (matching Flutter app icons)
        private fun getIconRes(context: Context, iconName: String): Int {
            val resName = "ic_shortcut_$iconName"
            val resId = context.resources.getIdentifier(resName, "drawable", context.packageName)
            // Fallback to place icon if custom icon not found
            return if (resId != 0) resId else {
                val fallback = context.resources.getIdentifier("ic_shortcut_place", "drawable", context.packageName)
                if (fallback != 0) fallback else android.R.drawable.ic_menu_mylocation
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.shortcut_widget)

            val jsonString = widgetData.getString("shortcuts_json", "[]") ?: "[]"
            val shortcuts = JSONArray(jsonString)

            for (i in slots.indices) {
                val slot = slots[i]

                if (i < shortcuts.length()) {
                    val shortcut = shortcuts.getJSONObject(i)
                    val label = shortcut.getString("label")
                    val lat = shortcut.getDouble("latitude")
                    val lng = shortcut.getDouble("longitude")
                    val iconName = shortcut.optString("iconName", "place")

                    views.setViewVisibility(slot.container, View.VISIBLE)
                    views.setTextViewText(slot.label, label)
                    views.setImageViewResource(slot.icon, getIconRes(context, iconName))

                    val navUri = Uri.parse("google.navigation:q=$lat,$lng")
                    val navIntent = Intent(Intent.ACTION_VIEW, navUri).apply {
                        setPackage("com.google.android.apps.maps")
                    }
                    val pendingIntent = PendingIntent.getActivity(
                        context,
                        i,
                        navIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    views.setOnClickPendingIntent(slot.container, pendingIntent)
                } else {
                    views.setViewVisibility(slot.container, View.GONE)
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
