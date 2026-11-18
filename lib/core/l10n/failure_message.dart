import 'package:flutter/widgets.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/l10n.dart';

String failureMessage(BuildContext context, Failure failure) {
  final l10n = context.l10n;
  return switch (failure) {
    LocationFailure(:final code) => switch (code) {
      LocationFailureCode.timeout => l10n.locationTimeout,
      LocationFailureCode.permissionDenied => l10n.locationPermissionHint,
      LocationFailureCode.serviceDisabled => l10n.locationServiceHint,
      LocationFailureCode.unknown => l10n.locationError,
    },
    AuthFailure(:final code) => switch (code) {
      AuthFailureCode.invalidPhone => l10n.errorInvalidPhone,
      AuthFailureCode.invalidCode => l10n.errorInvalidCode,
      AuthFailureCode.codeExpired => l10n.errorCodeExpired,
      AuthFailureCode.tooManyRequests => l10n.errorTooManyRequests,
      AuthFailureCode.network => l10n.errorNetwork,
      AuthFailureCode.quotaExceeded => l10n.errorQuota,
      AuthFailureCode.unknown => l10n.errorGeneric,
    },
    ValidationFailure(field: 'saved-places-limit') => l10n.savedPlaceLimit,
    ValidationFailure(field: 'saved-place') => l10n.savedPlaceInvalid,
    ValidationFailure(field: 'make' || 'model' || 'color') =>
      l10n.errorVehicleLength,
    ValidationFailure(field: 'plate') => l10n.errorPlateFormat,
    ValidationFailure(field: 'photo') => l10n.errorPhotoRequired,
    ValidationFailure(message: 'name-required') => l10n.errorNameRequired,
    ValidationFailure() => l10n.errorNameLength,
    OfferFailure(:final reason) => switch (reason) {
      OfferFailureReason.expired => l10n.offerLost,
      OfferFailureReason.notOffered => l10n.offerNotOffered,
      OfferFailureReason.driverBusy => l10n.offerDriverBusy,
    },
    SchedulingFailure() => l10n.tooManyScheduled,
    NetworkFailure() => l10n.errorNetwork,
    _ => l10n.errorGeneric,
  };
}
