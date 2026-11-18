import 'package:cloud_functions/cloud_functions.dart';
import 'package:mishwar/core/error/failures.dart';

Failure callableFailure(Object error) {
  if (error is FirebaseFunctionsException && error.details is Map) {
    final details = error.details as Map;
    final reason = details['reason'];
    if (const [
      'not-found',
      'inactive',
      'not-started',
      'expired',
      'limit-reached',
      'user-limit',
      'first-ride-only',
      'min-fare',
      'rate-limit',
    ].contains(reason)) {
      final minFare = details['minFare'];
      return PromoFailure(
        reason as String,
        minFareFils: minFare is num ? (minFare * 1000).round() : null,
      );
    }
  }
  return switch (error) {
    FirebaseFunctionsException(code: 'invalid-argument') =>
      const ValidationFailure('invalid-argument'),
    FirebaseFunctionsException(
      code: 'unavailable' || 'deadline-exceeded' || 'network-request-failed',
    ) =>
      const NetworkFailure('unavailable'),
    FirebaseFunctionsException(:final code) => ServerFailure(code),
    _ => const ServerFailure('invalid-response'),
  };
}
