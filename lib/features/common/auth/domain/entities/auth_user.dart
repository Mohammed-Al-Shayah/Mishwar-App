import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({required this.uid, this.phone});
  final String uid;
  final String? phone;
  @override
  List<Object?> get props => [uid, phone];
}
