package com.example.kanju

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.kanju/overlay"
    private val OVERLAY_PERMISSION_REQ_CODE = 1234
    private var overlayService: OverlayService? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "showOverlay" -> {
                    if (checkOverlayPermission()) {
                        startOverlayService()
                        result.success(true)
                    } else {
                        requestOverlayPermission()
                        result.error("PERMISSION_DENIED", "Overlay permission not granted", null)
                    }
                }
                "hideOverlay" -> {
                    stopOverlayService()
                    result.success(true)
                }
                "updateMessage" -> {
                    val message = call.argument<String>("message")
                    if (message != null) {
                        overlayService?.updateMessage(message)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Message is required", null)
                    }
                }
                "updateCountdown" -> {
                    val countdown = call.argument<Int>("countdown")
                    if (countdown != null) {
                        overlayService?.updateCountdown(countdown)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Countdown value is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivityForResult(intent, OVERLAY_PERMISSION_REQ_CODE)
        }
    }

    private fun startOverlayService() {
        val intent = Intent(this, OverlayService::class.java)
        startService(intent)
    }

    private fun stopOverlayService() {
        val intent = Intent(this, OverlayService::class.java)
        stopService(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == OVERLAY_PERMISSION_REQ_CODE) {
            if (checkOverlayPermission()) {
                startOverlayService()
            }
        }
    }
}