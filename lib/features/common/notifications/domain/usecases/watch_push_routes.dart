import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/core/usecase/usecase.dart';
import 'package:mishwar/features/common/notifications/domain/push_repository.dart';

@lazySingleton
class WatchPushRoutes implements StreamUseCase<String, NoParams> {
  WatchPushRoutes(this._push);
  final PushRepository _push;
  @override
  Stream<Either<Failure, String>> call(NoParams params) =>
      _push.openedRoutes.map(Right.new);
}

@lazySingleton
class GetInitialPushRoute implements UseCase<String?, NoParams> {
  GetInitialPushRoute(this._push);
  final PushRepository _push;
  @override
  Future<Either<Failure, String?>> call(NoParams params) =>
      _push.initialRoute();
}
