package com.zaim.my_prayer

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters

class UpdateWidgetWorker(context: Context, workerParameters: WorkerParameters) : Worker(context, workerParameters) {
    override fun doWork(): Result {
        Log.d("UpdateWidgetWorker", "Widget update task is running...")

        try {
            val intent = Intent(applicationContext, PrayerWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            }

            applicationContext.sendBroadcast(intent)

            Log.d("UpdateWidgetWorker", "Broadcast sent to update widget")

        } catch (e: Exception) {
            e.printStackTrace()
            return Result.failure()
        }

        return Result.success()
    }
}