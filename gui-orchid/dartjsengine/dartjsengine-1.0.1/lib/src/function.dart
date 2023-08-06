import 'package:jsparser/jsparser.dart';
import 'package:dartjsengine/dartjsengine.dart';
import 'package:symbol_table/symbol_table.dart';

/// The Dart function that is responsible for the logic of a given [JsFunction].
typedef JsObject? JsFunctionCallback(
    JSEngine jsengine, JsArguments arguments, JSContext ctx);

class JsFunction extends JsObject {
  final JsObject? Function(JSEngine, JsArguments, JSContext) f;
  final JsObject? context;
  SymbolTable<JsObject>? closureScope;
  Node? declaration;

  JsFunction(this.context, this.f) {
    typeof = 'function';
    properties['length'] = new JsNumber(0);
    properties['name'] = new JsString('anonymous');
    properties['prototype'] = new JsObject();
  }

  bool get isAnonymous {
    return properties['name'] == null ||
        properties['name'].toString() == 'anonymous';
  }

  String? get name {
    if (isAnonymous) {
      return '(anonymous function)';
    } else {
      return properties['name'].toString();
    }
  }

  void set name(String? value) => properties['name'] = new JsString(value ?? '');

  @override
  JsObject? getProperty(name, JSEngine jsengine, JSContext ctx) {
    if (name is JsString) {
      return getProperty(name.valueOf, jsengine, ctx);
    } else if (name == 'apply') {
      return wrapFunction((samurai, arguments, ctx) {
        var a1 = arguments.getProperty(1.0, samurai, ctx);
        var args = a1 is JsArray ? a1.valueOf : <JsObject>[];
        return samurai.invoke(this, args,
            arguments.valueOf.isEmpty ? ctx : ctx.bind(arguments.valueOf[0]));
      }, this, 'call');
    } else if (name == 'bind') {
      return wrapFunction(
          (_, arguments, ctx) => bind(
              arguments.getProperty(0.0, jsengine, ctx) ?? ctx.scope.context),
          this,
          'bind');
    } else if (name == 'call') {
      return wrapFunction((samurai, arguments, ctx) {
        JsObject? thisCtx = arguments.getProperty(0.0, samurai, ctx) ??
            ((arguments.valueOf.isNotEmpty ? arguments.valueOf[0] : null) ??
                ctx.scope.context);
        if (thisCtx == null) {
          throw Exception('thisCxt is null');
        }
        return samurai.invoke(this.bind(thisCtx),
            arguments.valueOf.skip(1).toList(), ctx.bind(thisCtx));
      }, this, 'call');
    } else if (name == 'constructor') {
      return JsFunctionConstructor.singleton;
    } else {
      return super.getProperty(name, jsengine, ctx);
    }
  }

  JsFunction bind(JsObject? newContext) {
    if (newContext == null) return bind(new JsNull());

    var ff = new JsFunction(newContext, f)
      ..properties.addAll(properties)
      ..closureScope = closureScope?.fork()
      ..declaration = declaration;

    if (isAnonymous || name == null)
      ff.name = 'bound ';
    else
      ff.name = 'bound $name';

    return ff;
  }

  @override
  String toString() {
    return isAnonymous ? '[Function]' : '[Function: $name]';
  }
}

class JsConstructor extends JsFunction {
  JsConstructor(JsObject context,
      JsObject Function(JSEngine, JsArguments, JSContext) f)
      : super(context, f);
}
