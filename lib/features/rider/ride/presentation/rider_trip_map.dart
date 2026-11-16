import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mishwar/core/geo/polyline.dart';
import 'package:mishwar/core/geo/trip_motion.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/core/widgets/map/mw_map.dart';
import 'package:mishwar/core/widgets/map/mw_map_fab.dart';
import 'package:mishwar/core/widgets/map/mw_map_markers.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/geo_point_value.dart';
import 'package:mishwar/features/rider/ride/presentation/bloc/ride_tracking_bloc.dart';

class RiderTripMap extends StatefulWidget {
  const RiderTripMap({
    required this.state,
    required this.sheetHeight,
    required this.pulse,
    this.mapBuilder,
    super.key,
  });
  final RideTrackingState state;
  final double sheetHeight;
  final Animation<double> pulse;
  final WidgetBuilder? mapBuilder;
  @override
  State<RiderTripMap> createState() => _RiderTripMapState();
}

class _RiderTripMapState extends State<RiderTripMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  MwMapController? _map;
  BitmapDescriptor? _car;
  BitmapDescriptor? _pickup;
  BitmapDescriptor? _dropoff;
  GeoPointValue? _from;
  GeoPointValue? _to;
  double _fromBearing = 0;
  double _toBearing = 0;
  bool _moved = false;
  bool _reduce = false;
  DateTime? _lastFit;
  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: AppSizes.markerDuration,
      value: 1,
    );
    _to = widget.state.driverLocation?.point;
    _toBearing = widget.state.driverLocation?.heading ?? 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.disableAnimationsOf(context);
    if (_reduce && _motion.isAnimating) _motion.value = 1;
    if (!kIsWeb && widget.mapBuilder == null && _car == null) {
      unawaited(_icons());
    }
  }

  Future<void> _icons() async {
    final ratio = MediaQuery.devicePixelRatioOf(context);
    final car = await MwMapMarkers.car(pixelRatio: ratio);
    final pickup = await MwMapMarkers.square(pickup: true, pixelRatio: ratio);
    final dropoff = await MwMapMarkers.square(pickup: false, pixelRatio: ratio);
    if (mounted) {
      setState(() {
        _car = car;
        _pickup = pickup;
        _dropoff = dropoff;
      });
    }
  }

  GeoPointValue? get _point => _from == null || _to == null
      ? _to
      : interpolatePoint(_from!, _to!, _motion.value);
  double get _bearing =>
      interpolateBearing(_fromBearing, _toBearing, _motion.value);
  @override
  void didUpdateWidget(RiderTripMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final location = widget.state.driverLocation;
    if (location != oldWidget.state.driverLocation) {
      _from = _point;
      _fromBearing = _bearing;
      _to = location?.point;
      _toBearing = location?.heading ?? _toBearing;
      if (_reduce || _from == null || _to == null) {
        _motion.value = 1;
      } else {
        unawaited(_motion.forward(from: 0));
      }
    }
    unawaited(_fit());
  }

  Future<void> _fit({bool force = false}) async {
    final ride = widget.state.ride;
    if (ride == null || _map == null || _moved) return;
    final now = DateTime.now();
    if (!force &&
        _lastFit != null &&
        now.difference(_lastFit!) < AppSizes.cameraInterval) {
      return;
    }
    _lastFit = now;
    final target = ride.status == RideStatus.inProgress
        ? ride.dropoff.location
        : ride.pickup.location;
    await _map!.fitBounds([?_to, target], AppSpacing.xl);
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      AnimatedBuilder(
        animation: Listenable.merge([_motion, widget.pulse]),
        builder: (context, _) {
          final ride = widget.state.ride;
          final trip = ride?.status == RideStatus.inProgress;
          final target = trip ? ride?.dropoff : ride?.pickup;
          final icon = trip ? _dropoff : _pickup;
          final point = _point;
          return MwMap(
            mapBuilder: widget.mapBuilder,
            padding: EdgeInsets.only(bottom: widget.sheetHeight),
            onUserInteraction: () {
              if (!_moved) setState(() => _moved = true);
            },
            onMapCreated: (map) {
              _map = map;
              unawaited(_fit(force: true));
            },
            markers: {
              if (target != null && icon != null)
                Marker(
                  markerId: const MarkerId('target'),
                  position: LatLng(target.location.lat, target.location.lng),
                  icon: icon,
                  anchor: const Offset(.5, .5),
                  infoWindow: InfoWindow(title: target.name),
                ),
              if (point != null && _car != null)
                Marker(
                  markerId: const MarkerId('driver'),
                  position: LatLng(point.lat, point.lng),
                  rotation: _bearing,
                  flat: true,
                  icon: _car!,
                  anchor: const Offset(.5, .5),
                ),
            },
            polylines: {
              if (trip && ride?.route != null)
                Polyline(
                  polylineId: const PolylineId('trip'),
                  color: context.colors.route,
                  width: AppSizes.routeWidth,
                  points: decodePolyline(
                    ride!.route!.polyline,
                  ).map((p) => LatLng(p.lat, p.lng)).toList(),
                ),
            },
            circles: {
              if (ride?.status == RideStatus.searching)
                for (var i = 0; i < 2; i++)
                  Circle(
                    circleId: CircleId('search-ring-$i'),
                    center: LatLng(
                      ride!.pickup.location.lat,
                      ride.pickup.location.lng,
                    ),
                    radius:
                        AppSizes.searchRingRadiusMeters *
                        (_reduce
                            ? (i + 1) / 2
                            : (widget.pulse.value + i / 2) % 1),
                    strokeWidth: AppSizes.routeWidth,
                    strokeColor: context.colors.textPrimary.withValues(
                      alpha: _reduce
                          ? .3
                          : 1 - (widget.pulse.value + i / 2) % 1,
                    ),
                  ),
            },
          );
        },
      ),
      if (_moved)
        Positioned(
          bottom: widget.sheetHeight + AppSpacing.md,
          right: AppSpacing.md,
          child: MwMapFab(
            icon: AppIcons.recenter,
            label: context.l10n.riderRecenter,
            onPressed: () {
              setState(() => _moved = false);
              unawaited(_fit(force: true));
            },
          ),
        ),
    ],
  );
}
