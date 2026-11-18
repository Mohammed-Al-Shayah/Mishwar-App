// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_service_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppServiceModel {

 ServiceId get id; bool get enabled; int get order;
/// Create a copy of AppServiceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppServiceModelCopyWith<AppServiceModel> get copyWith => _$AppServiceModelCopyWithImpl<AppServiceModel>(this as AppServiceModel, _$identity);

  /// Serializes this AppServiceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppServiceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,enabled,order);

@override
String toString() {
  return 'AppServiceModel(id: $id, enabled: $enabled, order: $order)';
}


}

/// @nodoc
abstract mixin class $AppServiceModelCopyWith<$Res>  {
  factory $AppServiceModelCopyWith(AppServiceModel value, $Res Function(AppServiceModel) _then) = _$AppServiceModelCopyWithImpl;
@useResult
$Res call({
 ServiceId id, bool enabled, int order
});




}
/// @nodoc
class _$AppServiceModelCopyWithImpl<$Res>
    implements $AppServiceModelCopyWith<$Res> {
  _$AppServiceModelCopyWithImpl(this._self, this._then);

  final AppServiceModel _self;
  final $Res Function(AppServiceModel) _then;

/// Create a copy of AppServiceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? enabled = null,Object? order = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ServiceId,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AppServiceModel].
extension AppServiceModelPatterns on AppServiceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppServiceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppServiceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppServiceModel value)  $default,){
final _that = this;
switch (_that) {
case _AppServiceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppServiceModel value)?  $default,){
final _that = this;
switch (_that) {
case _AppServiceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ServiceId id,  bool enabled,  int order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppServiceModel() when $default != null:
return $default(_that.id,_that.enabled,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ServiceId id,  bool enabled,  int order)  $default,) {final _that = this;
switch (_that) {
case _AppServiceModel():
return $default(_that.id,_that.enabled,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ServiceId id,  bool enabled,  int order)?  $default,) {final _that = this;
switch (_that) {
case _AppServiceModel() when $default != null:
return $default(_that.id,_that.enabled,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppServiceModel extends AppServiceModel {
  const _AppServiceModel({required this.id, required this.enabled, required this.order}): super._();
  factory _AppServiceModel.fromJson(Map<String, dynamic> json) => _$AppServiceModelFromJson(json);

@override final  ServiceId id;
@override final  bool enabled;
@override final  int order;

/// Create a copy of AppServiceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppServiceModelCopyWith<_AppServiceModel> get copyWith => __$AppServiceModelCopyWithImpl<_AppServiceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppServiceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppServiceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,enabled,order);

@override
String toString() {
  return 'AppServiceModel(id: $id, enabled: $enabled, order: $order)';
}


}

/// @nodoc
abstract mixin class _$AppServiceModelCopyWith<$Res> implements $AppServiceModelCopyWith<$Res> {
  factory _$AppServiceModelCopyWith(_AppServiceModel value, $Res Function(_AppServiceModel) _then) = __$AppServiceModelCopyWithImpl;
@override @useResult
$Res call({
 ServiceId id, bool enabled, int order
});




}
/// @nodoc
class __$AppServiceModelCopyWithImpl<$Res>
    implements _$AppServiceModelCopyWith<$Res> {
  __$AppServiceModelCopyWithImpl(this._self, this._then);

  final _AppServiceModel _self;
  final $Res Function(_AppServiceModel) _then;

/// Create a copy of AppServiceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? enabled = null,Object? order = null,}) {
  return _then(_AppServiceModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ServiceId,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
