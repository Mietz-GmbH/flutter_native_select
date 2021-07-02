package app.mietz.flutter_native_select

import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.TextView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject


/** FlutterNativeSelectPlugin */
class FlutterNativeSelectPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var context: Context
    private lateinit var activity: Activity

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_native_select")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method != "openSelect") {
            result.notImplemented()
            return
        }

        val jsonObject = JSONObject(call.arguments as String)
        val arguments = OpenSelectArguments(jsonObject)

        AlertDialog.Builder(activity)
                .also { if (arguments.title != null) it.setTitle(arguments.title) }
                .also {
                    it.setSingleChoiceItems(SelectAdapter(arguments.items), 0) { dialog, which ->
                        result.success(arguments.items[which].value)
                        dialog.dismiss()
                    }
                }
                .also {
                    arguments.clearText?.let { text ->
                        it.setNegativeButton(text) { _, _ -> result.success(null) }
                    }
                }
                .also { it.setOnCancelListener { result.success(null) } }
                .create()
                .show()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
    }

    private inner class SelectAdapter(
            private val items: List<NativeSelectItem>
    ) : BaseAdapter() {
        private val inflater = LayoutInflater.from(context)
        private var defaultColor = -1

        override fun getCount(): Int = items.size

        override fun getItem(position: Int): Any = items[position]

        override fun getItemId(position: Int): Long = position.toLong()

        override fun isEnabled(position: Int): Boolean = !items[position].disabled

        override fun getView(position: Int, convertView: View?, parent: ViewGroup?): View {
            val view = (convertView ?: inflater.inflate(
                    android.R.layout.simple_spinner_dropdown_item, parent, false)) as TextView
            if (defaultColor == -1) {
                defaultColor = view.textColors.defaultColor
            }

            val item = items[position]
            var color = item.color ?: defaultColor
            if (item.disabled) {
                color = (color and 0xffffff) or 0x66000000
            }
            view.text = item.label
            view.setTextColor(color)

            return view
        }
    }
}
