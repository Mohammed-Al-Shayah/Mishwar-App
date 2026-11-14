import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';

// Use cases expose one operation as an injectable domain contract.
// ignore: one_member_abstracts
abstract interface class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params);
}

// Streaming use cases use the same single-operation domain contract.
// ignore: one_member_abstracts
abstract interface class StreamUseCase<T, P> {
  Stream<Either<Failure, T>> call(P params);
}

final class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
