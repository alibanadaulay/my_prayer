package com.example.my_prayer

import android.appwidget.AppWidgetManager
import android.content.Intent
import android.util.Log
import android.widget.Toast
import com.orhanobut.hawk.Hawk
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(){
    private val CHANNEL = "prayer_widget_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updatePrayerWidget") {
                val prayerData = call.arguments as Map<String, String>

                val intent = Intent(this, PrayerWidgetProvider::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra("PRAYER_DATA", HashMap(prayerData)) // Pass the prayer data
                }
                sendBroadcast(intent)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
