import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/safety/domain/trusted_contact.dart';

abstract class SafetyRepository {
  Stream<Either<Failure, List<TrustedContact>>> watch(String uid);
  Future<Either<Failure, Unit>> save(String uid, TrustedContact contact);
  Future<Either<Failure, Unit>> delete(String uid, String id);
  Future<Either<Failure, String>> createShareLink(String rideId);
}
