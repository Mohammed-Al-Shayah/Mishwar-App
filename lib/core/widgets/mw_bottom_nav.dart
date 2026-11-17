import 'package:flutter/material.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';

class MwBottomNav extends StatelessWidget {
  const MwBottomNav({required this.index, required this.onTap, super.key});
  final int index;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: AppSizes.bottomNavHeight,
    child: BottomNavigationBar(
      currentIndex: index,
      onTap: onTap,
      backgroundColor: context.colors.background,
      elevation: 0,
      selectedItemColor: context.colors.textPrimary,
      unselectedItemColor: context.colors.textInactive,
      selectedLabelStyle: AppTextStyles.caption,
      unselectedLabelStyle: AppTextStyles.caption,
      iconSize: AppSizes.icon,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(AppIcons.map),
          label: context.l10n.navHome,
        ),
        BottomNavigationBarItem(
          icon: const Icon(AppIcons.clock),
          label: context.l10n.historyTitle,
        ),
        BottomNavigationBarItem(
          icon: const Icon(AppIcons.user),
          label: context.l10n.navAccount,
        ),
      ],
    ),
  );
}
