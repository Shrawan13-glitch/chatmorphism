package com.kino.app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.kino.app/foreground_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    ForegroundService.start(this)
                    result.success(true)
                }
                "stopService" -> {
                    ForegroundService.stop(this)
                    result.success(false)
                }
                "updateNotification" -> {
                    val title = call.argument<String>("title") ?: "Kino"
                    val content = call.argument<String>("content") ?: "Generating response..."
                    ForegroundService.updateNotification(this, title, content)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
