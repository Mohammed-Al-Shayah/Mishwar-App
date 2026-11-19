// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_earnings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DailyEarningsModel {

 String get currency; double get total; int get trips;
/// Create a copy of DailyEarningsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyEarningsModelCopyWith<DailyEarningsModel> get copyWith => _$DailyEarningsModelCopyWithImpl<DailyEarningsModel>(this as DailyEarningsModel, _$identity);

  /// Serializes this DailyEarningsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyEarningsModel&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.total, total) || other.total == total)&&(identical(other.trips, trips) || other.trips == trips));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currency,total,trips);

@override
String toString() {
  return 'DailyEarningsModel(currency: $currency, total: $total, trips: $trips)';
}


}

/// @nodoc
abstract mixin class $DailyEarningsModelCopyWith<$Res>  {
  factory $DailyEarningsModelCopyWith(DailyEarningsModel value, $Res Function(DailyEarningsModel) _then) = _$DailyEarningsModelCopyWithImpl;
@useResult
$Res call({
 String currency, double total, int trips
});




}
/// @nodoc
class _$DailyEarningsModelCopyWithImpl<$Res>
    implements $DailyEarningsModelCopyWith<$Res> {
  _$DailyEarningsModelCopyWithImpl(this._self, this._then);

  final DailyEarningsModel _self;
  final $Res Function(DailyEarningsModel) _then;

/// Create a copy of DailyEarningsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currency = null,Object? total = null,Object? trips = null,}) {
  return _then(_self.copyWith(
currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,trips: null == trips ? _self.trips : trips // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyEarningsModel].
extension DailyEarningsModelPatterns on DailyEarningsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyEarningsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyEarningsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyEarningsModel value)  $default,){
final _that = this;
switch (_that) {
case _DailyEarningsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyEarningsModel value)?  $default,){
final _that = this;
switch (_that) {
case _DailyEarningsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currency,  double total,  int trips)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyEarningsModel() when $default != null:
return $default(_that.currency,_that.total,_that.trips);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currency,  double total,  int trips)  $default,) {final _that = this;
switch (_that) {
case _DailyEarningsModel():
return $default(_that.currency,_that.total,_that.trips);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currency,  double total,  int trips)?  $default,) {final _that = this;
switch (_that) {
case _DailyEarningsModel() when $default != null:
return $default(_that.currency,_that.total,_that.trips);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyEarningsModel extends DailyEarningsModel {
  const _DailyEarningsModel({this.currency = 'JOD', this.total = 0.0, this.trips = 0}): super._();
  factory _DailyEarningsModel.fromJson(Map<String, dynamic> json) => _$DailyEarningsModelFromJson(json);

@override@JsonKey() final  String currency;
@override@JsonKey() final  double total;
@override@JsonKey() final  int trips;

/// Create a copy of DailyEarningsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyEarningsModelCopyWith<_DailyEarningsModel> get copyWith => __$DailyEarningsModelCopyWithImpl<_DailyEarningsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyEarningsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyEarningsModel&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.total, total) || other.total == total)&&(identical(other.trips, trips) || other.trips == trips));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currency,total,trips);

@override
String toString() {
  return 'DailyEarningsModel(currency: $currency, total: $total, trips: $trips)';
}


}

/// @nodoc
abstract mixin class _$DailyEarningsModelCopyWith<$Res> implements $DailyEarningsModelCopyWith<$Res> {
  factory _$DailyEarningsModelCopyWith(_DailyEarningsModel value, $Res Function(_DailyEarningsModel) _then) = __$DailyEarningsModelCopyWithImpl;
@override @useResult
$Res call({
 String currency, double total, int trips
});




}
/// @nodoc
class __$DailyEarningsModelCopyWithImpl<$Res>
    implements _$DailyEarningsModelCopyWith<$Res> {
  __$DailyEarningsModelCopyWithImpl(this._self, this._then);

  final _DailyEarningsModel _self;
  final $Res Function(_DailyEarningsModel) _then;

/// Create a copy of DailyEarningsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currency = null,Object? total = null,Object? trips = null,}) {
  return _then(_DailyEarningsModel(
currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,trips: null == trips ? _self.trips : trips // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
