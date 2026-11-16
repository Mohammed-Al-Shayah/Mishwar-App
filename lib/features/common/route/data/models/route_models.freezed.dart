// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RouteModel {

 String get polyline; int get distanceMeters; double get durationSeconds;
/// Create a copy of RouteModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteModelCopyWith<RouteModel> get copyWith => _$RouteModelCopyWithImpl<RouteModel>(this as RouteModel, _$identity);

  /// Serializes this RouteModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteModel&&(identical(other.polyline, polyline) || other.polyline == polyline)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,polyline,distanceMeters,durationSeconds);

@override
String toString() {
  return 'RouteModel(polyline: $polyline, distanceMeters: $distanceMeters, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class $RouteModelCopyWith<$Res>  {
  factory $RouteModelCopyWith(RouteModel value, $Res Function(RouteModel) _then) = _$RouteModelCopyWithImpl;
@useResult
$Res call({
 String polyline, int distanceMeters, double durationSeconds
});




}
/// @nodoc
class _$RouteModelCopyWithImpl<$Res>
    implements $RouteModelCopyWith<$Res> {
  _$RouteModelCopyWithImpl(this._self, this._then);

  final RouteModel _self;
  final $Res Function(RouteModel) _then;

/// Create a copy of RouteModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? polyline = null,Object? distanceMeters = null,Object? durationSeconds = null,}) {
  return _then(_self.copyWith(
polyline: null == polyline ? _self.polyline : polyline // ignore: cast_nullable_to_non_nullable
as String,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as int,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteModel].
extension RouteModelPatterns on RouteModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteModel value)  $default,){
final _that = this;
switch (_that) {
case _RouteModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteModel value)?  $default,){
final _that = this;
switch (_that) {
case _RouteModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String polyline,  int distanceMeters,  double durationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteModel() when $default != null:
return $default(_that.polyline,_that.distanceMeters,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String polyline,  int distanceMeters,  double durationSeconds)  $default,) {final _that = this;
switch (_that) {
case _RouteModel():
return $default(_that.polyline,_that.distanceMeters,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String polyline,  int distanceMeters,  double durationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _RouteModel() when $default != null:
return $default(_that.polyline,_that.distanceMeters,_that.durationSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteModel extends RouteModel {
  const _RouteModel({required this.polyline, required this.distanceMeters, required this.durationSeconds}): super._();
  factory _RouteModel.fromJson(Map<String, dynamic> json) => _$RouteModelFromJson(json);

@override final  String polyline;
@override final  int distanceMeters;
@override final  double durationSeconds;

/// Create a copy of RouteModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteModelCopyWith<_RouteModel> get copyWith => __$RouteModelCopyWithImpl<_RouteModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteModel&&(identical(other.polyline, polyline) || other.polyline == polyline)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,polyline,distanceMeters,durationSeconds);

@override
String toString() {
  return 'RouteModel(polyline: $polyline, distanceMeters: $distanceMeters, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class _$RouteModelCopyWith<$Res> implements $RouteModelCopyWith<$Res> {
  factory _$RouteModelCopyWith(_RouteModel value, $Res Function(_RouteModel) _then) = __$RouteModelCopyWithImpl;
@override @useResult
$Res call({
 String polyline, int distanceMeters, double durationSeconds
});




}
/// @nodoc
class __$RouteModelCopyWithImpl<$Res>
    implements _$RouteModelCopyWith<$Res> {
  __$RouteModelCopyWithImpl(this._self, this._then);

  final _RouteModel _self;
  final $Res Function(_RouteModel) _then;

/// Create a copy of RouteModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? polyline = null,Object? distanceMeters = null,Object? durationSeconds = null,}) {
  return _then(_RouteModel(
polyline: null == polyline ? _self.polyline : polyline // ignore: cast_nullable_to_non_nullable
as String,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as int,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$FareEstimateModel {

 VehicleType get vehicleType; double get amount; String get currency;
/// Create a copy of FareEstimateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FareEstimateModelCopyWith<FareEstimateModel> get copyWith => _$FareEstimateModelCopyWithImpl<FareEstimateModel>(this as FareEstimateModel, _$identity);

  /// Serializes this FareEstimateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FareEstimateModel&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vehicleType,amount,currency);

@override
String toString() {
  return 'FareEstimateModel(vehicleType: $vehicleType, amount: $amount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $FareEstimateModelCopyWith<$Res>  {
  factory $FareEstimateModelCopyWith(FareEstimateModel value, $Res Function(FareEstimateModel) _then) = _$FareEstimateModelCopyWithImpl;
@useResult
$Res call({
 VehicleType vehicleType, double amount, String currency
});




}
/// @nodoc
class _$FareEstimateModelCopyWithImpl<$Res>
    implements $FareEstimateModelCopyWith<$Res> {
  _$FareEstimateModelCopyWithImpl(this._self, this._then);

  final FareEstimateModel _self;
  final $Res Function(FareEstimateModel) _then;

/// Create a copy of FareEstimateModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vehicleType = null,Object? amount = null,Object? currency = null,}) {
  return _then(_self.copyWith(
vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FareEstimateModel].
extension FareEstimateModelPatterns on FareEstimateModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FareEstimateModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FareEstimateModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FareEstimateModel value)  $default,){
final _that = this;
switch (_that) {
case _FareEstimateModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FareEstimateModel value)?  $default,){
final _that = this;
switch (_that) {
case _FareEstimateModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VehicleType vehicleType,  double amount,  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FareEstimateModel() when $default != null:
return $default(_that.vehicleType,_that.amount,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VehicleType vehicleType,  double amount,  String currency)  $default,) {final _that = this;
switch (_that) {
case _FareEstimateModel():
return $default(_that.vehicleType,_that.amount,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VehicleType vehicleType,  double amount,  String currency)?  $default,) {final _that = this;
switch (_that) {
case _FareEstimateModel() when $default != null:
return $default(_that.vehicleType,_that.amount,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FareEstimateModel extends FareEstimateModel {
  const _FareEstimateModel({required this.vehicleType, required this.amount, required this.currency}): super._();
  factory _FareEstimateModel.fromJson(Map<String, dynamic> json) => _$FareEstimateModelFromJson(json);

@override final  VehicleType vehicleType;
@override final  double amount;
@override final  String currency;

/// Create a copy of FareEstimateModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FareEstimateModelCopyWith<_FareEstimateModel> get copyWith => __$FareEstimateModelCopyWithImpl<_FareEstimateModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FareEstimateModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FareEstimateModel&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vehicleType,amount,currency);

@override
String toString() {
  return 'FareEstimateModel(vehicleType: $vehicleType, amount: $amount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$FareEstimateModelCopyWith<$Res> implements $FareEstimateModelCopyWith<$Res> {
  factory _$FareEstimateModelCopyWith(_FareEstimateModel value, $Res Function(_FareEstimateModel) _then) = __$FareEstimateModelCopyWithImpl;
@override @useResult
$Res call({
 VehicleType vehicleType, double amount, String currency
});




}
/// @nodoc
class __$FareEstimateModelCopyWithImpl<$Res>
    implements _$FareEstimateModelCopyWith<$Res> {
  __$FareEstimateModelCopyWithImpl(this._self, this._then);

  final _FareEstimateModel _self;
  final $Res Function(_FareEstimateModel) _then;

/// Create a copy of FareEstimateModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vehicleType = null,Object? amount = null,Object? currency = null,}) {
  return _then(_FareEstimateModel(
vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$FareEstimatesModel {

 RouteModel get route; List<FareEstimateModel> get fares;
/// Create a copy of FareEstimatesModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FareEstimatesModelCopyWith<FareEstimatesModel> get copyWith => _$FareEstimatesModelCopyWithImpl<FareEstimatesModel>(this as FareEstimatesModel, _$identity);

  /// Serializes this FareEstimatesModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FareEstimatesModel&&(identical(other.route, route) || other.route == route)&&const DeepCollectionEquality().equals(other.fares, fares));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,route,const DeepCollectionEquality().hash(fares));

@override
String toString() {
  return 'FareEstimatesModel(route: $route, fares: $fares)';
}


}

/// @nodoc
abstract mixin class $FareEstimatesModelCopyWith<$Res>  {
  factory $FareEstimatesModelCopyWith(FareEstimatesModel value, $Res Function(FareEstimatesModel) _then) = _$FareEstimatesModelCopyWithImpl;
@useResult
$Res call({
 RouteModel route, List<FareEstimateModel> fares
});


$RouteModelCopyWith<$Res> get route;

}
/// @nodoc
class _$FareEstimatesModelCopyWithImpl<$Res>
    implements $FareEstimatesModelCopyWith<$Res> {
  _$FareEstimatesModelCopyWithImpl(this._self, this._then);

  final FareEstimatesModel _self;
  final $Res Function(FareEstimatesModel) _then;

/// Create a copy of FareEstimatesModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? route = null,Object? fares = null,}) {
  return _then(_self.copyWith(
route: null == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as RouteModel,fares: null == fares ? _self.fares : fares // ignore: cast_nullable_to_non_nullable
as List<FareEstimateModel>,
  ));
}
/// Create a copy of FareEstimatesModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RouteModelCopyWith<$Res> get route {
  
  return $RouteModelCopyWith<$Res>(_self.route, (value) {
    return _then(_self.copyWith(route: value));
  });
}
}


/// Adds pattern-matching-related methods to [FareEstimatesModel].
extension FareEstimatesModelPatterns on FareEstimatesModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FareEstimatesModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FareEstimatesModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FareEstimatesModel value)  $default,){
final _that = this;
switch (_that) {
case _FareEstimatesModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FareEstimatesModel value)?  $default,){
final _that = this;
switch (_that) {
case _FareEstimatesModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RouteModel route,  List<FareEstimateModel> fares)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FareEstimatesModel() when $default != null:
return $default(_that.route,_that.fares);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RouteModel route,  List<FareEstimateModel> fares)  $default,) {final _that = this;
switch (_that) {
case _FareEstimatesModel():
return $default(_that.route,_that.fares);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RouteModel route,  List<FareEstimateModel> fares)?  $default,) {final _that = this;
switch (_that) {
case _FareEstimatesModel() when $default != null:
return $default(_that.route,_that.fares);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FareEstimatesModel extends FareEstimatesModel {
  const _FareEstimatesModel({required this.route, required final  List<FareEstimateModel> fares}): _fares = fares,super._();
  factory _FareEstimatesModel.fromJson(Map<String, dynamic> json) => _$FareEstimatesModelFromJson(json);

@override final  RouteModel route;
 final  List<FareEstimateModel> _fares;
@override List<FareEstimateModel> get fares {
  if (_fares is EqualUnmodifiableListView) return _fares;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fares);
}


/// Create a copy of FareEstimatesModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FareEstimatesModelCopyWith<_FareEstimatesModel> get copyWith => __$FareEstimatesModelCopyWithImpl<_FareEstimatesModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FareEstimatesModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FareEstimatesModel&&(identical(other.route, route) || other.route == route)&&const DeepCollectionEquality().equals(other._fares, _fares));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,route,const DeepCollectionEquality().hash(_fares));

@override
String toString() {
  return 'FareEstimatesModel(route: $route, fares: $fares)';
}


}

/// @nodoc
abstract mixin class _$FareEstimatesModelCopyWith<$Res> implements $FareEstimatesModelCopyWith<$Res> {
  factory _$FareEstimatesModelCopyWith(_FareEstimatesModel value, $Res Function(_FareEstimatesModel) _then) = __$FareEstimatesModelCopyWithImpl;
@override @useResult
$Res call({
 RouteModel route, List<FareEstimateModel> fares
});


@override $RouteModelCopyWith<$Res> get route;

}
/// @nodoc
class __$FareEstimatesModelCopyWithImpl<$Res>
    implements _$FareEstimatesModelCopyWith<$Res> {
  __$FareEstimatesModelCopyWithImpl(this._self, this._then);

  final _FareEstimatesModel _self;
  final $Res Function(_FareEstimatesModel) _then;

/// Create a copy of FareEstimatesModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? route = null,Object? fares = null,}) {
  return _then(_FareEstimatesModel(
route: null == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as RouteModel,fares: null == fares ? _self._fares : fares // ignore: cast_nullable_to_non_nullable
as List<FareEstimateModel>,
  ));
}

/// Create a copy of FareEstimatesModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RouteModelCopyWith<$Res> get route {
  
  return $RouteModelCopyWith<$Res>(_self.route, (value) {
    return _then(_self.copyWith(route: value));
  });
}
}

// dart format on
