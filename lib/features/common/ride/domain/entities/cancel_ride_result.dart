import 'package:equatable/equatable.dart';

class CancelRideResult extends Equatable {
  const CancelRideResult({this.redispatched = false});
  final bool redispatched;
  @override
  List<Object> get props => [redispatched];
}
