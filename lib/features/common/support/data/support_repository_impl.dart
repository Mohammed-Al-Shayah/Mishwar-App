import 'package:cloud_functions/cloud_functions.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/support/data/support_remote_data_source.dart';
import 'package:mishwar/features/common/support/domain/support_repository.dart';
import 'package:mishwar/features/common/support/domain/support_ticket.dart';

@LazySingleton(as: SupportRepository)
class SupportRepositoryImpl implements SupportRepository {
  const SupportRepositoryImpl(this._source);
  final SupportRemoteDataSource _source;
  Stream<Either<Failure, T>> _stream<T>(Stream<T> Function() watch) async* {
    try {
      await for (final value in watch()) {
        yield Right(value);
      }
    } on Object {
      yield const Left(ServerFailure('support'));
    }
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on FirebaseFunctionsException catch (error) {
      if (error.details is Map &&
          (error.details as Map)['reason'] == 'too-many-open') {
        return const Left(ValidationFailure('support-limit'));
      }
      return const Left(ServerFailure('support'));
    } on Object {
      return const Left(ServerFailure('support'));
    }
  }

  @override
  Stream<Either<Failure, List<SupportTicket>>> watchTickets({
    String? uid,
    SupportStatus? status,
  }) => _stream(
    () => _source
        .watchTickets(uid: uid, status: status)
        .map((models) => List.unmodifiable(models.map((m) => m.toEntity()))),
  );
  @override
  Stream<Either<Failure, SupportTicket>> watchTicket(String id) =>
      _stream(() => _source.watchTicket(id).map((m) => m.toEntity()));
  @override
  Stream<Either<Failure, List<SupportMessage>>> watchMessages(String id) =>
      _stream(
        () => _source
            .watchMessages(id)
            .map(
              (models) => List.unmodifiable(models.map((m) => m.toEntity())),
            ),
      );
  @override
  Future<Either<Failure, String>> create(
    SupportCategory category,
    String message, {
    String? rideId,
  }) => _guard(() => _source.create(category, message, rideId: rideId));
  @override
  Future<Either<Failure, Unit>> send(
    String id,
    String text, {
    bool admin = false,
  }) => _guard(() async {
    await _source.send(id, text, admin: admin);
    return unit;
  });
  @override
  Future<Either<Failure, Unit>> markRead(String id) => _guard(() async {
    await _source.markRead(id);
    return unit;
  });
  @override
  Future<Either<Failure, Unit>> setStatus(String id, SupportStatus status) =>
      _guard(() async {
        await _source.setStatus(id, status);
        return unit;
      });
}
