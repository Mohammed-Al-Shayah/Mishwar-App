import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/widgets/mw_bottom_nav.dart';

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
      if (value == 2) context.go('/rider/account');
    },
  );
}
