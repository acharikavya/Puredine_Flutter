package com.restaurantos.flutter_staff_app

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Log.d(
            "MainActivity",
            "ACTIVITY CREATED"
        )

        val serviceIntent = Intent(
            this,
            TaskRemovalService::class.java
        )

        startService(serviceIntent)
    }

    override fun onDestroy() {

        Log.d(
            "MainActivity",
            "ACTIVITY DESTROYED - isFinishing=$isFinishing"
        )

        if (isFinishing) {

            Log.d(
                "MainActivity",
                "ACTIVITY FINISHING - CLEARING SESSION"
            )

            getSharedPreferences(
                "FlutterSharedPreferences",
                MODE_PRIVATE
            )
                .edit()
                .clear()
                .apply()

            Log.d(
                "MainActivity",
                "SESSION CLEARED"
            )
        }

        super.onDestroy()
    }
}