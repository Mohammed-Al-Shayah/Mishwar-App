import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_colors.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/theme_x.dart';

class MwStarRating extends StatelessWidget {
  const MwStarRating({required this.value, required this.onChanged, super.key});
  final int value;
  final ValueChanged<int>? onChanged;
  @override
  Widget build(BuildContext context) {
    final size = AppSizes.ratingControlStar;
    final gap = AppSpacing.xs;
    final width = size * 5 + gap * 4;
    void select(int stars) {
      if (onChanged == null || stars == value) return;
      unawaited(HapticFeedback.selectionClick());
      onChanged!(stars);
    }

    void position(Offset p) {
      final x = Directionality.of(context) == TextDirection.rtl
          ? width - p.dx
          : p.dx;
      select((x / (size + gap)).floor().clamp(0, 4) + 1);
    }

    return Align(
      child: Semantics(
        label: context.l10n.ratingStars(value),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: onChanged == null
              ? null
              : (d) => position(d.localPosition),
          onHorizontalDragUpdate: onChanged == null
              ? null
              : (d) => position(d.localPosition),
          child: SizedBox(
            width: width,
            child: Row(
              children: [
                for (var i = 1; i <= 5; i++) ...[
                  if (i > 1) SizedBox(width: gap),
                  Semantics(
                    button: true,
                    selected: value >= i,
                    label: context.l10n.ratingStars(i),
                    onTap: onChanged == null ? null : () => select(i),
                    child: ExcludeSemantics(
                      child: GestureDetector(
                        key: ValueKey('mw_star_$i'),
                        onTap: onChanged == null ? null : () => select(i),
                        // Selected stars are filled so the choice reads at a
                        // glance; unselected stay as light outlines.
                        child: value >= i
                            ? CustomPaint(
                                size: Size.square(size),
                                painter: _FilledStarPainter(
                                  context.colors.textPrimary,
                                ),
                              )
                            : Icon(
                                AppIcons.star,
                                size: size,
                                color: AppColors.grey300,
                              ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A five-point star with rounded joins, sized like the Phosphor outline star.
class _FilledStarPainter extends CustomPainter {
  const _FilledStarPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = size.shortestSide * 0.42;
    final inner = outer * 0.48;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point =
          center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas
      ..drawPath(path, Paint()..color = color)
      ..drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = size.shortestSide * 0.07,
      );
  }

  @override
  bool shouldRepaint(_FilledStarPainter old) => old.color != color;
}

/// Read-only stars (e.g. receipts): `value` filled, the rest light outlines.
class MwStarDisplay extends StatelessWidget {
  const MwStarDisplay({
    required this.value,
    required this.size,
    this.count = 5,
    super.key,
  });
  final int count;
  final int value;
  final double size;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 1; i <= count; i++)
        value >= i
            ? CustomPaint(
                size: Size.square(size),
                painter: _FilledStarPainter(context.colors.textPrimary),
              )
            : Icon(AppIcons.star, size: size, color: AppColors.grey300),
    ],
  );
}
