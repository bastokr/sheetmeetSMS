package com.shsoft.youngwonsms
 

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel 
import io.flutter.embedding.engine.FlutterEngine 
import io.flutter.plugins.GeneratedPluginRegistrant
import org.json.JSONObject
import android.telephony.SmsManager


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.shosft.youngwonsms/mms"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendMMS") {
                val phoneNumber = call.argument<String>("phoneNumber")
                val message = call.argument<String>("message")

                if (phoneNumber != null && message != null) {
                    sendMMS(phoneNumber, message)
                    result.success("MMS Sent")
                } else {
                    result.error("INVALID_ARGUMENT", "Phone number or message is null", null)
                }
            }  else if(call.method== "sendInvokeMessage"){
                result.success(sendInvokeMessage(call.arguments))
            }
            else {
                result.notImplemented()
            }
        }
    }

    private fun sendMMS(phoneNumber: String, message: String) {
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra("address", phoneNumber)
            putExtra("sms_body", message)
        }
        if (intent.resolveActivity(packageManager) != null) {
            startActivity(intent)
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
