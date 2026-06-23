package com.kino.app

import android.app.Notification
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.PowerManager

class ForegroundService : Service() {

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                acquireWakeLock(this)
                val notification = buildNotification(this)
                startForeground(NOTIFICATION_ID, notification)
            }
            ACTION_STOP -> {
                releaseWakeLock()
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
        }
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        releaseWakeLock()
        super.onDestroy()
    }

    companion object {
        private const val ACTION_START = "ACTION_START"
        private const val ACTION_STOP = "ACTION_STOP"
        private const val NOTIFICATION_ID = 888

        private var wakeLock: PowerManager.WakeLock? = null

        fun start(context: Context) {
            NotificationService.createChannel(context)
            val intent = Intent(context, ForegroundService::class.java).apply {
                action = ACTION_START
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            val intent = Intent(context, ForegroundService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }

        fun updateNotification(context: Context, title: String, content: String) {
            NotificationService.updateNotification(context, title, content)
        }

        private fun acquireWakeLock(context: Context) {
            if (wakeLock == null) {
                val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
                wakeLock = pm.newWakeLock(
                    PowerManager.PARTIAL_WAKE_LOCK,
                    "kino:generation_wakelock"
                )
                wakeLock?.acquire()
            }
        }

        private fun releaseWakeLock() {
            wakeLock?.let {
                if (it.isHeld) {
                    it.release()
                }
            }
            wakeLock = null
        }

        private fun buildNotification(context: Context): Notification {
            return NotificationService.buildNotification(context)
        }

        fun isWakeLockHeld(): Boolean = wakeLock?.isHeld == true
    }
}
