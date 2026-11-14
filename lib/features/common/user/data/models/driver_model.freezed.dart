// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverModel {

@JsonKey(includeToJson: false) String get id;@JsonKey(unknownEnumValue: DriverStatus.pending) DriverStatus get status; bool get isOnline; VehicleModel get vehicle; String? get licensePhotoPath; String? get rejectionReason; String? get currentRideId; DriverLocationModel? get location; double get heading;@TimestampConverter() DateTime? get lastSeenAt;
/// Create a copy of DriverModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverModelCopyWith<DriverModel> get copyWith => _$DriverModelCopyWithImpl<DriverModel>(this as DriverModel, _$identity);

  /// Serializes this DriverModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverModel&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle)&&(identical(other.licensePhotoPath, licensePhotoPath) || other.licensePhotoPath == licensePhotoPath)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.currentRideId, currentRideId) || other.currentRideId == currentRideId)&&(identical(other.location, location) || other.location == location)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,isOnline,vehicle,licensePhotoPath,rejectionReason,currentRideId,location,heading,lastSeenAt);

@override
String toString() {
  return 'DriverModel(id: $id, status: $status, isOnline: $isOnline, vehicle: $vehicle, licensePhotoPath: $licensePhotoPath, rejectionReason: $rejectionReason, currentRideId: $currentRideId, location: $location, heading: $heading, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class $DriverModelCopyWith<$Res>  {
  factory $DriverModelCopyWith(DriverModel value, $Res Function(DriverModel) _then) = _$DriverModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id,@JsonKey(unknownEnumValue: DriverStatus.pending) DriverStatus status, bool isOnline, VehicleModel vehicle, String? licensePhotoPath, String? rejectionReason, String? currentRideId, DriverLocationModel? location, double heading,@TimestampConverter() DateTime? lastSeenAt
});


