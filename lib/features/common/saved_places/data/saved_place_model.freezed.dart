// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_place_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavedPlaceModel {

@JsonKey(includeToJson: false) String get id; SavedPlaceLabel get label; String get name; String get address;@GeoPointConverter() GeoPointValue get geopoint;@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of SavedPlaceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedPlaceModelCopyWith<SavedPlaceModel> get copyWith => _$SavedPlaceModelCopyWithImpl<SavedPlaceModel>(this as SavedPlaceModel, _$identity);

  /// Serializes this SavedPlaceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedPlaceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.geopoint, geopoint) || other.geopoint == geopoint)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,name,address,geopoint,updatedAt);

@override
String toString() {
  return 'SavedPlaceModel(id: $id, label: $label, name: $name, address: $address, geopoint: $geopoint, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SavedPlaceModelCopyWith<$Res>  {
  factory $SavedPlaceModelCopyWith(SavedPlaceModel value, $Res Function(SavedPlaceModel) _then) = _$SavedPlaceModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, SavedPlaceLabel label, String name, String address,@GeoPointConverter() GeoPointValue geopoint,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$SavedPlaceModelCopyWithImpl<$Res>
    implements $SavedPlaceModelCopyWith<$Res> {
  _$SavedPlaceModelCopyWithImpl(this._self, this._then);

  final SavedPlaceModel _self;
  final $Res Function(SavedPlaceModel) _then;

/// Create a copy of SavedPlaceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? name = null,Object? address = null,Object? geopoint = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as SavedPlaceLabel,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,geopoint: null == geopoint ? _self.geopoint : geopoint // ignore: cast_nullable_to_non_nullable
as GeoPointValue,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedPlaceModel].
extension SavedPlaceModelPatterns on SavedPlaceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedPlaceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedPlaceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedPlaceModel value)  $default,){
final _that = this;
switch (_that) {
case _SavedPlaceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedPlaceModel value)?  $default,){
final _that = this;
switch (_that) {
case _SavedPlaceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  SavedPlaceLabel label,  String name,  String address, @GeoPointConverter()  GeoPointValue geopoint, @TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedPlaceModel() when $default != null:
return $default(_that.id,_that.label,_that.name,_that.address,_that.geopoint,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  SavedPlaceLabel label,  String name,  String address, @GeoPointConverter()  GeoPointValue geopoint, @TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SavedPlaceModel():
return $default(_that.id,_that.label,_that.name,_that.address,_that.geopoint,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  SavedPlaceLabel label,  String name,  String address, @GeoPointConverter()  GeoPointValue geopoint, @TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SavedPlaceModel() when $default != null:
return $default(_that.id,_that.label,_that.name,_that.address,_that.geopoint,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavedPlaceModel extends SavedPlaceModel {
  const _SavedPlaceModel({@JsonKey(includeToJson: false) required this.id, required this.label, required this.name, required this.address, @GeoPointConverter() required this.geopoint, @TimestampConverter() this.updatedAt}): super._();
  factory _SavedPlaceModel.fromJson(Map<String, dynamic> json) => _$SavedPlaceModelFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  SavedPlaceLabel label;
@override final  String name;
@override final  String address;
@override@GeoPointConverter() final  GeoPointValue geopoint;
@override@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of SavedPlaceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedPlaceModelCopyWith<_SavedPlaceModel> get copyWith => __$SavedPlaceModelCopyWithImpl<_SavedPlaceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedPlaceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedPlaceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.geopoint, geopoint) || other.geopoint == geopoint)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,name,address,geopoint,updatedAt);

@override
String toString() {
  return 'SavedPlaceModel(id: $id, label: $label, name: $name, address: $address, geopoint: $geopoint, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SavedPlaceModelCopyWith<$Res> implements $SavedPlaceModelCopyWith<$Res> {
  factory _$SavedPlaceModelCopyWith(_SavedPlaceModel value, $Res Function(_SavedPlaceModel) _then) = __$SavedPlaceModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, SavedPlaceLabel label, String name, String address,@GeoPointConverter() GeoPointValue geopoint,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$SavedPlaceModelCopyWithImpl<$Res>
    implements _$SavedPlaceModelCopyWith<$Res> {
  __$SavedPlaceModelCopyWithImpl(this._self, this._then);

  final _SavedPlaceModel _self;
  final $Res Function(_SavedPlaceModel) _then;

/// Create a copy of SavedPlaceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? name = null,Object? address = null,Object? geopoint = null,Object? updatedAt = freezed,}) {
  return _then(_SavedPlaceModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as SavedPlaceLabel,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,geopoint: null == geopoint ? _self.geopoint : geopoint // ignore: cast_nullable_to_non_nullable
as GeoPointValue,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
