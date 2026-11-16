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

 double get estimated; String get currency;@JsonKey(name: 'final') double? get finalAmount;
/// Create a copy of RideFareModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideFareModelCopyWith<RideFareModel> get copyWith => _$RideFareModelCopyWithImpl<RideFareModel>(this as RideFareModel, _$identity);

  /// Serializes this RideFareModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideFareModel&&(identical(other.estimated, estimated) || other.estimated == estimated)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.finalAmount, finalAmount) || other.finalAmount == finalAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,estimated,currency,finalAmount);

@override
String toString() {
  return 'RideFareModel(estimated: $estimated, currency: $currency, finalAmount: $finalAmount)';
}


}

/// @nodoc
abstract mixin class $RideFareModelCopyWith<$Res>  {
  factory $RideFareModelCopyWith(RideFareModel value, $Res Function(RideFareModel) _then) = _$RideFareModelCopyWithImpl;
@useResult
$Res call({
 double estimated, String currency,@JsonKey(name: 'final') double? finalAmount
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
@pragma('vm:prefer-inline') @override $Res call({Object? estimated = null,Object? currency = null,Object? finalAmount = freezed,}) {
  return _then(_self.copyWith(
estimated: null == estimated ? _self.estimated : estimated // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,finalAmount: freezed == finalAmount ? _self.finalAmount : finalAmount // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double estimated,  String currency, @JsonKey(name: 'final')  double? finalAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideFareModel() when $default != null:
return $default(_that.estimated,_that.currency,_that.finalAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double estimated,  String currency, @JsonKey(name: 'final')  double? finalAmount)  $default,) {final _that = this;
switch (_that) {
case _RideFareModel():
return $default(_that.estimated,_that.currency,_that.finalAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double estimated,  String currency, @JsonKey(name: 'final')  double? finalAmount)?  $default,) {final _that = this;
switch (_that) {
case _RideFareModel() when $default != null:
return $default(_that.estimated,_that.currency,_that.finalAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideFareModel implements RideFareModel {
  const _RideFareModel({required this.estimated, required this.currency, @JsonKey(name: 'final') this.finalAmount});
  factory _RideFareModel.fromJson(Map<String, dynamic> json) => _$RideFareModelFromJson(json);

@override final  double estimated;
@override final  String currency;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideFareModel&&(identical(other.estimated, estimated) || other.estimated == estimated)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.finalAmount, finalAmount) || other.finalAmount == finalAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,estimated,currency,finalAmount);

@override
String toString() {
  return 'RideFareModel(estimated: $estimated, currency: $currency, finalAmount: $finalAmount)';
}


}

/// @nodoc
abstract mixin class _$RideFareModelCopyWith<$Res> implements $RideFareModelCopyWith<$Res> {
  factory _$RideFareModelCopyWith(_RideFareModel value, $Res Function(_RideFareModel) _then) = __$RideFareModelCopyWithImpl;
@override @useResult
$Res call({
 double estimated, String currency,@JsonKey(name: 'final') double? finalAmount
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
@override @pragma('vm:prefer-inline') $Res call({Object? estimated = null,Object? currency = null,Object? finalAmount = freezed,}) {
  return _then(_RideFareModel(
estimated: null == estimated ? _self.estimated : estimated // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,finalAmount: freezed == finalAmount ? _self.finalAmount : finalAmount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$RideModel {

 String get id; String get riderId;@RideStatusConverter() RideStatus get status; VehicleType get vehicleType; RidePlaceModel get pickup; RidePlaceModel get dropoff; RideFareModel get fare;@TimestampConverter() DateTime get createdAt; String? get driverId; RouteModel? get route; String? get cancelledBy;@TimestampConverter() DateTime? get searchExpiresAt;@TimestampConverter() DateTime? get offerExpiresAt; int? get offerDistanceMeters;
/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideModelCopyWith<RideModel> get copyWith => _$RideModelCopyWithImpl<RideModel>(this as RideModel, _$identity);

  /// Serializes this RideModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideModel&&(identical(other.id, id) || other.id == id)&&(identical(other.riderId, riderId) || other.riderId == riderId)&&(identical(other.status, status) || other.status == status)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.pickup, pickup) || other.pickup == pickup)&&(identical(other.dropoff, dropoff) || other.dropoff == dropoff)&&(identical(other.fare, fare) || other.fare == fare)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.route, route) || other.route == route)&&(identical(other.cancelledBy, cancelledBy) || other.cancelledBy == cancelledBy)&&(identical(other.searchExpiresAt, searchExpiresAt) || other.searchExpiresAt == searchExpiresAt)&&(identical(other.offerExpiresAt, offerExpiresAt) || other.offerExpiresAt == offerExpiresAt)&&(identical(other.offerDistanceMeters, offerDistanceMeters) || other.offerDistanceMeters == offerDistanceMeters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,riderId,status,vehicleType,pickup,dropoff,fare,createdAt,driverId,route,cancelledBy,searchExpiresAt,offerExpiresAt,offerDistanceMeters);

@override
String toString() {
  return 'RideModel(id: $id, riderId: $riderId, status: $status, vehicleType: $vehicleType, pickup: $pickup, dropoff: $dropoff, fare: $fare, createdAt: $createdAt, driverId: $driverId, route: $route, cancelledBy: $cancelledBy, searchExpiresAt: $searchExpiresAt, offerExpiresAt: $offerExpiresAt, offerDistanceMeters: $offerDistanceMeters)';
}


}

/// @nodoc
abstract mixin class $RideModelCopyWith<$Res>  {
  factory $RideModelCopyWith(RideModel value, $Res Function(RideModel) _then) = _$RideModelCopyWithImpl;
@useResult
$Res call({
 String id, String riderId,@RideStatusConverter() RideStatus status, VehicleType vehicleType, RidePlaceModel pickup, RidePlaceModel dropoff, RideFareModel fare,@TimestampConverter() DateTime createdAt, String? driverId, RouteModel? route, String? cancelledBy,@TimestampConverter() DateTime? searchExpiresAt,@TimestampConverter() DateTime? offerExpiresAt, int? offerDistanceMeters
});


$RidePlaceModelCopyWith<$Res> get pickup;$RidePlaceModelCopyWith<$Res> get dropoff;$RideFareModelCopyWith<$Res> get fare;$RouteModelCopyWith<$Res>? get route;

}
/// @nodoc
class _$RideModelCopyWithImpl<$Res>
    implements $RideModelCopyWith<$Res> {
  _$RideModelCopyWithImpl(this._self, this._then);

  final RideModel _self;
  final $Res Function(RideModel) _then;

/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? riderId = null,Object? status = null,Object? vehicleType = null,Object? pickup = null,Object? dropoff = null,Object? fare = null,Object? createdAt = null,Object? driverId = freezed,Object? route = freezed,Object? cancelledBy = freezed,Object? searchExpiresAt = freezed,Object? offerExpiresAt = freezed,Object? offerDistanceMeters = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,riderId: null == riderId ? _self.riderId : riderId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideStatus,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,pickup: null == pickup ? _self.pickup : pickup // ignore: cast_nullable_to_non_nullable
as RidePlaceModel,dropoff: null == dropoff ? _self.dropoff : dropoff // ignore: cast_nullable_to_non_nullable
as RidePlaceModel,fare: null == fare ? _self.fare : fare // ignore: cast_nullable_to_non_nullable
as RideFareModel,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String riderId, @RideStatusConverter()  RideStatus status,  VehicleType vehicleType,  RidePlaceModel pickup,  RidePlaceModel dropoff,  RideFareModel fare, @TimestampConverter()  DateTime createdAt,  String? driverId,  RouteModel? route,  String? cancelledBy, @TimestampConverter()  DateTime? searchExpiresAt, @TimestampConverter()  DateTime? offerExpiresAt,  int? offerDistanceMeters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideModel() when $default != null:
return $default(_that.id,_that.riderId,_that.status,_that.vehicleType,_that.pickup,_that.dropoff,_that.fare,_that.createdAt,_that.driverId,_that.route,_that.cancelledBy,_that.searchExpiresAt,_that.offerExpiresAt,_that.offerDistanceMeters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String riderId, @RideStatusConverter()  RideStatus status,  VehicleType vehicleType,  RidePlaceModel pickup,  RidePlaceModel dropoff,  RideFareModel fare, @TimestampConverter()  DateTime createdAt,  String? driverId,  RouteModel? route,  String? cancelledBy, @TimestampConverter()  DateTime? searchExpiresAt, @TimestampConverter()  DateTime? offerExpiresAt,  int? offerDistanceMeters)  $default,) {final _that = this;
switch (_that) {
case _RideModel():
return $default(_that.id,_that.riderId,_that.status,_that.vehicleType,_that.pickup,_that.dropoff,_that.fare,_that.createdAt,_that.driverId,_that.route,_that.cancelledBy,_that.searchExpiresAt,_that.offerExpiresAt,_that.offerDistanceMeters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String riderId, @RideStatusConverter()  RideStatus status,  VehicleType vehicleType,  RidePlaceModel pickup,  RidePlaceModel dropoff,  RideFareModel fare, @TimestampConverter()  DateTime createdAt,  String? driverId,  RouteModel? route,  String? cancelledBy, @TimestampConverter()  DateTime? searchExpiresAt, @TimestampConverter()  DateTime? offerExpiresAt,  int? offerDistanceMeters)?  $default,) {final _that = this;
switch (_that) {
case _RideModel() when $default != null:
return $default(_that.id,_that.riderId,_that.status,_that.vehicleType,_that.pickup,_that.dropoff,_that.fare,_that.createdAt,_that.driverId,_that.route,_that.cancelledBy,_that.searchExpiresAt,_that.offerExpiresAt,_that.offerDistanceMeters);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _RideModel extends RideModel {
  const _RideModel({required this.id, required this.riderId, @RideStatusConverter() required this.status, required this.vehicleType, required this.pickup, required this.dropoff, required this.fare, @TimestampConverter() required this.createdAt, this.driverId, this.route, this.cancelledBy, @TimestampConverter() this.searchExpiresAt, @TimestampConverter() this.offerExpiresAt, this.offerDistanceMeters}): super._();
  factory _RideModel.fromJson(Map<String, dynamic> json) => _$RideModelFromJson(json);

@override final  String id;
@override final  String riderId;
@override@RideStatusConverter() final  RideStatus status;
@override final  VehicleType vehicleType;
@override final  RidePlaceModel pickup;
@override final  RidePlaceModel dropoff;
@override final  RideFareModel fare;
@override@TimestampConverter() final  DateTime createdAt;
@override final  String? driverId;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideModel&&(identical(other.id, id) || other.id == id)&&(identical(other.riderId, riderId) || other.riderId == riderId)&&(identical(other.status, status) || other.status == status)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.pickup, pickup) || other.pickup == pickup)&&(identical(other.dropoff, dropoff) || other.dropoff == dropoff)&&(identical(other.fare, fare) || other.fare == fare)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.route, route) || other.route == route)&&(identical(other.cancelledBy, cancelledBy) || other.cancelledBy == cancelledBy)&&(identical(other.searchExpiresAt, searchExpiresAt) || other.searchExpiresAt == searchExpiresAt)&&(identical(other.offerExpiresAt, offerExpiresAt) || other.offerExpiresAt == offerExpiresAt)&&(identical(other.offerDistanceMeters, offerDistanceMeters) || other.offerDistanceMeters == offerDistanceMeters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,riderId,status,vehicleType,pickup,dropoff,fare,createdAt,driverId,route,cancelledBy,searchExpiresAt,offerExpiresAt,offerDistanceMeters);

@override
String toString() {
  return 'RideModel(id: $id, riderId: $riderId, status: $status, vehicleType: $vehicleType, pickup: $pickup, dropoff: $dropoff, fare: $fare, createdAt: $createdAt, driverId: $driverId, route: $route, cancelledBy: $cancelledBy, searchExpiresAt: $searchExpiresAt, offerExpiresAt: $offerExpiresAt, offerDistanceMeters: $offerDistanceMeters)';
}


}

/// @nodoc
abstract mixin class _$RideModelCopyWith<$Res> implements $RideModelCopyWith<$Res> {
  factory _$RideModelCopyWith(_RideModel value, $Res Function(_RideModel) _then) = __$RideModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String riderId,@RideStatusConverter() RideStatus status, VehicleType vehicleType, RidePlaceModel pickup, RidePlaceModel dropoff, RideFareModel fare,@TimestampConverter() DateTime createdAt, String? driverId, RouteModel? route, String? cancelledBy,@TimestampConverter() DateTime? searchExpiresAt,@TimestampConverter() DateTime? offerExpiresAt, int? offerDistanceMeters
});


@override $RidePlaceModelCopyWith<$Res> get pickup;@override $RidePlaceModelCopyWith<$Res> get dropoff;@override $RideFareModelCopyWith<$Res> get fare;@override $RouteModelCopyWith<$Res>? get route;

}
/// @nodoc
class __$RideModelCopyWithImpl<$Res>
    implements _$RideModelCopyWith<$Res> {
  __$RideModelCopyWithImpl(this._self, this._then);

  final _RideModel _self;
  final $Res Function(_RideModel) _then;

/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? riderId = null,Object? status = null,Object? vehicleType = null,Object? pickup = null,Object? dropoff = null,Object? fare = null,Object? createdAt = null,Object? driverId = freezed,Object? route = freezed,Object? cancelledBy = freezed,Object? searchExpiresAt = freezed,Object? offerExpiresAt = freezed,Object? offerDistanceMeters = freezed,}) {
  return _then(_RideModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,riderId: null == riderId ? _self.riderId : riderId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideStatus,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,pickup: null == pickup ? _self.pickup : pickup // ignore: cast_nullable_to_non_nullable
as RidePlaceModel,dropoff: null == dropoff ? _self.dropoff : dropoff // ignore: cast_nullable_to_non_nullable
as RidePlaceModel,fare: null == fare ? _self.fare : fare // ignore: cast_nullable_to_non_nullable
as RideFareModel,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
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
$RouteModelCopyWith<$Res>? get route {
    if (_self.route == null) {
    return null;
  }

  return $RouteModelCopyWith<$Res>(_self.route!, (value) {
    return _then(_self.copyWith(route: value));
  });
}
}

// dart format on
