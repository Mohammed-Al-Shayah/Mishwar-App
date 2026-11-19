// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  role: $enumDecodeNullable(
    _$UserRoleEnumMap,
    json['role'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  pendingRatingRideId: json['pendingRatingRideId'] as String?,
  photoUrl: json['photoUrl'] as String?,
  rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
  ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
  balanceDueMinor: (json['balanceDueFils'] as num?)?.toInt() ?? 0,
  balanceDue:
      (json['balanceDue'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  homeMarket: json['homeMarket'] as String?,
  fcmToken: json['fcmToken'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'role': _$UserRoleEnumMap[instance.role],
      'photoUrl': instance.photoUrl,
      'rating': instance.rating,
      'ratingCount': instance.ratingCount,
      'fcmToken': instance.fcmToken,
    };

const _$UserRoleEnumMap = {UserRole.rider: 'rider', UserRole.driver: 'driver'};
