package com.locationshortcut.widget

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
 * Android home screen widget that displays up to 6 location shortcuts.
 * Each shortcut button directly opens Google Maps navigation.
 */
class ShortcutWidgetProvider : HomeWidgetProvider() {

    companion object {
        // Resource IDs for each slot (layout, icon, label)
        private data class SlotIds(val container: Int, val icon: Int, val label: Int)

        private val slots = listOf(
            SlotIds(R.id.slot_0, R.id.icon_0, R.id.label_0),
            SlotIds(R.id.slot_1, R.id.icon_1, R.id.label_1),
            SlotIds(R.id.slot_2, R.id.icon_2, R.id.label_2),
            SlotIds(R.id.slot_3, R.id.icon_3, R.id.label_3),
            SlotIds(R.id.slot_4, R.id.icon_4, R.id.label_4),
            SlotIds(R.id.slot_5, R.id.icon_5, R.id.label_5),
        )

        // Map icon names to Android system drawable resources
        private val iconMap = mapOf(
            "home" to android.R.drawable.ic_menu_myplaces,
            "hospital" to android.R.drawable.ic_menu_add,
            "bank" to android.R.drawable.ic_menu_agenda,
            "grocery" to android.R.drawable.ic_menu_gallery,
            "temple" to android.R.drawable.ic_menu_compass,
            "pharmacy" to android.R.drawable.ic_menu_add,
            "restaurant" to android.R.drawable.ic_menu_preferences,
            "park" to android.R.drawable.ic_menu_mapmode,
            "office" to android.R.drawable.ic_menu_edit,
            "school" to android.R.drawable.ic_menu_info_details,
            "place" to android.R.drawable.ic_menu_mylocation,
        )
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.shortcut_widget)

            // Read shortcut data synced from Flutter
            val jsonString = widgetData.getString("shortcuts_json", "[]") ?: "[]"
            val shortcuts = JSONArray(jsonString)

            // Populate each slot
            for (i in slots.indices) {
                val slot = slots[i]

                if (i < shortcuts.length()) {
                    val shortcut = shortcuts.getJSONObject(i)
                    val label = shortcut.getString("label")
                    val lat = shortcut.getDouble("latitude")
                    val lng = shortcut.getDouble("longitude")
                    val iconName = shortcut.optString("iconName", "place")

                    // Show the slot
                    views.setViewVisibility(slot.container, View.VISIBLE)
                    views.setTextViewText(slot.label, label)

                    // Set icon
                    val iconRes = iconMap[iconName] ?: android.R.drawable.ic_menu_mylocation
                    views.setImageViewResource(slot.icon, iconRes)

                    // Create PendingIntent to open Google Maps navigation directly
                    val navUri = Uri.parse("google.navigation:q=$lat,$lng")
                    val navIntent = Intent(Intent.ACTION_VIEW, navUri).apply {
                        setPackage("com.google.android.apps.maps")
                    }
                    val pendingIntent = PendingIntent.getActivity(
                        context,
                        i, // unique request code per slot
                        navIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    views.setOnClickPendingIntent(slot.container, pendingIntent)
                } else {
                    // Hide unused slots
                    views.setViewVisibility(slot.container, View.GONE)
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
