// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

@JsonKey(includeToJson: false) String get id; String get name; String get phone;@TimestampConverter() DateTime get createdAt;@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) UserRole? get role;@JsonKey(includeToJson: false) String? get pendingRatingRideId; String? get photoUrl; double get rating; int get ratingCount;@JsonKey(includeToJson: false, name: 'balanceDueFils') int get balanceDueMinor;@JsonKey(includeToJson: false) Map<String, int> get balanceDue;@JsonKey(includeToJson: false) String? get homeMarket; String? get fcmToken;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.role, role) || other.role == role)&&(identical(other.pendingRatingRideId, pendingRatingRideId) || other.pendingRatingRideId == pendingRatingRideId)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.balanceDueMinor, balanceDueMinor) || other.balanceDueMinor == balanceDueMinor)&&const DeepCollectionEquality().equals(other.balanceDue, balanceDue)&&(identical(other.homeMarket, homeMarket) || other.homeMarket == homeMarket)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,phone,createdAt,role,pendingRatingRideId,photoUrl,rating,ratingCount,balanceDueMinor,const DeepCollectionEquality().hash(balanceDue),homeMarket,fcmToken);

@override
String toString() {
  return 'UserModel(id: $id, name: $name, phone: $phone, createdAt: $createdAt, role: $role, pendingRatingRideId: $pendingRatingRideId, photoUrl: $photoUrl, rating: $rating, ratingCount: $ratingCount, balanceDueMinor: $balanceDueMinor, balanceDue: $balanceDue, homeMarket: $homeMarket, fcmToken: $fcmToken)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String name, String phone,@TimestampConverter() DateTime createdAt,@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) UserRole? role,@JsonKey(includeToJson: false) String? pendingRatingRideId, String? photoUrl, double rating, int ratingCount,@JsonKey(includeToJson: false, name: 'balanceDueFils') int balanceDueMinor,@JsonKey(includeToJson: false) Map<String, int> balanceDue,@JsonKey(includeToJson: false) String? homeMarket, String? fcmToken
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? phone = null,Object? createdAt = null,Object? role = freezed,Object? pendingRatingRideId = freezed,Object? photoUrl = freezed,Object? rating = null,Object? ratingCount = null,Object? balanceDueMinor = null,Object? balanceDue = null,Object? homeMarket = freezed,Object? fcmToken = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole?,pendingRatingRideId: freezed == pendingRatingRideId ? _self.pendingRatingRideId : pendingRatingRideId // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,balanceDueMinor: null == balanceDueMinor ? _self.balanceDueMinor : balanceDueMinor // ignore: cast_nullable_to_non_nullable
as int,balanceDue: null == balanceDue ? _self.balanceDue : balanceDue // ignore: cast_nullable_to_non_nullable
as Map<String, int>,homeMarket: freezed == homeMarket ? _self.homeMarket : homeMarket // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String name,  String phone, @TimestampConverter()  DateTime createdAt, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  UserRole? role, @JsonKey(includeToJson: false)  String? pendingRatingRideId,  String? photoUrl,  double rating,  int ratingCount, @JsonKey(includeToJson: false, name: 'balanceDueFils')  int balanceDueMinor, @JsonKey(includeToJson: false)  Map<String, int> balanceDue, @JsonKey(includeToJson: false)  String? homeMarket,  String? fcmToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.createdAt,_that.role,_that.pendingRatingRideId,_that.photoUrl,_that.rating,_that.ratingCount,_that.balanceDueMinor,_that.balanceDue,_that.homeMarket,_that.fcmToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String name,  String phone, @TimestampConverter()  DateTime createdAt, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  UserRole? role, @JsonKey(includeToJson: false)  String? pendingRatingRideId,  String? photoUrl,  double rating,  int ratingCount, @JsonKey(includeToJson: false, name: 'balanceDueFils')  int balanceDueMinor, @JsonKey(includeToJson: false)  Map<String, int> balanceDue, @JsonKey(includeToJson: false)  String? homeMarket,  String? fcmToken)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.name,_that.phone,_that.createdAt,_that.role,_that.pendingRatingRideId,_that.photoUrl,_that.rating,_that.ratingCount,_that.balanceDueMinor,_that.balanceDue,_that.homeMarket,_that.fcmToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String name,  String phone, @TimestampConverter()  DateTime createdAt, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  UserRole? role, @JsonKey(includeToJson: false)  String? pendingRatingRideId,  String? photoUrl,  double rating,  int ratingCount, @JsonKey(includeToJson: false, name: 'balanceDueFils')  int balanceDueMinor, @JsonKey(includeToJson: false)  Map<String, int> balanceDue, @JsonKey(includeToJson: false)  String? homeMarket,  String? fcmToken)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.createdAt,_that.role,_that.pendingRatingRideId,_that.photoUrl,_that.rating,_that.ratingCount,_that.balanceDueMinor,_that.balanceDue,_that.homeMarket,_that.fcmToken);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _UserModel extends UserModel {
  const _UserModel({@JsonKey(includeToJson: false) required this.id, required this.name, required this.phone, @TimestampConverter() required this.createdAt, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) this.role, @JsonKey(includeToJson: false) this.pendingRatingRideId, this.photoUrl, this.rating = 5.0, this.ratingCount = 0, @JsonKey(includeToJson: false, name: 'balanceDueFils') this.balanceDueMinor = 0, @JsonKey(includeToJson: false) final  Map<String, int> balanceDue = const <String, int>{}, @JsonKey(includeToJson: false) this.homeMarket, this.fcmToken}): _balanceDue = balanceDue,super._();
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String name;
@override final  String phone;
@override@TimestampConverter() final  DateTime createdAt;
@override@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) final  UserRole? role;
@override@JsonKey(includeToJson: false) final  String? pendingRatingRideId;
@override final  String? photoUrl;
@override@JsonKey() final  double rating;
@override@JsonKey() final  int ratingCount;
@override@JsonKey(includeToJson: false, name: 'balanceDueFils') final  int balanceDueMinor;
 final  Map<String, int> _balanceDue;
