import 'package:flutter_js/flutter_js.dart';
import 'package:test/test.dart';

void main() {
  test('Test evaluate and onMessage', () {
    final JavascriptRuntime javascriptRuntime =
        getJavascriptRuntime(forceJavascriptCoreOnAndroid: false);

    javascriptRuntime.onMessage('upper', (obj) {
      return (obj as String).toUpperCase();
    });
    JsEvalResult jsResult = javascriptRuntime.evaluate(
      """// js
    sendMessage('upper', JSON.stringify('hello'));
    """,
      sourceUrl: '<eval>',
    );
    var res = jsResult.stringResult;
    expect(res, equals('HELLO'));
  });
}
