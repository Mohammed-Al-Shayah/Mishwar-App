import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({required this.uid, this.phone, this.isAdmin = false});
  final String uid;
  final String? phone;
  final bool isAdmin;
  @override
  List<Object?> get props => [uid, phone, isAdmin];
}
