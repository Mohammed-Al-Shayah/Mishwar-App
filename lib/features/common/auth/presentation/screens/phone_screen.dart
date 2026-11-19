import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/validation/phone_input.dart';
import 'package:mishwar/core/widgets/mw_country_chip.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_text_field.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/phone_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/screens/auth_layout.dart';

class PhoneScreen extends StatelessWidget {
  const PhoneScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocConsumer<PhoneCubit, PhoneState>(
    listenWhen: (previous, current) =>
        current.session != null && previous.session != current.session,
    listener: (context, state) {
      if (!state.session!.autoVerified) {
        context.go('/auth/otp', extra: state.session);
      }
    },
    builder: (context, state) => AuthLayout(
      title: context.l10n.phoneTitle,
      bottom: MwPrimaryButton(
        key: const Key('phone_continue'),
        label: context.l10n.continueLabel,
        isLoading: state.isLoading,
        onPressed: state.normalizedPhone == null || state.remaining > 0
            ? null
            : context.read<PhoneCubit>().submit,
      ),
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              MwCountryChip(
                country: state.country,
                enabled: !state.isLoading,
                onChanged: context.read<PhoneCubit>().countryChanged,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: MwTextField(
                  key: const Key('phone_field'),
                  label: context.l10n.phoneLabel,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  enabled: !state.isLoading,
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  inputFormatters: phoneFormatters(),
                  onChanged: context.read<PhoneCubit>().phoneChanged,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          context.l10n.smsFootnote,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        if (state.locked)
          Text(
            context.l10n.errorTooManyRequests,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.negative,
            ),
          )
        else if (state.remaining > 0)
          Text(
            context.l10n.resendCountdown(state.remaining),
            style: AppTextStyles.tabular(context.textStyles.titleSmall!),
          ),
        FailureText(state.failure),
      ],
    ),
  );
}
