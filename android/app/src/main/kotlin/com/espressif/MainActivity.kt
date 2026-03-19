package com.espressif

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import com.espressif.ui.activities.EspMainActivity

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.cepfrontend/wifi_provisioning"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startProvisioning") {
                val intent = Intent(this, EspMainActivity::class.java)
                startActivity(intent)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }
}
