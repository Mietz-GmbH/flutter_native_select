package app.mietz.flutter_native_select

import org.json.JSONObject

/**
 * Created on 01.07.21.
 *
 * @author Maximilian Schelbach
 */
data class OpenSelectArguments(
        val items: List<NativeSelectItem>,
        val title: String?,
        val clearText: String?
) {
    constructor(jsonValue: JSONObject) : this(
            items = jsonValue.getJSONArray("items").let {
                List(it.length()) { index ->
                    NativeSelectItem(it.getJSONObject(index))
                }
            },
            title = if (jsonValue.isNull("title")) null else jsonValue.getString("title"),
            clearText = if (jsonValue.isNull("clearText")) null else
                jsonValue.getString("clearText")
    )
}
