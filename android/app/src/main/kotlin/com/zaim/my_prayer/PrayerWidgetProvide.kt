package com.zaim.my_prayer

import android.appwidget.AppWidgetProvider
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import io.flutter.plugins.sharedpreferences.sharedPreferencesDataStore
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import org.json.JSONObject

class PrayerWidgetProvider : AppWidgetProvider() {
    companion object {
        fun getPrayerTimesFromDataStore(context: Context): String {
            val key = stringPreferencesKey("prayerTimes") // Use the same key as Flutter

            return runBlocking {
                val preferences = context.sharedPreferencesDataStore.data.first()
                preferences[key] ?: "" // Default to empty JSON object
            }
        }

        fun getCurrentPrayer(context: Context): Long {
            val key = longPreferencesKey("currentPrayer") // Use the same key as Flutter

            return runBlocking {
                val preferences = context.sharedPreferencesDataStore.data.first()
                preferences[key] ?: 0L
            }
        }

        fun getArabicDate(context: Context): String {
            val key = stringPreferencesKey("arabicDate") // Use the same key as Flutter

            return runBlocking {
                val preferences = context.sharedPreferencesDataStore.data.first()
                val jsonString = preferences[key] ?: "" // Default to empty JSON object
                jsonString
            }
        }
    }

    override fun onEnabled(context: Context?) {
        super.onEnabled(context)
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        super.onReceive(context, intent)
        if (intent?.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            context?.let {
                val prayerData = intent.getSerializableExtra("PRAYER_DATA") as? Map<String, String>
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
        val prayerDataTemp = prayerData ?: retrieveMap(context)
        val currentPrayer = getCurrentPrayer(context)
        if (!prayerDataTemp.isNullOrEmpty()) {
            for (widgetId in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.prayer_list)

                // Display prayer data (or default message if null)
                prayerDataTemp.let {
                    views.setInt(R.id.ll_fajr, "setBackgroundResource", android.R.color.transparent);
                    views.setInt(R.id.ll_sunrise, "setBackgroundResource", android.R.color.transparent);
                    views.setInt(R.id.ll_dhuhr, "setBackgroundResource", android.R.color.transparent);
                    views.setInt(R.id.ll_asr, "setBackgroundResource", android.R.color.transparent);
                    views.setInt(R.id.ll_maghrib, "setBackgroundResource", android.R.color.transparent);
                    views.setInt(R.id.ll_isha, "setBackgroundResource", android.R.color.transparent);

                    val fajr = prayerDataTemp["Fajr"]
                    val sunrise = prayerDataTemp["Sunrise"]
                    val dhuhr = prayerDataTemp["Dhuhr"]
                    val asr = prayerDataTemp["Asr"]
                    val maghrib = prayerDataTemp["Maghrib"]
                    val isha = prayerDataTemp["Isha"]
                    val id = when (currentPrayer) {
                        1L -> {
                            views.setTextColor(
                                R.id.sunrise_time,
                                ContextCompat.getColor(context, R.color.current_prayer_text)
                            )
                            views.setTextColor(
                                R.id.sunrise_title,
                                ContextCompat.getColor(context, R.color.current_prayer_text)
                            )
                            R.id.ll_sunrise
                        }

                        2L -> {
                            views.setTextColor(
                                R.id.dhuhr_time,
                                ContextCompat.getColor(context, R.color.current_prayer_text)
                            )
                            views.setTextColor(
                                R.id.dhuhr_title,
                                ContextCompat.getColor(context, R.color.current_prayer_text)
                            )
                            R.id.ll_dhuhr
                        }

                        3L -> {
                            views.setTextColor(
                                R.id.asr_time,
                                ContextCompat.getColor(context, R.color.current_prayer_text)
                            )
                            views.setTextColor(
                                R.id.asr_title,
                                ContextCompat.getColor(context, R.color.current_prayer_text)
                            )
                            R.id.ll_asr
                        }

                        4L -> {
                            views.setTextColor(
                                R.id.maghrib_time,
                                ContextCompat.getColor(context, R.color.current_prayer_text)
                            )
                            views.setTextColor(
                                R.id.maghrib_title,
                                ContextCompat.getColor(context, R.color.current_prayer_text)
                            )
                            R.id.ll_maghrib
                        }

                        5L -> {
                            views.setTextColor(
                                R.id.isha_time,
                                ContextCompat.getColor(context, R.color.current_prayer_text)
                            )
                            views.setTextColor(
                                R.id.isha_title,
                                ContextCompat.getColor(context, R.color.current_prayer_text)
                            )
                            R.id.ll_isha
                        }

                        else -> {
                            views.setTextColor(
                                R.id.fajr_time,
                                ContextCompat.getColor(context, R.color.current_prayer_text)
                            )
                            views.setTextColor(
                                R.id.fajr_title,
                                ContextCompat.getColor(context, R.color.current_prayer_text)
                            )
                            R.id.ll_fajr
                        }
                    }
                    views.setInt(id, "setBackgroundResource", R.drawable.bg_current_prayer);

                    views.setTextViewText(R.id.arabic_date, getArabicDate(context))
                    views.setTextViewText(R.id.fajr_time, fajr ?: "-")
                    views.setTextViewText(R.id.sunrise_time, sunrise ?: "-")
                    views.setTextViewText(R.id.dhuhr_time, dhuhr ?: "-")
                    views.setTextViewText(R.id.asr_time, asr ?: "-")
                    views.setTextViewText(R.id.maghrib_time, maghrib ?: "-")
                    views.setTextViewText(R.id.isha_time, isha ?: "-")

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

    private fun retrieveMap(context: Context): Map<String, String>? {
        val jsonString = getPrayerTimesFromDataStore(context)

        return if (jsonString.isNotEmpty()) {
            val jsonObject = JSONObject(jsonString)
            val map = mutableMapOf<String, String>()

            for (key in jsonObject.keys()) {
                map[key] = jsonObject[key].toString()
            }
            map
        } else {
            null
        }
    }
}
