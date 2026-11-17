import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/widgets/mw_bottom_nav.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/home_cubit.dart';

class RiderBottomNav extends StatelessWidget {
  const RiderBottomNav({required this.index, super.key});
  final int index;
  @override
  Widget build(BuildContext context) => MwBottomNav(
    index: index,
    onTap: (value) async {
      if (value == index) return;
      if (value == 0) {
        context.go('/rider');
      }
      if (value == 1) {
        context.go('/rider/history');
        return;
      }
      if (value == 2) {
        final home = context.read<HomeCubit>();
        await showModalBottomSheet<void>(
          context: context,
          builder: (sheetContext) => SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: TextButton(
                onPressed: () async {
                  Navigator.pop(sheetContext);
                  await home.signOut();
                },
                child: Text(sheetContext.l10n.signOutLabel),
              ),
            ),
          ),
        );
      }
    },
  );
}
