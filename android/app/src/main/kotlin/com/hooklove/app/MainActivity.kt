package com.hooklove.app

import android.os.Build
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.hooklove.app/lockscreen"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableLockscreenMode()
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableLockscreenMode" -> {
                    enableLockscreenMode()
                    result.success(true)
                }
                "disableLockscreenMode" -> {
                    disableLockscreenMode()
                    result.success(true)
                }
                "isDeviceSecure" -> {
                    val keyguardManager = getSystemService(KEYGUARD_SERVICE) as android.app.KeyguardManager
                    result.success(keyguardManager.isDeviceSecure)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun enableLockscreenMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                setInheritShowWhenLocked(true)
            }
        }
    }

    private fun disableLockscreenMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(false)
            setTurnScreenOn(false)
        }
    }
}
