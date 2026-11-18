import 'package:equatable/equatable.dart';

enum SupportCategory {
  lostItem('lost_item'),
  fare('fare'),
  safety('safety'),
  other('other');

  const SupportCategory(this.code);
  final String code;
}

enum SupportStatus {
  open('open'),
  inProgress('in_progress'),
  closed('closed');

  const SupportStatus(this.code);
  final String code;
}

class SupportTicket extends Equatable {
  const SupportTicket({
    required this.id,
    required this.uid,
    required this.role,
    required this.category,
    required this.subject,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessageAt,
    required this.lastMessageBy,
    required this.userUnread,
    this.rideId,
  });
  final String id;
  final String uid;
  final String role;
  final String? rideId;
  final SupportCategory category;
  final String subject;
  final SupportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastMessageAt;
  final String lastMessageBy;
  final bool userUnread;
  @override
  List<Object?> get props => [
    id,
    uid,
    role,
    rideId,
    category,
    subject,
    status,
    createdAt,
    updatedAt,
    lastMessageAt,
    lastMessageBy,
    userUnread,
  ];
}

class SupportMessage extends Equatable {
  const SupportMessage({
    required this.id,
    required this.from,
    required this.text,
    this.createdAt,
  });
  final String id;
  final String from;
  final String text;
  final DateTime? createdAt;
  @override
  List<Object?> get props => [id, from, text, createdAt];
}
