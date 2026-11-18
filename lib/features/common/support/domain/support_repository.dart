import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/support/domain/support_ticket.dart';

abstract interface class SupportRepository {
  Stream<Either<Failure, List<SupportTicket>>> watchTickets({
    String? uid,
    SupportStatus? status,
  });
  Stream<Either<Failure, SupportTicket>> watchTicket(String id);
  Stream<Either<Failure, List<SupportMessage>>> watchMessages(String id);
  Future<Either<Failure, String>> create(
    SupportCategory category,
    String message, {
    String? rideId,
  });
  Future<Either<Failure, Unit>> send(
    String id,
    String text, {
    bool admin = false,
  });
  Future<Either<Failure, Unit>> markRead(String id);
  Future<Either<Failure, Unit>> setStatus(String id, SupportStatus status);
}
