package com.navigo.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

/**
 * NaviGo home screen widget — displays up to 6 location shortcuts.
 * Each shortcut button directly opens Google Maps navigation.
 *
 * Supports two visual styles controlled by the `widget_style` shared preference:
 *   • frostedGlass (default) – translucent glass cards
 *   • boldColors – vibrant solid-color blocks
 *
 * The widget is fully resizable — icons and layout adapt to the widget boundaries.
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

        /** Bold-color palette — one per slot. */
        private val boldSlotColors = intArrayOf(
            Color.parseColor("#FF1565C0"), // Blue
            Color.parseColor("#FF00897B"), // Teal
            Color.parseColor("#FFE65100"), // Deep Orange
            Color.parseColor("#FF6A1B9A"), // Purple
            Color.parseColor("#FF2E7D32"), // Green
            Color.parseColor("#FFC62828"), // Red
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

        fun buildRemoteViews(context: Context, widgetData: android.content.SharedPreferences): RemoteViews {
            val styleName = widgetData.getString("widget_style", "frostedGlass") ?: "frostedGlass"
            val isBold = styleName == "boldColors"

            val layoutRes = if (isBold) R.layout.shortcut_widget_bold else R.layout.shortcut_widget
            val views = RemoteViews(context.packageName, layoutRes)

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

                    // Apply per-slot color for bold style
                    if (isBold) {
                        views.setInt(slot.container, "setBackgroundColor", boldSlotColors[i % boldSlotColors.size])
                    }

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

            return views
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = buildRemoteViews(context, widgetData)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        // Re-render the widget when the user resizes it.
        // The layout uses weight-based sizing so icons and cells
        // automatically scale to fill the new boundaries.
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val views = buildRemoteViews(context, prefs)
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
