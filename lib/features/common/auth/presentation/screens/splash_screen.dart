import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/widgets/mw_logo.dart';
import 'package:mishwar/features/common/auth/presentation/screens/auth_layout.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/session/session_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: BlocBuilder<SessionCubit, SessionState>(
            builder: (context, state) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MwWordmark(semanticLabel: context.l10n.appName),
                if (state case SessionError(:final failure)) ...[
                  FailureText(failure),
                  TextButton(
                    key: const Key('session_retry'),
                    onPressed: context.read<SessionCubit>().retry,
                    child: Text(context.l10n.retryLabel),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
