package com.example.my_prayer

import android.appwidget.AppWidgetProvider
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.orhanobut.hawk.Hawk

class PrayerWidgetProvider : AppWidgetProvider() {

    override fun onReceive(context: Context?, intent: Intent?) {
        super.onReceive(context, intent)
        if (intent?.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            context?.let {
                val prayerData = intent.getSerializableExtra("PRAYER_DATA") as? Map<String, String>
                if (prayerData != null) {
                    val appWidgetManager = AppWidgetManager.getInstance(context)
                    val appWidgetIds = appWidgetManager.getAppWidgetIds(
                        ComponentName(
                            context,
                            PrayerWidgetProvider::class.java
                        )
                    )

                    // Update the widgets with the new data
                    updateWidgets(context, appWidgetManager, appWidgetIds, prayerData)
                }
            }
        }
    }
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        updateWidgets(context, appWidgetManager, appWidgetIds, null)
    }
    private fun updateWidgets(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        prayerData: Map<String, String>?
    ) {
        val prayerDataTemp = prayerData ?: Hawk.get("prayerMap")
        if (prayerDataTemp.isNotEmpty()) {
            for (widgetId in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.prayer_list)

                // Display prayer data (or default message if null)
//            val displayData = prayerData?.entries?.joinToString("\n") { "${it.key}: ${it.value}" }
//                ?: "No prayer data available"
                prayerDataTemp?.let {
                    views.setTextViewText(R.id.fajr_time, prayerDataTemp["Fajr"] ?: "-")
                    views.setTextViewText(R.id.sunrise_time, prayerDataTemp["Sunrise"] ?: "-")
                    views.setTextViewText(R.id.dhuhr_time, prayerDataTemp["Dhuhr"] ?: "-")
                    views.setTextViewText(R.id.asr_time, prayerDataTemp["Asr"] ?: "-")
                    views.setTextViewText(R.id.maghrib_time, prayerDataTemp["Maghrib"] ?: "-")
                    views.setTextViewText(R.id.isha_time, prayerDataTemp["Isha"] ?: "-")


                    views.setTextViewText(R.id.fajr_title, context.getString(R.string.fajr))
                    views.setTextViewText(R.id.sunrise_title, context.getString(R.string.sunrise))
                    views.setTextViewText(R.id.dhuhr_title, context.getString(R.string.dhuhr))
                    views.setTextViewText(R.id.asr_title, context.getString(R.string.asr))
                    views.setTextViewText(R.id.maghrib_title, context.getString(R.string.maghrib))
                    views.setTextViewText(R.id.isha_title, context.getString(R.string.isha))
                }


                // Update the widget
                appWidgetManager.updateAppWidget(widgetId, views)
            }
        }
    }
}
