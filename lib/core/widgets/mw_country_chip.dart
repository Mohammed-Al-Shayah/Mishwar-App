import 'package:flutter/material.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/validation/phone_numbers.dart';

class MwCountryChip extends StatelessWidget {
  const MwCountryChip({
    required this.country,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });
  final PhoneCountry country;
  final ValueChanged<PhoneCountry> onChanged;
  final bool enabled;
  @override
  Widget build(BuildContext context) => Material(
    color: context.colors.fill,
    borderRadius: AppRadius.pillBorder,
    child: InkWell(
      borderRadius: AppRadius.pillBorder,
      onTap: !enabled
          ? null
          : () async {
              final selected = await showModalBottomSheet<PhoneCountry>(
                context: context,
                isScrollControlled: true,
                builder: (context) => SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            context.l10n.chooseCountry,
                            style: context.textStyles.titleSmall,
                          ),
                        ),
                        for (final option in PhoneCountry.values)
                          ListTile(
                            minTileHeight: AppSizes.rowMinHeight,
                            leading: Text(option.flag),
                            title: Text(
                              option == PhoneCountry.jordan
                                  ? context.l10n.countryJordan
                                  : context.l10n.countryPalestine,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  option.dialCode,
                                  textDirection: TextDirection.ltr,
                                ),
                                SizedBox(width: AppSpacing.sm),
                                // Marks the current choice; keeps width stable.
                                Icon(
                                  AppIcons.check,
                                  size: AppSizes.icon,
                                  color: option == country
                                      ? context.colors.textPrimary
                                      : Colors.transparent,
                                ),
                              ],
                            ),
                            selected: option == country,
                            onTap: () => Navigator.pop(context, option),
                          ),
                      ],
                    ),
                  ),
                ),
              );
              if (selected != null && context.mounted) onChanged(selected);
            },
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Text(
          '${country.flag} ${country.dialCode}',
          semanticsLabel: context.l10n.chooseCountry,
          textDirection: TextDirection.ltr,
          style: context.textStyles.titleSmall,
        ),
      ),
    ),
  );
}
