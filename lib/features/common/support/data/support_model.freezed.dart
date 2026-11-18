// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'support_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SupportTicketModel {

 String get id; String get uid; String get role; String get category; String get subject; String get status;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get updatedAt;@TimestampConverter() DateTime get lastMessageAt; String get lastMessageBy; bool get userUnread; String? get rideId;
/// Create a copy of SupportTicketModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportTicketModelCopyWith<SupportTicketModel> get copyWith => _$SupportTicketModelCopyWithImpl<SupportTicketModel>(this as SupportTicketModel, _$identity);

  /// Serializes this SupportTicketModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportTicketModel&&(identical(other.id, id) || other.id == id)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.role, role) || other.role == role)&&(identical(other.category, category) || other.category == category)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessageBy, lastMessageBy) || other.lastMessageBy == lastMessageBy)&&(identical(other.userUnread, userUnread) || other.userUnread == userUnread)&&(identical(other.rideId, rideId) || other.rideId == rideId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uid,role,category,subject,status,createdAt,updatedAt,lastMessageAt,lastMessageBy,userUnread,rideId);

@override
String toString() {
  return 'SupportTicketModel(id: $id, uid: $uid, role: $role, category: $category, subject: $subject, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, lastMessageAt: $lastMessageAt, lastMessageBy: $lastMessageBy, userUnread: $userUnread, rideId: $rideId)';
}


}

