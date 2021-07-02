package app.mietz.flutter_native_select

import org.json.JSONObject

/**
 * Created on 01.07.21.
 *
 * @author Maximilian Schelbach
 */
data class NativeSelectItem(
        val value: String,
        val label: String,
        val disabled: Boolean,
        val color: Int?
) {
    constructor(jsonValue: JSONObject) : this(
            value = jsonValue.getString("value"),
            label = jsonValue.getString("label"),
            disabled = jsonValue.getBoolean("disabled"),
            color = jsonValue.takeUnless { it.isNull("color") }?.getInt("color")
    )
}
