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
    __dartjs_sendMessage('upper', JSON.stringify('hello'));
    """,
      sourceUrl: '<eval>',
    );
    var res = jsResult.rawResult;
    expect(res, equals('HELLO'));
  });

  test('Test Map', () {
    final JavascriptRuntime javascriptRuntime =
        getJavascriptRuntime(forceJavascriptCoreOnAndroid: false);

    javascriptRuntime.onMessage('get_map', (obj) {
      return {'key': 'value'};
    });
    JsEvalResult jsResult = javascriptRuntime.evaluate(
      """// js
    __dartjs_sendMessage('get_map', JSON.stringify({}));
    """,
      sourceUrl: '<eval>',
    );
    var res = jsResult.rawResult;
    expect(res, equals({'key': 'value'}));
  });
}
