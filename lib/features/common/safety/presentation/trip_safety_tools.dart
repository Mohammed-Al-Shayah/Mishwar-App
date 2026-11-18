import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/mw_driver_card.dart';
import 'package:mishwar/core/widgets/mw_list_row.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/safety/presentation/safety_sheet.dart';
import 'package:mishwar/features/common/safety/presentation/trip_safety_cubit.dart';
import 'package:mishwar/features/common/safety/presentation/trusted_contacts_cubit.dart';
import 'package:share_plus/share_plus.dart';

typedef TripShareLauncher = Future<void> Function(String text, Rect origin);
Future<void> shareTripText(String text, Rect origin) async {
  await SharePlus.instance.share(
    ShareParams(text: text, sharePositionOrigin: origin),
  );
}

Future<void> shareSafetyTrip(
  BuildContext context,
  RideEntity ride, {
  TripShareLauncher share = shareTripText,
}) async {
  final cubit = context.read<TripSafetyCubit>();
  final box = context.findRenderObject()! as RenderBox;
  final origin = box.localToGlobal(Offset.zero) & box.size;
  final url = await cubit.shareLink(ride.id);
  if (!context.mounted) return;
  if (url == null) {
    if (cubit.state.failure != null) _error(context);
    return;
  }
  try {
    await share(
      context.l10n.shareTripText(ride.driverInfo?.name ?? '', url),
      origin,
    );
  } on Object {
    if (context.mounted) _error(context);
  }
}

void _error(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(context.l10n.errorGeneric)),
);

Uri safetySmsUri(Iterable<String> phones, String body) => Uri(
  scheme: 'sms',
  path: phones.join(','),
  query: 'body=${Uri.encodeComponent(body)}',
);

Future<void> showTripSafety(
  BuildContext context, {
  required RiderUriLauncher launcher,
  RideEntity? ride,
  bool driver = false,
  TripShareLauncher share = shareTripText,
}) => safetySheet<void>(
  context,
  context.l10n.safetyToolkit,
  MultiBlocProvider(
    providers: [
      BlocProvider.value(value: context.read<TrustedContactsCubit>()),
      BlocProvider.value(value: context.read<TripSafetyCubit>()),
    ],
    child: _Tools(launcher: launcher, ride: ride, driver: driver, share: share),
  ),
);

class _Tools extends StatelessWidget {
  const _Tools({
    required this.launcher,
    required this.ride,
    required this.driver,
    required this.share,
  });
  final RiderUriLauncher launcher;
  final RideEntity? ride;
  final bool driver;
  final TripShareLauncher share;
  Future<void> _launch(BuildContext context, Uri uri) async {
    try {
      if (!await launcher(uri) && context.mounted) _error(context);
    } on Object {
      if (context.mounted) _error(context);
    }
  }

  Future<void> _emergency(BuildContext context) async {
    final confirmed = await safetySheet<bool>(
      context,
      context.l10n.emergencyCall,
      Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.l10n.emergencyConfirm),
            SizedBox(height: AppSpacing.md),
            MwPrimaryButton(
              label: context.l10n.accountConfirm,
              onPressed: () => Navigator.pop(context, true),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.accountCancel),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      await _launch(context, Uri(scheme: 'tel', path: '911'));
    }
  }

  Future<void> _sms(BuildContext context) async {
    final contacts = context.read<TrustedContactsCubit>().state.contacts;
    if (contacts.isEmpty) return;
    final cubit = context.read<TripSafetyCubit>();
    if (!driver && ride?.shareToken != null && cubit.state.url == null) {
      await cubit.shareLink(ride!.id);
    }
    final point = await cubit.position();
    if (point == null || !context.mounted) return;
    final coordinates = '${point.lat},${point.lng}';
    final vehicle = ride?.driverInfo?.vehicle;
    var body = driver
        ? context.l10n.safetyDriverSmsBody(coordinates)
        : context.l10n.safetySmsBody(
            ride?.driverInfo?.name ?? '',
            vehicle == null
                ? ''
                : '${vehicle.make} ${vehicle.model} ${vehicle.color}',
            vehicle?.plate ?? '',
            coordinates,
          );
    if (!driver && cubit.state.url != null) body += '\n${cubit.state.url}';
    await _launch(
      context,
      safetySmsUri(contacts.map((contact) => contact.phone), body),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<TrustedContactsCubit, TrustedContactsState>(
    builder: (context, contacts) =>
        BlocBuilder<TripSafetyCubit, TripSafetyState>(
          builder: (context, state) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                minTileHeight: AppSizes.rowMinHeight,
                leading: CircleAvatar(
                  radius: AppSizes.iconCircle / 2,
                  backgroundColor: context.colors.fill,
                  child: Icon(
                    AppIcons.phone,
                    size: AppSizes.icon,
                    color: context.colors.negative,
                  ),
                ),
                title: Text(
                  context.l10n.emergencyCall,
                  style: context.textStyles.titleMedium,
                ),
                onTap: () => _emergency(context),
              ),
              MwListRow(
                icon: AppIcons.mapPin,
                title: context.l10n.safetySms,
                subtitle: contacts.contacts.isEmpty
                    ? context.l10n.safetyNoContacts
                    : '',
                onTap:
                    contacts.loading || contacts.contacts.isEmpty || state.busy
                    ? null
                    : () => _sms(context),
              ),
              if (!driver && ride != null)
                MwListRow(
                  icon: AppIcons.share,
                  title: context.l10n.safetyShare,
                  subtitle: '',
                  onTap: state.busy
                      ? null
                      : () => shareSafetyTrip(context, ride!, share: share),
                ),
              if (state.busy || contacts.loading)
                const LinearProgressIndicator(),
              if (state.failure != null || contacts.failure != null)
                Text(
                  failureMessage(context, state.failure ?? contacts.failure!),
                  style: TextStyle(color: context.colors.negative),
                ),
            ],
          ),
        ),
  );
}
