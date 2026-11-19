import 'package:flutter/material.dart';
import 'package:mishwar/core/l10n/l10n.dart';

class MarketSwitcher extends StatelessWidget {
  const MarketSwitcher({
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;
  @override
  Widget build(BuildContext context) => SegmentedButton<String>(
    segments: [
      ButtonSegment(value: 'PS', label: Text(context.l10n.marketPalestine)),
      ButtonSegment(value: 'JO', label: Text(context.l10n.marketJordan)),
    ],
    selected: {value},
    onSelectionChanged: enabled ? (values) => onChanged(values.single) : null,
  );
}
