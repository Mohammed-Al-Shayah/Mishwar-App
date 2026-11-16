import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_active_ride_id.dart';

class ActiveRideListener extends StatefulWidget {
  const ActiveRideListener({
    required this.watch,
    required this.uid,
    required this.child,
    super.key,
  });
  final WatchActiveRideId watch;
  final String uid;
  final Widget child;
  @override
  State<ActiveRideListener> createState() => _ActiveRideListenerState();
}

class _ActiveRideListenerState extends State<ActiveRideListener> {
  StreamSubscription<dynamic>? _subscription;
  @override
  void initState() {
    super.initState();
    _subscription = widget
        .watch(widget.uid)
        .listen(
          (result) => result.fold((_) {}, (id) {
            if (id == null) return;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted &&
                  GoRouter.of(
                        context,
                      ).routeInformationProvider.value.uri.path ==
                      '/rider') {
                context.go('/rider/ride/$id');
              }
            });
            WidgetsBinding.instance.ensureVisualUpdate();
          }),
        );
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
