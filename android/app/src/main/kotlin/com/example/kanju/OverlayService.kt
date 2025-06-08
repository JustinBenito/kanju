package com.example.kanju

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import io.flutter.plugin.common.MethodChannel

class OverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var messageTextView: TextView? = null
    private var countdownTextView: TextView? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        setupOverlay()
    }

    private fun setupOverlay() {
        val inflater = getSystemService(LAYOUT_INFLATER_SERVICE) as LayoutInflater
        overlayView = inflater.inflate(R.layout.overlay_layout, null)

        messageTextView = overlayView?.findViewById(R.id.messageText)
        countdownTextView = overlayView?.findViewById(R.id.countdownText)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.CENTER
        }

        windowManager?.addView(overlayView, params)
    }

    fun updateMessage(message: String) {
        messageTextView?.post {
            messageTextView?.text = message
        }
    }

    fun updateCountdown(countdown: Int) {
        countdownTextView?.post {
            countdownTextView?.text = countdown.toString()
            countdownTextView?.visibility = if (countdown > 0) View.VISIBLE else View.GONE
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        if (overlayView != null && windowManager != null) {
            windowManager?.removeView(overlayView)
        }
    }
} 