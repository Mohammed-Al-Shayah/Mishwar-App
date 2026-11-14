import 'package:flutter/material.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/features/common/auth/presentation/screens/home_placeholder.dart';

class RiderHomePlaceholder extends StatelessWidget {
  const RiderHomePlaceholder({super.key});
  @override
  Widget build(BuildContext context) =>
      HomePlaceholder(title: context.l10n.riderMode);
}
