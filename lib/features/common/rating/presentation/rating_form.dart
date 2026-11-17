import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_colors.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_star_rating.dart';
import 'package:mishwar/core/widgets/mw_text_field.dart';
import 'package:mishwar/features/common/rating/domain/rating_tag.dart';
import 'package:mishwar/features/common/rating/presentation/rating_cubit.dart';

class RatingForm extends StatelessWidget {
  const RatingForm({required this.name, required this.onDone, super.key});
  final String name;
  final VoidCallback onDone;
  @override
  Widget build(BuildContext context) => BlocConsumer<RatingCubit, RatingState>(
    listener: (context, state) {
      if (state.status == RatingStatus.success) onDone();
    },
    builder: (context, state) {
      final cubit = context.read<RatingCubit>();
      final busy =
          state.status == RatingStatus.submitting ||
          state.status == RatingStatus.success;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            cubit.side == RatingSide.rider
                ? context.l10n.ratingRiderTitle(name)
                : context.l10n.ratingDriverTitle(name),
            style: AppTextStyles.title2,
          ),
          SizedBox(height: AppSpacing.xl),
          MwStarRating(
            value: state.stars,
            onChanged: busy ? null : cubit.selectStars,
          ),
          if (state.stars > 0) ...[
            SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final tag in cubit.availableTags)
                  ChoiceChip(
                    label: Text(ratingTagLabel(context, tag)),
                    selected: state.tags.contains(tag),
                    showCheckmark: false,
                    selectedColor: AppColors.black,
                    labelStyle: AppTextStyles.subhead.copyWith(
                      color: state.tags.contains(tag)
                          ? AppColors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.pillBorder,
                    ),
                    onSelected: busy ? null : (_) => cubit.toggleTag(tag),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            MwTextField(
              label: context.l10n.ratingComment,
              enabled: !busy,
              inputFormatters: [LengthLimitingTextInputFormatter(300)],
              onChanged: cubit.setComment,
            ),
          ],
          if (state.failure != null) ...[
            SizedBox(height: AppSpacing.md),
            Text(
              failureMessage(context, state.failure!),
              style: AppTextStyles.body,
            ),
          ],
          SizedBox(height: AppSpacing.xl),
          MwPrimaryButton(
            label: context.l10n.ratingSubmit,
            isLoading: state.status == RatingStatus.submitting,
            onPressed: busy || state.stars == 0 ? null : cubit.submit,
          ),
          TextButton(
            onPressed: busy ? null : cubit.skip,
            child: Text(context.l10n.ratingSkip),
          ),
        ],
      );
    },
  );
}

String ratingTagLabel(BuildContext context, RatingTag tag) => switch (tag) {
  RatingTag.safeDriving => context.l10n.ratingTagSafeDriving,
  RatingTag.cleanCar => context.l10n.ratingTagCleanCar,
  RatingTag.friendly => context.l10n.ratingTagFriendly,
  RatingTag.knowsRoute => context.l10n.ratingTagKnowsRoute,
  RatingTag.late => context.l10n.ratingTagLate,
  RatingTag.fastDriving => context.l10n.ratingTagFastDriving,
  RatingTag.dirtyCar => context.l10n.ratingTagDirtyCar,
  RatingTag.longerRoute => context.l10n.ratingTagLongerRoute,
  RatingTag.onTime => context.l10n.ratingTagOnTime,
  RatingTag.respectful => context.l10n.ratingTagRespectful,
  RatingTag.rude => context.l10n.ratingTagRude,
};
