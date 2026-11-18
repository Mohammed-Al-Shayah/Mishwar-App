import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/features/admin/domain/admin_repository.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';

String adminTitle(BuildContext context, AdminSection section) =>
    switch (section) {
      AdminSection.overview => context.l10n.adminOverview,
      AdminSection.drivers => context.l10n.adminDrivers,
      AdminSection.rides => context.l10n.adminRides,
      AdminSection.map => context.l10n.adminMap,
      AdminSection.pricing => context.l10n.adminPricing,
      AdminSection.content => context.l10n.adminContent,
    };
String adminStatus(BuildContext context, String? value) => switch (value) {
  'pending' => context.l10n.adminPending,
  'approved' => context.l10n.adminApproved,
  'suspended' => context.l10n.adminSuspended,
  'rejected' => context.l10n.adminRejected,
  'searching' => context.l10n.adminSearching,
  'accepted' => context.l10n.adminAccepted,
  'arriving' => context.l10n.adminArriving,
  'arrived' => context.l10n.adminArrived,
  'in_progress' => context.l10n.adminInProgress,
  'completed' => context.l10n.adminCompleted,
  'cancelled' => context.l10n.adminCancelled,
  'no_drivers' => context.l10n.adminNoDrivers,
  _ => context.l10n.adminAll,
};
String adminDate(BuildContext context, DateTime? date) => date == null
    ? context.l10n.adminUnknown
    : DateFormat.yMMMd(
        Localizations.localeOf(context).languageCode,
      ).add_Hm().format(date.toLocal());
String adminMoney(BuildContext context, int? fils) => fils == null
    ? context.l10n.adminUnknown
    : context.l10n.fareJod(Money(fils).toJodString());
String adminEvent(BuildContext context, String event) => switch (event) {
  'createdAt' => context.l10n.adminApplied,
  'acceptedAt' => context.l10n.adminAccepted,
  'arrivingAt' => context.l10n.adminArriving,
  'arrivedAt' => context.l10n.adminArrived,
  'startedAt' => context.l10n.adminInProgress,
  'completedAt' => context.l10n.adminCompleted,
  'cancelledAt' => context.l10n.adminCancelled,
  _ => context.l10n.adminTime,
};
