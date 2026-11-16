import 'package:equatable/equatable.dart';

/// JOD stored as integer fils, without floating-point currency arithmetic.
class Money extends Equatable {
  const Money(this.amount) : assert(amount >= 0, 'Amount must be nonnegative');
  final int amount;
  String toJodString() {
    final piastres = (amount + 5) ~/ 10;
    return '${piastres ~/ 100}.${(piastres % 100).toString().padLeft(2, '0')}';
  }

  @override
  List<Object> get props => [amount];
}
