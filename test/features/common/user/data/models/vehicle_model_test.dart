import 'package:flutter_test/flutter_test.dart';
import 'package:mishwar/features/common/user/data/models/vehicle_model.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

void main() {
  const model = VehicleModel(
    type: VehicleType.comfort,
    make: 'Toyota',
    model: 'Corolla',
    color: 'White',
    plate: '12-34567',
  );
  test('round trip and entity mapping', () {
    expect(VehicleModel.fromJson(model.toJson()), model);
    expect(VehicleModel.fromEntity(model.toEntity()), model);
    expect(model.toJson()['type'], 'comfort');
  });
  test('unknown vehicle falls back to economy', () {
    expect(
      VehicleModel.fromJson({...model.toJson(), 'type': 'future'}).type,
      VehicleType.economy,
    );
  });
}
