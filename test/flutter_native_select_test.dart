import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_native_select/flutter_native_select.dart';
import 'package:flutter_test/flutter_test.dart';

const color1 = Color(0xff000000);
const color2 = Color(0xff0000ff);

void main() {
  const MethodChannel channel = MethodChannel('flutter_native_select');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler(
        (methodCall) => Future.value(methodCall.arguments));
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('expect to fail, when duplicated items exists', () {
    expect(
        () => FlutterNativeSelect.openSelect(items: [
              NativeSelectItem(value: 'item', label: ''),
              NativeSelectItem(value: 'item', label: '')
            ]),
        throwsAssertionError);
  });

  test('expect to fail, when the default value is not one of the items', () {
    expect(
        () => FlutterNativeSelect.openSelect(
              items: [
                NativeSelectItem(value: 'item', label: ''),
              ],
              defaultValue: 'missing',
            ),
        throwsAssertionError);
  });

  test('expect to fail, when no items are given', () {
    expect(
        () => FlutterNativeSelect.openSelect(items: []), throwsAssertionError);
  });

  test('expect to fail, when all items are disabled', () {
    expect(
        () => FlutterNativeSelect.openSelect(items: [
              NativeSelectItem(value: 'item0', label: '', disabled: true),
              NativeSelectItem(value: 'item1', label: '', disabled: true)
            ]),
        throwsAssertionError);
  });

  test('check that data are correctly transferred', () async {
    final value = await FlutterNativeSelect.openSelect(
      items: [
        NativeSelectItem(
          value: 'item1',
          label: 'Item 1',
          disabled: true,
          color: color1,
        ),
        NativeSelectItem(
          value: 'item2',
          label: 'Item 2',
          color: color2,
        ),
        NativeSelectItem(
          value: 'item3',
          label: 'Item 3',
        ),
      ],
      defaultValue: 'item3',
      doneText: 'Done text',
      clearText: 'Clear text',
      title: 'Title',
    );
    final decodedValue = jsonDecode(value!);
    expect(decodedValue, {
      'items': [
        {
          'value': 'item1',
          'label': 'Item 1',
          'disabled': true,
          'color': color1.value,
        },
        {
          'value': 'item2',
          'label': 'Item 2',
          'disabled': false,
          'color': color2.value,
        },
        {
          'value': 'item3',
          'label': 'Item 3',
          'disabled': false,
          'color': null,
        },
      ],
      'defaultValue': 'item3',
      'doneText': 'Done text',
      'clearText': 'Clear text',
      'title': 'Title',
    });
  });
}
