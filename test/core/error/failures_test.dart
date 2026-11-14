import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/error/failures.dart';

void main() {
  final factories = <String, Failure Function(String)>{
    'ServerFailure': ServerFailure.new,
    'NetworkFailure': NetworkFailure.new,
    'AuthFailure': AuthFailure.new,
    'CacheFailure': CacheFailure.new,
    'UnexpectedFailure': UnexpectedFailure.new,
  };

  for (final entry in factories.entries) {
    group(entry.key, () {
      test('same messages are equal with matching hash codes', () {
        final first = entry.value('failure');
        final second = entry.value('failure');

        expect(first, equals(second));
        expect(first.hashCode, second.hashCode);
        expect(first.message, 'failure');
      });

      test('different messages are unequal', () {
        expect(entry.value('first'), isNot(equals(entry.value('second'))));
      });
    });
  }

  test('different failure types with the same message are unequal', () {
    expect(
      const ServerFailure('failure'),
      isNot(equals(const NetworkFailure('failure'))),
    );
  });
}
