import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
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
    ),
  );
}
