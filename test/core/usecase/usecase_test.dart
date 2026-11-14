import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/usecase/usecase.dart';

void main() {
  test('NoParams instances are equal with matching hash codes', () {
    // A constructor tear-off creates distinct instances for value equality.
    const create = NoParams.new;
    final first = create();
    final second = create();

    expect(first, equals(second));
    expect(first.hashCode, second.hashCode);
    expect(first.props, isEmpty);
  });
}
