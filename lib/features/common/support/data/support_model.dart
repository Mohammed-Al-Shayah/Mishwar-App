import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mishwar/core/firebase/converters.dart';
import 'package:mishwar/features/common/support/domain/support_ticket.dart';

part 'support_model.freezed.dart';
part 'support_model.g.dart';

@freezed
abstract class SupportTicketModel with _$SupportTicketModel {
  const factory SupportTicketModel({
    required String id,
    required String uid,
    required String role,
    required String category,
    required String subject,
    required String status,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    @TimestampConverter() required DateTime lastMessageAt,
    required String lastMessageBy,
    required bool userUnread,
    String? rideId,
  }) = _SupportTicketModel;
  const SupportTicketModel._();
  factory SupportTicketModel.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketModelFromJson(json);
  SupportTicket toEntity() => SupportTicket(
    id: id,
    uid: uid,
    role: role,
    category: SupportCategory.values.firstWhere((v) => v.code == category),
    subject: subject,
    status: SupportStatus.values.firstWhere((v) => v.code == status),
    createdAt: createdAt,
    updatedAt: updatedAt,
    lastMessageAt: lastMessageAt,
    lastMessageBy: lastMessageBy,
    userUnread: userUnread,
    rideId: rideId,
  );
}

@freezed
abstract class SupportMessageModel with _$SupportMessageModel {
  const factory SupportMessageModel({
    required String id,
    required String from,
    required String text,
    @TimestampConverter() DateTime? createdAt,
  }) = _SupportMessageModel;
  const SupportMessageModel._();
  factory SupportMessageModel.fromJson(Map<String, dynamic> json) =>
      _$SupportMessageModelFromJson(json);
  SupportMessage toEntity() =>
      SupportMessage(id: id, from: from, text: text, createdAt: createdAt);
}
