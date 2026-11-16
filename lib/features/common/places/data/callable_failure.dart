import 'package:cloud_functions/cloud_functions.dart';
import 'package:mishwar/core/error/failures.dart';

Failure callableFailure(Object error) => switch (error) {
  FirebaseFunctionsException(code: 'invalid-argument') =>
    const ValidationFailure('invalid-argument'),
  FirebaseFunctionsException(
    code: 'unavailable' || 'deadline-exceeded' || 'network-request-failed',
  ) =>
    const NetworkFailure('unavailable'),
  FirebaseFunctionsException(:final code) => ServerFailure(code),
  _ => const ServerFailure('invalid-response'),
};
