import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/core/widgets/mw_text_field.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/form_state.dart';
import 'package:mishwar/features/common/auth/presentation/cubit/name_cubit.dart';
import 'package:mishwar/features/common/auth/presentation/screens/auth_layout.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({required this.user, super.key});
  final AuthUser user;
  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<NameCubit, SubmissionState>(
    builder: (context, state) => AuthLayout(
      title: context.l10n.nameTitle,
      bottom: MwPrimaryButton(
        key: const Key('name_continue'),
        label: context.l10n.continueLabel,
        isLoading: state.isLoading,
        onPressed: state.succeeded
            ? null
            : () => context.read<NameCubit>().submit(
                widget.user,
                _first.text,
                _last.text,
              ),
      ),
      children: [
        MwTextField(
          key: const Key('first_name'),
          label: context.l10n.firstName,
          controller: _first,
          enabled: !state.isLoading,
          autofillHints: const [AutofillHints.givenName],
        ),
        SizedBox(height: AppSpacing.md),
        MwTextField(
          key: const Key('last_name'),
          label: context.l10n.lastName,
          controller: _last,
          enabled: !state.isLoading,
          autofillHints: const [AutofillHints.familyName],
        ),
        FailureText(state.failure),
      ],
    ),
  );
}
