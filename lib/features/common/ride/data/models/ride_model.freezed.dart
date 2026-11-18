// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RidePlaceModel {

 String get name; String get address;@GeoPointConverter() GeoPointValue get geopoint;
/// Create a copy of RidePlaceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RidePlaceModelCopyWith<RidePlaceModel> get copyWith => _$RidePlaceModelCopyWithImpl<RidePlaceModel>(this as RidePlaceModel, _$identity);

  /// Serializes this RidePlaceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RidePlaceModel&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.geopoint, geopoint) || other.geopoint == geopoint));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,address,geopoint);

@override
String toString() {
  return 'RidePlaceModel(name: $name, address: $address, geopoint: $geopoint)';
}


}

/// @nodoc
abstract mixin class $RidePlaceModelCopyWith<$Res>  {
  factory $RidePlaceModelCopyWith(RidePlaceModel value, $Res Function(RidePlaceModel) _then) = _$RidePlaceModelCopyWithImpl;
@useResult
$Res call({
 String name, String address,@GeoPointConverter() GeoPointValue geopoint
});




}
/// @nodoc
class _$RidePlaceModelCopyWithImpl<$Res>
    implements $RidePlaceModelCopyWith<$Res> {
  _$RidePlaceModelCopyWithImpl(this._self, this._then);

  final RidePlaceModel _self;
  final $Res Function(RidePlaceModel) _then;

/// Create a copy of RidePlaceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? address = null,Object? geopoint = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,geopoint: null == geopoint ? _self.geopoint : geopoint // ignore: cast_nullable_to_non_nullable
as GeoPointValue,
  ));
}

}


