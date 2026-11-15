import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/location/domain/repositories/location_repository.dart';

@lazySingleton
class OpenAppSettings {
  const OpenAppSettings(this._repository);
  final LocationRepository _repository;
  Future<void> call() => _repository.openAppSettings();
}
