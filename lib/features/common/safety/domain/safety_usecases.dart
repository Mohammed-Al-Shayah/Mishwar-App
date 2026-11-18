import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/safety/domain/safety_repository.dart';
import 'package:mishwar/features/common/safety/domain/trusted_contact.dart';

@lazySingleton
class WatchTrustedContacts {
  const WatchTrustedContacts(this._repository);
  final SafetyRepository _repository;
  Stream<Either<Failure, List<TrustedContact>>> call(String uid) =>
      _repository.watch(uid);
}

@lazySingleton
class SaveTrustedContact {
  const SaveTrustedContact(this._repository);
  final SafetyRepository _repository;
  Future<Either<Failure, Unit>> call(String uid, TrustedContact contact) =>
      validTrustedContact(contact)
      ? _repository.save(uid, contact)
      : Future.value(const Left(ValidationFailure('trusted-contact')));
}

@lazySingleton
class DeleteTrustedContact {
  const DeleteTrustedContact(this._repository);
  final SafetyRepository _repository;
  Future<Either<Failure, Unit>> call(String uid, String id) =>
      _repository.delete(uid, id);
}

@lazySingleton
class CreateShareLink {
  const CreateShareLink(this._repository);
  final SafetyRepository _repository;
  Future<Either<Failure, String>> call(String rideId) =>
      _repository.createShareLink(rideId);
}
