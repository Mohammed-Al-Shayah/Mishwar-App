/// Supported mobile destinations. National numbers contain nine digits.
enum PhoneCountry {
  jordan('JO', '+962', '🇯🇴', '7[789][0-9]{7}'),
  palestine('PS', '+970', '🇵🇸', '5[69][0-9]{7}');

  const PhoneCountry(this.region, this.dialCode, this.flag, this.pattern);
  final String region;
  final String dialCode;
  final String flag;
  final String pattern;
  static PhoneCountry fromRegion(String? region) =>
      region?.toUpperCase() == 'PS' ? palestine : jordan;
}

String westernDigits(String input) => String.fromCharCodes(
  input.runes.map(
    (r) => switch (r) {
      >= 0x0660 && <= 0x0669 => r - 0x0660 + 48,
      >= 0x06f0 && <= 0x06f9 => r - 0x06f0 + 48,
      _ => r,
    },
  ),
);

/// Accepts national input (optional trunk 0) or an allowed E.164 number.
String? normalizePhone(
  String input, {
  PhoneCountry country = PhoneCountry.jordan,
}) {
  var number = westernDigits(input);
  var selectedCountry = country;
  if (number.startsWith('+')) {
    final countries = PhoneCountry.values.where(
      (c) => number.startsWith(c.dialCode),
    );
    if (countries.isEmpty) return null;
    selectedCountry = countries.first;
    number = number.substring(selectedCountry.dialCode.length);
  } else if (number.startsWith('0')) {
    number = number.substring(1);
  }
  if (number.length != 9 || !RegExp(selectedCountry.pattern).hasMatch(number)) {
    return null;
  }
  return selectedCountry.dialCode + number;
}

bool isSupportedPhone(String input) =>
    input.startsWith('+') && normalizePhone(input) == input;
