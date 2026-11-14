import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/core/firebase/firebase_env.dart';

void main() {
  test('Android emulator uses the host loopback alias', () {
    expect(emulatorHost(isAndroid: true, isWeb: false), '10.0.2.2');
  });

  test('web uses localhost, including browsers on Android', () {
    expect(emulatorHost(isAndroid: false, isWeb: true), 'localhost');
    expect(emulatorHost(isAndroid: true, isWeb: true), 'localhost');
  });

  test('iOS and desktop use localhost', () {
    expect(emulatorHost(isAndroid: false, isWeb: false), 'localhost');
  });
}
