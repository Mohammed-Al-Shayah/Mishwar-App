import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mishwar/core/l10n/l10n.dart';
import 'package:mishwar/core/theme/app_radius.dart';
import 'package:mishwar/core/theme/app_sizes.dart';
import 'package:mishwar/core/theme/app_text_styles.dart';
import 'package:mishwar/core/theme/theme_x.dart';

class MwOtpInput extends StatefulWidget {
  const MwOtpInput({required this.onChanged, this.enabled = true, super.key});
  final ValueChanged<String> onChanged;
  final bool enabled;
  @override
  State<MwOtpInput> createState() => _MwOtpInputState();
}

class _MwOtpInputState extends State<MwOtpInput> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focus = List.generate(6, (_) => FocusNode());
  void _changed(int index, String value) {
    if (value.length > 1) {
      final digits = value.characters.take(6).toList();
      for (var i = 0; i < 6; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      _focus[(digits.length - 1).clamp(0, 5)].requestFocus();
    } else if (value.isNotEmpty && index < 5) {
      _focus[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focus[index - 1].requestFocus();
    }
    widget.onChanged(_controllers.map((controller) => controller.text).join());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focus in _focus) {
      focus.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AutofillGroup(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          6,
          (index) => SizedBox(
            width: AppSizes.otpWidth,
            height: AppSizes.otpHeight,
            child: Semantics(
              label: context.l10n.otpDigit(index + 1),
              child: TextField(
                key: Key('otp_digit_$index'),
                controller: _controllers[index],
                focusNode: _focus[index],
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                expands: true,
                maxLines: null,
                style: AppTextStyles.tabular(context.textStyles.titleMedium!),
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (value) => _changed(index, value),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.buttonBorder,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.buttonBorder,
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.buttonBorder,
                    borderSide: BorderSide(
                      color: context.colors.textPrimary,
                      width: AppSizes.selectedBorder,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
