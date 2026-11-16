import 'package:equatable/equatable.dart';

enum LocationFailureCode { timeout, permissionDenied, serviceDisabled, unknown }

final class LocationFailure extends Failure {
  const LocationFailure(this.code) : super('location');
  final LocationFailureCode code;
  @override
  List<Object> get props => [code];
}

enum AuthFailureCode {
  invalidPhone,
  invalidCode,
  codeExpired,
  tooManyRequests,
  network,
  quotaExceeded,
  unknown;

  static AuthFailureCode fromFirebaseCode(String? code) => switch (code) {
    'invalid-phone-number' => invalidPhone,
    'invalid-verification-code' => invalidCode,
    'session-expired' => codeExpired,
    'too-many-requests' => tooManyRequests,
    'network-request-failed' => network,
    'quota-exceeded' => quotaExceeded,
    _ => unknown,
  };
}

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

final class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message, {this.code = AuthFailureCode.unknown});

  final AuthFailureCode code;

  @override
  List<Object> get props => [message, code];
}

final class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [this.code = 'invalid']);
  String get field => message;
  final String code;
  @override
  List<Object> get props => [field, code];
}

final class ActiveRideFailure extends Failure {
  const ActiveRideFailure(this.activeRideId) : super('active-ride');
  final String activeRideId;
  @override
  List<Object> get props => [activeRideId];
}
