package com.restaurantos.flutter_staff_app

import android.app.Service
import android.content.Intent
import android.os.IBinder

class TaskRemovalService : Service() {

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int
    ): Int {
        return START_NOT_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        // Clear Flutter SharedPreferences when the app
        // is removed from the Android Recent Apps screen.
        getSharedPreferences(
            "FlutterSharedPreferences",
            MODE_PRIVATE
        )
            .edit()
            .clear()
            .apply()

        stopSelf()

        super.onTaskRemoved(rootIntent)
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}