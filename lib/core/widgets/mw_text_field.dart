import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MwTextField extends StatelessWidget {
  const MwTextField({
    required this.label,
    this.onChanged,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.textDirection,
    this.enabled = true,
    this.autofillHints,
    super.key,
  });
  final String label;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;
  final bool enabled;
  final Iterable<String>? autofillHints;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    textDirection: textDirection,
    enabled: enabled,
    autofillHints: autofillHints,
    decoration: InputDecoration(labelText: label),
  );
}
