package com.example.home_widget_app

import android.appwidget.AppWidgetProvider
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.example.my_prayer.R
import com.example.my_prayer.WidgetRemoteViewsService

class PrayerWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.prayer_list)
            
            // Set the RemoteViewsService (for horizontal list view)
            val intent = Intent(context, WidgetRemoteViewsService::class.java)
            views.setRemoteAdapter(R.id.widget_recycler_view, intent)

            // Update the widget
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
