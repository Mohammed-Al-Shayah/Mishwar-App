import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/validation/phone_numbers.dart';

void main() {
  for (final country in PhoneCountry.values) {
    final prefixes = country == PhoneCountry.jordan
        ? ['77', '78', '79']
        : ['56', '59'];
    for (final prefix in prefixes) {
      final national = '${prefix}1234567';
      test('normalizes ${country.region} $prefix', () {
        for (final input in [
          national,
          '0$national',
          country.dialCode + national,
        ]) {
          expect(
            normalizePhone(input, country: country),
            country.dialCode + national,
          );
        }
        final arabic = String.fromCharCodes(
          '0$national'.runes.map((r) => r - 48 + 0x0660),
        );
        final persian = String.fromCharCodes(
          national.runes.map((r) => r - 48 + 0x06f0),
        );
        expect(
          normalizePhone(arabic, country: country),
          country.dialCode + national,
        );
        expect(
          normalizePhone(persian, country: country),
          country.dialCode + national,
        );
      });
    }
  }
  test('rejects unsupported countries, prefixes, whitespace and lengths', () {
    for (final value in [
      '',
      '+12025550123',
      '+962761234567',
      '+970581234567',
      '+970591234567\n',
      '+9620791234567',
      ' 0791234567',
      '079 1234567',
      '07912345678',
      '123456789',
    ]) {
      expect(normalizePhone(value), isNull, reason: value);
    }
    expect(
      normalizePhone('0591234567', country: PhoneCountry.palestine),
      '+970591234567',
    );
    expect(normalizePhone('0591234567'), isNull);
    expect(isSupportedPhone('+970591234567'), isTrue);
    expect(isSupportedPhone('+962791234567'), isTrue);
  });
  test('device region defaults', () {
    expect(PhoneCountry.fromRegion('PS'), PhoneCountry.palestine);
    for (final region in ['JO', 'US', null]) {
      expect(PhoneCountry.fromRegion(region), PhoneCountry.jordan);
    }
  });
}
