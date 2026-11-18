import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/support/domain/support_repository.dart';
import 'package:mishwar/features/common/support/domain/support_ticket.dart';

@lazySingleton
class WatchSupportTickets {
  const WatchSupportTickets(this._repository);
  final SupportRepository _repository;
  Stream<Either<Failure, List<SupportTicket>>> call({
    String? uid,
    SupportStatus? status,
  }) => _repository.watchTickets(uid: uid, status: status);
}

@lazySingleton
class WatchSupportTicket {
  const WatchSupportTicket(this._repository);
  final SupportRepository _repository;
  Stream<Either<Failure, SupportTicket>> call(String id) =>
      _repository.watchTicket(id);
}

@lazySingleton
class WatchSupportMessages {
  const WatchSupportMessages(this._repository);
  final SupportRepository _repository;
  Stream<Either<Failure, List<SupportMessage>>> call(String id) =>
      _repository.watchMessages(id);
}

@lazySingleton
class CreateSupportTicket {
  const CreateSupportTicket(this._repository);
  final SupportRepository _repository;
  Future<Either<Failure, String>> call(
    SupportCategory category,
    String message, {
    String? rideId,
  }) {
    final text = message.trim();
    if (text.isEmpty || text.length > 1000) {
      return Future.value(const Left(ValidationFailure('support-message')));
    }
    return _repository.create(category, text, rideId: rideId);
  }
}

@lazySingleton
class SendSupportMessage {
  const SendSupportMessage(this._repository);
  final SupportRepository _repository;
  Future<Either<Failure, Unit>> call(
    String id,
    String text, {
    bool admin = false,
  }) {
    final value = text.trim();
    if (value.isEmpty || value.length > 1000) {
      return Future.value(const Left(ValidationFailure('support-message')));
    }
    return _repository.send(id, value, admin: admin);
  }
}

@lazySingleton
class MarkSupportRead {
  const MarkSupportRead(this._repository);
  final SupportRepository _repository;
  Future<Either<Failure, Unit>> call(String id) => _repository.markRead(id);
}

@lazySingleton
class SetSupportStatus {
  const SetSupportStatus(this._repository);
  final SupportRepository _repository;
  Future<Either<Failure, Unit>> call(String id, SupportStatus status) =>
      _repository.setStatus(id, status);
}
