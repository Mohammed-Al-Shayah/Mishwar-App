import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/role_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/screens/auth_layout.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({required this.user, super.key});
  final UserEntity user;
  @override
  Widget build(BuildContext context) => BlocBuilder<RoleCubit, RoleState>(
    builder: (context, state) => AuthLayout(
      title: context.l10n.appName,
      wordmark: true,
      bottom: MwPrimaryButton(
        key: const Key('role_continue'),
        label: context.l10n.continueLabel,
        isLoading: state.isLoading,
        onPressed: state.role == null || state.succeeded
            ? null
            : () => context.read<RoleCubit>().submit(user.id),
      ),
      children: [
        Text(context.l10n.roleTitle, style: context.textStyles.headlineMedium),
        SizedBox(height: AppSpacing.xl),
        for (final role in UserRole.values) ...[
          Semantics(
            selected: state.role == role,
            button: true,
            child: Material(
              color: state.role == role
                  ? context.colors.fillSubtle
                  : context.colors.background,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.vehicleRowBorder,
                side: state.role == role
                    ? BorderSide(
                        color: context.colors.textPrimary,
                        width: AppSizes.selectedBorder,
                      )
                    : BorderSide.none,
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: Key('role_${role.name}'),
                onTap: state.isLoading || state.succeeded
                    ? null
                    : () => context.read<RoleCubit>().select(role),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: AppSizes.rowMinHeight),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: AppSizes.iconCircle,
                          height: AppSizes.iconCircle,
                          decoration: BoxDecoration(
                            color: context.colors.fill,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            role == UserRole.rider
                                ? AppIcons.person
                                : AppIcons.car,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role == UserRole.rider
                                    ? context.l10n.roleRider
                                    : context.l10n.roleDriver,
                                style: context.textStyles.titleMedium,
                              ),
                              SizedBox(height: AppSpacing.xxs),
                              Text(
                                role == UserRole.rider
                                    ? context.l10n.roleRiderSubtitle
                                    : context.l10n.roleDriverSubtitle,
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
          SizedBox(height: AppSpacing.sm),
        ],
        FailureText(state.failure),
      ],
    ),
  );
}
