import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mishwar/core/theme/app_radius.dart';

class MwTextField extends StatelessWidget {
  const MwTextField({
    required this.label,
    this.onChanged,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.textDirection,
    this.enabled = true,
    this.autofillHints,
    this.autofocus = false,
    this.textInputAction,
    this.suffixIcon,
    this.floatLabel = true,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    super.key,
  });
  final String label;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;

  /// False keeps the label inside the pill (placeholder-like), for
  /// single-field sheets whose title already names the field.
  final bool floatLabel;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    minLines: minLines,
    maxLines: maxLines,
    maxLength: maxLength,
    onChanged: onChanged,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    textDirection: textDirection,
    enabled: enabled,
    autofillHints: autofillHints,
    autofocus: autofocus,
    textInputAction: textInputAction,
    decoration: InputDecoration(
      labelText: label,
      floatingLabelBehavior: floatLabel ? null : FloatingLabelBehavior.never,
      hintText: hintText,
      suffixIcon: suffixIcon,
      // Pill corners suit one line; taller multi-line fields use tile corners.
      border: _multiline ? _tile : null,
      enabledBorder: _multiline ? _tile : null,
      focusedBorder: _multiline ? _tile : null,
      disabledBorder: _multiline ? _tile : null,
    ),
  );

  bool get _multiline => (maxLines ?? 2) > 1 || (minLines ?? 1) > 1;
  InputBorder get _tile => OutlineInputBorder(
    borderRadius: AppRadius.tileBorder,
    borderSide: BorderSide.none,
  );
}
