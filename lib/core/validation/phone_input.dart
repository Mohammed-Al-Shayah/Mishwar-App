import 'package:flutter/services.dart';

List<TextInputFormatter> jordanPhoneFormatters() => [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(10),
];
