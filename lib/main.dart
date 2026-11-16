import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/app/app.dart';
import 'package:mishwar/app/bloc_observer.dart';
import 'package:mishwar/app/di/injection.dart';
import 'package:mishwar/core/firebase/firebase_bootstrap.dart';
import 'package:mishwar/features/common/notifications/data/background_handler.dart';
import 'package:mishwar/features/common/notifications/domain/push_token_sync.dart';
import 'package:mishwar/features/common/notifications/domain/usecases/watch_push_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.init();
  await configureDependencies();
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(pushBackgroundHandler);
    getIt<PushTokenSync>().start();
  }
  Bloc.observer = AppBlocObserver();
  runApp(
    MishwarApp(
      watchPushRoutes: kIsWeb ? null : getIt<WatchPushRoutes>(),
      initialPushRoute: kIsWeb ? null : getIt<GetInitialPushRoute>(),
    ),
  );
}
