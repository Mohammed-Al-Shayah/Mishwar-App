import 'package:flutter/material.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/l10n/failure_message.dart';
import 'package:mishwar/core/theme/app_spacing.dart';
import 'package:mishwar/core/theme/theme_x.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    required this.title,
    required this.children,
    this.bottom,
    this.wordmark = false,
    super.key,
  });
  final String title;
  final bool wordmark;
  final List<Widget> children;
  final Widget? bottom;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: wordmark
                          ? context.textStyles.displayLarge
                          : context.textStyles.headlineMedium,
                    ),
                    SizedBox(height: wordmark ? AppSpacing.xxl : AppSpacing.xl),
                    ...children,
                  ],
                ),
              ),
            ),
            if (bottom != null) ...[SizedBox(height: AppSpacing.md), bottom!],
          ],
        ),
      ),
    ),
  );
}

class FailureText extends StatelessWidget {
  const FailureText(this.failure, {super.key});
  final Failure? failure;
  @override
  Widget build(BuildContext context) => failure == null
      ? const SizedBox.shrink()
      : Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Text(
            failureMessage(context, failure!),
            key: const Key('failure_message'),
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.negative,
            ),
          ),
        );
}
