import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Root widget with responsive sizing and a temporary role picker.
class MishwarApp extends StatelessWidget {
  const MishwarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => const MaterialApp(
        title: 'Mishwar',
        debugShowCheckedModeBanner: false,
        home: RoleSelectPlaceholder(),
      ),
    );
  }
}

/// Temporary role picker: the single app opens in rider or driver mode.
class RoleSelectPlaceholder extends StatelessWidget {
  const RoleSelectPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mishwar'),
            SizedBox(height: 24.h),
            FilledButton(
              key: const Key('role_rider'),
              onPressed: () => _open(context, 'Rider mode'),
              child: const Text('Rider'),
            ),
            SizedBox(height: 12.h),
            OutlinedButton(
              key: const Key('role_driver'),
              onPressed: () => _open(context, 'Driver mode'),
              child: const Text('Driver'),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, String label) {
    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(label)),
          ),
        ),
      ),
    );
  }
}
