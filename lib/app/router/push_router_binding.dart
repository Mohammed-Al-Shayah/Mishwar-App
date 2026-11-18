import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/notifications/domain/usecases/watch_push_routes.dart';

class PushRouterBinding {
  PushRouterBinding(
    this._router,
    WatchPushRoutes watch,
    GetInitialPushRoute initial,
  ) {
    _subscription = watch(const NoParams()).listen((result) {
      result.fold((_) {}, _navigate);
    }, onError: (Object _) {});
    unawaited(_initial(initial));
  }
  final GoRouter _router;
  late final StreamSubscription<dynamic> _subscription;
  bool _disposed = false;
  void _navigate(String route) {
    if (!_disposed &&
        (route == '/driver' ||
            RegExp(
              r'^/(rider|driver)/support/[A-Za-z0-9_-]{1,128}$',
            ).hasMatch(route))) {
      _router.go(route);
    }
  }

  Future<void> _initial(GetInitialPushRoute initial) async {
    final result = await initial(const NoParams());
    result.fold((_) {}, (route) {
      if (route != null) _navigate(route);
    });
  }

  void dispose() {
    _disposed = true;
    unawaited(_subscription.cancel());
  }
}
