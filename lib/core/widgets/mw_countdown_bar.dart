import 'package:flutter/material.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/theme_x.dart';

/// Smoothly interpolates server deadline updates, then continues to zero.
class MwCountdownBar extends StatelessWidget {
  const MwCountdownBar({
    required this.remaining,
    this.total = const Duration(seconds: 15),
    super.key,
  });
  final Duration remaining;
  final Duration total;
  @override
  Widget build(BuildContext context) {
    final progress = total.inMicroseconds <= 0
        ? 0.0
        : (remaining.inMicroseconds / total.inMicroseconds).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      key: ValueKey(remaining),
      tween: Tween(begin: progress, end: 0),
      duration: remaining > Duration.zero ? remaining : Duration.zero,
      builder: (context, value, _) => SizedBox(
        width: double.infinity,
        height: AppSizes.countdownHeight,
        child: CustomPaint(
          painter: _CountdownPainter(
            value,
            context.colors.textPrimary,
            context.colors.fill,
            Directionality.of(context),
          ),
        ),
      ),
    );
  }
}

class _CountdownPainter extends CustomPainter {
  const _CountdownPainter(
    this.progress,
    this.foreground,
    this.track,
    this.direction,
  );
  final double progress;
  final Color foreground;
  final Color track;
  final TextDirection direction;
  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..drawRect(Offset.zero & size, Paint()..color = track)
      ..drawRect(
        Rect.fromLTWH(
          direction == TextDirection.rtl ? size.width * (1 - progress) : 0,
          0,
          size.width * progress,
          size.height,
        ),
        Paint()..color = foreground,
      );
  }

  @override
  bool shouldRepaint(_CountdownPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      foreground != oldDelegate.foreground ||
      track != oldDelegate.track ||
      direction != oldDelegate.direction;
}
