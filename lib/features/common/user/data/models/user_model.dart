// Freezed forwards annotations to generated fields.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/core/firebase/converters.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  @JsonSerializable(explicitToJson: true)
  const factory UserModel({
    @JsonKey(includeToJson: false) required String id,
    required String name,
    required String phone,
    @TimestampConverter() required DateTime createdAt,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    UserRole? role,
    String? photoUrl,
    @Default(5.0) double rating,
    @Default(0) int ratingCount,
    String? fcmToken,
  }) = _UserModel;
  const UserModel._();
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  factory UserModel.fromFirestore(FirestoreDocument snapshot) =>
      UserModel.fromJson({
        ...snapshot.data() ?? <String, dynamic>{},
        'id': snapshot.id,
      });
  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    id: entity.id,
    name: entity.name,
    phone: entity.phone,
    role: entity.role,
    photoUrl: entity.photoUrl,
    rating: entity.rating,
    ratingCount: entity.ratingCount,
    createdAt: entity.createdAt,
  );
  UserEntity toEntity() => UserEntity(
    id: id,
    name: name,
    phone: phone,
    role: role,
    photoUrl: photoUrl,
    rating: rating,
    ratingCount: ratingCount,
    createdAt: createdAt,
  );
}
