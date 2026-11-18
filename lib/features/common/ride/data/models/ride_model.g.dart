// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RidePlaceModel _$RidePlaceModelFromJson(Map<String, dynamic> json) =>
    _RidePlaceModel(
      name: json['name'] as String,
      address: json['address'] as String,
      geopoint: const GeoPointConverter().fromJson(
        json['geopoint'] as GeoPoint,
      ),
    );

Map<String, dynamic> _$RidePlaceModelToJson(_RidePlaceModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'geopoint': const GeoPointConverter().toJson(instance.geopoint),
    };

_RideFareModel _$RideFareModelFromJson(Map<String, dynamic> json) =>
    _RideFareModel(
      estimated: (json['estimated'] as num).toDouble(),
      currency: json['currency'] as String,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      cancellationFee: (json['cancellationFee'] as num?)?.toDouble() ?? 0,
      waitingFee: (json['waitingFee'] as num?)?.toDouble() ?? 0,
      previousBalance: (json['previousBalance'] as num?)?.toDouble() ?? 0,
      finalAmount: (json['final'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RideFareModelToJson(_RideFareModel instance) =>
    <String, dynamic>{
      'estimated': instance.estimated,
      'currency': instance.currency,
      'discount': instance.discount,
      'cancellationFee': instance.cancellationFee,
      'waitingFee': instance.waitingFee,
      'previousBalance': instance.previousBalance,
      'final': instance.finalAmount,
    };

_RideModel _$RideModelFromJson(Map<String, dynamic> json) => _RideModel(
  id: json['id'] as String,
  riderId: json['riderId'] as String,
  status: const RideStatusConverter().fromJson(json['status'] as String),
  vehicleType: $enumDecode(_$VehicleTypeEnumMap, json['vehicleType']),
  pickup: RidePlaceModel.fromJson(json['pickup'] as Map<String, dynamic>),
  dropoff: RidePlaceModel.fromJson(json['dropoff'] as Map<String, dynamic>),
  fare: RideFareModel.fromJson(json['fare'] as Map<String, dynamic>),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  scheduledFor: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['scheduledFor'],
    const TimestampConverter().fromJson,
  ),
  serviceType:
      $enumDecodeNullable(_$ServiceTypeEnumMap, json['serviceType']) ??
      ServiceType.ride,
  parcel: json['parcel'] == null
      ? null
      : ParcelDetailsModel.fromJson(json['parcel'] as Map<String, dynamic>),
  promo: json['promo'] == null
      ? null
      : RidePromoModel.fromJson(json['promo'] as Map<String, dynamic>),
  driverRating: json['driverRating'] == null
      ? null
      : RideRatingModel.fromJson(json['driverRating'] as Map<String, dynamic>),
  riderRating: json['riderRating'] == null
      ? null
      : RideRatingModel.fromJson(json['riderRating'] as Map<String, dynamic>),
  shareToken: json['shareToken'] as String?,
  driverId: json['driverId'] as String?,
  driverInfo: json['driverInfo'] == null
      ? null
      : RidePartyInfoModel.fromJson(json['driverInfo'] as Map<String, dynamic>),
  riderInfo: json['riderInfo'] == null
      ? null
      : RidePartyInfoModel.fromJson(json['riderInfo'] as Map<String, dynamic>),
  acceptedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['acceptedAt'],
    const TimestampConverter().fromJson,
  ),
  arrivingAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['arrivingAt'],
    const TimestampConverter().fromJson,
  ),
  arrivedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['arrivedAt'],
    const TimestampConverter().fromJson,
  ),
  startedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['startedAt'],
    const TimestampConverter().fromJson,
  ),
  completedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['completedAt'],
    const TimestampConverter().fromJson,
  ),
  route: json['route'] == null
      ? null
      : RouteModel.fromJson(json['route'] as Map<String, dynamic>),
  cancelledBy: json['cancelledBy'] as String?,
  searchExpiresAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['searchExpiresAt'],
    const TimestampConverter().fromJson,
  ),
  offerExpiresAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['offerExpiresAt'],
    const TimestampConverter().fromJson,
  ),
  offerDistanceMeters: (json['offerDistanceMeters'] as num?)?.toInt(),
);

