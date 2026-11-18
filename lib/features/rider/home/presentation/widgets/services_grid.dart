import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/features/common/app_config/domain/app_service.dart';
import 'package:mishwar/features/common/app_config/presentation/app_config_cubit.dart';

String serviceTitle(BuildContext context, ServiceId id) => switch (id) {
  ServiceId.ride => context.l10n.serviceRide,
  ServiceId.schedule => context.l10n.serviceSchedule,
  ServiceId.parcel => context.l10n.serviceParcel,
  ServiceId.airport => context.l10n.serviceAirport,
};
String serviceDescription(BuildContext context, ServiceId id) => switch (id) {
  ServiceId.ride => context.l10n.serviceRideDescription,
  ServiceId.schedule => context.l10n.serviceScheduleDescription,
  ServiceId.parcel => context.l10n.serviceParcelDescription,
  ServiceId.airport => context.l10n.serviceAirportDescription,
};
void serviceComingSoon(BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.serviceSoonMessage),
        duration: const Duration(seconds: 2),
      ),
    );

class ServicesGrid extends StatelessWidget {
  const ServicesGrid({
    required this.services,
    required this.onService,
    this.onAll,
    this.full = false,
    super.key,
  });
  final List<AppService> services;
  final ValueChanged<ServiceId> onService;
  final VoidCallback? onAll;
  final bool full;
  @override
  Widget build(BuildContext context) {
    final sorted = List<AppService>.of(services)
      ..sort((a, b) {
        final order = a.order.compareTo(b.order);
        return order == 0 ? a.id.index.compareTo(b.id.index) : order;
      });
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!full)
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.servicesSuggestions,
                  style: AppTextStyles.title2,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size(AppSizes.iconCircle, AppSizes.iconCircle),
                ),
                onPressed: onAll,
                child: Text(context.l10n.servicesAll),
              ),
            ],
          ),
        if (full)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            mainAxisExtent: _fullTileHeight(context),
            children: [for (final service in sorted) _tile(context, service)],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final service in sorted)
                SizedBox(
                  width: AppSizes.serviceTile,
                  child: _tile(context, service),
                ),
            ],
          ),
      ],
    );
  }

  double _fullTileHeight(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    double line(TextStyle style) =>
        scaler.scale(style.fontSize!) * style.height!;
    return AppSpacing.md * 2 +
        AppSizes.serviceGlyph +
        AppSpacing.xxs * 3 +
        line(AppTextStyles.caption) +
        line(AppTextStyles.subhead) +
        line(AppTextStyles.footnote);
  }

  Widget _tile(BuildContext context, AppService service) => Semantics(
    button: true,
    label: service.enabled
        ? serviceTitle(context, service.id)
        : '${serviceTitle(context, service.id)}, ${context.l10n.serviceSoon}',
    child: InkWell(
      key: ValueKey('service_${service.id.name}'),
      borderRadius: AppRadius.tileBorder,
      onTap: () =>
          service.enabled ? onService(service.id) : serviceComingSoon(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: full ? null : AppSizes.serviceTile,
            width: full ? double.infinity : AppSizes.serviceTile,
            padding: full
                ? EdgeInsets.all(AppSpacing.md)
                : EdgeInsets.all(AppSpacing.xxs),
            decoration: BoxDecoration(
              color: context.colors.fill,
              borderRadius: AppRadius.tileBorder,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  switch (service.id) {
                    ServiceId.ride => AppIcons.car,
                    ServiceId.schedule => AppIcons.calendar,
                    ServiceId.parcel => AppIcons.package,
                    ServiceId.airport => AppIcons.airplane,
                  },
                  size: AppSizes.serviceGlyph,
                  color: service.enabled
                      ? context.colors.textPrimary
                      : context.colors.textInactive,
                ),
                if (!service.enabled)
                  Padding(
                    padding: EdgeInsets.only(top: AppSpacing.xxs),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: AppRadius.pillBorder,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxs,
                        ),
                        child: Text(
                          context.l10n.serviceSoon,
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            serviceTitle(context, service.id),
            style: AppTextStyles.subhead,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (full)
            Text(
              serviceDescription(context, service.id),
              style: AppTextStyles.footnote.copyWith(
                color: context.colors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    ),
  );
}

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.contentServices)),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: BlocBuilder<AppConfigCubit, AppConfigState>(
        builder: (context, state) => ServicesGrid(
          services: state.services,
          full: true,
          onService: (id) {
            if (context.canPop()) {
              context.pop(id);
            } else {
              context.go('/rider', extra: id);
            }
          },
        ),
      ),
    ),
  );
}
