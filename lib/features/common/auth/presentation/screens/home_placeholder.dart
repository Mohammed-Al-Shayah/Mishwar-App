import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/theme_x.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/form_state.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/home_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/screens/auth_layout.dart';

class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({required this.title, super.key});
  final String title;
  @override
  Widget build(BuildContext context) => BlocBuilder<HomeCubit, SubmissionState>(
    builder: (context, state) => AuthLayout(
      title: title,
      children: [
        Text(context.l10n.comingSoon, style: context.textStyles.bodyLarge),
        FailureText(state.failure),
        TextButton(
          key: const Key('sign_out'),
          onPressed: state.isLoading ? null : context.read<HomeCubit>().signOut,
          child: Text(context.l10n.signOutLabel),
        ),
      ],
    ),
  );
}