Map<String, dynamic> _$RideModelToJson(_RideModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'riderId': instance.riderId,
      'status': const RideStatusConverter().toJson(instance.status),
      'vehicleType': _$VehicleTypeEnumMap[instance.vehicleType]!,
      'pickup': instance.pickup.toJson(),
      'dropoff': instance.dropoff.toJson(),
      'fare': instance.fare.toJson(),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'scheduledFor': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.scheduledFor,
        const TimestampConverter().toJson,
      ),
      'serviceType': _$ServiceTypeEnumMap[instance.serviceType]!,
      'parcel': instance.parcel?.toJson(),
      'promo': instance.promo?.toJson(),
      'driverRating': instance.driverRating?.toJson(),
      'riderRating': instance.riderRating?.toJson(),
      'shareToken': instance.shareToken,
      'driverId': instance.driverId,
      'driverInfo': instance.driverInfo?.toJson(),
      'riderInfo': instance.riderInfo?.toJson(),
      'acceptedAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.acceptedAt,
        const TimestampConverter().toJson,
      ),
      'arrivingAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.arrivingAt,
        const TimestampConverter().toJson,
      ),
      'arrivedAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.arrivedAt,
        const TimestampConverter().toJson,
      ),
      'startedAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.startedAt,
        const TimestampConverter().toJson,
      ),
      'completedAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.completedAt,
        const TimestampConverter().toJson,
      ),
      'route': instance.route?.toJson(),
      'cancelledBy': instance.cancelledBy,
      'searchExpiresAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.searchExpiresAt,
        const TimestampConverter().toJson,
      ),
      'offerExpiresAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.offerExpiresAt,
        const TimestampConverter().toJson,
      ),
      'offerDistanceMeters': instance.offerDistanceMeters,
    };

const _$VehicleTypeEnumMap = {
  VehicleType.economy: 'economy',
  VehicleType.comfort: 'comfort',
  VehicleType.van: 'van',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$ServiceTypeEnumMap = {
  ServiceType.ride: 'ride',
  ServiceType.parcel: 'parcel',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_RidePartyInfoModel _$RidePartyInfoModelFromJson(Map<String, dynamic> json) =>
    _RidePartyInfoModel(
      name: json['name'] as String,
      phone: json['phone'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      vehicle: json['vehicle'] == null
          ? null
          : VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RidePartyInfoModelToJson(_RidePartyInfoModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'rating': instance.rating,
      'vehicle': instance.vehicle?.toJson(),
    };

_RideRatingModel _$RideRatingModelFromJson(Map<String, dynamic> json) =>
    _RideRatingModel(stars: (json['stars'] as num).toInt());

Map<String, dynamic> _$RideRatingModelToJson(_RideRatingModel instance) =>
    <String, dynamic>{'stars': instance.stars};

_RidePromoModel _$RidePromoModelFromJson(Map<String, dynamic> json) =>
    _RidePromoModel(
      code: json['code'] as String,
      applied: json['applied'] as bool?,
    );

Map<String, dynamic> _$RidePromoModelToJson(_RidePromoModel instance) =>
    <String, dynamic>{'code': instance.code, 'applied': instance.applied};

_ParcelDetailsModel _$ParcelDetailsModelFromJson(Map<String, dynamic> json) =>
    _ParcelDetailsModel(
      recipientName: json['recipientName'] as String,
      recipientPhone: json['recipientPhone'] as String,
      description: json['description'] as String,
      photoPath: json['photoPath'] as String?,
      codeAttempts: (json['codeAttempts'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ParcelDetailsModelToJson(_ParcelDetailsModel instance) =>
    <String, dynamic>{
      'recipientName': instance.recipientName,
      'recipientPhone': instance.recipientPhone,
      'description': instance.description,
      'photoPath': instance.photoPath,
      'codeAttempts': instance.codeAttempts,
    };
