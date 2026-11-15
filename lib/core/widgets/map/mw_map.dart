import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';

class MwMapController {
  MwMapController(this._controller, {this.reduceMotion = false});
  final GoogleMapController _controller;
  final bool reduceMotion;
  Future<void> animateTo(GeoPointValue point, {double zoom = 16}) {
    final update = CameraUpdate.newLatLngZoom(
      LatLng(point.lat, point.lng),
      zoom,
    );
    return reduceMotion
        ? _controller.moveCamera(update)
        : _controller.animateCamera(update);
  }
}

class MwMap extends StatefulWidget {
  const MwMap({
    this.permissionGranted = false,
    this.padding = EdgeInsets.zero,
    this.onMapCreated,
    this.mapBuilder,
    super.key,
  });
  final bool permissionGranted;
  final EdgeInsets padding;
  final ValueChanged<MwMapController>? onMapCreated;

  /// Tests supply a placeholder builder so no platform map is created.
  final WidgetBuilder? mapBuilder;
  @override
  State<MwMap> createState() => _MwMapState();
}

class _MwMapState extends State<MwMap> {
  late Future<List<String>> _styles;
  @override
  void initState() {
    super.initState();
    _styles = Future.wait(
      [
        'light',
        'dark',
      ].map((name) => rootBundle.loadString('assets/map_styles/$name.json')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mapBuilder != null) return widget.mapBuilder!(context);
    if (kIsWeb) return const MwMapPlaceholder();
    return FutureBuilder<List<String>>(
      future: _styles,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const MwMapPlaceholder();
        return GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(31.9539, 35.9106),
            zoom: 13,
          ),
          style: snapshot
              .data![Theme.of(context).brightness == Brightness.dark ? 1 : 0],
          myLocationEnabled: widget.permissionGranted,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          padding: widget.padding,
          onMapCreated: (controller) => widget.onMapCreated?.call(
            MwMapController(
              controller,
              reduceMotion: MediaQuery.disableAnimationsOf(context),
            ),
          ),
        );
      },
    );
  }
}

class MwMapPlaceholder extends StatelessWidget {
  const MwMapPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.fillSubtle,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.map,
            size: AppSizes.icon,
            color: context.colors.textInactive,
          ),
          Text(
            context.l10n.mapMobileOnly,
            style: context.textStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
