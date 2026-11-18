import 'package:equatable/equatable.dart';

enum ServiceId { ride, schedule, parcel, airport }

class AppService extends Equatable {
  const AppService({
    required this.id,
    required this.enabled,
    required this.order,
  });
  final ServiceId id;
  final bool enabled;
  final int order;
  static const defaults = [
    AppService(id: ServiceId.ride, enabled: true, order: 0),
    AppService(id: ServiceId.schedule, enabled: true, order: 1),
    AppService(id: ServiceId.parcel, enabled: false, order: 2),
    AppService(id: ServiceId.airport, enabled: false, order: 3),
  ];
  @override
  List<Object> get props => [id, enabled, order];
}
