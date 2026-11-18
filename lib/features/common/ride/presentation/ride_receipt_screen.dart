import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/app_theme.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/mw_list_row.dart';
import 'package:mishwar/core/widgets/mw_star_rating.dart';
import 'package:mishwar/core/widgets/trip_stops.dart';
import 'package:mishwar/features/common/pricing/domain/entities/money.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/presentation/fee_widgets.dart';
import 'package:mishwar/features/common/ride/presentation/history_widgets.dart';
import 'package:mishwar/features/common/ride/presentation/promo_discount_row.dart';
import 'package:mishwar/features/common/ride/presentation/ride_receipt_cubit.dart';
import 'package:share_plus/share_plus.dart';

class RideReceiptScreen extends StatelessWidget {
  const RideReceiptScreen({
    required this.rideId,
    this.driver = false,
    super.key,
  });
  final String rideId;
  final bool driver;
  @override
  Widget build(BuildContext context) => driver
      ? Theme(
          data: AppTheme.dark(),
          child: _Receipt(rideId: rideId, driver: true),
        )
      : _Receipt(rideId: rideId, driver: false);
}

class _Receipt extends StatelessWidget {
  const _Receipt({required this.rideId, required this.driver});
  final String rideId;
  final bool driver;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.receiptTitle)),
    body: BlocBuilder<RideReceiptCubit, RideReceiptState>(
      builder: (context, state) {
        final ride = state.ride;
        if (state.failure != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(failureMessage(context, state.failure!)),
                TextButton(
                  onPressed: () =>
                      context.read<RideReceiptCubit>().load(rideId),
                  child: Text(context.l10n.retryLabel),
                ),
              ],
            ),
          );
        }
        if (ride == null) {
          return Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: const HistorySkeleton(),
          );
        }
        return RideReceiptContent(ride: ride, driver: driver);
      },
    ),
  );
}

class RideReceiptContent extends StatelessWidget {
  const RideReceiptContent({
    required this.ride,
    this.driver = false,
    super.key,
  });
  final RideEntity ride;
  final bool driver;
  @override
  Widget build(BuildContext context) {
    final party = driver ? ride.riderInfo : ride.driverInfo;
    final vehicle = ride.driverInfo?.vehicle;
    final rating = driver ? ride.riderRating : ride.driverRating;
    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          historyDate(context, ride.createdAt),
          style: AppTextStyles.tabular(AppTextStyles.footnote),
        ),
        SizedBox(height: AppSpacing.md),
        TripStops(ride: ride),
        if (ride.parcel case final parcel?) ...[
          SizedBox(height: AppSpacing.md),
          Text(context.l10n.parcelRecipient, style: AppTextStyles.footnote),
          Text(parcel.recipientName, style: AppTextStyles.headline),
          Text(parcel.description, style: AppTextStyles.body),
        ],
        SizedBox(height: AppSpacing.lg),
        if (party != null) Text(party.name, style: AppTextStyles.headline),
        if (vehicle != null) ...[
          Text(
            context.l10n.receiptVehicle(
              vehicle.make,
              vehicle.model,
              vehicle.color,
            ),
            style: AppTextStyles.body,
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              vehicle.plate,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.tabular(AppTextStyles.title2),
            ),
          ),
        ],
        if (rating != null) ...[
          SizedBox(height: AppSpacing.md),
          Text(context.l10n.receiptYourRating, style: AppTextStyles.footnote),
          Semantics(
            label: context.l10n.receiptStars(rating),
            child: ExcludeSemantics(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: MwStarDisplay(value: rating, size: AppSizes.icon),
              ),
            ),
          ),
        ],
        SizedBox(height: AppSpacing.lg),
        if (ride.status == RideStatus.noDrivers)
          Text(context.l10n.historyNoDrivers, style: AppTextStyles.body)
        else ...[
          if (ride.status != RideStatus.cancelled)
            _fareRow(
              context,
              context.l10n.receiptFare,
              context.l10n.fareJod(
                Money(
                  (ride.fareFinalFils ?? ride.fareEstimatedFils) -
                      ride.fareWaitingFeeFils -
                      ride.farePreviousBalanceFils +
                      (ride.promoApplied == true ? ride.discountFils : 0),
                ).toJodString(),
              ),
            ),
          PromoDiscountRow(ride: ride),
          FareFeeRows(ride: ride),
          _fareRow(
            context,
            context.l10n.receiptPayment,
            context.l10n.cashPayment,
            price: false,
          ),
          Divider(height: AppSpacing.xl),
          _fareRow(
            context,
            context.l10n.receiptTotal,
            ridePrice(context, ride),
            total: true,
          ),
        ],
        if (ride.status == RideStatus.cancelled)
          Text(
            receiptCancellation(context, ride),
            style: AppTextStyles.footnote.copyWith(
              color: context.colors.negative,
            ),
          ),
        SizedBox(height: AppSpacing.md),
        MwListRow(
          icon: AppIcons.warning,
          title: context.l10n.receiptReport,
          subtitle: '',
          onTap: () => context.push(
            '/${driver ? 'driver' : 'rider'}/support/new?rideId=${Uri.encodeQueryComponent(ride.id)}',
          ),
        ),
        Builder(
          builder: (rowContext) => MwListRow(
            icon: AppIcons.share,
            title: context.l10n.receiptShare,
            subtitle: '',
            onTap: () async {
              final box = rowContext.findRenderObject()! as RenderBox;
              try {
                await SharePlus.instance.share(
                  ShareParams(
                    text: receiptText(context, ride),
                    sharePositionOrigin:
                        box.localToGlobal(Offset.zero) & box.size,
                  ),
                );
              } on Object {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.errorGeneric)),
                  );
                }
              }
            },
          ),
        ),
        if (!driver) ...[
          SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: () => context.push('/rider/confirm', extra: ride.draft),
            child: Text(context.l10n.receiptRebook),
          ),
        ],
      ],
    );
  }

  Widget _fareRow(
    BuildContext context,
    String label,
    String value, {
    bool total = false,
    bool price = true,
  }) => Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: total ? AppTextStyles.title2 : AppTextStyles.body,
          ),
        ),
        Text(
          value,
          textDirection: price ? TextDirection.ltr : null,
          style: AppTextStyles.tabular(
            total ? AppTextStyles.title2 : AppTextStyles.headline,
          ),
        ),
      ],
    ),
  );
}

