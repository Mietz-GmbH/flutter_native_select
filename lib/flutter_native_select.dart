import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';

class NativeSelectItem {
  final String value;
  final String label;
  final bool disabled;
  final Color? color;

  const NativeSelectItem({
    required this.value,
    required this.label,
    this.disabled = false,
    this.color,
  });
}

class FlutterNativeSelect {
  static const MethodChannel _channel =
      const MethodChannel('flutter_native_select');

  static Future<String?> openSelect({
    required List<NativeSelectItem> items,
    /** iOS only */
    String? defaultValue,
    /** iOS only */
    String doneText = 'Done',
    String? clearText,
    /** Android only */
    String? title,
  }) {
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
