import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/user/domain/entities/user_role.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
    this.role,
    this.photoUrl,
    this.pendingRatingRideId,
    this.rating = 5.0,
    this.ratingCount = 0,
  });
  final String id;
  final String? pendingRatingRideId;
  final String name;
  final String phone;
  final UserRole? role;
  final String? photoUrl;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;
  static const _unset = Object();
  UserEntity copyWith({
    String? id,
    String? name,
    String? phone,
    Object? pendingRatingRideId = _unset,
    Object? role = _unset,
    Object? photoUrl = _unset,
    double? rating,
    int? ratingCount,
    DateTime? createdAt,
  }) => UserEntity(
    id: id ?? this.id,
    pendingRatingRideId: identical(pendingRatingRideId, _unset)
        ? this.pendingRatingRideId
        : pendingRatingRideId as String?,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    role: identical(role, _unset) ? this.role : role as UserRole?,
    photoUrl: identical(photoUrl, _unset) ? this.photoUrl : photoUrl as String?,
    rating: rating ?? this.rating,
    ratingCount: ratingCount ?? this.ratingCount,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  List<Object?> get props => [
    id,
    pendingRatingRideId,
    name,
    phone,
    role,
    photoUrl,
    rating,
    ratingCount,
    createdAt,
  ];
}
