package com.episode.vcommunity

import android.content.Intent
import com.episode.vcommunity.tesseract4android.sample.OCRActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.episode.vcommunity.ar.SolarActivity


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.yourapp/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method.equals("launchActivity")) {
                    val intent = Intent(Intent.ACTION_MAIN)
                    intent.setClass(this, OCRActivity::class.java)
                    startActivity(intent)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
            
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "NativeMethodChannel")
            .setMethodCallHandler { call, result ->
            if (call.method == "showAugmentedReality") {
                SolarActivity.startActivity(context, call.arguments<String>() as String)
            } else {
                result.notImplemented()
            }
        }
    }

}
