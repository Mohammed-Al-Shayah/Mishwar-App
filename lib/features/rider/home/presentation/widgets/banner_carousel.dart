import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_colors.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/features/common/app_config/domain/app_banner.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({
    required this.banners,
    required this.onAction,
    super.key,
  });
  final List<AppBanner> banners;
  final ValueChanged<AppBanner> onAction;
  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel>
    with WidgetsBindingObserver {
  final _controller = PageController();
  Timer? _timer;
  int _page = 0;
  final _touches = <int>{};
  bool _active = true;
  bool _reduced = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    _restart();
  }

  @override
  void didUpdateWidget(BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listEquals(oldWidget.banners, widget.banners)) return;
    if (_page >= widget.banners.length) {
      _page = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) _controller.jumpToPage(0);
      });
    }
    _restart();
  }

  void _restart() {
    _timer?.cancel();
    if (_reduced ||
        !_active ||
        _touches.isNotEmpty ||
        widget.banners.length < 2) {
      return;
    }
    _timer = Timer(AppSizes.bannerInterval, () {
      if (!mounted || !_controller.hasClients) return;
      unawaited(
        _controller.animateToPage(
          (_page + 1) % widget.banners.length,
          duration: AppSizes.contentDuration,
          curve: Curves.easeOutCubic,
        ),
      );
    });
  }

  void _release(PointerEvent event) {
    _touches.remove(event.pointer);
    _restart();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    _restart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Listener(
          onPointerDown: (event) {
            _touches.add(event.pointer);
            _timer?.cancel();
          },
          onPointerUp: _release,
          onPointerCancel: _release,
          child: AspectRatio(
            aspectRatio: AppSizes.bannerAspectRatio,
            child: ClipRRect(
              borderRadius: AppRadius.tileBorder,
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.banners.length,
                onPageChanged: (page) {
                  setState(() => _page = page);
                  _restart();
                },
                itemBuilder: (context, index) {
                  final banner = widget.banners[index];
                  return Semantics(
                    button: true,
                    label: banner.title,
                    child: InkWell(
                      onTap: () => widget.onAction(banner),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            banner.imageUrl,
                            fit: BoxFit.cover,
                            excludeFromSemantics: true,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                ? child
                                : ColoredBox(color: context.colors.fill),
                            errorBuilder: (context, error, stack) =>
                                ColoredBox(color: context.colors.fill),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppColors.black.withValues(
                                    alpha: AppSizes.bannerOverlayAlpha,
                                  ),
                                  AppColors.black.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  banner.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.title2.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                                Text(
                                  banner.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.footnote.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (widget.banners.length > 1)
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.banners.length; i++)
                  Semantics(
                    label: context.l10n.bannerPage(
                      i + 1,
                      widget.banners.length,
                    ),
                    selected: i == _page,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                      child: SizedBox(
                        width: AppSizes.bannerDot,
                        height: AppSizes.bannerDot,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _page
                                ? context.colors.textPrimary
                                : context.colors.grabber,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
