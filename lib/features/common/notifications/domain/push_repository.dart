import 'package:fpdart/fpdart.dart';
import 'package:mishwar/core/error/failures.dart';

abstract interface class PushRepository {
  Future<Either<Failure, bool>> requestPermission();
  Future<Either<Failure, String?>> token();
  Stream<Either<Failure, String>> get onTokenRefresh;
  Future<Either<Failure, Unit>> deleteToken();
  Future<Either<Failure, Unit>> saveToken(String uid, String token);
  Future<Either<Failure, Unit>> removeToken(String uid);
  Stream<String> get openedRoutes;
  Future<Either<Failure, String?>> initialRoute();
}
