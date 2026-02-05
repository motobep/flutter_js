import 'dart:io';

import 'package:flutter_js/javascript_runtime.dart';

import './extensions/handle_promises.dart';
import './quickjs/quickjs_runtime2.dart';

export './extensions/handle_promises.dart';

export './quickjs/quickjs_runtime2.dart';
export 'javascript_runtime.dart';
export 'js_eval_result.dart';

JavascriptRuntime getJavascriptRuntime({
  bool forceJavascriptCoreOnAndroid = false,
  bool xhr = true,
  Map<String, dynamic>? extraArgs = const {},
}) {
  JavascriptRuntime runtime;
  if ((Platform.isAndroid && !forceJavascriptCoreOnAndroid)) {
    int stackSize = extraArgs?['stackSize'] ?? 1024 * 1024;
    runtime = QuickJsRuntime2(stackSize: stackSize);
  } else {
    runtime = QuickJsRuntime2();
  }
  runtime.enableHandlePromises();
  return runtime;
}
