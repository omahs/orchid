import 'package:dartjsengine/dartjsengine.dart';
import 'package:jsparser/jsparser.dart';
import 'package:orchid/api/orchid_log.dart';

// dartjsengine depends uses jsparser
// https://github.com/anuragvohraec/dartJSEngine

class JSConfig {
  var jsEngine = JSEngine();

  JSConfig(String? js) {
    // parsejs doesn't like an empty input or statement
    if (js == null || js.trim().isEmpty) {
      js = "{}";
    }
    Program jsProgram = parsejs(js, filename: 'program.js');
    visitProgram(jsProgram, jsEngine);
  }

  // Note: This executes the program like jsEngine.visitProgram() but guards
  // Note: each statement execution, ignoring exceptions.
  JsObject? visitProgram(Program node, JSEngine jsEngine) {
    String stackName = node.filename ?? '<entry>';
    CallStack callStack = new CallStack();
    JSContext ctx = new JSContext(jsEngine.globalScope, callStack);
    callStack.push(node.filename, node.line, stackName);

    JsObject? out;
    for (var statement in node.body) {
      callStack.push(statement.filename, statement.line, stackName);
      var result;
      try {
        result = jsEngine.visitStatement(statement, ctx, stackName);
      } catch (err) {
        log("js_config: Error in user config statement: $err");
      }

      if (statement is ExpressionStatement) {
        out = result;
      }
      callStack.pop();
    }

    callStack.pop();
    return out;
  }

  bool evalBoolDefault(String expression, bool defaultValue) {
    try {
      return evalBool(expression);
    } catch (err) {
      return defaultValue;
    }
  }

  bool evalBool(String expression) {
    JsObject? val = _eval(expression);
    if (val?.valueOf is bool) {
      return val?.valueOf;
    }
    throw Exception("Expression not a boolean: $val");
  }

  int evalIntDefault(String expression, int defaultValue) {
    try {
      return evalInt(expression);
    } catch (err) {
      //log("evalIntDefault: $err");
      return defaultValue;
    }
  }
  int? evalIntDefaultNull(String expression) {
    try {
      return evalInt(expression);
    } catch (err) {
      //log("evalIntDefault: $err");
      return null;
    }
  }

  int evalInt(String expression) {
    JsObject? val = _eval(expression);
    try {
      return int.parse(val.toString());
    } catch (err) {
      throw Exception(
          "Expression not int: $val, type=${val.runtimeType}, $err");
    }
  }

  double evalDoubleDefault(String expression, double defaultValue) {
    try {
      return evalDouble(expression);
    } catch (err) {
      return defaultValue;
    }
  }

  double? evalDoubleDefaultNull(String expression) {
    try {
      return evalDouble(expression);
    } catch (err) {
      return null;
    }
  }

  double evalDouble(String expression) {
    JsObject? val = _eval(expression);
    if (val?.valueOf is double) {
      return val?.valueOf;
    }
    throw Exception("Expression not double: $val");
  }

  String evalStringDefault(String expression, String defaultValue) {
    try {
      return evalString(expression) ?? defaultValue;
    } catch (err) {
      return defaultValue;
    }
  }

  String? evalStringDefaultNullable(String expression, String? defaultValue) {
    try {
      return evalString(expression);
    } catch (err) {
      return defaultValue;
    }
  }

  String? evalStringDefaultNull(String expression) {
    try {
      return evalString(expression);
    } catch (err) {
      return null;
    }
  }

  String? evalString(String expression) {
    JsObject? val = _eval(expression);
    if (val?.valueOf is String) {
      return val?.valueOf;
    }
    throw Exception("Expression not a string: $val");
  }

  JsObject? evalObject(String expression) {
    return _eval(expression);
  }

  JsObject? _eval(String expression) {
    JsObject? val = jsEngine.visitProgram(parsejs(expression, filename: "eval"));
    return val;
  }
}
