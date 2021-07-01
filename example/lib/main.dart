import 'package:flutter/material.dart';
import 'package:flutter_native_select/flutter_native_select.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _lastResult;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text('Open select'),
                onPressed: () => FlutterNativeSelect.openSelect(
                  items: [
                    NativeSelectItem(value: 'item0', label: 'Item 0'),
                    NativeSelectItem(value: 'item1', label: 'Item 1'),
                    NativeSelectItem(value: 'item2', label: 'Item 2'),
                    NativeSelectItem(
                      value: 'disabled1',
                      label: 'Disabled item 1',
                      disabled: true,
                      color: Colors.red[900],
                    ),
                    NativeSelectItem(
                      value: 'disabled2',
                      label: 'Disabled item 2',
                      disabled: true,
                    ),
                    NativeSelectItem(
                      value: 'disabled3',
                      label: 'Disabled item 3',
                      disabled: true,
                    ),
                    NativeSelectItem(
                      value: 'blue',
                      label: 'Blue item',
                      color: Colors.blue[900],
                    ),
                  ],
                  defaultValue: _lastResult,
                  clearText: _lastResult == null ? null : 'Clear',
                ).then((value) => setState(() => _lastResult = value)),
              ),
              if (_lastResult != null) Text('Selected: $_lastResult'),
            ],
          ),
        ),
      ),
    );
  }
}
