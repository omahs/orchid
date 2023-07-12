// @dart=2.9
import 'package:orchid/orchid.dart';
import 'package:orchid/api/orchid_eth/token_type.dart';
import 'package:orchid/api/orchid_eth/tokens.dart';
import 'format_currency.dart';

final _formatCurrency = formatCurrency;

class ScalarValue<T extends num> {
  final T value;

  const ScalarValue(this.value);

  String toString() {
    return value.toString();
  }

  // Note: This is *not* locale sensitive. See NumberFormat.
  // @See formatCurrency()
  String toStringAsFixed(int len) {
    return value.toStringAsFixed(len);
  }

  bool operator ==(o) => o is ScalarValue<T> && o.value == value;

  int get hashCode => value.hashCode;
}

class USD extends ScalarValue<double> {
  static const zero = USD(0.0);

  // TODO: rebase on pennies?
  const USD(double value) : super(value);

  USD multiplyDouble(double other) {
    return USD(value * other);
  }

  USD operator +(USD other) {
    return USD(value + other.value);
  }

  USD operator -(USD other) {
    return USD(value - other.value);
  }

  USD operator *(double other) {
    return multiplyDouble(other);
  }

  USD divideDouble(double other) {
    return USD(value / other);
  }

  USD operator /(double other) {
    return divideDouble(other);
  }

  String formatCurrency(
      {@required Locale locale,
        int precision = 2,
        bool showPrefix = true,
        showSuffix = false}) {
    return (showPrefix ? '\$' : '') +
        _formatCurrency(this.value, locale: locale, precision: precision) +
        (showSuffix ? ' USD' : '');
  }

  /// convert a token amount and price to string
  static String formatUSDValue({
    BuildContext context,
    Token tokenAmount,
    USD price,
    bool showSuffix = true,
  }) {
    return ((price ?? USD.zero) * (tokenAmount ?? Tokens.TOK.zero).floatValue)
        .formatCurrency(
        locale: context.locale,
        precision: 2,
        showPrefix: false,
        showSuffix: showSuffix);
  }
}

