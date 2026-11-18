// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_banner_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppBannerModel {

 String get id; String get title; String get subtitle; String get imageUrl; String get action; int get order;@TimestampConverter() DateTime get validUntil; bool get active; String? get promoCode; String? get url;
/// Create a copy of AppBannerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppBannerModelCopyWith<AppBannerModel> get copyWith => _$AppBannerModelCopyWithImpl<AppBannerModel>(this as AppBannerModel, _$identity);

  /// Serializes this AppBannerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppBannerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.action, action) || other.action == action)&&(identical(other.order, order) || other.order == order)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.active, active) || other.active == active)&&(identical(other.promoCode, promoCode) || other.promoCode == promoCode)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,subtitle,imageUrl,action,order,validUntil,active,promoCode,url);

@override
String toString() {
  return 'AppBannerModel(id: $id, title: $title, subtitle: $subtitle, imageUrl: $imageUrl, action: $action, order: $order, validUntil: $validUntil, active: $active, promoCode: $promoCode, url: $url)';
}


}

/// @nodoc
abstract mixin class $AppBannerModelCopyWith<$Res>  {
  factory $AppBannerModelCopyWith(AppBannerModel value, $Res Function(AppBannerModel) _then) = _$AppBannerModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String subtitle, String imageUrl, String action, int order,@TimestampConverter() DateTime validUntil, bool active, String? promoCode, String? url
});




}
/// @nodoc
class _$AppBannerModelCopyWithImpl<$Res>
    implements $AppBannerModelCopyWith<$Res> {
  _$AppBannerModelCopyWithImpl(this._self, this._then);

  final AppBannerModel _self;
  final $Res Function(AppBannerModel) _then;

/// Create a copy of AppBannerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? subtitle = null,Object? imageUrl = null,Object? action = null,Object? order = null,Object? validUntil = null,Object? active = null,Object? promoCode = freezed,Object? url = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,promoCode: freezed == promoCode ? _self.promoCode : promoCode // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppBannerModel].
extension AppBannerModelPatterns on AppBannerModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppBannerModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppBannerModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppBannerModel value)  $default,){
final _that = this;
switch (_that) {
case _AppBannerModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppBannerModel value)?  $default,){
final _that = this;
switch (_that) {
case _AppBannerModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String subtitle,  String imageUrl,  String action,  int order, @TimestampConverter()  DateTime validUntil,  bool active,  String? promoCode,  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppBannerModel() when $default != null:
return $default(_that.id,_that.title,_that.subtitle,_that.imageUrl,_that.action,_that.order,_that.validUntil,_that.active,_that.promoCode,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String subtitle,  String imageUrl,  String action,  int order, @TimestampConverter()  DateTime validUntil,  bool active,  String? promoCode,  String? url)  $default,) {final _that = this;
switch (_that) {
case _AppBannerModel():
return $default(_that.id,_that.title,_that.subtitle,_that.imageUrl,_that.action,_that.order,_that.validUntil,_that.active,_that.promoCode,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String subtitle,  String imageUrl,  String action,  int order, @TimestampConverter()  DateTime validUntil,  bool active,  String? promoCode,  String? url)?  $default,) {final _that = this;
switch (_that) {
case _AppBannerModel() when $default != null:
return $default(_that.id,_that.title,_that.subtitle,_that.imageUrl,_that.action,_that.order,_that.validUntil,_that.active,_that.promoCode,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppBannerModel extends AppBannerModel {
  const _AppBannerModel({required this.id, required this.title, required this.subtitle, required this.imageUrl, required this.action, required this.order, @TimestampConverter() required this.validUntil, required this.active, this.promoCode, this.url}): super._();
  factory _AppBannerModel.fromJson(Map<String, dynamic> json) => _$AppBannerModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String subtitle;
@override final  String imageUrl;
@override final  String action;
@override final  int order;
@override@TimestampConverter() final  DateTime validUntil;
@override final  bool active;
@override final  String? promoCode;
@override final  String? url;

/// Create a copy of AppBannerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppBannerModelCopyWith<_AppBannerModel> get copyWith => __$AppBannerModelCopyWithImpl<_AppBannerModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppBannerModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppBannerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.action, action) || other.action == action)&&(identical(other.order, order) || other.order == order)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.active, active) || other.active == active)&&(identical(other.promoCode, promoCode) || other.promoCode == promoCode)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,subtitle,imageUrl,action,order,validUntil,active,promoCode,url);

@override
String toString() {
  return 'AppBannerModel(id: $id, title: $title, subtitle: $subtitle, imageUrl: $imageUrl, action: $action, order: $order, validUntil: $validUntil, active: $active, promoCode: $promoCode, url: $url)';
}


}

/// @nodoc
abstract mixin class _$AppBannerModelCopyWith<$Res> implements $AppBannerModelCopyWith<$Res> {
  factory _$AppBannerModelCopyWith(_AppBannerModel value, $Res Function(_AppBannerModel) _then) = __$AppBannerModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String subtitle, String imageUrl, String action, int order,@TimestampConverter() DateTime validUntil, bool active, String? promoCode, String? url
});




}
/// @nodoc
class __$AppBannerModelCopyWithImpl<$Res>
    implements _$AppBannerModelCopyWith<$Res> {
  __$AppBannerModelCopyWithImpl(this._self, this._then);

  final _AppBannerModel _self;
  final $Res Function(_AppBannerModel) _then;

/// Create a copy of AppBannerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? subtitle = null,Object? imageUrl = null,Object? action = null,Object? order = null,Object? validUntil = null,Object? active = null,Object? promoCode = freezed,Object? url = freezed,}) {
  return _then(_AppBannerModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,promoCode: freezed == promoCode ? _self.promoCode : promoCode // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