/// @nodoc
abstract mixin class $SupportTicketModelCopyWith<$Res>  {
  factory $SupportTicketModelCopyWith(SupportTicketModel value, $Res Function(SupportTicketModel) _then) = _$SupportTicketModelCopyWithImpl;
@useResult
$Res call({
 String id, String uid, String role, String category, String subject, String status,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt,@TimestampConverter() DateTime lastMessageAt, String lastMessageBy, bool userUnread, String? rideId
});




}
/// @nodoc
class _$SupportTicketModelCopyWithImpl<$Res>
    implements $SupportTicketModelCopyWith<$Res> {
  _$SupportTicketModelCopyWithImpl(this._self, this._then);

  final SupportTicketModel _self;
  final $Res Function(SupportTicketModel) _then;

/// Create a copy of SupportTicketModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uid = null,Object? role = null,Object? category = null,Object? subject = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? lastMessageAt = null,Object? lastMessageBy = null,Object? userUnread = null,Object? rideId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastMessageAt: null == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastMessageBy: null == lastMessageBy ? _self.lastMessageBy : lastMessageBy // ignore: cast_nullable_to_non_nullable
as String,userUnread: null == userUnread ? _self.userUnread : userUnread // ignore: cast_nullable_to_non_nullable
as bool,rideId: freezed == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportTicketModel].
extension SupportTicketModelPatterns on SupportTicketModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportTicketModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportTicketModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportTicketModel value)  $default,){
final _that = this;
switch (_that) {
case _SupportTicketModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportTicketModel value)?  $default,){
final _that = this;
switch (_that) {
case _SupportTicketModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String uid,  String role,  String category,  String subject,  String status, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt, @TimestampConverter()  DateTime lastMessageAt,  String lastMessageBy,  bool userUnread,  String? rideId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportTicketModel() when $default != null:
return $default(_that.id,_that.uid,_that.role,_that.category,_that.subject,_that.status,_that.createdAt,_that.updatedAt,_that.lastMessageAt,_that.lastMessageBy,_that.userUnread,_that.rideId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String uid,  String role,  String category,  String subject,  String status, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt, @TimestampConverter()  DateTime lastMessageAt,  String lastMessageBy,  bool userUnread,  String? rideId)  $default,) {final _that = this;
switch (_that) {
case _SupportTicketModel():
return $default(_that.id,_that.uid,_that.role,_that.category,_that.subject,_that.status,_that.createdAt,_that.updatedAt,_that.lastMessageAt,_that.lastMessageBy,_that.userUnread,_that.rideId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String uid,  String role,  String category,  String subject,  String status, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt, @TimestampConverter()  DateTime lastMessageAt,  String lastMessageBy,  bool userUnread,  String? rideId)?  $default,) {final _that = this;
switch (_that) {
case _SupportTicketModel() when $default != null:
return $default(_that.id,_that.uid,_that.role,_that.category,_that.subject,_that.status,_that.createdAt,_that.updatedAt,_that.lastMessageAt,_that.lastMessageBy,_that.userUnread,_that.rideId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SupportTicketModel extends SupportTicketModel {
  const _SupportTicketModel({required this.id, required this.uid, required this.role, required this.category, required this.subject, required this.status, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt, @TimestampConverter() required this.lastMessageAt, required this.lastMessageBy, required this.userUnread, this.rideId}): super._();
  factory _SupportTicketModel.fromJson(Map<String, dynamic> json) => _$SupportTicketModelFromJson(json);

@override final  String id;
@override final  String uid;
@override final  String role;
@override final  String category;
@override final  String subject;
@override final  String status;
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime updatedAt;
@override@TimestampConverter() final  DateTime lastMessageAt;
@override final  String lastMessageBy;
@override final  bool userUnread;
@override final  String? rideId;

/// Create a copy of SupportTicketModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportTicketModelCopyWith<_SupportTicketModel> get copyWith => __$SupportTicketModelCopyWithImpl<_SupportTicketModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupportTicketModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportTicketModel&&(identical(other.id, id) || other.id == id)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.role, role) || other.role == role)&&(identical(other.category, category) || other.category == category)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessageBy, lastMessageBy) || other.lastMessageBy == lastMessageBy)&&(identical(other.userUnread, userUnread) || other.userUnread == userUnread)&&(identical(other.rideId, rideId) || other.rideId == rideId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uid,role,category,subject,status,createdAt,updatedAt,lastMessageAt,lastMessageBy,userUnread,rideId);

@override
String toString() {
  return 'SupportTicketModel(id: $id, uid: $uid, role: $role, category: $category, subject: $subject, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, lastMessageAt: $lastMessageAt, lastMessageBy: $lastMessageBy, userUnread: $userUnread, rideId: $rideId)';
}


}

/// @nodoc
abstract mixin class _$SupportTicketModelCopyWith<$Res> implements $SupportTicketModelCopyWith<$Res> {
  factory _$SupportTicketModelCopyWith(_SupportTicketModel value, $Res Function(_SupportTicketModel) _then) = __$SupportTicketModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String uid, String role, String category, String subject, String status,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt,@TimestampConverter() DateTime lastMessageAt, String lastMessageBy, bool userUnread, String? rideId
});




}
/// @nodoc
class __$SupportTicketModelCopyWithImpl<$Res>
    implements _$SupportTicketModelCopyWith<$Res> {
  __$SupportTicketModelCopyWithImpl(this._self, this._then);

  final _SupportTicketModel _self;
  final $Res Function(_SupportTicketModel) _then;

/// Create a copy of SupportTicketModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uid = null,Object? role = null,Object? category = null,Object? subject = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? lastMessageAt = null,Object? lastMessageBy = null,Object? userUnread = null,Object? rideId = freezed,}) {
  return _then(_SupportTicketModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastMessageAt: null == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastMessageBy: null == lastMessageBy ? _self.lastMessageBy : lastMessageBy // ignore: cast_nullable_to_non_nullable
as String,userUnread: null == userUnread ? _self.userUnread : userUnread // ignore: cast_nullable_to_non_nullable
as bool,rideId: freezed == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SupportMessageModel {

 String get id; String get from; String get text;@TimestampConverter() DateTime? get createdAt;
/// Create a copy of SupportMessageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportMessageModelCopyWith<SupportMessageModel> get copyWith => _$SupportMessageModelCopyWithImpl<SupportMessageModel>(this as SupportMessageModel, _$identity);

  /// Serializes this SupportMessageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportMessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.from, from) || other.from == from)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,from,text,createdAt);

@override
String toString() {
  return 'SupportMessageModel(id: $id, from: $from, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SupportMessageModelCopyWith<$Res>  {
  factory $SupportMessageModelCopyWith(SupportMessageModel value, $Res Function(SupportMessageModel) _then) = _$SupportMessageModelCopyWithImpl;
@useResult
$Res call({
 String id, String from, String text,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class _$SupportMessageModelCopyWithImpl<$Res>
    implements $SupportMessageModelCopyWith<$Res> {
  _$SupportMessageModelCopyWithImpl(this._self, this._then);

  final SupportMessageModel _self;
  final $Res Function(SupportMessageModel) _then;

/// Create a copy of SupportMessageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? from = null,Object? text = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportMessageModel].
extension SupportMessageModelPatterns on SupportMessageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportMessageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportMessageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportMessageModel value)  $default,){
final _that = this;
switch (_that) {
case _SupportMessageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportMessageModel value)?  $default,){
final _that = this;
switch (_that) {
case _SupportMessageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String from,  String text, @TimestampConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportMessageModel() when $default != null:
return $default(_that.id,_that.from,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String from,  String text, @TimestampConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _SupportMessageModel():
return $default(_that.id,_that.from,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String from,  String text, @TimestampConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SupportMessageModel() when $default != null:
return $default(_that.id,_that.from,_that.text,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SupportMessageModel extends SupportMessageModel {
  const _SupportMessageModel({required this.id, required this.from, required this.text, @TimestampConverter() this.createdAt}): super._();
  factory _SupportMessageModel.fromJson(Map<String, dynamic> json) => _$SupportMessageModelFromJson(json);

@override final  String id;
@override final  String from;
@override final  String text;
@override@TimestampConverter() final  DateTime? createdAt;

/// Create a copy of SupportMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportMessageModelCopyWith<_SupportMessageModel> get copyWith => __$SupportMessageModelCopyWithImpl<_SupportMessageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupportMessageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportMessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.from, from) || other.from == from)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,from,text,createdAt);

@override
String toString() {
  return 'SupportMessageModel(id: $id, from: $from, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SupportMessageModelCopyWith<$Res> implements $SupportMessageModelCopyWith<$Res> {
  factory _$SupportMessageModelCopyWith(_SupportMessageModel value, $Res Function(_SupportMessageModel) _then) = __$SupportMessageModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String from, String text,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class __$SupportMessageModelCopyWithImpl<$Res>
    implements _$SupportMessageModelCopyWith<$Res> {
  __$SupportMessageModelCopyWithImpl(this._self, this._then);

  final _SupportMessageModel _self;
  final $Res Function(_SupportMessageModel) _then;

/// Create a copy of SupportMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? from = null,Object? text = null,Object? createdAt = freezed,}) {
  return _then(_SupportMessageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
