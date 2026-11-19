import 'package:flutter/services.dart';
import 'package:mishwar/core/validation/phone_numbers.dart';

List<TextInputFormatter> phoneFormatters() => [
  TextInputFormatter.withFunction(
    (oldValue, newValue) =>
        newValue.copyWith(text: westernDigits(newValue.text)),
  ),
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(10),
];
