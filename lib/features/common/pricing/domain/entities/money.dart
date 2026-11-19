import 'package:equatable/equatable.dart';

/// Currency-tagged minor units received from the server.
class Money extends Equatable {
  const Money(this.amount, [this.currency = 'JOD'])
    : assert(amount >= 0, 'Amount must be nonnegative'),
      assert(currency == 'ILS' || currency == 'JOD', 'Unsupported currency');
  final int amount;
  final String currency;
  static int scale(String currency) => switch (currency) {
    'ILS' => 100,
    'JOD' => 1000,
    _ => throw const FormatException('Unsupported currency'),
  };
  String toDisplayString() {
    final cents = currency == 'JOD' ? (amount + 5) ~/ 10 : amount;
    final symbol = currency == 'ILS' ? '\u20aa' : 'JD';
    final fraction = (cents % 100).toString().padLeft(2, '0');
    return '$symbol ${cents ~/ 100}.$fraction';
  }

  @override
  List<Object> get props => [amount, currency];
}
