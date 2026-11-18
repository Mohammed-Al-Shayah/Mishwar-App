import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/app/di/injection.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/presentation/parcel_tools_cubit.dart';

class ParcelCodeCard extends StatelessWidget {
  const ParcelCodeCard({required this.ride, required this.launcher, super.key});
  final RideEntity ride;
  final Future<bool> Function(Uri) launcher;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ParcelToolsCubit>()..watch(ride.id),
    child: BlocBuilder<ParcelToolsCubit, ParcelToolsState>(
      builder: (context, state) => Container(
        margin: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.fill,
          borderRadius: AppRadius.tileBorder,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.code case final code?) ...[
              Text(context.l10n.parcelCode(code), style: AppTextStyles.title2),
              TextButton(
                onPressed: () async {
                  var opened = false;
                  try {
                    final message = Uri.encodeComponent(
                      context.l10n.parcelSms(code),
                    );
                    opened = await launcher(
                      Uri(
                        scheme: 'sms',
                        path: ride.parcel!.recipientPhone,
                        query: 'body=$message',
                      ),
                    );
                  } on Object {
                    opened = false;
                  }
                  if (!opened && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.errorGeneric)),
                    );
                  }
                },
                child: Text(context.l10n.parcelSendCode),
              ),
            ] else if (state.failure != null) ...[
              Text(failureMessage(context, state.failure!)),
              TextButton(
                onPressed: () =>
                    context.read<ParcelToolsCubit>().watch(ride.id),
                child: Text(context.l10n.retryLabel),
              ),
            ] else
              const LinearProgressIndicator(),
          ],
        ),
      ),
    ),
  );
}

class ParcelPhotoButton extends StatelessWidget {
  const ParcelPhotoButton({
    required this.rideId,
    required this.launcher,
    super.key,
  });
  final String rideId;
  final Future<bool> Function(Uri) launcher;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ParcelToolsCubit>(),
    child: BlocConsumer<ParcelToolsCubit, ParcelToolsState>(
      listener: (context, state) async {
        if (state.url case final url?) {
          var opened = false;
          try {
            opened = await launcher(url);
          } on Object {
            opened = false;
          }
          if (!opened && context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(context.l10n.errorGeneric)));
          }
        }
      },
      builder: (context, state) => Column(
        children: [
          TextButton(
            onPressed: state.busy
                ? null
                : () => context.read<ParcelToolsCubit>().photo(rideId),
            child: Text(context.l10n.parcelPhoto),
          ),
          if (state.busy) const LinearProgressIndicator(),
          if (state.failure != null)
            Text(
              failureMessage(context, state.failure!),
              style: AppTextStyles.footnote.copyWith(
                color: context.colors.negative,
              ),
            ),
        ],
      ),
    ),
  );
}
