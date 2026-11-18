import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_text_field.dart';
import 'package:mishwar/features/rider/confirm/presentation/cubit/ride_confirm_cubit.dart';

Future<void> showPromoSheet(BuildContext context) async {
  final cubit = context.read<RideConfirmCubit>();
  await showModalBottomSheet<void>(
    // This sheet draws its own grabber.
    showDragHandle: false,
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(value: cubit, child: const PromoSheet()),
  );
}

class PromoSheet extends StatefulWidget {
  const PromoSheet({super.key});
  @override
  State<PromoSheet> createState() => _PromoSheetState();
}

class _PromoSheetState extends State<PromoSheet> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<RideConfirmCubit, RideConfirmState>(
        listenWhen: (previous, current) =>
            previous is RideConfirmLoaded &&
            previous.promoLoading &&
            current is RideConfirmLoaded &&
            current.promoQuote != null,
        listener: (context, state) => Navigator.of(context).pop(),
        builder: (context, state) {
          final loaded = state is RideConfirmLoaded ? state : null;
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: AppSizes.grabberWidth,
                      height: AppSizes.grabberHeight,
                      decoration: BoxDecoration(
                        color: context.colors.grabber,
                        borderRadius: AppRadius.pillBorder,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      context.l10n.promoAdd,
                      style: AppTextStyles.headline,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(height: AppSpacing.md),
                  MwTextField(
                    label: context.l10n.promoCodeLabel,
                    floatLabel: false,
                    hintText: context.l10n.promoCodeLabel,
                    controller: _controller,
                    textDirection: TextDirection.ltr,
                    autofocus: true,
                    enabled: !(loaded?.promoLoading ?? false),
                    inputFormatters: [
                      TextInputFormatter.withFunction(
                        (oldValue, newValue) => newValue.copyWith(
                          text: newValue.text.toUpperCase(),
                        ),
                      ),
                    ],
                  ),
                  if (loaded?.promoFailure != null)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Text(
                        failureMessage(context, loaded!.promoFailure!),
                        style: AppTextStyles.footnote.copyWith(
                          color: context.colors.negative,
                        ),
                      ),
                    ),
                  SizedBox(height: AppSpacing.md),
                  MwPrimaryButton(
                    label: context.l10n.promoApply,
                    isLoading: loaded?.promoLoading ?? false,
                    onPressed: () => context
                        .read<RideConfirmCubit>()
                        .applyPromo(_controller.text),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
