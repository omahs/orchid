
abstract class UserConfig {
  bool evalBoolDefault(String expression, bool defaultValue);

  bool evalBool(String expression);

  int evalIntDefault(String expression, int defaultValue);

  int? evalIntDefaultNull(String expression);

  int evalInt(String expression);

  double evalDoubleDefault(String expression, double defaultValue);

  double? evalDoubleDefaultNull(String expression);

  double evalDouble(String expression);

  String evalStringDefault(String expression, String defaultValue);

  String? evalStringDefaultNullable(String expression, String? defaultValue);

  String? evalStringDefaultNull(String expression);

  String? evalString(String expression);
}

class MapUserConfig implements UserConfig {
  final Map<String, String> map;

  MapUserConfig(this.map);

  bool evalBoolDefault(String expression, bool defaultValue) {
    try {
      return evalBool(expression);
    } catch (err) {
      return defaultValue;
    }
  }

  bool evalBool(String expression) {
    var val = _eval(expression);
    if (val?.toLowerCase() == 'true') {
      return true;
    }
    if (val?.toLowerCase() == 'false') {
      return false;
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
    var val = _eval(expression);
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
    var val = _eval(expression);
    try {
      return double.parse(val!);
    } catch (err) {
      throw Exception("Expression not double: $val, $err");
    }
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
    return _eval(expression);
  }

  String? _eval(String expression) {
    return map[expression];
  }
}