$VehicleModelCopyWith<$Res> get vehicle;$DriverLocationModelCopyWith<$Res>? get location;

}
/// @nodoc
class _$DriverModelCopyWithImpl<$Res>
    implements $DriverModelCopyWith<$Res> {
  _$DriverModelCopyWithImpl(this._self, this._then);

  final DriverModel _self;
  final $Res Function(DriverModel) _then;

/// Create a copy of DriverModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? isOnline = null,Object? vehicle = null,Object? licensePhotoPath = freezed,Object? rejectionReason = freezed,Object? currentRideId = freezed,Object? location = freezed,Object? heading = null,Object? lastSeenAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DriverStatus,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,vehicle: null == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as VehicleModel,licensePhotoPath: freezed == licensePhotoPath ? _self.licensePhotoPath : licensePhotoPath // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,currentRideId: freezed == currentRideId ? _self.currentRideId : currentRideId // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as DriverLocationModel?,heading: null == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of DriverModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VehicleModelCopyWith<$Res> get vehicle {
  
  return $VehicleModelCopyWith<$Res>(_self.vehicle, (value) {
    return _then(_self.copyWith(vehicle: value));
  });
}/// Create a copy of DriverModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverLocationModelCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $DriverLocationModelCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [DriverModel].
extension DriverModelPatterns on DriverModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverModel value)  $default,){
final _that = this;
switch (_that) {
case _DriverModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverModel value)?  $default,){
final _that = this;
switch (_that) {
case _DriverModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id, @JsonKey(unknownEnumValue: DriverStatus.pending)  DriverStatus status,  bool isOnline,  VehicleModel vehicle,  String? licensePhotoPath,  String? rejectionReason,  String? currentRideId,  DriverLocationModel? location,  double heading, @TimestampConverter()  DateTime? lastSeenAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverModel() when $default != null:
return $default(_that.id,_that.status,_that.isOnline,_that.vehicle,_that.licensePhotoPath,_that.rejectionReason,_that.currentRideId,_that.location,_that.heading,_that.lastSeenAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id, @JsonKey(unknownEnumValue: DriverStatus.pending)  DriverStatus status,  bool isOnline,  VehicleModel vehicle,  String? licensePhotoPath,  String? rejectionReason,  String? currentRideId,  DriverLocationModel? location,  double heading, @TimestampConverter()  DateTime? lastSeenAt)  $default,) {final _that = this;
switch (_that) {
case _DriverModel():
return $default(_that.id,_that.status,_that.isOnline,_that.vehicle,_that.licensePhotoPath,_that.rejectionReason,_that.currentRideId,_that.location,_that.heading,_that.lastSeenAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id, @JsonKey(unknownEnumValue: DriverStatus.pending)  DriverStatus status,  bool isOnline,  VehicleModel vehicle,  String? licensePhotoPath,  String? rejectionReason,  String? currentRideId,  DriverLocationModel? location,  double heading, @TimestampConverter()  DateTime? lastSeenAt)?  $default,) {final _that = this;
switch (_that) {
case _DriverModel() when $default != null:
return $default(_that.id,_that.status,_that.isOnline,_that.vehicle,_that.licensePhotoPath,_that.rejectionReason,_that.currentRideId,_that.location,_that.heading,_that.lastSeenAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _DriverModel extends DriverModel {
  const _DriverModel({@JsonKey(includeToJson: false) required this.id, @JsonKey(unknownEnumValue: DriverStatus.pending) required this.status, required this.isOnline, required this.vehicle, this.licensePhotoPath, this.rejectionReason, this.currentRideId, this.location, this.heading = 0, @TimestampConverter() this.lastSeenAt}): super._();
  factory _DriverModel.fromJson(Map<String, dynamic> json) => _$DriverModelFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override@JsonKey(unknownEnumValue: DriverStatus.pending) final  DriverStatus status;
@override final  bool isOnline;
@override final  VehicleModel vehicle;
@override final  String? licensePhotoPath;
@override final  String? rejectionReason;
@override final  String? currentRideId;
@override final  DriverLocationModel? location;
@override@JsonKey() final  double heading;
@override@TimestampConverter() final  DateTime? lastSeenAt;

/// Create a copy of DriverModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverModelCopyWith<_DriverModel> get copyWith => __$DriverModelCopyWithImpl<_DriverModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverModel&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle)&&(identical(other.licensePhotoPath, licensePhotoPath) || other.licensePhotoPath == licensePhotoPath)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.currentRideId, currentRideId) || other.currentRideId == currentRideId)&&(identical(other.location, location) || other.location == location)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,isOnline,vehicle,licensePhotoPath,rejectionReason,currentRideId,location,heading,lastSeenAt);

@override
String toString() {
  return 'DriverModel(id: $id, status: $status, isOnline: $isOnline, vehicle: $vehicle, licensePhotoPath: $licensePhotoPath, rejectionReason: $rejectionReason, currentRideId: $currentRideId, location: $location, heading: $heading, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class _$DriverModelCopyWith<$Res> implements $DriverModelCopyWith<$Res> {
  factory _$DriverModelCopyWith(_DriverModel value, $Res Function(_DriverModel) _then) = __$DriverModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id,@JsonKey(unknownEnumValue: DriverStatus.pending) DriverStatus status, bool isOnline, VehicleModel vehicle, String? licensePhotoPath, String? rejectionReason, String? currentRideId, DriverLocationModel? location, double heading,@TimestampConverter() DateTime? lastSeenAt
});


@override $VehicleModelCopyWith<$Res> get vehicle;@override $DriverLocationModelCopyWith<$Res>? get location;

}
/// @nodoc
class __$DriverModelCopyWithImpl<$Res>
    implements _$DriverModelCopyWith<$Res> {
  __$DriverModelCopyWithImpl(this._self, this._then);

  final _DriverModel _self;
  final $Res Function(_DriverModel) _then;

/// Create a copy of DriverModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? isOnline = null,Object? vehicle = null,Object? licensePhotoPath = freezed,Object? rejectionReason = freezed,Object? currentRideId = freezed,Object? location = freezed,Object? heading = null,Object? lastSeenAt = freezed,}) {
  return _then(_DriverModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DriverStatus,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,vehicle: null == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as VehicleModel,licensePhotoPath: freezed == licensePhotoPath ? _self.licensePhotoPath : licensePhotoPath // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,currentRideId: freezed == currentRideId ? _self.currentRideId : currentRideId // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as DriverLocationModel?,heading: null == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of DriverModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VehicleModelCopyWith<$Res> get vehicle {
  
  return $VehicleModelCopyWith<$Res>(_self.vehicle, (value) {
    return _then(_self.copyWith(vehicle: value));
  });
}/// Create a copy of DriverModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverLocationModelCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $DriverLocationModelCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// @nodoc
mixin _$DriverLocationModel {

@GeoPointConverter() GeoPointValue get geopoint; String get geohash;
/// Create a copy of DriverLocationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverLocationModelCopyWith<DriverLocationModel> get copyWith => _$DriverLocationModelCopyWithImpl<DriverLocationModel>(this as DriverLocationModel, _$identity);

  /// Serializes this DriverLocationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverLocationModel&&(identical(other.geopoint, geopoint) || other.geopoint == geopoint)&&(identical(other.geohash, geohash) || other.geohash == geohash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,geopoint,geohash);

@override
String toString() {
  return 'DriverLocationModel(geopoint: $geopoint, geohash: $geohash)';
}


}

/// @nodoc
abstract mixin class $DriverLocationModelCopyWith<$Res>  {
  factory $DriverLocationModelCopyWith(DriverLocationModel value, $Res Function(DriverLocationModel) _then) = _$DriverLocationModelCopyWithImpl;
@useResult
$Res call({
@GeoPointConverter() GeoPointValue geopoint, String geohash
});




}
/// @nodoc
class _$DriverLocationModelCopyWithImpl<$Res>
    implements $DriverLocationModelCopyWith<$Res> {
  _$DriverLocationModelCopyWithImpl(this._self, this._then);

  final DriverLocationModel _self;
  final $Res Function(DriverLocationModel) _then;

/// Create a copy of DriverLocationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? geopoint = null,Object? geohash = null,}) {
  return _then(_self.copyWith(
geopoint: null == geopoint ? _self.geopoint : geopoint // ignore: cast_nullable_to_non_nullable
as GeoPointValue,geohash: null == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverLocationModel].
extension DriverLocationModelPatterns on DriverLocationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverLocationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverLocationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverLocationModel value)  $default,){
final _that = this;
switch (_that) {
case _DriverLocationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverLocationModel value)?  $default,){
final _that = this;
switch (_that) {
case _DriverLocationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@GeoPointConverter()  GeoPointValue geopoint,  String geohash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverLocationModel() when $default != null:
return $default(_that.geopoint,_that.geohash);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@GeoPointConverter()  GeoPointValue geopoint,  String geohash)  $default,) {final _that = this;
switch (_that) {
case _DriverLocationModel():
return $default(_that.geopoint,_that.geohash);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@GeoPointConverter()  GeoPointValue geopoint,  String geohash)?  $default,) {final _that = this;
switch (_that) {
case _DriverLocationModel() when $default != null:
return $default(_that.geopoint,_that.geohash);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverLocationModel extends DriverLocationModel {
  const _DriverLocationModel({@GeoPointConverter() required this.geopoint, required this.geohash}): super._();
  factory _DriverLocationModel.fromJson(Map<String, dynamic> json) => _$DriverLocationModelFromJson(json);

@override@GeoPointConverter() final  GeoPointValue geopoint;
@override final  String geohash;

/// Create a copy of DriverLocationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverLocationModelCopyWith<_DriverLocationModel> get copyWith => __$DriverLocationModelCopyWithImpl<_DriverLocationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverLocationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverLocationModel&&(identical(other.geopoint, geopoint) || other.geopoint == geopoint)&&(identical(other.geohash, geohash) || other.geohash == geohash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,geopoint,geohash);

@override
String toString() {
  return 'DriverLocationModel(geopoint: $geopoint, geohash: $geohash)';
}


}

/// @nodoc
abstract mixin class _$DriverLocationModelCopyWith<$Res> implements $DriverLocationModelCopyWith<$Res> {
  factory _$DriverLocationModelCopyWith(_DriverLocationModel value, $Res Function(_DriverLocationModel) _then) = __$DriverLocationModelCopyWithImpl;
@override @useResult
$Res call({
@GeoPointConverter() GeoPointValue geopoint, String geohash
});




}
/// @nodoc
class __$DriverLocationModelCopyWithImpl<$Res>
    implements _$DriverLocationModelCopyWith<$Res> {
  __$DriverLocationModelCopyWithImpl(this._self, this._then);

  final _DriverLocationModel _self;
  final $Res Function(_DriverLocationModel) _then;

/// Create a copy of DriverLocationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? geopoint = null,Object? geohash = null,}) {
  return _then(_DriverLocationModel(
geopoint: null == geopoint ? _self.geopoint : geopoint // ignore: cast_nullable_to_non_nullable
as GeoPointValue,geohash: null == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
