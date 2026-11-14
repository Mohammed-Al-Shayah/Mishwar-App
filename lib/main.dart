import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/app/app.dart';
import 'package:mishwar/app/bloc_observer.dart';
import 'package:mishwar/app/di/injection.dart';
import 'package:mishwar/core/firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.init();
  await configureDependencies();
  Bloc.observer = AppBlocObserver();
  runApp(const MishwarApp());
}
