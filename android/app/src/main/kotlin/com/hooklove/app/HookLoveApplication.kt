package com.hooklove.app

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import com.google.firebase.FirebaseApp

class HookLoveApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        FirebaseApp.initializeApp(this)
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        val manager = getSystemService(NotificationManager::class.java)

        val drawingChannel = NotificationChannel(
            DRAWING_CHANNEL_ID,
            getString(R.string.drawing_channel_name),
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = getString(R.string.drawing_channel_desc)
            enableVibration(true)
            enableLights(true)
            setShowBadge(false)
        }

        val foregroundChannel = NotificationChannel(
            FOREGROUND_CHANNEL_ID,
            getString(R.string.foreground_channel_name),
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = getString(R.string.foreground_channel_desc)
            setShowBadge(false)
        }

        manager.createNotificationChannel(drawingChannel)
        manager.createNotificationChannel(foregroundChannel)
    }

    companion object {
        const val DRAWING_CHANNEL_ID = "hooklove_drawing"
        const val FOREGROUND_CHANNEL_ID = "hooklove_foreground"
    }
}
