import 'package:flutter/material.dart';

/// Placeholder root widget. T0.2/T0.3 replace this with
/// ScreenUtilInit + MaterialApp.router + localization.
class MishwarApp extends StatelessWidget {
  const MishwarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mishwar',
      debugShowCheckedModeBanner: false,
      home: RoleSelectPlaceholder(),
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
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('role_rider'),
              onPressed: () => _open(context, 'Rider mode'),
              child: const Text('Rider'),
            ),
            const SizedBox(height: 12),
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text(label)),
        ),
      ),
    );
  }
}
