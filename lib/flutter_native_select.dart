import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

/// This class contains information for one select item
class NativeSelectItem {
  /// The key of the item. This should be some kind of id. When the item is
  /// selected, this value is retured in the future.
  final String value;

  /// The display text for the select item.
  final String label;

  /// If this is true, the item is not selectable and the opacity of the item
  /// will be decresed to indicate that the item is disable.
  final bool disabled;

  /// If given, the text color of the select item is changed to this color.
  final Color? color;

  /// The constructor for a [NativeSelectItem]
  const NativeSelectItem({
    required this.value,
    required this.label,
    this.disabled = false,
    this.color,
  });
}

/// The platform interface for the [flutter_native_select] plugin
/// A flutter plugin which can open a native select box.
class FlutterNativeSelect {
  static const MethodChannel _channel =
      const MethodChannel('flutter_native_select');

  /// This method opens a select box that matches the native style.
  ///
  /// [items] is a list of select items. The list must not be empty and the
  /// values inside of the list, must be unique. Futhermore, some of the given
  /// items must not be disabled.
  /// [defaultValue] iOS only, the item which is preselected. If this value is
  /// omitted, the first not disabled item is chosen automatically.
  /// [doneText] iOS only, the text of the done button in the toolbar.
  /// [clearText] if this text is given, a button which clears the selection is
  /// displayed to the user. On iOS, this button is in the toolbar next to the
  /// done button. On Android, this button is below the list of items.
  /// [title] Android only, if the text is given, a title is shows above the
  /// items in the dialog.
  ///
  /// This method returns a future, which resolves the dialog is dismissed or
  /// closed. If the user, selected a item the [value] of the item is returned.
  /// In case the user pressed the back button on Android, or pressed the clear
  /// button, the future resolves with null.
  static Future<String?> openSelect({
    required List<NativeSelectItem> items,
    String? defaultValue,
    String doneText = 'Done',
    String? clearText,
    String? title,
  }) {
    assert(items.isNotEmpty, 'Items must not be empty!');
    assert(items.any((element) => !element.disabled),
        'Not all items must be disabled!');
    assert(items.map((e) => e.value).toSet().length == items.length,
        'Values in select items must be unique!');
    assert(
        defaultValue == null ||
            items.any((element) => element.value == defaultValue),
        'Default value must be one of the given items!');

    return _channel.invokeMethod(
        'openSelect',
        jsonEncode({
          'items': [
            for (final item in items)
              {
                'value': item.value,
                'label': item.label,
                'disabled': item.disabled,
                'color': item.color?.value,
              }
          ],
          'defaultValue': defaultValue ??
              items.firstWhere((element) => !element.disabled).value,
          'doneText': doneText,
          'clearText': clearText,
          'title': title,
        }));
  }
}
