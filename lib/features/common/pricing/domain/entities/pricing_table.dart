import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/pricing/domain/entities/vehicle_rates.dart';
import 'package:mishwar/features/common/user/domain/entities/vehicle_entity.dart';

class PricingTable extends Equatable {
  PricingTable(Map<VehicleType, VehicleRates> rates)
    : rates = Map.unmodifiable(rates) {
    if (!VehicleType.values.every(rates.containsKey)) {
      throw ArgumentError('Every vehicle type needs rates');
    }
  }
  factory PricingTable.defaults() => PricingTable(const {
    VehicleType.economy: VehicleRates(
      base: 500,
      perKm: 300,
      perMin: 50,
      minimum: 1500,
    ),
    VehicleType.comfort: VehicleRates(
      base: 800,
      perKm: 450,
      perMin: 70,
      minimum: 2500,
    ),
    VehicleType.van: VehicleRates(
      base: 1000,
      perKm: 550,
      perMin: 80,
      minimum: 3000,
    ),
  });
  final Map<VehicleType, VehicleRates> rates;
  VehicleRates operator [](VehicleType type) => rates[type]!;
  @override
  List<Object> get props => [rates];
}
