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
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/form_state.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/home_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/screens/auth_layout.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/user/domain/entities/driver_entity.dart';
import 'package:mishwar/features/driver/onboarding/presentation/screens/driver_onboarding_screen.dart';

class DriverPendingScreen extends StatelessWidget {
  const DriverPendingScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<SessionCubit, SessionState>(
    builder: (context, session) {
      if (session is! SessionReady || session.driver == null) {
        return const SizedBox.shrink();
      }
      final driver = session.driver!;
      final rejected = driver.status == DriverStatus.rejected;
      final suspended = driver.status == DriverStatus.suspended;
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: AppSizes.statusCircle,
                              height: AppSizes.statusCircle,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.colors.fill,
                              ),
                              child: Icon(AppIcons.clock, size: AppSizes.icon),
                            ),
                          ),
                          SizedBox(height: AppSpacing.xl),
                          Text(
                            rejected
                                ? context.l10n.driverRejectedTitle
                                : suspended
                                ? context.l10n.driverSuspendedTitle
                                : context.l10n.driverPendingTitle,
                            textAlign: TextAlign.center,
                            style: context.textStyles.headlineMedium,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            rejected
                                ? driver.rejectionReason ??
                                      context.l10n.driverRejectedBody
                                : suspended
                                ? context.l10n.driverSuspendedBody
                                : context.l10n.driverPendingBody,
                            textAlign: TextAlign.center,
                            style: context.textStyles.bodySmall?.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xl),
                          Container(
                            padding: EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: context.colors.fillSubtle,
                              borderRadius: AppRadius.tileBorder,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicleLabel(context, driver.vehicle.type),
                                  style: context.textStyles.titleMedium,
                                ),
                                SizedBox(height: AppSpacing.xs),
                                Text(
                                  context.l10n.vehicleSummary(
                                    driver.vehicle.make,
                                    driver.vehicle.model,
                                    driver.vehicle.color,
                                  ),
                                  style: context.textStyles.bodySmall,
                                ),
                                SizedBox(height: AppSpacing.xs),
                                Text(
                                  driver.vehicle.plate,
                                  textDirection: TextDirection.ltr,
                                  style: AppTextStyles.tabular(
                                    context.textStyles.titleLarge!,
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
                if (rejected)
                  MwPrimaryButton(
                    label: context.l10n.driverResubmit,
                    onPressed: () => context.go('/driver/onboarding'),
                  ),
                // TODO(T5.2): Add mode switching for immutable roles.
                BlocBuilder<HomeCubit, SubmissionState>(
                  builder: (context, state) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FailureText(state.failure),
                      TextButton(
                        key: const Key('sign_out'),
                        onPressed: state.isLoading
                            ? null
                            : context.read<HomeCubit>().signOut,
                        child: Text(context.l10n.signOutLabel),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
