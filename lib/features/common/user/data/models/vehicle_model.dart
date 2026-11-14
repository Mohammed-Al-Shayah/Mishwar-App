// Freezed forwards annotations to generated fields.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/core/firebase/converters.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

part 'vehicle_model.freezed.dart';
part 'vehicle_model.g.dart';

@freezed
abstract class VehicleModel with _$VehicleModel {
  @JsonSerializable(explicitToJson: true)
  const factory VehicleModel({
    @JsonKey(unknownEnumValue: VehicleType.economy) required VehicleType type,
    required String make,
    required String model,
    required String color,
    required String plate,
  }) = _VehicleModel;
  const VehicleModel._();
  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);
  factory VehicleModel.fromFirestore(FirestoreDocument snapshot) =>
      VehicleModel.fromJson({
        ...snapshot.data() ?? <String, dynamic>{},
      });
  factory VehicleModel.fromEntity(VehicleEntity entity) => VehicleModel(
    type: entity.type,
    make: entity.make,
    model: entity.model,
    color: entity.color,
    plate: entity.plate,
  );
  VehicleEntity toEntity() => VehicleEntity(
    type: type,
    make: make,
    model: model,
    color: color,
    plate: plate,
  );
}
