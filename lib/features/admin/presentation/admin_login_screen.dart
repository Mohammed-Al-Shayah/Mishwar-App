import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/admin_sizes.dart';
import 'package:mishwar/core/theme/admin_theme.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/widgets/mw_primary_button.dart';
import 'package:mishwar/features/admin/presentation/admin_cubit.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({this.denied = false, super.key});
  final bool denied;
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AdminTheme.light(),
    child: Scaffold(
      body: Center(
        child: SizedBox(
          width: AdminSizes.login,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: BlocBuilder<AdminLoginCubit, AdminLoginState>(
              builder: (context, state) => Form(
                key: _form,
                child: AutofillGroup(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.l10n.appName,
                        style: AppTextStyles.largeTitle,
                      ),
                      SizedBox(height: AppSpacing.xl),
                      Text(
                        widget.denied
                            ? context.l10n.adminDenied
                            : context.l10n.adminSignIn,
                        style: AppTextStyles.title1,
                      ),
                      if (!widget.denied) ...[
                        SizedBox(height: AppSpacing.xl),
                        TextFormField(
                          controller: _email,
                          decoration: InputDecoration(
                            labelText: context.l10n.adminEmail,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username],
                          textDirection: TextDirection.ltr,
                          validator: (value) =>
                              value != null && value.contains('@')
                              ? null
                              : context.l10n.adminError,
                        ),
                        SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _password,
                          decoration: InputDecoration(
                            labelText: context.l10n.adminPassword,
                          ),
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          validator: (value) =>
                              value != null && value.isNotEmpty
                              ? null
                              : context.l10n.adminError,
                          onFieldSubmitted: (_) => _submit(context),
                        ),
                      ],
                      if (state.failed)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          child: Text(context.l10n.adminError),
                        ),
                      SizedBox(height: AppSpacing.xl),
                      MwPrimaryButton(
                        label: widget.denied
                            ? context.l10n.adminSignOut
                            : context.l10n.adminSignIn,
                        isLoading: state.loading,
                        onPressed: () => widget.denied
                            ? context.read<AdminLoginCubit>().signOut()
                            : _submit(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  void _submit(BuildContext context) {
    if (_form.currentState!.validate()) {
      unawaited(
        context.read<AdminLoginCubit>().signIn(_email.text, _password.text),
      );
    }
  }
}
