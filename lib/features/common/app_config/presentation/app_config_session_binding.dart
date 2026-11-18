import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/features/common/app_config/presentation/app_config_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';

class AppConfigSessionBinding extends StatefulWidget {
  const AppConfigSessionBinding({required this.child, super.key});
  final Widget child;
  @override
  State<AppConfigSessionBinding> createState() =>
      _AppConfigSessionBindingState();
}

class _AppConfigSessionBindingState extends State<AppConfigSessionBinding> {
  @override
  void initState() {
    super.initState();
    _sync(context.read<SessionCubit>().state);
  }

  void _sync(SessionState state) {
    final cubit = context.read<AppConfigCubit>();
    final uid = switch (state) {
      SessionReady(:final user) => user.id,
      SessionNeedsRole(:final user) => user.id,
      SessionNeedsName(:final authUser) ||
      SessionWeb(:final authUser) => authUser.uid,
      _ => null,
    };
    unawaited(uid == null ? cubit.stop() : cubit.start(uid));
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<SessionCubit, SessionState>(
        listener: (_, state) => _sync(state),
        child: widget.child,
      );
}
