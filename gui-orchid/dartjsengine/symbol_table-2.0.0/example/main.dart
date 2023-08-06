import 'package:symbol_table/symbol_table.dart';

void main() {
  var scope = new SymbolTable<int>();
  var symbol = scope.assign('three', 3);
  print(symbol.value); // 3
  symbol.visibility = Visibility.private;

  var child = scope.createChild();
  child.create('three', value: 4);

  print(child.resolve('three')!.value); // 4
}
