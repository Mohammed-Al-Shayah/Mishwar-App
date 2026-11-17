// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdminRecordModel {

 String get id; Map<String, dynamic> get fields;
/// Create a copy of AdminRecordModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminRecordModelCopyWith<AdminRecordModel> get copyWith => _$AdminRecordModelCopyWithImpl<AdminRecordModel>(this as AdminRecordModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminRecordModel&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.fields, fields));
}


@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(fields));

@override
String toString() {
  return 'AdminRecordModel(id: $id, fields: $fields)';
}


}

/// @nodoc
abstract mixin class $AdminRecordModelCopyWith<$Res>  {
  factory $AdminRecordModelCopyWith(AdminRecordModel value, $Res Function(AdminRecordModel) _then) = _$AdminRecordModelCopyWithImpl;
@useResult
$Res call({
 String id, Map<String, dynamic> fields
});




}
/// @nodoc
class _$AdminRecordModelCopyWithImpl<$Res>
    implements $AdminRecordModelCopyWith<$Res> {
  _$AdminRecordModelCopyWithImpl(this._self, this._then);

  final AdminRecordModel _self;
  final $Res Function(AdminRecordModel) _then;

/// Create a copy of AdminRecordModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fields = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminRecordModel].
extension AdminRecordModelPatterns on AdminRecordModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminRecordModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminRecordModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminRecordModel value)  $default,){
final _that = this;
switch (_that) {
case _AdminRecordModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminRecordModel value)?  $default,){
final _that = this;
switch (_that) {
case _AdminRecordModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Map<String, dynamic> fields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminRecordModel() when $default != null:
return $default(_that.id,_that.fields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Map<String, dynamic> fields)  $default,) {final _that = this;
switch (_that) {
case _AdminRecordModel():
return $default(_that.id,_that.fields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Map<String, dynamic> fields)?  $default,) {final _that = this;
switch (_that) {
case _AdminRecordModel() when $default != null:
return $default(_that.id,_that.fields);case _:
  return null;

}
}

}

/// @nodoc


class _AdminRecordModel extends AdminRecordModel {
  const _AdminRecordModel({required this.id, required final  Map<String, dynamic> fields}): _fields = fields,super._();
  

@override final  String id;
 final  Map<String, dynamic> _fields;
@override Map<String, dynamic> get fields {
  if (_fields is EqualUnmodifiableMapView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fields);
}


/// Create a copy of AdminRecordModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminRecordModelCopyWith<_AdminRecordModel> get copyWith => __$AdminRecordModelCopyWithImpl<_AdminRecordModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminRecordModel&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._fields, _fields));
}


@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_fields));

@override
String toString() {
  return 'AdminRecordModel(id: $id, fields: $fields)';
}


}

/// @nodoc
abstract mixin class _$AdminRecordModelCopyWith<$Res> implements $AdminRecordModelCopyWith<$Res> {
  factory _$AdminRecordModelCopyWith(_AdminRecordModel value, $Res Function(_AdminRecordModel) _then) = __$AdminRecordModelCopyWithImpl;
@override @useResult
$Res call({
 String id, Map<String, dynamic> fields
});




}
/// @nodoc
class __$AdminRecordModelCopyWithImpl<$Res>
    implements _$AdminRecordModelCopyWith<$Res> {
  __$AdminRecordModelCopyWithImpl(this._self, this._then);

  final _AdminRecordModel _self;
  final $Res Function(_AdminRecordModel) _then;

/// Create a copy of AdminRecordModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fields = null,}) {
  return _then(_AdminRecordModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
