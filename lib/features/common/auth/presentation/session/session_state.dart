import 'package:equatable/equatable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/auth/domain/entities/auth_user.dart';
import 'package:mishwar/features/common/user/domain/entities/user_entity.dart';

sealed class SessionState extends Equatable {
  const SessionState();
  @override
  List<Object?> get props => [];
}

final class SessionUnknown extends SessionState {
  const SessionUnknown();
}

final class SessionSignedOut extends SessionState {
  const SessionSignedOut();
}

final class SessionNeedsName extends SessionState {
  const SessionNeedsName(this.authUser);
  final AuthUser authUser;
  @override
  List<Object?> get props => [authUser];
}

final class SessionNeedsRole extends SessionState {
  const SessionNeedsRole(this.user);
  final UserEntity user;
  @override
  List<Object?> get props => [user];
}

final class SessionReady extends SessionState {
  const SessionReady(this.user);
  final UserEntity user;
  @override
  List<Object?> get props => [user];
}

final class SessionError extends SessionState {
  const SessionError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
