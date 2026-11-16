// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaceSuggestionModel {

 String get placeId; String get primaryText; String get secondaryText;
/// Create a copy of PlaceSuggestionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceSuggestionModelCopyWith<PlaceSuggestionModel> get copyWith => _$PlaceSuggestionModelCopyWithImpl<PlaceSuggestionModel>(this as PlaceSuggestionModel, _$identity);

  /// Serializes this PlaceSuggestionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceSuggestionModel&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.primaryText, primaryText) || other.primaryText == primaryText)&&(identical(other.secondaryText, secondaryText) || other.secondaryText == secondaryText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placeId,primaryText,secondaryText);

@override
String toString() {
  return 'PlaceSuggestionModel(placeId: $placeId, primaryText: $primaryText, secondaryText: $secondaryText)';
}


}

/// @nodoc
abstract mixin class $PlaceSuggestionModelCopyWith<$Res>  {
  factory $PlaceSuggestionModelCopyWith(PlaceSuggestionModel value, $Res Function(PlaceSuggestionModel) _then) = _$PlaceSuggestionModelCopyWithImpl;
@useResult
$Res call({
 String placeId, String primaryText, String secondaryText
});




}
/// @nodoc
class _$PlaceSuggestionModelCopyWithImpl<$Res>
    implements $PlaceSuggestionModelCopyWith<$Res> {
  _$PlaceSuggestionModelCopyWithImpl(this._self, this._then);

  final PlaceSuggestionModel _self;
  final $Res Function(PlaceSuggestionModel) _then;

/// Create a copy of PlaceSuggestionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = null,Object? primaryText = null,Object? secondaryText = null,}) {
  return _then(_self.copyWith(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,primaryText: null == primaryText ? _self.primaryText : primaryText // ignore: cast_nullable_to_non_nullable
as String,secondaryText: null == secondaryText ? _self.secondaryText : secondaryText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaceSuggestionModel].
extension PlaceSuggestionModelPatterns on PlaceSuggestionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceSuggestionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceSuggestionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceSuggestionModel value)  $default,){
final _that = this;
switch (_that) {
case _PlaceSuggestionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceSuggestionModel value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceSuggestionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String placeId,  String primaryText,  String secondaryText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceSuggestionModel() when $default != null:
return $default(_that.placeId,_that.primaryText,_that.secondaryText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String placeId,  String primaryText,  String secondaryText)  $default,) {final _that = this;
switch (_that) {
case _PlaceSuggestionModel():
return $default(_that.placeId,_that.primaryText,_that.secondaryText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String placeId,  String primaryText,  String secondaryText)?  $default,) {final _that = this;
switch (_that) {
case _PlaceSuggestionModel() when $default != null:
return $default(_that.placeId,_that.primaryText,_that.secondaryText);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceSuggestionModel extends PlaceSuggestionModel {
  const _PlaceSuggestionModel({required this.placeId, required this.primaryText, required this.secondaryText}): super._();
  factory _PlaceSuggestionModel.fromJson(Map<String, dynamic> json) => _$PlaceSuggestionModelFromJson(json);

@override final  String placeId;
@override final  String primaryText;
@override final  String secondaryText;

/// Create a copy of PlaceSuggestionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceSuggestionModelCopyWith<_PlaceSuggestionModel> get copyWith => __$PlaceSuggestionModelCopyWithImpl<_PlaceSuggestionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceSuggestionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceSuggestionModel&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.primaryText, primaryText) || other.primaryText == primaryText)&&(identical(other.secondaryText, secondaryText) || other.secondaryText == secondaryText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placeId,primaryText,secondaryText);

@override
String toString() {
  return 'PlaceSuggestionModel(placeId: $placeId, primaryText: $primaryText, secondaryText: $secondaryText)';
}


}

/// @nodoc
abstract mixin class _$PlaceSuggestionModelCopyWith<$Res> implements $PlaceSuggestionModelCopyWith<$Res> {
  factory _$PlaceSuggestionModelCopyWith(_PlaceSuggestionModel value, $Res Function(_PlaceSuggestionModel) _then) = __$PlaceSuggestionModelCopyWithImpl;
@override @useResult
$Res call({
 String placeId, String primaryText, String secondaryText
});




}
/// @nodoc
class __$PlaceSuggestionModelCopyWithImpl<$Res>
    implements _$PlaceSuggestionModelCopyWith<$Res> {
  __$PlaceSuggestionModelCopyWithImpl(this._self, this._then);

  final _PlaceSuggestionModel _self;
  final $Res Function(_PlaceSuggestionModel) _then;

/// Create a copy of PlaceSuggestionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = null,Object? primaryText = null,Object? secondaryText = null,}) {
  return _then(_PlaceSuggestionModel(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,primaryText: null == primaryText ? _self.primaryText : primaryText // ignore: cast_nullable_to_non_nullable
as String,secondaryText: null == secondaryText ? _self.secondaryText : secondaryText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PlaceDetailsModel {

 String get placeId; String get name; String get address; double get lat; double get lng;
/// Create a copy of PlaceDetailsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceDetailsModelCopyWith<PlaceDetailsModel> get copyWith => _$PlaceDetailsModelCopyWithImpl<PlaceDetailsModel>(this as PlaceDetailsModel, _$identity);

  /// Serializes this PlaceDetailsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceDetailsModel&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placeId,name,address,lat,lng);

@override
String toString() {
  return 'PlaceDetailsModel(placeId: $placeId, name: $name, address: $address, lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class $PlaceDetailsModelCopyWith<$Res>  {
  factory $PlaceDetailsModelCopyWith(PlaceDetailsModel value, $Res Function(PlaceDetailsModel) _then) = _$PlaceDetailsModelCopyWithImpl;
@useResult
$Res call({
 String placeId, String name, String address, double lat, double lng
});




}
/// @nodoc
class _$PlaceDetailsModelCopyWithImpl<$Res>
    implements $PlaceDetailsModelCopyWith<$Res> {
  _$PlaceDetailsModelCopyWithImpl(this._self, this._then);

  final PlaceDetailsModel _self;
  final $Res Function(PlaceDetailsModel) _then;

/// Create a copy of PlaceDetailsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = null,Object? name = null,Object? address = null,Object? lat = null,Object? lng = null,}) {
  return _then(_self.copyWith(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaceDetailsModel].
extension PlaceDetailsModelPatterns on PlaceDetailsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceDetailsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceDetailsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceDetailsModel value)  $default,){
final _that = this;
switch (_that) {
case _PlaceDetailsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceDetailsModel value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceDetailsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String placeId,  String name,  String address,  double lat,  double lng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceDetailsModel() when $default != null:
return $default(_that.placeId,_that.name,_that.address,_that.lat,_that.lng);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String placeId,  String name,  String address,  double lat,  double lng)  $default,) {final _that = this;
switch (_that) {
case _PlaceDetailsModel():
return $default(_that.placeId,_that.name,_that.address,_that.lat,_that.lng);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String placeId,  String name,  String address,  double lat,  double lng)?  $default,) {final _that = this;
switch (_that) {
case _PlaceDetailsModel() when $default != null:
return $default(_that.placeId,_that.name,_that.address,_that.lat,_that.lng);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceDetailsModel extends PlaceDetailsModel {
  const _PlaceDetailsModel({required this.placeId, required this.name, required this.address, required this.lat, required this.lng}): super._();
  factory _PlaceDetailsModel.fromJson(Map<String, dynamic> json) => _$PlaceDetailsModelFromJson(json);

@override final  String placeId;
@override final  String name;
@override final  String address;
@override final  double lat;
@override final  double lng;

/// Create a copy of PlaceDetailsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceDetailsModelCopyWith<_PlaceDetailsModel> get copyWith => __$PlaceDetailsModelCopyWithImpl<_PlaceDetailsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceDetailsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceDetailsModel&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placeId,name,address,lat,lng);

@override
String toString() {
  return 'PlaceDetailsModel(placeId: $placeId, name: $name, address: $address, lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class _$PlaceDetailsModelCopyWith<$Res> implements $PlaceDetailsModelCopyWith<$Res> {
  factory _$PlaceDetailsModelCopyWith(_PlaceDetailsModel value, $Res Function(_PlaceDetailsModel) _then) = __$PlaceDetailsModelCopyWithImpl;
@override @useResult
$Res call({
 String placeId, String name, String address, double lat, double lng
});




}
/// @nodoc
class __$PlaceDetailsModelCopyWithImpl<$Res>
    implements _$PlaceDetailsModelCopyWith<$Res> {
  __$PlaceDetailsModelCopyWithImpl(this._self, this._then);

  final _PlaceDetailsModel _self;
  final $Res Function(_PlaceDetailsModel) _then;

/// Create a copy of PlaceDetailsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = null,Object? name = null,Object? address = null,Object? lat = null,Object? lng = null,}) {
  return _then(_PlaceDetailsModel(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
