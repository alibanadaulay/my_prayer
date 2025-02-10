package com.example.my_prayer

import android.app.Application
import androidx.work.Configuration
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequest
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

class App :Application() {

    override fun onCreate() {
        super.onCreate()
        val workManagerConfig = Configuration.Builder().build()
        WorkManager.initialize(this, workManagerConfig)

        val periodicWorkRequest = PeriodicWorkRequest.Builder(
            UpdateWidgetWorker::class.java, 15, TimeUnit.MINUTES
        ).build()

        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            "PrayerWidgetUpdate",
            ExistingPeriodicWorkPolicy.KEEP, // Prevents multiple instances
            periodicWorkRequest
        )
    }
}