/// Adds pattern-matching-related methods to [RidePlaceModel].
extension RidePlaceModelPatterns on RidePlaceModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RidePlaceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RidePlaceModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RidePlaceModel value)  $default,){
final _that = this;
switch (_that) {
case _RidePlaceModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RidePlaceModel value)?  $default,){
final _that = this;
switch (_that) {
case _RidePlaceModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String address, @GeoPointConverter()  GeoPointValue geopoint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RidePlaceModel() when $default != null:
return $default(_that.name,_that.address,_that.geopoint);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String address, @GeoPointConverter()  GeoPointValue geopoint)  $default,) {final _that = this;
switch (_that) {
case _RidePlaceModel():
return $default(_that.name,_that.address,_that.geopoint);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String address, @GeoPointConverter()  GeoPointValue geopoint)?  $default,) {final _that = this;
switch (_that) {
case _RidePlaceModel() when $default != null:
return $default(_that.name,_that.address,_that.geopoint);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RidePlaceModel extends RidePlaceModel {
  const _RidePlaceModel({required this.name, required this.address, @GeoPointConverter() required this.geopoint}): super._();
  factory _RidePlaceModel.fromJson(Map<String, dynamic> json) => _$RidePlaceModelFromJson(json);

@override final  String name;
@override final  String address;
@override@GeoPointConverter() final  GeoPointValue geopoint;

/// Create a copy of RidePlaceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RidePlaceModelCopyWith<_RidePlaceModel> get copyWith => __$RidePlaceModelCopyWithImpl<_RidePlaceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RidePlaceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RidePlaceModel&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.geopoint, geopoint) || other.geopoint == geopoint));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,address,geopoint);

@override
String toString() {
  return 'RidePlaceModel(name: $name, address: $address, geopoint: $geopoint)';
}


}

/// @nodoc
abstract mixin class _$RidePlaceModelCopyWith<$Res> implements $RidePlaceModelCopyWith<$Res> {
  factory _$RidePlaceModelCopyWith(_RidePlaceModel value, $Res Function(_RidePlaceModel) _then) = __$RidePlaceModelCopyWithImpl;
@override @useResult
$Res call({
 String name, String address,@GeoPointConverter() GeoPointValue geopoint
});




}
/// @nodoc
class __$RidePlaceModelCopyWithImpl<$Res>
    implements _$RidePlaceModelCopyWith<$Res> {
  __$RidePlaceModelCopyWithImpl(this._self, this._then);

  final _RidePlaceModel _self;
  final $Res Function(_RidePlaceModel) _then;

/// Create a copy of RidePlaceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? address = null,Object? geopoint = null,}) {
  return _then(_RidePlaceModel(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,geopoint: null == geopoint ? _self.geopoint : geopoint // ignore: cast_nullable_to_non_nullable
as GeoPointValue,
  ));
}


}


/// @nodoc
mixin _$RideFareModel {

 double get estimated; String get currency; double get discount; double get cancellationFee; double get waitingFee; double get previousBalance;@JsonKey(name: 'final') double? get finalAmount;
/// Create a copy of RideFareModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideFareModelCopyWith<RideFareModel> get copyWith => _$RideFareModelCopyWithImpl<RideFareModel>(this as RideFareModel, _$identity);

  /// Serializes this RideFareModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideFareModel&&(identical(other.estimated, estimated) || other.estimated == estimated)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.cancellationFee, cancellationFee) || other.cancellationFee == cancellationFee)&&(identical(other.waitingFee, waitingFee) || other.waitingFee == waitingFee)&&(identical(other.previousBalance, previousBalance) || other.previousBalance == previousBalance)&&(identical(other.finalAmount, finalAmount) || other.finalAmount == finalAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,estimated,currency,discount,cancellationFee,waitingFee,previousBalance,finalAmount);

@override
String toString() {
  return 'RideFareModel(estimated: $estimated, currency: $currency, discount: $discount, cancellationFee: $cancellationFee, waitingFee: $waitingFee, previousBalance: $previousBalance, finalAmount: $finalAmount)';
}


}

/// @nodoc
abstract mixin class $RideFareModelCopyWith<$Res>  {
  factory $RideFareModelCopyWith(RideFareModel value, $Res Function(RideFareModel) _then) = _$RideFareModelCopyWithImpl;
@useResult
$Res call({
 double estimated, String currency, double discount, double cancellationFee, double waitingFee, double previousBalance,@JsonKey(name: 'final') double? finalAmount
});




}
/// @nodoc
class _$RideFareModelCopyWithImpl<$Res>
    implements $RideFareModelCopyWith<$Res> {
  _$RideFareModelCopyWithImpl(this._self, this._then);

  final RideFareModel _self;
  final $Res Function(RideFareModel) _then;

/// Create a copy of RideFareModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? estimated = null,Object? currency = null,Object? discount = null,Object? cancellationFee = null,Object? waitingFee = null,Object? previousBalance = null,Object? finalAmount = freezed,}) {
  return _then(_self.copyWith(
estimated: null == estimated ? _self.estimated : estimated // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,cancellationFee: null == cancellationFee ? _self.cancellationFee : cancellationFee // ignore: cast_nullable_to_non_nullable
as double,waitingFee: null == waitingFee ? _self.waitingFee : waitingFee // ignore: cast_nullable_to_non_nullable
as double,previousBalance: null == previousBalance ? _self.previousBalance : previousBalance // ignore: cast_nullable_to_non_nullable
as double,finalAmount: freezed == finalAmount ? _self.finalAmount : finalAmount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [RideFareModel].
extension RideFareModelPatterns on RideFareModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideFareModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideFareModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideFareModel value)  $default,){
final _that = this;
switch (_that) {
case _RideFareModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideFareModel value)?  $default,){
final _that = this;
switch (_that) {
case _RideFareModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double estimated,  String currency,  double discount,  double cancellationFee,  double waitingFee,  double previousBalance, @JsonKey(name: 'final')  double? finalAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideFareModel() when $default != null:
return $default(_that.estimated,_that.currency,_that.discount,_that.cancellationFee,_that.waitingFee,_that.previousBalance,_that.finalAmount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double estimated,  String currency,  double discount,  double cancellationFee,  double waitingFee,  double previousBalance, @JsonKey(name: 'final')  double? finalAmount)  $default,) {final _that = this;
switch (_that) {
case _RideFareModel():
return $default(_that.estimated,_that.currency,_that.discount,_that.cancellationFee,_that.waitingFee,_that.previousBalance,_that.finalAmount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double estimated,  String currency,  double discount,  double cancellationFee,  double waitingFee,  double previousBalance, @JsonKey(name: 'final')  double? finalAmount)?  $default,) {final _that = this;
switch (_that) {
case _RideFareModel() when $default != null:
return $default(_that.estimated,_that.currency,_that.discount,_that.cancellationFee,_that.waitingFee,_that.previousBalance,_that.finalAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideFareModel implements RideFareModel {
  const _RideFareModel({required this.estimated, required this.currency, this.discount = 0, this.cancellationFee = 0, this.waitingFee = 0, this.previousBalance = 0, @JsonKey(name: 'final') this.finalAmount});
  factory _RideFareModel.fromJson(Map<String, dynamic> json) => _$RideFareModelFromJson(json);

@override final  double estimated;
@override final  String currency;
@override@JsonKey() final  double discount;
@override@JsonKey() final  double cancellationFee;
@override@JsonKey() final  double waitingFee;
@override@JsonKey() final  double previousBalance;
@override@JsonKey(name: 'final') final  double? finalAmount;

/// Create a copy of RideFareModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideFareModelCopyWith<_RideFareModel> get copyWith => __$RideFareModelCopyWithImpl<_RideFareModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideFareModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideFareModel&&(identical(other.estimated, estimated) || other.estimated == estimated)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.cancellationFee, cancellationFee) || other.cancellationFee == cancellationFee)&&(identical(other.waitingFee, waitingFee) || other.waitingFee == waitingFee)&&(identical(other.previousBalance, previousBalance) || other.previousBalance == previousBalance)&&(identical(other.finalAmount, finalAmount) || other.finalAmount == finalAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,estimated,currency,discount,cancellationFee,waitingFee,previousBalance,finalAmount);

@override
String toString() {
  return 'RideFareModel(estimated: $estimated, currency: $currency, discount: $discount, cancellationFee: $cancellationFee, waitingFee: $waitingFee, previousBalance: $previousBalance, finalAmount: $finalAmount)';
}


}

/// @nodoc
abstract mixin class _$RideFareModelCopyWith<$Res> implements $RideFareModelCopyWith<$Res> {
  factory _$RideFareModelCopyWith(_RideFareModel value, $Res Function(_RideFareModel) _then) = __$RideFareModelCopyWithImpl;
@override @useResult
$Res call({
 double estimated, String currency, double discount, double cancellationFee, double waitingFee, double previousBalance,@JsonKey(name: 'final') double? finalAmount
});




}
/// @nodoc
class __$RideFareModelCopyWithImpl<$Res>
    implements _$RideFareModelCopyWith<$Res> {
  __$RideFareModelCopyWithImpl(this._self, this._then);

  final _RideFareModel _self;
  final $Res Function(_RideFareModel) _then;

/// Create a copy of RideFareModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? estimated = null,Object? currency = null,Object? discount = null,Object? cancellationFee = null,Object? waitingFee = null,Object? previousBalance = null,Object? finalAmount = freezed,}) {
  return _then(_RideFareModel(
estimated: null == estimated ? _self.estimated : estimated // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,cancellationFee: null == cancellationFee ? _self.cancellationFee : cancellationFee // ignore: cast_nullable_to_non_nullable
as double,waitingFee: null == waitingFee ? _self.waitingFee : waitingFee // ignore: cast_nullable_to_non_nullable
as double,previousBalance: null == previousBalance ? _self.previousBalance : previousBalance // ignore: cast_nullable_to_non_nullable
as double,finalAmount: freezed == finalAmount ? _self.finalAmount : finalAmount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$RideModel {

 String get id; String get riderId;@RideStatusConverter() RideStatus get status; VehicleType get vehicleType; RidePlaceModel get pickup; RidePlaceModel get dropoff; RideFareModel get fare;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime? get scheduledFor; RidePromoModel? get promo; RideRatingModel? get driverRating; RideRatingModel? get riderRating; String? get shareToken; String? get driverId; RidePartyInfoModel? get driverInfo; RidePartyInfoModel? get riderInfo;@TimestampConverter() DateTime? get acceptedAt;@TimestampConverter() DateTime? get arrivingAt;@TimestampConverter() DateTime? get arrivedAt;@TimestampConverter() DateTime? get startedAt;@TimestampConverter() DateTime? get completedAt; RouteModel? get route; String? get cancelledBy;@TimestampConverter() DateTime? get searchExpiresAt;@TimestampConverter() DateTime? get offerExpiresAt; int? get offerDistanceMeters;
/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideModelCopyWith<RideModel> get copyWith => _$RideModelCopyWithImpl<RideModel>(this as RideModel, _$identity);

  /// Serializes this RideModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideModel&&(identical(other.id, id) || other.id == id)&&(identical(other.riderId, riderId) || other.riderId == riderId)&&(identical(other.status, status) || other.status == status)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.pickup, pickup) || other.pickup == pickup)&&(identical(other.dropoff, dropoff) || other.dropoff == dropoff)&&(identical(other.fare, fare) || other.fare == fare)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor)&&(identical(other.promo, promo) || other.promo == promo)&&(identical(other.driverRating, driverRating) || other.driverRating == driverRating)&&(identical(other.riderRating, riderRating) || other.riderRating == riderRating)&&(identical(other.shareToken, shareToken) || other.shareToken == shareToken)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverInfo, driverInfo) || other.driverInfo == driverInfo)&&(identical(other.riderInfo, riderInfo) || other.riderInfo == riderInfo)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.arrivingAt, arrivingAt) || other.arrivingAt == arrivingAt)&&(identical(other.arrivedAt, arrivedAt) || other.arrivedAt == arrivedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.route, route) || other.route == route)&&(identical(other.cancelledBy, cancelledBy) || other.cancelledBy == cancelledBy)&&(identical(other.searchExpiresAt, searchExpiresAt) || other.searchExpiresAt == searchExpiresAt)&&(identical(other.offerExpiresAt, offerExpiresAt) || other.offerExpiresAt == offerExpiresAt)&&(identical(other.offerDistanceMeters, offerDistanceMeters) || other.offerDistanceMeters == offerDistanceMeters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,riderId,status,vehicleType,pickup,dropoff,fare,createdAt,scheduledFor,promo,driverRating,riderRating,shareToken,driverId,driverInfo,riderInfo,acceptedAt,arrivingAt,arrivedAt,startedAt,completedAt,route,cancelledBy,searchExpiresAt,offerExpiresAt,offerDistanceMeters]);

@override
String toString() {
  return 'RideModel(id: $id, riderId: $riderId, status: $status, vehicleType: $vehicleType, pickup: $pickup, dropoff: $dropoff, fare: $fare, createdAt: $createdAt, scheduledFor: $scheduledFor, promo: $promo, driverRating: $driverRating, riderRating: $riderRating, shareToken: $shareToken, driverId: $driverId, driverInfo: $driverInfo, riderInfo: $riderInfo, acceptedAt: $acceptedAt, arrivingAt: $arrivingAt, arrivedAt: $arrivedAt, startedAt: $startedAt, completedAt: $completedAt, route: $route, cancelledBy: $cancelledBy, searchExpiresAt: $searchExpiresAt, offerExpiresAt: $offerExpiresAt, offerDistanceMeters: $offerDistanceMeters)';
}


}

/// @nodoc
abstract mixin class $RideModelCopyWith<$Res>  {
  factory $RideModelCopyWith(RideModel value, $Res Function(RideModel) _then) = _$RideModelCopyWithImpl;
@useResult
$Res call({
 String id, String riderId,@RideStatusConverter() RideStatus status, VehicleType vehicleType, RidePlaceModel pickup, RidePlaceModel dropoff, RideFareModel fare,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime? scheduledFor, RidePromoModel? promo, RideRatingModel? driverRating, RideRatingModel? riderRating, String? shareToken, String? driverId, RidePartyInfoModel? driverInfo, RidePartyInfoModel? riderInfo,@TimestampConverter() DateTime? acceptedAt,@TimestampConverter() DateTime? arrivingAt,@TimestampConverter() DateTime? arrivedAt,@TimestampConverter() DateTime? startedAt,@TimestampConverter() DateTime? completedAt, RouteModel? route, String? cancelledBy,@TimestampConverter() DateTime? searchExpiresAt,@TimestampConverter() DateTime? offerExpiresAt, int? offerDistanceMeters
});


$RidePlaceModelCopyWith<$Res> get pickup;$RidePlaceModelCopyWith<$Res> get dropoff;$RideFareModelCopyWith<$Res> get fare;$RidePromoModelCopyWith<$Res>? get promo;$RideRatingModelCopyWith<$Res>? get driverRating;$RideRatingModelCopyWith<$Res>? get riderRating;$RidePartyInfoModelCopyWith<$Res>? get driverInfo;$RidePartyInfoModelCopyWith<$Res>? get riderInfo;$RouteModelCopyWith<$Res>? get route;

}
/// @nodoc
class _$RideModelCopyWithImpl<$Res>
    implements $RideModelCopyWith<$Res> {
  _$RideModelCopyWithImpl(this._self, this._then);

  final RideModel _self;
  final $Res Function(RideModel) _then;

/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? riderId = null,Object? status = null,Object? vehicleType = null,Object? pickup = null,Object? dropoff = null,Object? fare = null,Object? createdAt = null,Object? scheduledFor = freezed,Object? promo = freezed,Object? driverRating = freezed,Object? riderRating = freezed,Object? shareToken = freezed,Object? driverId = freezed,Object? driverInfo = freezed,Object? riderInfo = freezed,Object? acceptedAt = freezed,Object? arrivingAt = freezed,Object? arrivedAt = freezed,Object? startedAt = freezed,Object? completedAt = freezed,Object? route = freezed,Object? cancelledBy = freezed,Object? searchExpiresAt = freezed,Object? offerExpiresAt = freezed,Object? offerDistanceMeters = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,riderId: null == riderId ? _self.riderId : riderId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideStatus,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,pickup: null == pickup ? _self.pickup : pickup // ignore: cast_nullable_to_non_nullable
as RidePlaceModel,dropoff: null == dropoff ? _self.dropoff : dropoff // ignore: cast_nullable_to_non_nullable
as RidePlaceModel,fare: null == fare ? _self.fare : fare // ignore: cast_nullable_to_non_nullable
as RideFareModel,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledFor: freezed == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as DateTime?,promo: freezed == promo ? _self.promo : promo // ignore: cast_nullable_to_non_nullable
as RidePromoModel?,driverRating: freezed == driverRating ? _self.driverRating : driverRating // ignore: cast_nullable_to_non_nullable
as RideRatingModel?,riderRating: freezed == riderRating ? _self.riderRating : riderRating // ignore: cast_nullable_to_non_nullable
as RideRatingModel?,shareToken: freezed == shareToken ? _self.shareToken : shareToken // ignore: cast_nullable_to_non_nullable
as String?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,driverInfo: freezed == driverInfo ? _self.driverInfo : driverInfo // ignore: cast_nullable_to_non_nullable
as RidePartyInfoModel?,riderInfo: freezed == riderInfo ? _self.riderInfo : riderInfo // ignore: cast_nullable_to_non_nullable
as RidePartyInfoModel?,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,arrivingAt: freezed == arrivingAt ? _self.arrivingAt : arrivingAt // ignore: cast_nullable_to_non_nullable
as DateTime?,arrivedAt: freezed == arrivedAt ? _self.arrivedAt : arrivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as RouteModel?,cancelledBy: freezed == cancelledBy ? _self.cancelledBy : cancelledBy // ignore: cast_nullable_to_non_nullable
as String?,searchExpiresAt: freezed == searchExpiresAt ? _self.searchExpiresAt : searchExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,offerExpiresAt: freezed == offerExpiresAt ? _self.offerExpiresAt : offerExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,offerDistanceMeters: freezed == offerDistanceMeters ? _self.offerDistanceMeters : offerDistanceMeters // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RidePlaceModelCopyWith<$Res> get pickup {
  
  return $RidePlaceModelCopyWith<$Res>(_self.pickup, (value) {
    return _then(_self.copyWith(pickup: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RidePlaceModelCopyWith<$Res> get dropoff {
  
  return $RidePlaceModelCopyWith<$Res>(_self.dropoff, (value) {
    return _then(_self.copyWith(dropoff: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RideFareModelCopyWith<$Res> get fare {
  
  return $RideFareModelCopyWith<$Res>(_self.fare, (value) {
    return _then(_self.copyWith(fare: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RidePromoModelCopyWith<$Res>? get promo {
    if (_self.promo == null) {
    return null;
  }

  return $RidePromoModelCopyWith<$Res>(_self.promo!, (value) {
    return _then(_self.copyWith(promo: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RideRatingModelCopyWith<$Res>? get driverRating {
    if (_self.driverRating == null) {
    return null;
  }

  return $RideRatingModelCopyWith<$Res>(_self.driverRating!, (value) {
    return _then(_self.copyWith(driverRating: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RideRatingModelCopyWith<$Res>? get riderRating {
    if (_self.riderRating == null) {
    return null;
  }

  return $RideRatingModelCopyWith<$Res>(_self.riderRating!, (value) {
    return _then(_self.copyWith(riderRating: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RidePartyInfoModelCopyWith<$Res>? get driverInfo {
    if (_self.driverInfo == null) {
    return null;
  }

  return $RidePartyInfoModelCopyWith<$Res>(_self.driverInfo!, (value) {
    return _then(_self.copyWith(driverInfo: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RidePartyInfoModelCopyWith<$Res>? get riderInfo {
    if (_self.riderInfo == null) {
    return null;
  }

  return $RidePartyInfoModelCopyWith<$Res>(_self.riderInfo!, (value) {
    return _then(_self.copyWith(riderInfo: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RouteModelCopyWith<$Res>? get route {
    if (_self.route == null) {
    return null;
  }

  return $RouteModelCopyWith<$Res>(_self.route!, (value) {
    return _then(_self.copyWith(route: value));
  });
}
}


/// Adds pattern-matching-related methods to [RideModel].
extension RideModelPatterns on RideModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideModel value)  $default,){
final _that = this;
switch (_that) {
case _RideModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideModel value)?  $default,){
final _that = this;
switch (_that) {
case _RideModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String riderId, @RideStatusConverter()  RideStatus status,  VehicleType vehicleType,  RidePlaceModel pickup,  RidePlaceModel dropoff,  RideFareModel fare, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime? scheduledFor,  RidePromoModel? promo,  RideRatingModel? driverRating,  RideRatingModel? riderRating,  String? shareToken,  String? driverId,  RidePartyInfoModel? driverInfo,  RidePartyInfoModel? riderInfo, @TimestampConverter()  DateTime? acceptedAt, @TimestampConverter()  DateTime? arrivingAt, @TimestampConverter()  DateTime? arrivedAt, @TimestampConverter()  DateTime? startedAt, @TimestampConverter()  DateTime? completedAt,  RouteModel? route,  String? cancelledBy, @TimestampConverter()  DateTime? searchExpiresAt, @TimestampConverter()  DateTime? offerExpiresAt,  int? offerDistanceMeters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideModel() when $default != null:
return $default(_that.id,_that.riderId,_that.status,_that.vehicleType,_that.pickup,_that.dropoff,_that.fare,_that.createdAt,_that.scheduledFor,_that.promo,_that.driverRating,_that.riderRating,_that.shareToken,_that.driverId,_that.driverInfo,_that.riderInfo,_that.acceptedAt,_that.arrivingAt,_that.arrivedAt,_that.startedAt,_that.completedAt,_that.route,_that.cancelledBy,_that.searchExpiresAt,_that.offerExpiresAt,_that.offerDistanceMeters);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String riderId, @RideStatusConverter()  RideStatus status,  VehicleType vehicleType,  RidePlaceModel pickup,  RidePlaceModel dropoff,  RideFareModel fare, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime? scheduledFor,  RidePromoModel? promo,  RideRatingModel? driverRating,  RideRatingModel? riderRating,  String? shareToken,  String? driverId,  RidePartyInfoModel? driverInfo,  RidePartyInfoModel? riderInfo, @TimestampConverter()  DateTime? acceptedAt, @TimestampConverter()  DateTime? arrivingAt, @TimestampConverter()  DateTime? arrivedAt, @TimestampConverter()  DateTime? startedAt, @TimestampConverter()  DateTime? completedAt,  RouteModel? route,  String? cancelledBy, @TimestampConverter()  DateTime? searchExpiresAt, @TimestampConverter()  DateTime? offerExpiresAt,  int? offerDistanceMeters)  $default,) {final _that = this;
switch (_that) {
case _RideModel():
return $default(_that.id,_that.riderId,_that.status,_that.vehicleType,_that.pickup,_that.dropoff,_that.fare,_that.createdAt,_that.scheduledFor,_that.promo,_that.driverRating,_that.riderRating,_that.shareToken,_that.driverId,_that.driverInfo,_that.riderInfo,_that.acceptedAt,_that.arrivingAt,_that.arrivedAt,_that.startedAt,_that.completedAt,_that.route,_that.cancelledBy,_that.searchExpiresAt,_that.offerExpiresAt,_that.offerDistanceMeters);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String riderId, @RideStatusConverter()  RideStatus status,  VehicleType vehicleType,  RidePlaceModel pickup,  RidePlaceModel dropoff,  RideFareModel fare, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime? scheduledFor,  RidePromoModel? promo,  RideRatingModel? driverRating,  RideRatingModel? riderRating,  String? shareToken,  String? driverId,  RidePartyInfoModel? driverInfo,  RidePartyInfoModel? riderInfo, @TimestampConverter()  DateTime? acceptedAt, @TimestampConverter()  DateTime? arrivingAt, @TimestampConverter()  DateTime? arrivedAt, @TimestampConverter()  DateTime? startedAt, @TimestampConverter()  DateTime? completedAt,  RouteModel? route,  String? cancelledBy, @TimestampConverter()  DateTime? searchExpiresAt, @TimestampConverter()  DateTime? offerExpiresAt,  int? offerDistanceMeters)?  $default,) {final _that = this;
switch (_that) {
case _RideModel() when $default != null:
return $default(_that.id,_that.riderId,_that.status,_that.vehicleType,_that.pickup,_that.dropoff,_that.fare,_that.createdAt,_that.scheduledFor,_that.promo,_that.driverRating,_that.riderRating,_that.shareToken,_that.driverId,_that.driverInfo,_that.riderInfo,_that.acceptedAt,_that.arrivingAt,_that.arrivedAt,_that.startedAt,_that.completedAt,_that.route,_that.cancelledBy,_that.searchExpiresAt,_that.offerExpiresAt,_that.offerDistanceMeters);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _RideModel extends RideModel {
  const _RideModel({required this.id, required this.riderId, @RideStatusConverter() required this.status, required this.vehicleType, required this.pickup, required this.dropoff, required this.fare, @TimestampConverter() required this.createdAt, @TimestampConverter() this.scheduledFor, this.promo, this.driverRating, this.riderRating, this.shareToken, this.driverId, this.driverInfo, this.riderInfo, @TimestampConverter() this.acceptedAt, @TimestampConverter() this.arrivingAt, @TimestampConverter() this.arrivedAt, @TimestampConverter() this.startedAt, @TimestampConverter() this.completedAt, this.route, this.cancelledBy, @TimestampConverter() this.searchExpiresAt, @TimestampConverter() this.offerExpiresAt, this.offerDistanceMeters}): super._();
  factory _RideModel.fromJson(Map<String, dynamic> json) => _$RideModelFromJson(json);

@override final  String id;
@override final  String riderId;
@override@RideStatusConverter() final  RideStatus status;
@override final  VehicleType vehicleType;
@override final  RidePlaceModel pickup;
@override final  RidePlaceModel dropoff;
@override final  RideFareModel fare;
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime? scheduledFor;
@override final  RidePromoModel? promo;
@override final  RideRatingModel? driverRating;
@override final  RideRatingModel? riderRating;
@override final  String? shareToken;
@override final  String? driverId;
@override final  RidePartyInfoModel? driverInfo;
@override final  RidePartyInfoModel? riderInfo;
@override@TimestampConverter() final  DateTime? acceptedAt;
@override@TimestampConverter() final  DateTime? arrivingAt;
@override@TimestampConverter() final  DateTime? arrivedAt;
@override@TimestampConverter() final  DateTime? startedAt;
@override@TimestampConverter() final  DateTime? completedAt;
@override final  RouteModel? route;
@override final  String? cancelledBy;
@override@TimestampConverter() final  DateTime? searchExpiresAt;
@override@TimestampConverter() final  DateTime? offerExpiresAt;
@override final  int? offerDistanceMeters;

/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideModelCopyWith<_RideModel> get copyWith => __$RideModelCopyWithImpl<_RideModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideModel&&(identical(other.id, id) || other.id == id)&&(identical(other.riderId, riderId) || other.riderId == riderId)&&(identical(other.status, status) || other.status == status)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.pickup, pickup) || other.pickup == pickup)&&(identical(other.dropoff, dropoff) || other.dropoff == dropoff)&&(identical(other.fare, fare) || other.fare == fare)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor)&&(identical(other.promo, promo) || other.promo == promo)&&(identical(other.driverRating, driverRating) || other.driverRating == driverRating)&&(identical(other.riderRating, riderRating) || other.riderRating == riderRating)&&(identical(other.shareToken, shareToken) || other.shareToken == shareToken)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverInfo, driverInfo) || other.driverInfo == driverInfo)&&(identical(other.riderInfo, riderInfo) || other.riderInfo == riderInfo)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.arrivingAt, arrivingAt) || other.arrivingAt == arrivingAt)&&(identical(other.arrivedAt, arrivedAt) || other.arrivedAt == arrivedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.route, route) || other.route == route)&&(identical(other.cancelledBy, cancelledBy) || other.cancelledBy == cancelledBy)&&(identical(other.searchExpiresAt, searchExpiresAt) || other.searchExpiresAt == searchExpiresAt)&&(identical(other.offerExpiresAt, offerExpiresAt) || other.offerExpiresAt == offerExpiresAt)&&(identical(other.offerDistanceMeters, offerDistanceMeters) || other.offerDistanceMeters == offerDistanceMeters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,riderId,status,vehicleType,pickup,dropoff,fare,createdAt,scheduledFor,promo,driverRating,riderRating,shareToken,driverId,driverInfo,riderInfo,acceptedAt,arrivingAt,arrivedAt,startedAt,completedAt,route,cancelledBy,searchExpiresAt,offerExpiresAt,offerDistanceMeters]);

@override
String toString() {
  return 'RideModel(id: $id, riderId: $riderId, status: $status, vehicleType: $vehicleType, pickup: $pickup, dropoff: $dropoff, fare: $fare, createdAt: $createdAt, scheduledFor: $scheduledFor, promo: $promo, driverRating: $driverRating, riderRating: $riderRating, shareToken: $shareToken, driverId: $driverId, driverInfo: $driverInfo, riderInfo: $riderInfo, acceptedAt: $acceptedAt, arrivingAt: $arrivingAt, arrivedAt: $arrivedAt, startedAt: $startedAt, completedAt: $completedAt, route: $route, cancelledBy: $cancelledBy, searchExpiresAt: $searchExpiresAt, offerExpiresAt: $offerExpiresAt, offerDistanceMeters: $offerDistanceMeters)';
}


}

/// @nodoc
abstract mixin class _$RideModelCopyWith<$Res> implements $RideModelCopyWith<$Res> {
  factory _$RideModelCopyWith(_RideModel value, $Res Function(_RideModel) _then) = __$RideModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String riderId,@RideStatusConverter() RideStatus status, VehicleType vehicleType, RidePlaceModel pickup, RidePlaceModel dropoff, RideFareModel fare,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime? scheduledFor, RidePromoModel? promo, RideRatingModel? driverRating, RideRatingModel? riderRating, String? shareToken, String? driverId, RidePartyInfoModel? driverInfo, RidePartyInfoModel? riderInfo,@TimestampConverter() DateTime? acceptedAt,@TimestampConverter() DateTime? arrivingAt,@TimestampConverter() DateTime? arrivedAt,@TimestampConverter() DateTime? startedAt,@TimestampConverter() DateTime? completedAt, RouteModel? route, String? cancelledBy,@TimestampConverter() DateTime? searchExpiresAt,@TimestampConverter() DateTime? offerExpiresAt, int? offerDistanceMeters
});


@override $RidePlaceModelCopyWith<$Res> get pickup;@override $RidePlaceModelCopyWith<$Res> get dropoff;@override $RideFareModelCopyWith<$Res> get fare;@override $RidePromoModelCopyWith<$Res>? get promo;@override $RideRatingModelCopyWith<$Res>? get driverRating;@override $RideRatingModelCopyWith<$Res>? get riderRating;@override $RidePartyInfoModelCopyWith<$Res>? get driverInfo;@override $RidePartyInfoModelCopyWith<$Res>? get riderInfo;@override $RouteModelCopyWith<$Res>? get route;

}
/// @nodoc
class __$RideModelCopyWithImpl<$Res>
    implements _$RideModelCopyWith<$Res> {
  __$RideModelCopyWithImpl(this._self, this._then);

  final _RideModel _self;
  final $Res Function(_RideModel) _then;

/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? riderId = null,Object? status = null,Object? vehicleType = null,Object? pickup = null,Object? dropoff = null,Object? fare = null,Object? createdAt = null,Object? scheduledFor = freezed,Object? promo = freezed,Object? driverRating = freezed,Object? riderRating = freezed,Object? shareToken = freezed,Object? driverId = freezed,Object? driverInfo = freezed,Object? riderInfo = freezed,Object? acceptedAt = freezed,Object? arrivingAt = freezed,Object? arrivedAt = freezed,Object? startedAt = freezed,Object? completedAt = freezed,Object? route = freezed,Object? cancelledBy = freezed,Object? searchExpiresAt = freezed,Object? offerExpiresAt = freezed,Object? offerDistanceMeters = freezed,}) {
  return _then(_RideModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,riderId: null == riderId ? _self.riderId : riderId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideStatus,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,pickup: null == pickup ? _self.pickup : pickup // ignore: cast_nullable_to_non_nullable
as RidePlaceModel,dropoff: null == dropoff ? _self.dropoff : dropoff // ignore: cast_nullable_to_non_nullable
as RidePlaceModel,fare: null == fare ? _self.fare : fare // ignore: cast_nullable_to_non_nullable
as RideFareModel,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledFor: freezed == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as DateTime?,promo: freezed == promo ? _self.promo : promo // ignore: cast_nullable_to_non_nullable
as RidePromoModel?,driverRating: freezed == driverRating ? _self.driverRating : driverRating // ignore: cast_nullable_to_non_nullable
as RideRatingModel?,riderRating: freezed == riderRating ? _self.riderRating : riderRating // ignore: cast_nullable_to_non_nullable
as RideRatingModel?,shareToken: freezed == shareToken ? _self.shareToken : shareToken // ignore: cast_nullable_to_non_nullable
as String?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,driverInfo: freezed == driverInfo ? _self.driverInfo : driverInfo // ignore: cast_nullable_to_non_nullable
as RidePartyInfoModel?,riderInfo: freezed == riderInfo ? _self.riderInfo : riderInfo // ignore: cast_nullable_to_non_nullable
as RidePartyInfoModel?,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,arrivingAt: freezed == arrivingAt ? _self.arrivingAt : arrivingAt // ignore: cast_nullable_to_non_nullable
as DateTime?,arrivedAt: freezed == arrivedAt ? _self.arrivedAt : arrivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as RouteModel?,cancelledBy: freezed == cancelledBy ? _self.cancelledBy : cancelledBy // ignore: cast_nullable_to_non_nullable
as String?,searchExpiresAt: freezed == searchExpiresAt ? _self.searchExpiresAt : searchExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,offerExpiresAt: freezed == offerExpiresAt ? _self.offerExpiresAt : offerExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,offerDistanceMeters: freezed == offerDistanceMeters ? _self.offerDistanceMeters : offerDistanceMeters // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RidePlaceModelCopyWith<$Res> get pickup {
  
  return $RidePlaceModelCopyWith<$Res>(_self.pickup, (value) {
    return _then(_self.copyWith(pickup: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RidePlaceModelCopyWith<$Res> get dropoff {
  
  return $RidePlaceModelCopyWith<$Res>(_self.dropoff, (value) {
    return _then(_self.copyWith(dropoff: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RideFareModelCopyWith<$Res> get fare {
  
  return $RideFareModelCopyWith<$Res>(_self.fare, (value) {
    return _then(_self.copyWith(fare: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RidePromoModelCopyWith<$Res>? get promo {
    if (_self.promo == null) {
    return null;
  }

  return $RidePromoModelCopyWith<$Res>(_self.promo!, (value) {
    return _then(_self.copyWith(promo: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RideRatingModelCopyWith<$Res>? get driverRating {
    if (_self.driverRating == null) {
    return null;
  }

  return $RideRatingModelCopyWith<$Res>(_self.driverRating!, (value) {
    return _then(_self.copyWith(driverRating: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RideRatingModelCopyWith<$Res>? get riderRating {
    if (_self.riderRating == null) {
    return null;
  }

  return $RideRatingModelCopyWith<$Res>(_self.riderRating!, (value) {
    return _then(_self.copyWith(riderRating: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RidePartyInfoModelCopyWith<$Res>? get driverInfo {
    if (_self.driverInfo == null) {
    return null;
  }

  return $RidePartyInfoModelCopyWith<$Res>(_self.driverInfo!, (value) {
    return _then(_self.copyWith(driverInfo: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RidePartyInfoModelCopyWith<$Res>? get riderInfo {
    if (_self.riderInfo == null) {
    return null;
  }

  return $RidePartyInfoModelCopyWith<$Res>(_self.riderInfo!, (value) {
    return _then(_self.copyWith(riderInfo: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RouteModelCopyWith<$Res>? get route {
    if (_self.route == null) {
    return null;
  }

  return $RouteModelCopyWith<$Res>(_self.route!, (value) {
    return _then(_self.copyWith(route: value));
  });
}
}


/// @nodoc
mixin _$RidePartyInfoModel {

 String get name; String get phone; double get rating; VehicleModel? get vehicle;
/// Create a copy of RidePartyInfoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RidePartyInfoModelCopyWith<RidePartyInfoModel> get copyWith => _$RidePartyInfoModelCopyWithImpl<RidePartyInfoModel>(this as RidePartyInfoModel, _$identity);

  /// Serializes this RidePartyInfoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RidePartyInfoModel&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,phone,rating,vehicle);

@override
String toString() {
  return 'RidePartyInfoModel(name: $name, phone: $phone, rating: $rating, vehicle: $vehicle)';
}


}

/// @nodoc
abstract mixin class $RidePartyInfoModelCopyWith<$Res>  {
  factory $RidePartyInfoModelCopyWith(RidePartyInfoModel value, $Res Function(RidePartyInfoModel) _then) = _$RidePartyInfoModelCopyWithImpl;
@useResult
$Res call({
 String name, String phone, double rating, VehicleModel? vehicle
});


$VehicleModelCopyWith<$Res>? get vehicle;

}
/// @nodoc
class _$RidePartyInfoModelCopyWithImpl<$Res>
    implements $RidePartyInfoModelCopyWith<$Res> {
  _$RidePartyInfoModelCopyWithImpl(this._self, this._then);

  final RidePartyInfoModel _self;
  final $Res Function(RidePartyInfoModel) _then;

/// Create a copy of RidePartyInfoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? phone = null,Object? rating = null,Object? vehicle = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,vehicle: freezed == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as VehicleModel?,
  ));
}
/// Create a copy of RidePartyInfoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VehicleModelCopyWith<$Res>? get vehicle {
    if (_self.vehicle == null) {
    return null;
  }

  return $VehicleModelCopyWith<$Res>(_self.vehicle!, (value) {
    return _then(_self.copyWith(vehicle: value));
  });
}
}


/// Adds pattern-matching-related methods to [RidePartyInfoModel].
extension RidePartyInfoModelPatterns on RidePartyInfoModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RidePartyInfoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RidePartyInfoModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RidePartyInfoModel value)  $default,){
final _that = this;
switch (_that) {
case _RidePartyInfoModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RidePartyInfoModel value)?  $default,){
final _that = this;
switch (_that) {
case _RidePartyInfoModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String phone,  double rating,  VehicleModel? vehicle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RidePartyInfoModel() when $default != null:
return $default(_that.name,_that.phone,_that.rating,_that.vehicle);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String phone,  double rating,  VehicleModel? vehicle)  $default,) {final _that = this;
switch (_that) {
case _RidePartyInfoModel():
return $default(_that.name,_that.phone,_that.rating,_that.vehicle);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String phone,  double rating,  VehicleModel? vehicle)?  $default,) {final _that = this;
switch (_that) {
case _RidePartyInfoModel() when $default != null:
return $default(_that.name,_that.phone,_that.rating,_that.vehicle);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _RidePartyInfoModel extends RidePartyInfoModel {
  const _RidePartyInfoModel({required this.name, required this.phone, this.rating = 5.0, this.vehicle}): super._();
  factory _RidePartyInfoModel.fromJson(Map<String, dynamic> json) => _$RidePartyInfoModelFromJson(json);

@override final  String name;
@override final  String phone;
@override@JsonKey() final  double rating;
@override final  VehicleModel? vehicle;

/// Create a copy of RidePartyInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RidePartyInfoModelCopyWith<_RidePartyInfoModel> get copyWith => __$RidePartyInfoModelCopyWithImpl<_RidePartyInfoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RidePartyInfoModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RidePartyInfoModel&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,phone,rating,vehicle);

@override
String toString() {
  return 'RidePartyInfoModel(name: $name, phone: $phone, rating: $rating, vehicle: $vehicle)';
}


}

/// @nodoc
abstract mixin class _$RidePartyInfoModelCopyWith<$Res> implements $RidePartyInfoModelCopyWith<$Res> {
  factory _$RidePartyInfoModelCopyWith(_RidePartyInfoModel value, $Res Function(_RidePartyInfoModel) _then) = __$RidePartyInfoModelCopyWithImpl;
@override @useResult
$Res call({
 String name, String phone, double rating, VehicleModel? vehicle
});


@override $VehicleModelCopyWith<$Res>? get vehicle;

}
/// @nodoc
class __$RidePartyInfoModelCopyWithImpl<$Res>
    implements _$RidePartyInfoModelCopyWith<$Res> {
  __$RidePartyInfoModelCopyWithImpl(this._self, this._then);

  final _RidePartyInfoModel _self;
  final $Res Function(_RidePartyInfoModel) _then;

/// Create a copy of RidePartyInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? phone = null,Object? rating = null,Object? vehicle = freezed,}) {
  return _then(_RidePartyInfoModel(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,vehicle: freezed == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as VehicleModel?,
  ));
}

/// Create a copy of RidePartyInfoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VehicleModelCopyWith<$Res>? get vehicle {
    if (_self.vehicle == null) {
    return null;
  }

  return $VehicleModelCopyWith<$Res>(_self.vehicle!, (value) {
    return _then(_self.copyWith(vehicle: value));
  });
}
}


/// @nodoc
mixin _$RideRatingModel {

 int get stars;
/// Create a copy of RideRatingModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideRatingModelCopyWith<RideRatingModel> get copyWith => _$RideRatingModelCopyWithImpl<RideRatingModel>(this as RideRatingModel, _$identity);

  /// Serializes this RideRatingModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideRatingModel&&(identical(other.stars, stars) || other.stars == stars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stars);

@override
String toString() {
  return 'RideRatingModel(stars: $stars)';
}


}

/// @nodoc
abstract mixin class $RideRatingModelCopyWith<$Res>  {
  factory $RideRatingModelCopyWith(RideRatingModel value, $Res Function(RideRatingModel) _then) = _$RideRatingModelCopyWithImpl;
@useResult
$Res call({
 int stars
});




}
/// @nodoc
class _$RideRatingModelCopyWithImpl<$Res>
    implements $RideRatingModelCopyWith<$Res> {
  _$RideRatingModelCopyWithImpl(this._self, this._then);

  final RideRatingModel _self;
  final $Res Function(RideRatingModel) _then;

/// Create a copy of RideRatingModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stars = null,}) {
  return _then(_self.copyWith(
stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RideRatingModel].
extension RideRatingModelPatterns on RideRatingModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideRatingModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideRatingModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideRatingModel value)  $default,){
final _that = this;
switch (_that) {
case _RideRatingModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideRatingModel value)?  $default,){
final _that = this;
switch (_that) {
case _RideRatingModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int stars)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideRatingModel() when $default != null:
return $default(_that.stars);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int stars)  $default,) {final _that = this;
switch (_that) {
case _RideRatingModel():
return $default(_that.stars);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int stars)?  $default,) {final _that = this;
switch (_that) {
case _RideRatingModel() when $default != null:
return $default(_that.stars);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideRatingModel implements RideRatingModel {
  const _RideRatingModel({required this.stars});
  factory _RideRatingModel.fromJson(Map<String, dynamic> json) => _$RideRatingModelFromJson(json);

@override final  int stars;

/// Create a copy of RideRatingModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideRatingModelCopyWith<_RideRatingModel> get copyWith => __$RideRatingModelCopyWithImpl<_RideRatingModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideRatingModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideRatingModel&&(identical(other.stars, stars) || other.stars == stars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stars);

@override
String toString() {
  return 'RideRatingModel(stars: $stars)';
}


}

/// @nodoc
abstract mixin class _$RideRatingModelCopyWith<$Res> implements $RideRatingModelCopyWith<$Res> {
  factory _$RideRatingModelCopyWith(_RideRatingModel value, $Res Function(_RideRatingModel) _then) = __$RideRatingModelCopyWithImpl;
@override @useResult
$Res call({
 int stars
});




}
/// @nodoc
class __$RideRatingModelCopyWithImpl<$Res>
    implements _$RideRatingModelCopyWith<$Res> {
  __$RideRatingModelCopyWithImpl(this._self, this._then);

  final _RideRatingModel _self;
  final $Res Function(_RideRatingModel) _then;

/// Create a copy of RideRatingModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stars = null,}) {
  return _then(_RideRatingModel(
stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RidePromoModel {

 String get code; bool? get applied;
/// Create a copy of RidePromoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RidePromoModelCopyWith<RidePromoModel> get copyWith => _$RidePromoModelCopyWithImpl<RidePromoModel>(this as RidePromoModel, _$identity);

  /// Serializes this RidePromoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RidePromoModel&&(identical(other.code, code) || other.code == code)&&(identical(other.applied, applied) || other.applied == applied));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,applied);

@override
String toString() {
  return 'RidePromoModel(code: $code, applied: $applied)';
}


}

/// @nodoc
abstract mixin class $RidePromoModelCopyWith<$Res>  {
  factory $RidePromoModelCopyWith(RidePromoModel value, $Res Function(RidePromoModel) _then) = _$RidePromoModelCopyWithImpl;
@useResult
$Res call({
 String code, bool? applied
});




}
/// @nodoc
class _$RidePromoModelCopyWithImpl<$Res>
    implements $RidePromoModelCopyWith<$Res> {
  _$RidePromoModelCopyWithImpl(this._self, this._then);

  final RidePromoModel _self;
  final $Res Function(RidePromoModel) _then;

/// Create a copy of RidePromoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? applied = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,applied: freezed == applied ? _self.applied : applied // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [RidePromoModel].
extension RidePromoModelPatterns on RidePromoModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RidePromoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RidePromoModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RidePromoModel value)  $default,){
final _that = this;
switch (_that) {
case _RidePromoModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RidePromoModel value)?  $default,){
final _that = this;
switch (_that) {
case _RidePromoModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  bool? applied)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RidePromoModel() when $default != null:
return $default(_that.code,_that.applied);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  bool? applied)  $default,) {final _that = this;
switch (_that) {
case _RidePromoModel():
return $default(_that.code,_that.applied);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  bool? applied)?  $default,) {final _that = this;
switch (_that) {
case _RidePromoModel() when $default != null:
return $default(_that.code,_that.applied);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RidePromoModel implements RidePromoModel {
  const _RidePromoModel({required this.code, this.applied});
  factory _RidePromoModel.fromJson(Map<String, dynamic> json) => _$RidePromoModelFromJson(json);

@override final  String code;
@override final  bool? applied;

/// Create a copy of RidePromoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RidePromoModelCopyWith<_RidePromoModel> get copyWith => __$RidePromoModelCopyWithImpl<_RidePromoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RidePromoModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RidePromoModel&&(identical(other.code, code) || other.code == code)&&(identical(other.applied, applied) || other.applied == applied));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,applied);

@override
String toString() {
  return 'RidePromoModel(code: $code, applied: $applied)';
}


}

/// @nodoc
abstract mixin class _$RidePromoModelCopyWith<$Res> implements $RidePromoModelCopyWith<$Res> {
  factory _$RidePromoModelCopyWith(_RidePromoModel value, $Res Function(_RidePromoModel) _then) = __$RidePromoModelCopyWithImpl;
@override @useResult
$Res call({
 String code, bool? applied
});




}
/// @nodoc
class __$RidePromoModelCopyWithImpl<$Res>
    implements _$RidePromoModelCopyWith<$Res> {
  __$RidePromoModelCopyWithImpl(this._self, this._then);

  final _RidePromoModel _self;
  final $Res Function(_RidePromoModel) _then;

/// Create a copy of RidePromoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? applied = freezed,}) {
  return _then(_RidePromoModel(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,applied: freezed == applied ? _self.applied : applied // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
