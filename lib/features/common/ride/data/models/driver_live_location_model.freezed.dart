// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_live_location_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverLiveLocationModel {

@JsonKey(name: 'geopoint')@GeoPointConverter() GeoPointValue get point;@TimestampConverter() DateTime get updatedAt; double? get heading;
/// Create a copy of DriverLiveLocationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverLiveLocationModelCopyWith<DriverLiveLocationModel> get copyWith => _$DriverLiveLocationModelCopyWithImpl<DriverLiveLocationModel>(this as DriverLiveLocationModel, _$identity);

  /// Serializes this DriverLiveLocationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverLiveLocationModel&&(identical(other.point, point) || other.point == point)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.heading, heading) || other.heading == heading));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,point,updatedAt,heading);

@override
String toString() {
  return 'DriverLiveLocationModel(point: $point, updatedAt: $updatedAt, heading: $heading)';
}


}

/// @nodoc
abstract mixin class $DriverLiveLocationModelCopyWith<$Res>  {
  factory $DriverLiveLocationModelCopyWith(DriverLiveLocationModel value, $Res Function(DriverLiveLocationModel) _then) = _$DriverLiveLocationModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'geopoint')@GeoPointConverter() GeoPointValue point,@TimestampConverter() DateTime updatedAt, double? heading
});




}
/// @nodoc
class _$DriverLiveLocationModelCopyWithImpl<$Res>
    implements $DriverLiveLocationModelCopyWith<$Res> {
  _$DriverLiveLocationModelCopyWithImpl(this._self, this._then);

  final DriverLiveLocationModel _self;
  final $Res Function(DriverLiveLocationModel) _then;

/// Create a copy of DriverLiveLocationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? point = null,Object? updatedAt = null,Object? heading = freezed,}) {
  return _then(_self.copyWith(
point: null == point ? _self.point : point // ignore: cast_nullable_to_non_nullable
as GeoPointValue,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverLiveLocationModel].
extension DriverLiveLocationModelPatterns on DriverLiveLocationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverLiveLocationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverLiveLocationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverLiveLocationModel value)  $default,){
final _that = this;
switch (_that) {
case _DriverLiveLocationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverLiveLocationModel value)?  $default,){
final _that = this;
switch (_that) {
case _DriverLiveLocationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'geopoint')@GeoPointConverter()  GeoPointValue point, @TimestampConverter()  DateTime updatedAt,  double? heading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverLiveLocationModel() when $default != null:
return $default(_that.point,_that.updatedAt,_that.heading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'geopoint')@GeoPointConverter()  GeoPointValue point, @TimestampConverter()  DateTime updatedAt,  double? heading)  $default,) {final _that = this;
switch (_that) {
case _DriverLiveLocationModel():
return $default(_that.point,_that.updatedAt,_that.heading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'geopoint')@GeoPointConverter()  GeoPointValue point, @TimestampConverter()  DateTime updatedAt,  double? heading)?  $default,) {final _that = this;
switch (_that) {
case _DriverLiveLocationModel() when $default != null:
return $default(_that.point,_that.updatedAt,_that.heading);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverLiveLocationModel extends DriverLiveLocationModel {
  const _DriverLiveLocationModel({@JsonKey(name: 'geopoint')@GeoPointConverter() required this.point, @TimestampConverter() required this.updatedAt, this.heading}): super._();
  factory _DriverLiveLocationModel.fromJson(Map<String, dynamic> json) => _$DriverLiveLocationModelFromJson(json);

@override@JsonKey(name: 'geopoint')@GeoPointConverter() final  GeoPointValue point;
@override@TimestampConverter() final  DateTime updatedAt;
@override final  double? heading;

/// Create a copy of DriverLiveLocationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverLiveLocationModelCopyWith<_DriverLiveLocationModel> get copyWith => __$DriverLiveLocationModelCopyWithImpl<_DriverLiveLocationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverLiveLocationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverLiveLocationModel&&(identical(other.point, point) || other.point == point)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.heading, heading) || other.heading == heading));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,point,updatedAt,heading);

@override
String toString() {
  return 'DriverLiveLocationModel(point: $point, updatedAt: $updatedAt, heading: $heading)';
}


}

/// @nodoc
abstract mixin class _$DriverLiveLocationModelCopyWith<$Res> implements $DriverLiveLocationModelCopyWith<$Res> {
  factory _$DriverLiveLocationModelCopyWith(_DriverLiveLocationModel value, $Res Function(_DriverLiveLocationModel) _then) = __$DriverLiveLocationModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'geopoint')@GeoPointConverter() GeoPointValue point,@TimestampConverter() DateTime updatedAt, double? heading
});




}
/// @nodoc
class __$DriverLiveLocationModelCopyWithImpl<$Res>
    implements _$DriverLiveLocationModelCopyWith<$Res> {
  __$DriverLiveLocationModelCopyWithImpl(this._self, this._then);

  final _DriverLiveLocationModel _self;
  final $Res Function(_DriverLiveLocationModel) _then;

/// Create a copy of DriverLiveLocationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? point = null,Object? updatedAt = null,Object? heading = freezed,}) {
  return _then(_DriverLiveLocationModel(
point: null == point ? _self.point : point // ignore: cast_nullable_to_non_nullable
as GeoPointValue,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
