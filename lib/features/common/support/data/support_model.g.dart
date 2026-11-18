// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SupportTicketModel _$SupportTicketModelFromJson(Map<String, dynamic> json) =>
    _SupportTicketModel(
      id: json['id'] as String,
      uid: json['uid'] as String,
      role: json['role'] as String,
      category: json['category'] as String,
      subject: json['subject'] as String,
      status: json['status'] as String,
      createdAt: const TimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
      updatedAt: const TimestampConverter().fromJson(
        json['updatedAt'] as Timestamp,
      ),
      lastMessageAt: const TimestampConverter().fromJson(
        json['lastMessageAt'] as Timestamp,
      ),
      lastMessageBy: json['lastMessageBy'] as String,
      userUnread: json['userUnread'] as bool,
      rideId: json['rideId'] as String?,
    );

Map<String, dynamic> _$SupportTicketModelToJson(
  _SupportTicketModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'uid': instance.uid,
  'role': instance.role,
  'category': instance.category,
  'subject': instance.subject,
  'status': instance.status,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
  'lastMessageAt': const TimestampConverter().toJson(instance.lastMessageAt),
  'lastMessageBy': instance.lastMessageBy,
  'userUnread': instance.userUnread,
  'rideId': instance.rideId,
};

_SupportMessageModel _$SupportMessageModelFromJson(Map<String, dynamic> json) =>
    _SupportMessageModel(
      id: json['id'] as String,
      from: json['from'] as String,
      text: json['text'] as String,
      createdAt: _$JsonConverterFromJson<Timestamp, DateTime>(
        json['createdAt'],
        const TimestampConverter().fromJson,
      ),
    );

Map<String, dynamic> _$SupportMessageModelToJson(
  _SupportMessageModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'from': instance.from,
  'text': instance.text,
  'createdAt': _$JsonConverterToJson<Timestamp, DateTime>(
    instance.createdAt,
    const TimestampConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
