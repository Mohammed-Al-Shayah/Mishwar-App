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

  /// Map padding is supplied to MwMap; this is additional edge clearance.
  Future<void> fitBounds(List<GeoPointValue> points, double padding) {
    if (points.isEmpty) return Future.value();
    var south = points.first.lat;
    var north = south;
    var west = points.first.lng;
    var east = west;
    for (final point in points) {
      if (point.lat < south) south = point.lat;
      if (point.lat > north) north = point.lat;
      if (point.lng < west) west = point.lng;
      if (point.lng > east) east = point.lng;
    }
    if (south == north && west == east) return animateTo(points.first);
    final update = CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(south, west),
        northeast: LatLng(north, east),
      ),
      padding,
    );
    return reduceMotion
        ? _controller.moveCamera(update)
        : _controller.animateCamera(update);
  }

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
    this.polylines = const {},
    this.markers = const {},
    this.circles = const {},
    this.permissionGranted = false,
    this.padding = EdgeInsets.zero,
    this.onMapCreated,
    this.initialTarget,
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.onCameraIdle,
    this.onUserInteraction,
    this.mapBuilder,
    super.key,
  });
  final VoidCallback? onUserInteraction;
  final GeoPointValue? initialTarget;
  final VoidCallback? onCameraMoveStarted;
  final ValueChanged<GeoPointValue>? onCameraMove;
  final VoidCallback? onCameraIdle;
  final Set<Polyline> polylines;
  final Set<Marker> markers;
  final Set<Circle> circles;
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
        return Listener(
          onPointerMove: (_) => widget.onUserInteraction?.call(),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.initialTarget?.lat ?? 31.9539,
                widget.initialTarget?.lng ?? 35.9106,
              ),
              zoom: widget.initialTarget == null ? 13 : 16,
            ),
            onCameraMoveStarted: widget.onCameraMoveStarted,
            onCameraMove: (position) => widget.onCameraMove?.call(
              GeoPointValue(
                position.target.latitude,
                position.target.longitude,
              ),
            ),
            onCameraIdle: widget.onCameraIdle,
            style: snapshot
                .data![Theme.of(context).brightness == Brightness.dark ? 1 : 0],
            myLocationEnabled: widget.permissionGranted,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            padding: widget.padding,
            polylines: widget.polylines,
            markers: widget.markers,
            circles: widget.circles,
            onMapCreated: (controller) => widget.onMapCreated?.call(
              MwMapController(
                controller,
                reduceMotion: MediaQuery.disableAnimationsOf(context),
              ),
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
