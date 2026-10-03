package com.example.intario_ai

import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.intario_ai/ar_launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAppInstalled" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        result.success(isAppInstalled(packageName))
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name cannot be null", null)
                    }
                }
                "launchApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        result.success(launchApp(packageName))
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name cannot be null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isAppInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun launchApp(packageName: String): Boolean {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        return if (launchIntent != null) {
            launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(launchIntent)
            true
        } else {
            false
        }
    }
}
