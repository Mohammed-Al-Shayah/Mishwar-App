import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/features/driver/presence/presentation/bloc/driver_presence_bloc.dart';

/// Owns presence startup for both home and direct trip deep links.
class DriverShell extends StatefulWidget {
  const DriverShell({required this.uid, required this.child, super.key});
  final String uid;
  final Widget child;
  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  bool _started = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    context.read<DriverPresenceBloc>().add(
      Started(
        uid: widget.uid,
        notificationTitle: context.l10n.driverTrackingTitle,
        notificationText: context.l10n.driverTrackingText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
