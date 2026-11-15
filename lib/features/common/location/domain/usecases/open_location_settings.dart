import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/location/domain/repositories/location_repository.dart';

@lazySingleton
class OpenLocationSettings {
  const OpenLocationSettings(this._repository);
  final LocationRepository _repository;
  Future<void> call() => _repository.openLocationSettings();
}