String receiptCancellation(BuildContext context, RideEntity ride) =>
    switch (ride.cancelledBy) {
      'rider' => context.l10n.receiptCancelledRider,
      'driver' => context.l10n.receiptCancelledDriver,
      _ => context.l10n.receiptCancelledSystem,
    };

/// Same server fare components as the visible receipt, shared as plain text.
String receiptText(BuildContext context, RideEntity ride) {
  final l = context.l10n;
  String amount(int fils) => l.fareJod(Money(fils).toJodString());
  final lines = [
    l.receiptTitle,
    historyDate(context, ride.createdAt),
    l.historyRoute(ride.pickup.name, ride.dropoff.name),
  ];
  if (ride.status == RideStatus.noDrivers) {
    return [...lines, l.historyNoDrivers].join('\n');
  }
  if (ride.status == RideStatus.cancelled) {
    lines.add(receiptCancellation(context, ride));
  } else {
    final base =
        (ride.fareFinalFils ?? ride.fareEstimatedFils) -
        ride.fareWaitingFeeFils -
        ride.farePreviousBalanceFils +
        (ride.promoApplied == true ? ride.discountFils : 0);
    lines.add(
      '${l.receiptFare}: ${amount(base)}',
    );
  }
  if (ride.promoApplied == true && ride.discountFils > 0) {
    lines.add(
      l.promoDiscount(
        ride.promoCode ?? '',
        Money(ride.discountFils).toJodString(),
      ),
    );
  }
  for (final (label, value) in [
    (l.feeWaiting, ride.fareWaitingFeeFils),
    (l.feePreviousBalance, ride.farePreviousBalanceFils),
    if (ride.status == RideStatus.cancelled)
      (l.feeCancellation, ride.fareCancellationFeeFils),
  ]) {
    if (value > 0) lines.add('$label: ${amount(value)}');
  }
  return [
    ...lines,
    '${l.receiptTotal}: ${ridePrice(context, ride)}',
    '${l.receiptPayment}: ${l.cashPayment}',
  ].join('\n');
}
