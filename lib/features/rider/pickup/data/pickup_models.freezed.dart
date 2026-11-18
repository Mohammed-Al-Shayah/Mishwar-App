// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pickup_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PickupAddressModel {

 String get name; String get address;
/// Create a copy of PickupAddressModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PickupAddressModelCopyWith<PickupAddressModel> get copyWith => _$PickupAddressModelCopyWithImpl<PickupAddressModel>(this as PickupAddressModel, _$identity);

  /// Serializes this PickupAddressModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PickupAddressModel&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,address);

@override
String toString() {
  return 'PickupAddressModel(name: $name, address: $address)';
}


}

/// @nodoc
abstract mixin class $PickupAddressModelCopyWith<$Res>  {
  factory $PickupAddressModelCopyWith(PickupAddressModel value, $Res Function(PickupAddressModel) _then) = _$PickupAddressModelCopyWithImpl;
@useResult
$Res call({
 String name, String address
});




}
/// @nodoc
class _$PickupAddressModelCopyWithImpl<$Res>
    implements $PickupAddressModelCopyWith<$Res> {
  _$PickupAddressModelCopyWithImpl(this._self, this._then);

  final PickupAddressModel _self;
  final $Res Function(PickupAddressModel) _then;

/// Create a copy of PickupAddressModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? address = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PickupAddressModel].
extension PickupAddressModelPatterns on PickupAddressModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PickupAddressModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PickupAddressModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PickupAddressModel value)  $default,){
final _that = this;
switch (_that) {
case _PickupAddressModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PickupAddressModel value)?  $default,){
final _that = this;
switch (_that) {
case _PickupAddressModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PickupAddressModel() when $default != null:
return $default(_that.name,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String address)  $default,) {final _that = this;
switch (_that) {
case _PickupAddressModel():
return $default(_that.name,_that.address);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String address)?  $default,) {final _that = this;
switch (_that) {
case _PickupAddressModel() when $default != null:
return $default(_that.name,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PickupAddressModel extends PickupAddressModel {
  const _PickupAddressModel({required this.name, required this.address}): super._();
  factory _PickupAddressModel.fromJson(Map<String, dynamic> json) => _$PickupAddressModelFromJson(json);

@override final  String name;
@override final  String address;

/// Create a copy of PickupAddressModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PickupAddressModelCopyWith<_PickupAddressModel> get copyWith => __$PickupAddressModelCopyWithImpl<_PickupAddressModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PickupAddressModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PickupAddressModel&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,address);

@override
String toString() {
  return 'PickupAddressModel(name: $name, address: $address)';
}


}

/// @nodoc
abstract mixin class _$PickupAddressModelCopyWith<$Res> implements $PickupAddressModelCopyWith<$Res> {
  factory _$PickupAddressModelCopyWith(_PickupAddressModel value, $Res Function(_PickupAddressModel) _then) = __$PickupAddressModelCopyWithImpl;
@override @useResult
$Res call({
 String name, String address
});




}
/// @nodoc
class __$PickupAddressModelCopyWithImpl<$Res>
    implements _$PickupAddressModelCopyWith<$Res> {
  __$PickupAddressModelCopyWithImpl(this._self, this._then);

  final _PickupAddressModel _self;
  final $Res Function(_PickupAddressModel) _then;

/// Create a copy of PickupAddressModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? address = null,}) {
  return _then(_PickupAddressModel(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PickupSuggestionModel {

 String get id; String get name; double get lat; double get lng; double get distanceMeters;
/// Create a copy of PickupSuggestionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PickupSuggestionModelCopyWith<PickupSuggestionModel> get copyWith => _$PickupSuggestionModelCopyWithImpl<PickupSuggestionModel>(this as PickupSuggestionModel, _$identity);

  /// Serializes this PickupSuggestionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PickupSuggestionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,lat,lng,distanceMeters);

@override
String toString() {
  return 'PickupSuggestionModel(id: $id, name: $name, lat: $lat, lng: $lng, distanceMeters: $distanceMeters)';
}


}

/// @nodoc
abstract mixin class $PickupSuggestionModelCopyWith<$Res>  {
  factory $PickupSuggestionModelCopyWith(PickupSuggestionModel value, $Res Function(PickupSuggestionModel) _then) = _$PickupSuggestionModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, double lat, double lng, double distanceMeters
});




}
/// @nodoc
class _$PickupSuggestionModelCopyWithImpl<$Res>
    implements $PickupSuggestionModelCopyWith<$Res> {
  _$PickupSuggestionModelCopyWithImpl(this._self, this._then);

  final PickupSuggestionModel _self;
  final $Res Function(PickupSuggestionModel) _then;

/// Create a copy of PickupSuggestionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? lat = null,Object? lng = null,Object? distanceMeters = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PickupSuggestionModel].
extension PickupSuggestionModelPatterns on PickupSuggestionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PickupSuggestionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PickupSuggestionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PickupSuggestionModel value)  $default,){
final _that = this;
switch (_that) {
case _PickupSuggestionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PickupSuggestionModel value)?  $default,){
final _that = this;
switch (_that) {
case _PickupSuggestionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double lat,  double lng,  double distanceMeters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PickupSuggestionModel() when $default != null:
return $default(_that.id,_that.name,_that.lat,_that.lng,_that.distanceMeters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double lat,  double lng,  double distanceMeters)  $default,) {final _that = this;
switch (_that) {
case _PickupSuggestionModel():
return $default(_that.id,_that.name,_that.lat,_that.lng,_that.distanceMeters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double lat,  double lng,  double distanceMeters)?  $default,) {final _that = this;
switch (_that) {
case _PickupSuggestionModel() when $default != null:
return $default(_that.id,_that.name,_that.lat,_that.lng,_that.distanceMeters);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PickupSuggestionModel extends PickupSuggestionModel {
  const _PickupSuggestionModel({required this.id, required this.name, required this.lat, required this.lng, required this.distanceMeters}): super._();
  factory _PickupSuggestionModel.fromJson(Map<String, dynamic> json) => _$PickupSuggestionModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  double lat;
@override final  double lng;
@override final  double distanceMeters;

/// Create a copy of PickupSuggestionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PickupSuggestionModelCopyWith<_PickupSuggestionModel> get copyWith => __$PickupSuggestionModelCopyWithImpl<_PickupSuggestionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PickupSuggestionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PickupSuggestionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,lat,lng,distanceMeters);

@override
String toString() {
  return 'PickupSuggestionModel(id: $id, name: $name, lat: $lat, lng: $lng, distanceMeters: $distanceMeters)';
}


}

/// @nodoc
abstract mixin class _$PickupSuggestionModelCopyWith<$Res> implements $PickupSuggestionModelCopyWith<$Res> {
  factory _$PickupSuggestionModelCopyWith(_PickupSuggestionModel value, $Res Function(_PickupSuggestionModel) _then) = __$PickupSuggestionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double lat, double lng, double distanceMeters
});




}
/// @nodoc
class __$PickupSuggestionModelCopyWithImpl<$Res>
    implements _$PickupSuggestionModelCopyWith<$Res> {
  __$PickupSuggestionModelCopyWithImpl(this._self, this._then);

  final _PickupSuggestionModel _self;
  final $Res Function(_PickupSuggestionModel) _then;

/// Create a copy of PickupSuggestionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? lat = null,Object? lng = null,Object? distanceMeters = null,}) {
  return _then(_PickupSuggestionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
