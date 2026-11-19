// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'promo_quote_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PromoQuoteModel {

 String get code; double get discount; double get fareBefore; double get fareAfter; String get currency;
/// Create a copy of PromoQuoteModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PromoQuoteModelCopyWith<PromoQuoteModel> get copyWith => _$PromoQuoteModelCopyWithImpl<PromoQuoteModel>(this as PromoQuoteModel, _$identity);

  /// Serializes this PromoQuoteModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PromoQuoteModel&&(identical(other.code, code) || other.code == code)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.fareBefore, fareBefore) || other.fareBefore == fareBefore)&&(identical(other.fareAfter, fareAfter) || other.fareAfter == fareAfter)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,discount,fareBefore,fareAfter,currency);

@override
String toString() {
  return 'PromoQuoteModel(code: $code, discount: $discount, fareBefore: $fareBefore, fareAfter: $fareAfter, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $PromoQuoteModelCopyWith<$Res>  {
  factory $PromoQuoteModelCopyWith(PromoQuoteModel value, $Res Function(PromoQuoteModel) _then) = _$PromoQuoteModelCopyWithImpl;
@useResult
$Res call({
 String code, double discount, double fareBefore, double fareAfter, String currency
});




}
/// @nodoc
class _$PromoQuoteModelCopyWithImpl<$Res>
    implements $PromoQuoteModelCopyWith<$Res> {
  _$PromoQuoteModelCopyWithImpl(this._self, this._then);

  final PromoQuoteModel _self;
  final $Res Function(PromoQuoteModel) _then;

/// Create a copy of PromoQuoteModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? discount = null,Object? fareBefore = null,Object? fareAfter = null,Object? currency = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,fareBefore: null == fareBefore ? _self.fareBefore : fareBefore // ignore: cast_nullable_to_non_nullable
as double,fareAfter: null == fareAfter ? _self.fareAfter : fareAfter // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PromoQuoteModel].
extension PromoQuoteModelPatterns on PromoQuoteModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PromoQuoteModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PromoQuoteModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PromoQuoteModel value)  $default,){
final _that = this;
switch (_that) {
case _PromoQuoteModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PromoQuoteModel value)?  $default,){
final _that = this;
switch (_that) {
case _PromoQuoteModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  double discount,  double fareBefore,  double fareAfter,  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PromoQuoteModel() when $default != null:
return $default(_that.code,_that.discount,_that.fareBefore,_that.fareAfter,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  double discount,  double fareBefore,  double fareAfter,  String currency)  $default,) {final _that = this;
switch (_that) {
case _PromoQuoteModel():
return $default(_that.code,_that.discount,_that.fareBefore,_that.fareAfter,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  double discount,  double fareBefore,  double fareAfter,  String currency)?  $default,) {final _that = this;
switch (_that) {
case _PromoQuoteModel() when $default != null:
return $default(_that.code,_that.discount,_that.fareBefore,_that.fareAfter,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PromoQuoteModel extends PromoQuoteModel {
  const _PromoQuoteModel({required this.code, required this.discount, required this.fareBefore, required this.fareAfter, this.currency = 'JOD'}): super._();
  factory _PromoQuoteModel.fromJson(Map<String, dynamic> json) => _$PromoQuoteModelFromJson(json);

@override final  String code;
@override final  double discount;
@override final  double fareBefore;
@override final  double fareAfter;
@override@JsonKey() final  String currency;

/// Create a copy of PromoQuoteModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PromoQuoteModelCopyWith<_PromoQuoteModel> get copyWith => __$PromoQuoteModelCopyWithImpl<_PromoQuoteModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PromoQuoteModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PromoQuoteModel&&(identical(other.code, code) || other.code == code)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.fareBefore, fareBefore) || other.fareBefore == fareBefore)&&(identical(other.fareAfter, fareAfter) || other.fareAfter == fareAfter)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,discount,fareBefore,fareAfter,currency);

@override
String toString() {
  return 'PromoQuoteModel(code: $code, discount: $discount, fareBefore: $fareBefore, fareAfter: $fareAfter, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$PromoQuoteModelCopyWith<$Res> implements $PromoQuoteModelCopyWith<$Res> {
  factory _$PromoQuoteModelCopyWith(_PromoQuoteModel value, $Res Function(_PromoQuoteModel) _then) = __$PromoQuoteModelCopyWithImpl;
@override @useResult
$Res call({
 String code, double discount, double fareBefore, double fareAfter, String currency
});




}
/// @nodoc
class __$PromoQuoteModelCopyWithImpl<$Res>
    implements _$PromoQuoteModelCopyWith<$Res> {
  __$PromoQuoteModelCopyWithImpl(this._self, this._then);

  final _PromoQuoteModel _self;
  final $Res Function(_PromoQuoteModel) _then;

/// Create a copy of PromoQuoteModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? discount = null,Object? fareBefore = null,Object? fareAfter = null,Object? currency = null,}) {
  return _then(_PromoQuoteModel(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,fareBefore: null == fareBefore ? _self.fareBefore : fareBefore // ignore: cast_nullable_to_non_nullable
as double,fareAfter: null == fareAfter ? _self.fareAfter : fareAfter // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
