import 'package:flutter/widgets.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/l10n.dart';

String failureMessage(BuildContext context, Failure failure) {
  final l10n = context.l10n;
  return switch (failure) {
    AuthFailure(:final code) => switch (code) {
      AuthFailureCode.invalidPhone => l10n.errorInvalidPhone,
      AuthFailureCode.invalidCode => l10n.errorInvalidCode,
      AuthFailureCode.codeExpired => l10n.errorCodeExpired,
      AuthFailureCode.tooManyRequests => l10n.errorTooManyRequests,
      AuthFailureCode.network => l10n.errorNetwork,
      AuthFailureCode.quotaExceeded => l10n.errorQuota,
      AuthFailureCode.unknown => l10n.errorGeneric,
    },
    ValidationFailure(field: 'make' || 'model' || 'color') =>
      l10n.errorVehicleLength,
    ValidationFailure(field: 'plate') => l10n.errorPlateFormat,
    ValidationFailure(field: 'photo') => l10n.errorPhotoRequired,
    ValidationFailure(message: 'name-required') => l10n.errorNameRequired,
    ValidationFailure() => l10n.errorNameLength,
    NetworkFailure() => l10n.errorNetwork,
    _ => l10n.errorGeneric,
  };
}
