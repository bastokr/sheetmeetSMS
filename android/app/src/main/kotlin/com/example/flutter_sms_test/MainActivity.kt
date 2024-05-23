package com.shsoft.youngwonsms
 

 
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import org.json.JSONObject
import android.telephony.SmsManager

class MainActivity: FlutterActivity() {
	
    // 작성된 코드 영역 시작
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.native_connection_study")
        channel.setMethodCallHandler { methodCall, result ->
            if(methodCall.method == "sendInvokeMessage"){
                result.success(sendInvokeMessage(methodCall.arguments))
            }else{
                result.notImplemented()
            }
        }
    }

    private fun sendInvokeMessage(arguments: Any?): Any {
        val smsManager:SmsManager
        smsManager = this.getSystemService(SmsManager::class.java)
         
        val args: List<Any> = (arguments as List<Any>?) ?: mutableListOf()
        smsManager.sendTextMessage(args[0].toString(), null, args[1].toString(), null, null)
        val json = JSONObject(mapOf("name" to args[0], "age" to args[1]).toString())
        return json.toString()
    }
    // 작성된 코드 영역 끝
}

