import 'package:equatable/equatable.dart';

enum ServiceType { ride, parcel, airport }

class ParcelDetails extends Equatable {
  const ParcelDetails({
    required this.recipientName,
    required this.recipientPhone,
    required this.description,
    this.photoPath,
    this.codeAttempts = 0,
  });
  final String recipientName;
  final String recipientPhone;
  final String description;
  final String? photoPath;
  final int codeAttempts;
  @override
  List<Object?> get props => [
    recipientName,
    recipientPhone,
    description,
    photoPath,
    codeAttempts,
  ];
}
