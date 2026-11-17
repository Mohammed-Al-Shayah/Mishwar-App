import 'package:flutter/material.dart';
import 'package:mishwar/core/theme/app_colors.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/brand_tokens.dart';
import 'package:mishwar/core/theme/theme_x.dart';

/// Original Arabic meem glyph. Foreground mode is adaptive-icon safe.
class MwLogoMark extends StatelessWidget {
  const MwLogoMark({this.foreground = false, super.key});

  final bool foreground;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: BrandTokens.iconSize,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: foreground ? null : AppColors.black,
            borderRadius: BorderRadius.circular(
              size * BrandTokens.iconRadiusFraction,
            ),
          ),
          child: FractionallySizedBox(
            widthFactor: BrandTokens.iconSafeFraction,
            heightFactor: BrandTokens.iconSafeFraction,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Transform.translate(
                  offset: Offset(0, size * BrandTokens.glyphOffsetFraction),
                  child: const FittedBox(
                    child: Text(
                      'م', // Fixed brand artwork, not localized copy.
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: size * BrandTokens.markStartFraction,
                  top: size * BrandTokens.markTopFraction,
                  child: _BrandDot(size: size * BrandTokens.markFraction),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Arabic brand artwork with a small yellow mark, in either theme.
class MwWordmark extends StatelessWidget {
  const MwWordmark({this.color, this.semanticLabel, super.key});

  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    image: true,
    excludeSemantics: true,
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: 1,
      heightFactor: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandDot(size: AppTextStyles.largeTitle.fontSize! / 6),
          Text(
            'مشوار', // The wordmark stays Arabic in every locale.
            textDirection: TextDirection.rtl,
            style: AppTextStyles.largeTitle.copyWith(
              color: color ?? context.colors.textPrimary,
            ),
          ),
        ],
      ),
    ),
  );
}

class _BrandDot extends StatelessWidget {
  const _BrandDot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: AppColors.brand,
      shape: BoxShape.circle,
    ),
  );
}
