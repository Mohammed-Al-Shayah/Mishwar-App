import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/mw_otp_input.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/otp_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/screens/auth_layout.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<OtpCubit, OtpState>(
    builder: (context, state) => AuthLayout(
      title: context.l10n.otpTitle,
      children: [
        Text(
          context.l10n.otpSent(_ltr(state.session.phone)),
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.xl),
        MwOtpInput(
          key: ObjectKey(state.session),
          enabled: !state.isLoading && !state.succeeded && !state.needsNewCode,
          onChanged: context.read<OtpCubit>().codeChanged,
        ),
        if (state.locked)
          Text(
            context.l10n.errorTooManyRequests,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.negative,
            ),
          ),
        if (state.needsNewCode)
          Text(
            context.l10n.otpRequestNew,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.negative,
            ),
          ),
        FailureText(state.failure),
        if (state.isLoading)
          LinearProgressIndicator(color: context.colors.textPrimary),
        TextButton(
          key: const Key('otp_resend'),
          onPressed: state.remaining > 0 || state.isLoading || state.succeeded
              ? null
              : context.read<OtpCubit>().resend,
          child: Text(
            state.remaining > 0
                ? context.l10n.resendCountdown(state.remaining)
                : context.l10n.resendCode,
            style: AppTextStyles.tabular(context.textStyles.titleSmall!),
          ),
        ),
        TextButton(
          key: const Key('otp_edit_phone'),
          onPressed: () => context.go('/auth/phone'),
          child: Text(context.l10n.editPhone),
        ),
      ],
    ),
  );
}

/// Wraps [text] in LRE…PDF so '+962…' stays left-to-right inside Arabic copy.
String _ltr(String text) =>
    '${String.fromCharCode(0x202A)}$text${String.fromCharCode(0x202C)}';
