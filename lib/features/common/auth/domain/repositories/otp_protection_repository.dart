import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';

class OtpProtection extends Equatable {
  const OtpProtection({this.remaining = 0, this.locked = false});
  final int remaining;
  final bool locked;
  @override
  List<Object?> get props => [remaining, locked];
}

// Repository boundary keeps persistence outside the domain.
// ignore: one_member_abstracts
abstract interface class OtpProtectionRepository {
  Future<Either<Failure, OtpProtection>> read(String phone);
}
