package appkit

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.embedding.android.FlutterActivity
class AppkitPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel

  private var applicationContext: Context? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "appkit")
    channel.setMethodCallHandler(this)
    applicationContext = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "createMainNotificationChannel" -> {
        val id = call.argument<String>("id")
        val name = call.argument<String>("name")
        val description = call.argument<String>("description")
        if (id == null || name == null || description == null) {
          result.error(
              "InvalidArguments",
              "Arguments 'id', 'name' and 'description' are required",
              null
          )
        } else {
          createNotificationChannel(
              channelId = id,
              channelName = name,
              channelDescription = description,
              result = result
          )
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    applicationContext = null
  }

  private fun createNotificationChannel(
      channelId: String,
      channelName: String,
      channelDescription: String,
      result: MethodChannel.Result
  ) {
    val context = applicationContext
    if (context != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

      val channel = NotificationChannel(
          channelId,
          channelName,
          NotificationManager.IMPORTANCE_HIGH
      )

      channel.description = channelDescription

      val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
      notificationManager.createNotificationChannel(channel)
      result.success(true)
    } else {
      result.success(false)
    }
  }
}
