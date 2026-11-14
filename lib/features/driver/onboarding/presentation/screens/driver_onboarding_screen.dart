import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_text_field.dart';
import 'package:mishwar/features/common/auth/presentation/screens/auth_layout.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';
import 'package:mishwar/features/driver/onboarding/presentation/cubit/driver_onboarding_cubit.dart';

String vehicleLabel(BuildContext context, VehicleType type) => switch (type) {
  VehicleType.economy => context.l10n.vehicleEconomy,
  VehicleType.comfort => context.l10n.vehicleComfort,
  VehicleType.van => context.l10n.vehicleVan,
};

class DriverOnboardingScreen extends StatefulWidget {
  const DriverOnboardingScreen({required this.uid, this.driver, super.key});
  final String uid;
  final DriverEntity? driver;
  @override
  State<DriverOnboardingScreen> createState() => _DriverOnboardingScreenState();
}

class _DriverOnboardingScreenState extends State<DriverOnboardingScreen> {
  late final Map<String, TextEditingController> _controllers;
  @override
  void initState() {
    super.initState();
    final vehicle = widget.driver?.vehicle;
    _controllers = {
      for (final entry in {
        'make': vehicle?.make,
        'model': vehicle?.model,
        'color': vehicle?.color,
        'plate': vehicle?.plate,
      }.entries)
        entry.key: TextEditingController(text: entry.value ?? ''),
    };
    context.read<DriverOnboardingCubit>().prefill(widget.driver);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pick() async {
    final cubit = context.read<DriverOnboardingCubit>();
    var source = ImageSource.gallery;
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      final selected = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(AppIcons.camera),
                title: Text(context.l10n.photoCamera),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(AppIcons.image),
                title: Text(context.l10n.photoGallery),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
      if (selected == null) return;
      source = selected;
    }
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted || cubit.isClosed) return;
      final extension = file.name.split('.').last.toLowerCase();
      final mime =
          file.mimeType ??
          switch (extension) {
            'png' => 'image/png',
            'webp' => 'image/webp',
            'heic' => 'image/heic',
            _ => 'image/jpeg',
          };
      cubit.photoSelected(bytes, mime);
    } on Object {
      if (mounted && !cubit.isClosed) cubit.photoFailed();
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<DriverOnboardingCubit, DriverOnboardingState>(
    builder: (context, state) {
      final cubit = context.read<DriverOnboardingCubit>();
      return AuthLayout(
        title: context.l10n.driverRegisterTitle,
        bottom: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            FailureText(state.failure),
            MwPrimaryButton(
              key: const Key('driver_submit'),
              label: context.l10n.driverSubmit,
              isLoading: state.isLoading,
              onPressed: state.succeeded
                  ? null
                  : () => cubit.submit(widget.uid),
            ),
          ],
        ),
        children: [
          Text(
            context.l10n.driverReviewTime,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            context.l10n.vehicleTypeTitle,
            style: context.textStyles.headlineSmall,
          ),
          SizedBox(height: AppSpacing.sm),
          for (final type in VehicleType.values) ...[
            Semantics(
              selected: state.type == type,
              button: true,
              child: Material(
                color: state.type == type
                    ? context.colors.fillSubtle
                    : context.colors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.vehicleRowBorder,
                  side: state.type == type
                      ? BorderSide(
                          color: context.colors.textPrimary,
                          width: AppSizes.selectedBorder,
                        )
                      : BorderSide.none,
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: state.isLoading || state.succeeded
                      ? null
                      : () => cubit.select(type),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: AppSizes.rowMinHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      child: Row(
                        children: [
                          Container(
                            width: AppSizes.iconCircle,
                            height: AppSizes.iconCircle,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colors.fill,
                            ),
                            child: const Icon(AppIcons.car),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicleLabel(context, type),
                                  style: context.textStyles.titleMedium,
                                ),
                                Text(
                                  switch (type) {
                                    VehicleType.economy =>
                                      context.l10n.vehicleEconomyDescription,
                                    VehicleType.comfort =>
                                      context.l10n.vehicleComfortDescription,
                                    VehicleType.van =>
                                      context.l10n.vehicleVanDescription,
                                  },
                                  style: context.textStyles.bodySmall?.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xs),
          ],
          SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.vehicleDetailsTitle,
            style: context.textStyles.headlineSmall,
          ),
          SizedBox(height: AppSpacing.sm),
          for (final entry in {
            'make': context.l10n.vehicleMake,
            'model': context.l10n.vehicleModel,
            'color': context.l10n.vehicleColor,
            'plate': context.l10n.vehiclePlate,
          }.entries) ...[
            MwTextField(
              key: Key('vehicle_${entry.key}'),
              label: entry.value,
              controller: _controllers[entry.key],
              enabled: !state.isLoading && !state.succeeded,
              hintText: entry.key == 'plate'
                  ? context.l10n.vehiclePlateHint
                  : null,
              textDirection: entry.key == 'plate' ? TextDirection.ltr : null,
              inputFormatters: entry.key == 'plate'
                  ? [FilteringTextInputFormatter.allow(RegExp('[0-9٠-٩-]'))]
                  : null,
              onChanged: (value) => cubit.change(entry.key, value),
            ),
            FailureText(state.errors[entry.key]),
            SizedBox(height: AppSpacing.sm),
          ],
          Text(
            context.l10n.licenseTitle,
            style: context.textStyles.headlineSmall,
          ),
          SizedBox(height: AppSpacing.sm),
          Material(
            color: context.colors.fillSubtle,
            borderRadius: AppRadius.tileBorder,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: state.isLoading || state.succeeded ? null : _pick,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    if (state.photo != null)
                      ClipRRect(
                        borderRadius: AppRadius.tileBorder,
                        child: Image.memory(
                          state.photo!,
                          height: AppSizes.licenseThumbnail,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Icon(AppIcons.image, size: AppSizes.iconCircle),
                    TextButton(
                      onPressed: state.isLoading || state.succeeded
                          ? null
                          : _pick,
                      child: Text(
                        state.photo != null || state.photoPath != null
                            ? context.l10n.photoChange
                            : context.l10n.photoChoose,
                      ),
                    ),
                    if (state.photo == null && state.photoPath != null)
                      Text(
                        context.l10n.photoSaved,
                        style: context.textStyles.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
          ),
          FailureText(state.errors['photo']),
        ],
      );
    },
  );
}