@override@JsonKey(includeToJson: false) Map<String, int> get balanceDue {
  if (_balanceDue is EqualUnmodifiableMapView) return _balanceDue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_balanceDue);
}

@override@JsonKey(includeToJson: false) final  String? homeMarket;
@override final  String? fcmToken;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.role, role) || other.role == role)&&(identical(other.pendingRatingRideId, pendingRatingRideId) || other.pendingRatingRideId == pendingRatingRideId)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.balanceDueMinor, balanceDueMinor) || other.balanceDueMinor == balanceDueMinor)&&const DeepCollectionEquality().equals(other._balanceDue, _balanceDue)&&(identical(other.homeMarket, homeMarket) || other.homeMarket == homeMarket)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,phone,createdAt,role,pendingRatingRideId,photoUrl,rating,ratingCount,balanceDueMinor,const DeepCollectionEquality().hash(_balanceDue),homeMarket,fcmToken);

@override
String toString() {
  return 'UserModel(id: $id, name: $name, phone: $phone, createdAt: $createdAt, role: $role, pendingRatingRideId: $pendingRatingRideId, photoUrl: $photoUrl, rating: $rating, ratingCount: $ratingCount, balanceDueMinor: $balanceDueMinor, balanceDue: $balanceDue, homeMarket: $homeMarket, fcmToken: $fcmToken)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String name, String phone,@TimestampConverter() DateTime createdAt,@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) UserRole? role,@JsonKey(includeToJson: false) String? pendingRatingRideId, String? photoUrl, double rating, int ratingCount,@JsonKey(includeToJson: false, name: 'balanceDueFils') int balanceDueMinor,@JsonKey(includeToJson: false) Map<String, int> balanceDue,@JsonKey(includeToJson: false) String? homeMarket, String? fcmToken
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? phone = null,Object? createdAt = null,Object? role = freezed,Object? pendingRatingRideId = freezed,Object? photoUrl = freezed,Object? rating = null,Object? ratingCount = null,Object? balanceDueMinor = null,Object? balanceDue = null,Object? homeMarket = freezed,Object? fcmToken = freezed,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole?,pendingRatingRideId: freezed == pendingRatingRideId ? _self.pendingRatingRideId : pendingRatingRideId // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,balanceDueMinor: null == balanceDueMinor ? _self.balanceDueMinor : balanceDueMinor // ignore: cast_nullable_to_non_nullable
as int,balanceDue: null == balanceDue ? _self._balanceDue : balanceDue // ignore: cast_nullable_to_non_nullable
as Map<String, int>,homeMarket: freezed == homeMarket ? _self.homeMarket : homeMarket // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
