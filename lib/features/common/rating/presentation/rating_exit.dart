import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';
import 'package:mishwar/features/common/rating/domain/rating_tag.dart';
import 'package:mishwar/features/common/rating/presentation/rating_cubit.dart';

class RatingExit extends StatelessWidget {
  const RatingExit({required this.child, super.key});
  final Widget child;
  static void finish(BuildContext context) {
    final cubit = context.read<RatingCubit>();
    final session = context.read<SessionCubit>().state;
    if (cubit.state.status != RatingStatus.success ||
        session is! SessionReady) {
      return;
    }
    final pending = cubit.side == RatingSide.rider
        ? session.user.pendingRatingRideId
        : session.driver?.pendingRatingRideId;
    if (pending != cubit.rideId) {
      context.go(cubit.side == RatingSide.rider ? '/rider' : '/driver');
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<SessionCubit, SessionState>(
        listener: (context, _) => finish(context),
        child: child,
      );
}
