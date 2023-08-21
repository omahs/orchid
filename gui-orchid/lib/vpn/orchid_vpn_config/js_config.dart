import 'dart:convert';
import 'package:orchid/util/user_config.dart';
import 'package:flutter_js/flutter_js.dart';

class JSConfig extends UserConfig {
  final jsEngine = getJavascriptRuntime(forceJavascriptCoreOnAndroid: false);

  JSConfig(String? js) {
    // parsejs doesn't like an empty input or statement
    if (js == null || js.trim().isEmpty) {
      js = "{}";
    }
    jsEngine.evaluate(js);
  }

  dynamic evalObject(String expression) {
    return jsonDecode(jsEngine.evaluate("JSON.stringify($expression)").toString());
  }

  @override
  String? get(String expression) {
    return jsEngine.evaluate(expression).toString();
  }
}
