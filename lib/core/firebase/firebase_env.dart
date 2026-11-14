const bool useEmulators = bool.fromEnvironment(
  'USE_EMULATORS',
  defaultValue: true,
);

String emulatorHost({required bool isAndroid, required bool isWeb}) {
  const override = String.fromEnvironment('EMULATOR_HOST');
  if (override.isNotEmpty) return override;
  return isAndroid && !isWeb ? '10.0.2.2' : 'localhost';
}

const int storageEmulatorPort = 9199;
const int authEmulatorPort = 9099;
const int firestoreEmulatorPort = 8080;
const int functionsEmulatorPort = 5001;
const String functionsRegion = 'europe-west1';
