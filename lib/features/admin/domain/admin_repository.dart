import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/pricing/domain/entities/pricing_table.dart';

enum AdminSection {
  overview,
  drivers,
  rides,
  map,
  pricing,
  content,
  support,
  settings,
  promos,
  reports,
}

const adminActiveStatuses = [
  'searching',
  'accepted',
  'arriving',
  'arrived',
  'in_progress',
];

class AdminEntry extends Equatable {
  AdminEntry({
    required this.id,
    required this.status,
    this.currency = 'JOD',
    this.name = '',
    this.phone = '',
    this.vehicle = '',
    this.plate = '',
    this.rating = 0,
    this.createdAt,
    this.licensePath,
    this.licenseUrl,
    this.completed = 0,
    this.cancelled = 0,
    this.rider = '',
    this.driver = '',
    this.pickup = '',
    this.dropoff = '',
    this.estimated,
    this.finalFare,
    this.riderRating,
    this.driverRating,
    Map<String, DateTime> timeline = const {},
    this.lat,
    this.lng,
    this.busy = false,
    this.reason = '',
  }) : timeline = Map.unmodifiable(timeline);
  final String currency;
  final String id;
  final String status;
  final String name;
  final String phone;
  final String vehicle;
  final String plate;
  final String rider;
  final String driver;
  final String pickup;
  final String dropoff;
  final String reason;
  final String? licensePath;
  final String? licenseUrl;
  final num rating;
  final int completed;
  final int cancelled;
  final DateTime? createdAt;
  final int? estimated;
  final int? finalFare;
  final num? riderRating;
  final num? driverRating;
  final Map<String, DateTime> timeline;
  final double? lat;
  final double? lng;
  final bool busy;
  @override
  List<Object?> get props => [
    id,
    currency,
    status,
    name,
    phone,
    vehicle,
    plate,
    rating,
    createdAt,
    licensePath,
    licenseUrl,
    completed,
    cancelled,
    rider,
    driver,
    pickup,
    dropoff,
    estimated,
    finalFare,
    riderRating,
    driverRating,
    timeline,
    lat,
    lng,
    busy,
    reason,
  ];
}

class AdminQuery extends Equatable {
  const AdminQuery({
    required this.section,
    this.status,
    this.from,
    this.to,
    this.after,
    this.rideId,
  });
  final AdminSection section;
  final String? status;
  final String? after;
  final String? rideId;
  final DateTime? from;
  final DateTime? to;
  @override
  List<Object?> get props => [section, status, from, to, after, rideId];
}

class AdminData extends Equatable {
  AdminData({
    List<AdminEntry> entries = const [],
    List<int> stats = const [],
    this.next,
    this.pricing,
    this.marketPricing = const {},
    this.revenue = const {},
    this.updatedAt,
    this.updatedBy,
  }) : entries = List.unmodifiable(entries),
       stats = List.unmodifiable(stats);
  final List<AdminEntry> entries;
  final List<int> stats;
  final String? next;
  final String? updatedBy;
  final PricingTable? pricing;
  final Map<String, PricingTable> marketPricing;
  final Map<String, int> revenue;
  final DateTime? updatedAt;
  @override
  List<Object?> get props => [
    entries,
    stats,
    next,
    pricing,
    marketPricing,
    revenue,
    updatedAt,
    updatedBy,
  ];
}

abstract interface class AdminRepository {
  Future<Either<Failure, Unit>> signIn(String email, String password);
  Stream<Either<Failure, AdminData>> watch(AdminSection section);
  Future<Either<Failure, AdminData>> load(AdminQuery query);
  Future<Either<Failure, String>> license(String path);
  Future<Either<Failure, Unit>> action(
    String name,
    Map<String, Object> arguments,
  );
}
