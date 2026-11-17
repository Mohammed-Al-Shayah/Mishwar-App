import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/maps/admin_maps_loader.dart';
import 'package:mishwar/core/theme/admin_sizes.dart';
import 'package:mishwar/core/theme/app_icons.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/features/admin/domain/admin_repository.dart';

class AdminLiveMap extends StatefulWidget {
  const AdminLiveMap({required this.drivers, super.key});
  final List<AdminEntry> drivers;
  @override
  State<AdminLiveMap> createState() => _AdminLiveMapState();
}

class _AdminLiveMapState extends State<AdminLiveMap> {
  late final Future<bool> _ready = loadAdminMaps();
  late final Future<String> _style = rootBundle.loadString(
    'assets/map_styles/light.json',
  );
  final _icons = <bool, BitmapDescriptor>{};
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (const String.fromEnvironment('MAPS_WEB_KEY').isNotEmpty) {
      unawaited(_makeIcons());
    }
  }

  Future<void> _makeIcons() async {
    final colors = context.colors;
    for (final busy in [false, true]) {
      final recorder = PictureRecorder();
      Canvas(recorder).drawCircle(
        const Offset(12, 12),
        8,
        Paint()..color = busy ? colors.textPrimary : colors.positive,
      );
      final image = await recorder.endRecording().toImage(24, 24);
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      image.dispose();
      if (mounted && bytes != null) {
        setState(
          () =>
              _icons[busy] = BitmapDescriptor.bytes(bytes.buffer.asUint8List()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: _ready,
    builder: (context, ready) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ready.data == true)
          FutureBuilder<String>(
            future: _style,
            builder: (context, style) => SizedBox(
              height: AdminSizes.map,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _center(),
                  zoom: 11,
                ),
                style: style.data,
                myLocationButtonEnabled: false,
                markers: {
                  for (final d in widget.drivers)
                    if (d.lat != null && d.lng != null)
                      Marker(
                        markerId: MarkerId(d.id),
                        position: LatLng(d.lat!, d.lng!),
                        icon: _icons[d.busy] ?? BitmapDescriptor.defaultMarker,
                        infoWindow: InfoWindow(
                          title: d.name,
                          snippet: d.busy
                              ? context.l10n.adminBusy
                              : context.l10n.adminFree,
                        ),
                      ),
                },
              ),
            ),
          )
        else if (ready.connectionState == ConnectionState.done)
          Text(
            const String.fromEnvironment('MAPS_WEB_KEY').isEmpty
                ? context.l10n.adminMapFallback
                : context.l10n.adminMapFailed,
          )
        else
          const LinearProgressIndicator(),
        for (final d in widget.drivers)
          ListTile(
            leading: Icon(
              AppIcons.mapPin,
              size: AppSizes.icon,
              color: d.busy
                  ? context.colors.textPrimary
                  : context.colors.positive,
            ),
            title: Text(d.name),
            subtitle: Text(
              '${d.lat ?? context.l10n.adminUnknown}, '
              '${d.lng ?? context.l10n.adminUnknown}',
              textDirection: TextDirection.ltr,
            ),
            trailing: Text(
              d.busy ? context.l10n.adminBusy : context.l10n.adminFree,
            ),
          ),
        if (widget.drivers.isEmpty) Text(context.l10n.adminEmpty),
      ],
    ),
  );
  LatLng _center() {
    final driver = widget.drivers
        .where((e) => e.lat != null && e.lng != null)
        .firstOrNull;
    return driver == null
        ? const LatLng(31.9539, 35.9106)
        : LatLng(driver.lat!, driver.lng!);
  }
}
