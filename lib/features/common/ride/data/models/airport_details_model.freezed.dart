// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'airport_details_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AirportDetailsModel {

@AirportDirectionConverter() AirportDirection get direction; String? get flightNumber; bool get fixedFare;
/// Create a copy of AirportDetailsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AirportDetailsModelCopyWith<AirportDetailsModel> get copyWith => _$AirportDetailsModelCopyWithImpl<AirportDetailsModel>(this as AirportDetailsModel, _$identity);

  /// Serializes this AirportDetailsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AirportDetailsModel&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.flightNumber, flightNumber) || other.flightNumber == flightNumber)&&(identical(other.fixedFare, fixedFare) || other.fixedFare == fixedFare));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,direction,flightNumber,fixedFare);

@override
String toString() {
  return 'AirportDetailsModel(direction: $direction, flightNumber: $flightNumber, fixedFare: $fixedFare)';
}


}

/// @nodoc
abstract mixin class $AirportDetailsModelCopyWith<$Res>  {
  factory $AirportDetailsModelCopyWith(AirportDetailsModel value, $Res Function(AirportDetailsModel) _then) = _$AirportDetailsModelCopyWithImpl;
@useResult
$Res call({
@AirportDirectionConverter() AirportDirection direction, String? flightNumber, bool fixedFare
});




}
/// @nodoc
class _$AirportDetailsModelCopyWithImpl<$Res>
    implements $AirportDetailsModelCopyWith<$Res> {
  _$AirportDetailsModelCopyWithImpl(this._self, this._then);

  final AirportDetailsModel _self;
  final $Res Function(AirportDetailsModel) _then;

/// Create a copy of AirportDetailsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? direction = null,Object? flightNumber = freezed,Object? fixedFare = null,}) {
  return _then(_self.copyWith(
direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as AirportDirection,flightNumber: freezed == flightNumber ? _self.flightNumber : flightNumber // ignore: cast_nullable_to_non_nullable
as String?,fixedFare: null == fixedFare ? _self.fixedFare : fixedFare // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AirportDetailsModel].
extension AirportDetailsModelPatterns on AirportDetailsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AirportDetailsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AirportDetailsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AirportDetailsModel value)  $default,){
final _that = this;
switch (_that) {
case _AirportDetailsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AirportDetailsModel value)?  $default,){
final _that = this;
switch (_that) {
case _AirportDetailsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@AirportDirectionConverter()  AirportDirection direction,  String? flightNumber,  bool fixedFare)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AirportDetailsModel() when $default != null:
return $default(_that.direction,_that.flightNumber,_that.fixedFare);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@AirportDirectionConverter()  AirportDirection direction,  String? flightNumber,  bool fixedFare)  $default,) {final _that = this;
switch (_that) {
case _AirportDetailsModel():
return $default(_that.direction,_that.flightNumber,_that.fixedFare);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@AirportDirectionConverter()  AirportDirection direction,  String? flightNumber,  bool fixedFare)?  $default,) {final _that = this;
switch (_that) {
case _AirportDetailsModel() when $default != null:
return $default(_that.direction,_that.flightNumber,_that.fixedFare);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AirportDetailsModel extends AirportDetailsModel {
  const _AirportDetailsModel({@AirportDirectionConverter() required this.direction, this.flightNumber, this.fixedFare = true}): super._();
  factory _AirportDetailsModel.fromJson(Map<String, dynamic> json) => _$AirportDetailsModelFromJson(json);

@override@AirportDirectionConverter() final  AirportDirection direction;
@override final  String? flightNumber;
@override@JsonKey() final  bool fixedFare;

/// Create a copy of AirportDetailsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AirportDetailsModelCopyWith<_AirportDetailsModel> get copyWith => __$AirportDetailsModelCopyWithImpl<_AirportDetailsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AirportDetailsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AirportDetailsModel&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.flightNumber, flightNumber) || other.flightNumber == flightNumber)&&(identical(other.fixedFare, fixedFare) || other.fixedFare == fixedFare));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,direction,flightNumber,fixedFare);

@override
String toString() {
  return 'AirportDetailsModel(direction: $direction, flightNumber: $flightNumber, fixedFare: $fixedFare)';
}


}

/// @nodoc
abstract mixin class _$AirportDetailsModelCopyWith<$Res> implements $AirportDetailsModelCopyWith<$Res> {
  factory _$AirportDetailsModelCopyWith(_AirportDetailsModel value, $Res Function(_AirportDetailsModel) _then) = __$AirportDetailsModelCopyWithImpl;
@override @useResult
$Res call({
@AirportDirectionConverter() AirportDirection direction, String? flightNumber, bool fixedFare
});




}
/// @nodoc
class __$AirportDetailsModelCopyWithImpl<$Res>
    implements _$AirportDetailsModelCopyWith<$Res> {
  __$AirportDetailsModelCopyWithImpl(this._self, this._then);

  final _AirportDetailsModel _self;
  final $Res Function(_AirportDetailsModel) _then;

/// Create a copy of AirportDetailsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? direction = null,Object? flightNumber = freezed,Object? fixedFare = null,}) {
  return _then(_AirportDetailsModel(
direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as AirportDirection,flightNumber: freezed == flightNumber ? _self.flightNumber : flightNumber // ignore: cast_nullable_to_non_nullable
as String?,fixedFare: null == fixedFare ? _self.fixedFare : fixedFare // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
